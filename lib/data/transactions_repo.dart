import 'package:sqlite3/sqlite3.dart';

import '../core/dates.dart';
import '../core/money.dart';
import 'models.dart';

/// Filters for listing transactions. All fields are optional and combined with AND.
class TxnFilter {
  const TxnFilter({
    this.from,
    this.to,
    this.types = const {},
    this.categoryIds = const {},
    this.sourceIds = const {},
    this.minAmount,
    this.maxAmount,
    this.search = '',
    this.investmentId,
    this.debtId,
  });

  final DateTime? from;
  final DateTime? to;
  final Set<TxnType> types;
  final Set<int> categoryIds;
  final Set<int> sourceIds;
  final int? minAmount;
  final int? maxAmount;
  final String search;
  final int? investmentId;
  final int? debtId;

  /// Number of user-chosen filters, shown as a badge.
  int get activeCount => (types.isEmpty ? 0 : 1) + (categoryIds.isEmpty ? 0 : 1) + (sourceIds.isEmpty ? 0 : 1) + (minAmount == null && maxAmount == null ? 0 : 1);

  TxnFilter copyWith({DateTime? from, DateTime? to, Set<TxnType>? types, Set<int>? categoryIds, Set<int>? sourceIds, int? Function()? minAmount, int? Function()? maxAmount, String? search}) =>
      TxnFilter(
        from: from ?? this.from,
        to: to ?? this.to,
        types: types ?? this.types,
        categoryIds: categoryIds ?? this.categoryIds,
        sourceIds: sourceIds ?? this.sourceIds,
        minAmount: minAmount == null ? this.minAmount : minAmount(),
        maxAmount: maxAmount == null ? this.maxAmount : maxAmount(),
        search: search ?? this.search,
      );
}

/// Builds an FTS5 prefix query from free text: `team din` -> `"team"* "din"*`.
/// Returns null if there is nothing searchable.
String? ftsQuery(String input) {
  final words = input.toLowerCase().split(RegExp(r'[^\p{L}\p{N}]+', unicode: true)).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return null;
  return words.map((w) => '"$w"*').join(' ');
}

class TransactionsRepo {
  TransactionsRepo(this.db);

  final Database db;

  static const _select = '''
SELECT t.*, c.name AS c_name, c.kind AS c_kind, c.icon AS c_icon, c.color AS c_color,
       s.name AS s_name, s.kind AS s_kind, s.last4 AS s_last4
FROM transactions t
JOIN categories c ON c.id = t.category_id
LEFT JOIN sources s ON s.id = t.source_id
''';

  bool _inflowFor(Txn t) {
    if (t.type == TxnType.income) return true;
    if (t.type == TxnType.debt && t.debtId != null) {
      return db.select('SELECT direction FROM debts WHERE id = ?', [t.debtId]).first['direction'] == DebtDirection.owedToMe.name;
    }
    return false;
  }

  List<Object?> _values(Txn t) => [
    t.type.name,
    t.amount,
    _inflowFor(t) ? 1 : 0,
    t.categoryId,
    t.sourceId,
    t.occurredAt.millisecondsSinceEpoch,
    t.merchant.trim(),
    t.note.trim(),
    t.tags.join(' '),
    (t.place?.trim().isEmpty ?? true) ? null : t.place!.trim(),
    t.lat,
    t.lng,
    t.investmentId,
    t.debtId,
  ];

  int insert(Txn t, {DateTime? now}) {
    db.execute(
      '''
INSERT INTO transactions(type, amount, inflow, category_id, source_id, occurred_at, merchant, note, tags, place, lat, lng, investment_id, debt_id, created_at)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [..._values(t), (now ?? DateTime.now()).millisecondsSinceEpoch],
    );
    return db.lastInsertRowId;
  }

  /// Inserts many rows in one transaction (used by import).
  int insertAll(Iterable<Txn> txns) {
    var n = 0;
    db.execute('BEGIN');
    for (final t in txns) {
      insert(t);
      n++;
    }
    db.execute('COMMIT');
    return n;
  }

  void update(Txn t) {
    db.execute(
      '''
UPDATE transactions SET type = ?, amount = ?, inflow = ?, category_id = ?, source_id = ?, occurred_at = ?, merchant = ?, note = ?, tags = ?, place = ?, lat = ?, lng = ?, investment_id = ?, debt_id = ?
WHERE id = ?''',
      [..._values(t), t.id],
    );
  }

  /// Soft delete so the UI can offer undo.
  void delete(int id) => db.execute('UPDATE transactions SET deleted = 1 WHERE id = ?', [id]);

  void restore(int id) => db.execute('UPDATE transactions SET deleted = 0 WHERE id = ?', [id]);

  /// Permanently removes soft-deleted rows.
  void purgeDeleted() => db.execute('DELETE FROM transactions WHERE deleted = 1');

  TxnView? byId(int id) {
    final r = db.select('$_select WHERE t.id = ? AND t.deleted = 0', [id]);
    return r.isEmpty ? null : TxnView.fromRow(r.first);
  }

  (String, List<Object?>) _where(TxnFilter f) {
    final clauses = <String>['t.deleted = 0'];
    final args = <Object?>[];
    if (f.from != null) {
      clauses.add('t.occurred_at >= ?');
      args.add(f.from!.millisecondsSinceEpoch);
    }
    if (f.to != null) {
      clauses.add('t.occurred_at < ?');
      args.add(f.to!.millisecondsSinceEpoch);
    }
    void inList(String col, Iterable<Object> values) {
      clauses.add('$col IN (${List.filled(values.length, '?').join(',')})');
      args.addAll(values);
    }

    if (f.types.isNotEmpty) inList('t.type', f.types.map((e) => e.name));
    if (f.categoryIds.isNotEmpty) inList('t.category_id', f.categoryIds);
    if (f.sourceIds.isNotEmpty) inList('t.source_id', f.sourceIds);
    if (f.investmentId != null) {
      clauses.add('t.investment_id = ?');
      args.add(f.investmentId);
    }
    if (f.debtId != null) {
      clauses.add('t.debt_id = ?');
      args.add(f.debtId);
    }
    if (f.minAmount != null) {
      clauses.add('t.amount >= ?');
      args.add(f.minAmount);
    }
    if (f.maxAmount != null) {
      clauses.add('t.amount <= ?');
      args.add(f.maxAmount);
    }
    final q = ftsQuery(f.search);
    if (q != null) {
      final amount = parseInr(f.search);
      if (amount != null && amount > 0) {
        clauses.add('(t.id IN (SELECT rowid FROM txn_fts WHERE txn_fts MATCH ?) OR t.amount = ?)');
        args.addAll([q, amount]);
      } else {
        clauses.add('t.id IN (SELECT rowid FROM txn_fts WHERE txn_fts MATCH ?)');
        args.add(q);
      }
    }
    return (clauses.join(' AND '), args);
  }

  List<TxnView> list(TxnFilter f, {int limit = 200, int offset = 0}) {
    final (where, args) = _where(f);
    return db.select('$_select WHERE $where ORDER BY t.occurred_at DESC, t.id DESC LIMIT ? OFFSET ?', [...args, limit, offset]).map(TxnView.fromRow).toList();
  }

  Totals totals(TxnFilter f) {
    final (where, args) = _where(f);
    final r = db.select('''
SELECT
  coalesce(sum(CASE WHEN t.type = 'spend' THEN t.amount END), 0) AS spend,
  coalesce(sum(CASE WHEN t.type = 'invest' THEN t.amount END), 0) AS invest,
  coalesce(sum(CASE WHEN t.type = 'income' THEN t.amount END), 0) AS income,
  coalesce(sum(CASE WHEN t.type = 'debt' AND t.inflow = 0 THEN t.amount END), 0) AS debt_out,
  coalesce(sum(CASE WHEN t.type = 'debt' AND t.inflow = 1 THEN t.amount END), 0) AS debt_in,
  count(*) AS n
FROM transactions t WHERE $where''', args).first;
    return Totals(spend: r['spend'] as int, invest: r['invest'] as int, income: r['income'] as int, debtOut: r['debt_out'] as int, debtIn: r['debt_in'] as int, count: r['n'] as int);
  }

  Totals totalsIn(Period p) => totals(TxnFilter(from: p.start, to: p.end));

  /// Totals per category for one transaction type, largest first.
  List<CategoryTotal> byCategory(Period p, TxnType type) {
    final r = db.select(
      '''
SELECT c.*, sum(t.amount) AS total, count(*) AS n
FROM transactions t JOIN categories c ON c.id = t.category_id
WHERE t.deleted = 0 AND t.type = ? AND t.occurred_at >= ? AND t.occurred_at < ?
GROUP BY c.id ORDER BY total DESC''',
      [type.name, p.start.millisecondsSinceEpoch, p.end.millisecondsSinceEpoch],
    );
    return r.map((row) => CategoryTotal(category: Category.fromRow(row), total: row['total'] as int, count: row['n'] as int)).toList();
  }

  /// Spend/invest per sub-period: weeks of a month, months of a year, days of a week.
  List<Bucket> buckets(Period p) {
    final ranges = <Period>[];
    switch (p.kind) {
      case PeriodKind.year:
        for (var m = 1; m <= 12; m++) {
          ranges.add(Period.of(PeriodKind.month, DateTime(p.start.year, m)));
        }
      case PeriodKind.month:
        var w = Period.of(PeriodKind.week, p.start);
        while (w.start.isBefore(p.end)) {
          ranges.add(w);
          w = w.next;
        }
      case PeriodKind.week:
        for (var d = 0; d < 7; d++) {
          final s = DateTime(p.start.year, p.start.month, p.start.day + d);
          ranges.add(Period(PeriodKind.week, s, DateTime(s.year, s.month, s.day + 1)));
        }
    }
    final stmt = db.prepare('''
SELECT coalesce(sum(CASE WHEN type = 'spend' THEN amount END), 0) AS spend,
       coalesce(sum(CASE WHEN type = 'invest' THEN amount END), 0) AS invest
FROM transactions WHERE deleted = 0 AND occurred_at >= ? AND occurred_at < ?''');
    final out = <Bucket>[];
    for (final r in ranges) {
      final row = stmt.select([r.start.millisecondsSinceEpoch, r.end.millisecondsSinceEpoch]).first;
      out.add(Bucket(start: r.start, spend: row['spend'] as int, invest: row['invest'] as int));
    }
    stmt.close();
    return out;
  }

  /// Sum spent (type spend) in [p], optionally limited to categories.
  int spentIn(Period p, {List<int> categoryIds = const [], TxnType type = TxnType.spend}) {
    final f = TxnFilter(from: p.start, to: p.end, types: {type}, categoryIds: categoryIds.toSet());
    final t = totals(f);
    return type == TxnType.spend ? t.spend : t.invest;
  }

  /// True when a transaction with the same day, amount and merchant exists.
  bool isDuplicate(Txn t) {
    final day = dayStart(t.occurredAt);
    final r = db.select('SELECT 1 FROM transactions WHERE deleted = 0 AND amount = ? AND lower(merchant) = lower(?) AND occurred_at >= ? AND occurred_at < ? LIMIT 1', [
      t.amount,
      t.merchant.trim(),
      day.millisecondsSinceEpoch,
      DateTime(day.year, day.month, day.day + 1).millisecondsSinceEpoch,
    ]);
    return r.isNotEmpty;
  }

  /// Distinct tags used so far, most frequent first (for autocomplete).
  List<String> tags() {
    final counts = <String, int>{};
    for (final r in db.select("SELECT tags FROM transactions WHERE deleted = 0 AND tags != ''")) {
      for (final tag in (r['tags'] as String).split(' ')) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final list = counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!) != 0 ? counts[b]!.compareTo(counts[a]!) : a.compareTo(b));
    return list;
  }
}
