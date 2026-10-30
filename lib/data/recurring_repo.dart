import 'dart:math' as math;

import 'package:sqlite3/sqlite3.dart';

import '../l10n/l10n.dart';
import 'models.dart';
import 'transactions_repo.dart';

enum Frequency { daily, weekly, monthly, yearly }

String frequencyLabel(Frequency f) => switch (f) {
  Frequency.daily => currentL10n.daily,
  Frequency.weekly => currentL10n.weekly,
  Frequency.monthly => currentL10n.monthly,
  Frequency.yearly => currentL10n.yearly,
};

int _daysIn(int year, int month) => DateTime(year, month + 1, 0).day;

/// The [n]th occurrence (0 = [start]) of a schedule. Months and years are
/// counted from [start] so a rule on the 31st lands on 28/29 Feb and goes
/// back to the 31st in March.
DateTime occurrence(DateTime start, Frequency f, int n) {
  switch (f) {
    case Frequency.daily:
      return DateTime(start.year, start.month, start.day + n, start.hour, start.minute);
    case Frequency.weekly:
      return DateTime(start.year, start.month, start.day + 7 * n, start.hour, start.minute);
    case Frequency.monthly:
      final first = DateTime(start.year, start.month + n);
      return DateTime(first.year, first.month, math.min(start.day, _daysIn(first.year, first.month)), start.hour, start.minute);
    case Frequency.yearly:
      final y = start.year + n;
      return DateTime(y, start.month, math.min(start.day, _daysIn(y, start.month)), start.hour, start.minute);
  }
}

/// A schedule that creates (or, when [autoCreate] is false, only reminds
/// about) a transaction built from [template].
class RecurringRule {
  const RecurringRule({this.id, required this.template, required this.frequency, required this.startAt, this.endAt, this.count = 0, this.paused = false, this.autoCreate = true});

  factory RecurringRule.fromRow(Row r) {
    final tags = r['tags'] as String;
    final start = DateTime.fromMillisecondsSinceEpoch(r['start_at'] as int);
    return RecurringRule(
      id: r['id'] as int,
      template: Txn(
        type: enumByName(TxnType.values, r['type']),
        amount: r['amount'] as int,
        categoryId: r['category_id'] as int,
        sourceId: r['source_id'] as int?,
        occurredAt: start,
        merchant: r['merchant'] as String,
        note: r['note'] as String,
        tags: tags.isEmpty ? const [] : tags.split(' '),
        place: r['place'] as String?,
        lat: r['lat'] as double?,
        lng: r['lng'] as double?,
        investmentId: r['investment_id'] as int?,
        debtId: r['debt_id'] as int?,
      ),
      frequency: enumByName(Frequency.values, r['frequency']),
      startAt: start,
      endAt: r['end_at'] == null ? null : DateTime.fromMillisecondsSinceEpoch(r['end_at'] as int),
      count: r['count'] as int,
      paused: r['paused'] == 1,
      autoCreate: r['auto_create'] == 1,
    );
  }

  final int? id;
  final Txn template;
  final Frequency frequency;
  final DateTime startAt;
  final DateTime? endAt;

  /// Occurrences already materialised (or passed, for reminders).
  final int count;
  final bool paused;

  /// False for reminder-only rules (e.g. a SIP the user pays by hand).
  final bool autoCreate;

  DateTime get nextRun => occurrence(startAt, frequency, count);

  /// True once the next occurrence is past the end date.
  bool get ended => endAt != null && nextRun.isAfter(endAt!);

  RecurringRule copyWith({Txn? template, Frequency? frequency, DateTime? startAt, DateTime? Function()? endAt, int? count, bool? paused, bool? autoCreate}) => RecurringRule(
    id: id,
    template: template ?? this.template,
    frequency: frequency ?? this.frequency,
    startAt: startAt ?? this.startAt,
    endAt: endAt == null ? this.endAt : endAt(),
    count: count ?? this.count,
    paused: paused ?? this.paused,
    autoCreate: autoCreate ?? this.autoCreate,
  );
}

/// A rule's next occurrence, for "Coming up" lists and reminders.
class Upcoming {
  const Upcoming(this.rule, this.at);

  final RecurringRule rule;
  final DateTime at;
}

class RecurringRepo {
  RecurringRepo(this.db) : _txns = TransactionsRepo(db);

  final Database db;
  final TransactionsRepo _txns;

  List<Object?> _values(RecurringRule r) {
    final t = r.template;
    return [
      t.type.name,
      t.amount,
      t.categoryId,
      t.sourceId,
      t.merchant.trim(),
      t.note.trim(),
      t.tags.join(' '),
      (t.place?.trim().isEmpty ?? true) ? null : t.place!.trim(),
      t.lat,
      t.lng,
      t.investmentId,
      t.debtId,
      r.frequency.name,
      r.startAt.millisecondsSinceEpoch,
      r.endAt?.millisecondsSinceEpoch,
      r.count,
      r.nextRun.millisecondsSinceEpoch,
      r.paused ? 1 : 0,
      r.autoCreate ? 1 : 0,
    ];
  }

  int add(RecurringRule r) {
    db.execute('''
INSERT INTO recurring_rules(type, amount, category_id, source_id, merchant, note, tags, place, lat, lng, investment_id, debt_id, frequency, start_at, end_at, count, next_run, paused, auto_create)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''', _values(r));
    return db.lastInsertRowId;
  }

  void save(RecurringRule r) {
    db.execute(
      '''
UPDATE recurring_rules SET type = ?, amount = ?, category_id = ?, source_id = ?, merchant = ?, note = ?, tags = ?, place = ?, lat = ?, lng = ?, investment_id = ?, debt_id = ?,
  frequency = ?, start_at = ?, end_at = ?, count = ?, next_run = ?, paused = ?, auto_create = ?
WHERE id = ?''',
      [..._values(r), r.id],
    );
  }

  /// Saves [first] as occurrence 0 of a new rule and links it. Returns the
  /// transaction id.
  int createFrom(Txn first, Frequency frequency, {DateTime? endAt, required DateTime now}) {
    db.execute('BEGIN');
    final ruleId = add(RecurringRule(template: first, frequency: frequency, startAt: first.occurredAt, endAt: endAt, count: 1));
    final id = _txns.insert(first.copyWith(recurringId: () => ruleId), now: now);
    db.execute('COMMIT');
    return id;
  }

  List<RecurringRule> rules() => db.select('SELECT * FROM recurring_rules ORDER BY paused, next_run, id').map(RecurringRule.fromRow).toList();

  RecurringRule? byId(int id) {
    final r = db.select('SELECT * FROM recurring_rules WHERE id = ?', [id]);
    return r.isEmpty ? null : RecurringRule.fromRow(r.first);
  }

  /// The SIP (recurring invest rule) of an investment, if any.
  RecurringRule? forInvestment(int investmentId) {
    final r = db.select("SELECT * FROM recurring_rules WHERE investment_id = ? AND type = 'invest' ORDER BY id DESC LIMIT 1", [investmentId]);
    return r.isEmpty ? null : RecurringRule.fromRow(r.first);
  }

  /// Pausing stops new occurrences; resuming skips the ones missed meanwhile.
  void setPaused(int id, bool paused, {required DateTime now}) {
    var r = byId(id)!.copyWith(paused: paused);
    if (!paused) {
      while (!r.nextRun.isAfter(now)) {
        r = r.copyWith(count: r.count + 1);
      }
    }
    save(r);
  }

  /// Deletes the rule; transactions it created stay, unlinked.
  void delete(int id) {
    db.execute('BEGIN');
    db.execute('UPDATE transactions SET recurring_id = NULL WHERE recurring_id = ?', [id]);
    db.execute('DELETE FROM recurring_rules WHERE id = ?', [id]);
    db.execute('COMMIT');
  }

  /// Creates every occurrence due by [now], catching up missed periods.
  /// Idempotent: each occurrence advances the rule's count in the same
  /// database transaction. Reminder-only rules just move past due dates.
  /// Returns the number of transactions created.
  int run(DateTime now) {
    var created = 0;
    db.execute('BEGIN');
    for (final rule in db.select('SELECT * FROM recurring_rules WHERE paused = 0 AND next_run <= ?', [now.millisecondsSinceEpoch]).map(RecurringRule.fromRow)) {
      var r = rule;
      while (!r.ended && !r.nextRun.isAfter(now)) {
        if (r.autoCreate) {
          _txns.insert(
            r.template.copyWith(occurredAt: r.nextRun, recurringId: () => r.id),
            now: now,
          );
          created++;
        }
        r = r.copyWith(count: r.count + 1);
      }
      save(r);
    }
    db.execute('COMMIT');
    return created;
  }

  /// Next occurrence of each active rule within [days] after [now].
  List<Upcoming> upcoming(DateTime now, {int days = 30}) {
    final until = DateTime(now.year, now.month, now.day + days + 1);
    return [
      for (final r in rules())
        if (!r.paused && !r.ended && !r.nextRun.isBefore(now) && r.nextRun.isBefore(until)) Upcoming(r, r.nextRun),
    ]..sort((a, b) => a.at.compareTo(b.at));
  }
}
