import 'package:sqlite3/sqlite3.dart';

import '../core/dates.dart';
import 'models.dart';

/// Categories and payment sources.
class CatalogRepo {
  CatalogRepo(this.db);

  final Database db;

  List<Category> categories({CategoryKind? kind, bool includeArchived = false}) {
    final where = <String>[if (!includeArchived) 'archived = 0', if (kind != null) 'kind = ?'];
    final sql = 'SELECT * FROM categories${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'} ORDER BY sort_order, id';
    return db.select(sql, [if (kind != null) kind.name]).map(Category.fromRow).toList();
  }

  Category category(int id) => Category.fromRow(db.select('SELECT * FROM categories WHERE id = ?', [id]).first);

  /// The fallback category ("Others") used when the user picks nothing.
  Category defaultCategory() => Category.fromRow(db.select('SELECT * FROM categories WHERE is_default = 1 LIMIT 1').first);

  /// First category of a kind, used as default for invest/income.
  Category firstOf(CategoryKind kind) => kind == CategoryKind.spend ? defaultCategory() : categories(kind: kind).first;

  Category? findCategoryByName(String name) {
    final r = db.select('SELECT * FROM categories WHERE lower(name) = lower(?) LIMIT 1', [name.trim()]);
    return r.isEmpty ? null : Category.fromRow(r.first);
  }

  int addCategory({required String name, required CategoryKind kind, required String icon, required int color}) {
    final next = db.select('SELECT coalesce(max(sort_order), 0) + 1 AS n FROM categories').first['n'] as int;
    db.execute('INSERT INTO categories(name, kind, icon, color, sort_order) VALUES (?, ?, ?, ?, ?)', [name.trim(), kind.name, icon, color, next]);
    return db.lastInsertRowId;
  }

  void renameCategory(int id, String name) => db.execute('UPDATE categories SET name = ? WHERE id = ?', [name.trim(), id]);

  /// Archives a category. The default category cannot be archived.
  bool archiveCategory(int id) {
    final c = category(id);
    if (c.isDefault) return false;
    db.execute('UPDATE categories SET archived = 1 WHERE id = ?', [id]);
    return true;
  }

  /// Persists a new order for the given ids.
  void reorderCategories(List<int> ids) {
    db.execute('BEGIN');
    for (var i = 0; i < ids.length; i++) {
      db.execute('UPDATE categories SET sort_order = ? WHERE id = ?', [i, ids[i]]);
    }
    db.execute('COMMIT');
  }

  List<PaymentSource> sources({bool includeArchived = false}) =>
      db.select('SELECT * FROM sources${includeArchived ? '' : ' WHERE archived = 0'} ORDER BY is_default DESC, id').map(PaymentSource.fromRow).toList();

  PaymentSource? defaultSource() {
    final r = db.select('SELECT * FROM sources WHERE is_default = 1 AND archived = 0 LIMIT 1');
    return r.isEmpty ? null : PaymentSource.fromRow(r.first);
  }

  int addSource({required String name, required SourceKind kind, String? last4, int? creditLimit, bool makeDefault = false}) {
    db.execute('INSERT INTO sources(name, kind, last4, credit_limit) VALUES (?, ?, ?, ?)', [name.trim(), kind.name, last4, creditLimit]);
    final id = db.lastInsertRowId;
    if (makeDefault) setDefaultSource(id);
    return id;
  }

  void setDefaultSource(int id) {
    db.execute('BEGIN');
    db.execute('UPDATE sources SET is_default = 0');
    db.execute('UPDATE sources SET is_default = 1 WHERE id = ?', [id]);
    db.execute('COMMIT');
  }

  /// Archives a source; if it was the default, the next source becomes default.
  void archiveSource(int id) {
    db.execute('UPDATE sources SET archived = 1, is_default = 0 WHERE id = ?', [id]);
    if (defaultSource() == null) {
      final rest = sources();
      if (rest.isNotEmpty) setDefaultSource(rest.first.id);
    }
  }

  /// Money that left through each source in [p] (spend + invest + debt payments).
  Map<int, int> spentBySource(Period p) {
    final r = db.select(
      '''
SELECT source_id, sum(amount) AS total FROM transactions
WHERE deleted = 0 AND inflow = 0 AND source_id IS NOT NULL AND occurred_at >= ? AND occurred_at < ?
GROUP BY source_id''',
      [p.start.millisecondsSinceEpoch, p.end.millisecondsSinceEpoch],
    );
    return {for (final row in r) row['source_id'] as int: row['total'] as int};
  }
}
