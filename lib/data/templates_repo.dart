import 'package:sqlite3/sqlite3.dart';

import 'models.dart';

/// A saved transaction the user can re-add with one tap. Quick picks built
/// from frequent merchants have no [id].
class TxnTemplate {
  const TxnTemplate({this.id, required this.name, required this.type, required this.amount, required this.categoryId, this.sourceId, this.merchant = '', this.note = '', this.tags = const []});

  factory TxnTemplate.fromRow(Row r, {String? name}) {
    final tags = r['tags'] as String;
    return TxnTemplate(
      id: name == null ? r['id'] as int : null,
      name: name ?? r['name'] as String,
      type: enumByName(TxnType.values, r['type']),
      amount: r['amount'] as int,
      categoryId: r['category_id'] as int,
      sourceId: r['source_id'] as int?,
      merchant: r['merchant'] as String,
      note: r['note'] as String,
      tags: tags.isEmpty ? const [] : tags.split(' '),
    );
  }

  final int? id;
  final String name;
  final TxnType type;
  final int amount;
  final int categoryId;
  final int? sourceId;
  final String merchant;
  final String note;
  final List<String> tags;
}

class TemplatesRepo {
  TemplatesRepo(this.db);

  final Database db;

  int add(TxnTemplate t) {
    db.execute('INSERT INTO templates(name, type, amount, category_id, source_id, merchant, note, tags) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', [
      t.name.trim(),
      t.type.name,
      t.amount,
      t.categoryId,
      t.sourceId,
      t.merchant.trim(),
      t.note.trim(),
      t.tags.join(' '),
    ]);
    return db.lastInsertRowId;
  }

  List<TxnTemplate> list() => db.select('SELECT * FROM templates ORDER BY name COLLATE NOCASE, id').map(TxnTemplate.fromRow).toList();

  void delete(int id) => db.execute('DELETE FROM templates WHERE id = ?', [id]);

  /// Merchants used at least twice in the last [days], most used first, as
  /// their latest transaction. Merchants already saved as templates are skipped.
  List<TxnTemplate> frequent(DateTime now, {int days = 90, int limit = 6}) {
    final since = DateTime(now.year, now.month, now.day - days).millisecondsSinceEpoch;
    final r = db.select(
      '''
SELECT t.*, f.n FROM transactions t JOIN (
  SELECT lower(merchant) AS m, count(*) AS n, max(id) AS last FROM transactions
  WHERE deleted = 0 AND merchant != '' AND occurred_at >= ?
    AND lower(merchant) NOT IN (SELECT lower(merchant) FROM templates WHERE merchant != '')
  GROUP BY lower(merchant) HAVING n >= 2
) f ON t.id = f.last
ORDER BY f.n DESC, t.id DESC LIMIT ?''',
      [since, limit],
    );
    return r.map((row) => TxnTemplate.fromRow(row, name: row['merchant'] as String)).toList();
  }
}
