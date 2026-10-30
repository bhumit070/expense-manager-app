import 'package:sqlite3/sqlite3.dart';

import '../core/dates.dart';
import 'models.dart';

/// Categories and payment sources.
class CatalogRepo {
  CatalogRepo(this.db);

  final Database db;

  /// Categories in tree order: each parent followed by its sub-categories.
  List<Category> categories({CategoryKind? kind, bool includeArchived = false}) {
    final where = <String>[if (!includeArchived) 'archived = 0', if (kind != null) 'kind = ?'];
    final sql = 'SELECT * FROM categories${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'} ORDER BY sort_order, id';
    final flat = db.select(sql, [if (kind != null) kind.name]).map(Category.fromRow).toList();
    final ids = {for (final c in flat) c.id};
    final kids = <int, List<Category>>{};
    for (final c in flat) {
      if (c.isChild && ids.contains(c.parentId)) (kids[c.parentId!] ??= []).add(c);
    }
    return [
      for (final c in flat)
        if (!c.isChild || !ids.contains(c.parentId)) ...[c, ...?kids[c.id]],
    ];
  }

  /// Top-level categories of [kind] that can take sub-categories.
  List<Category> parents(CategoryKind kind) => categories(kind: kind).where((c) => !c.isChild).toList();

  List<Category> children(int parentId) => db.select('SELECT * FROM categories WHERE parent_id = ? AND archived = 0 ORDER BY sort_order, id', [parentId]).map(Category.fromRow).toList();

  Category category(int id) => Category.fromRow(db.select('SELECT * FROM categories WHERE id = ?', [id]).first);

  /// The fallback category ("Others") used when the user picks nothing.
  Category defaultCategory() => Category.fromRow(db.select('SELECT * FROM categories WHERE is_default = 1 LIMIT 1').first);

  /// First category of a kind, used as default for invest/income.
  Category firstOf(CategoryKind kind) => kind == CategoryKind.spend ? defaultCategory() : categories(kind: kind).first;

  /// Finds a category by name, preferring top-level matches. With [parentId],
  /// only sub-categories of that parent match.
  Category? findCategoryByName(String name, {int? parentId}) {
    final scope = parentId == null ? '' : ' AND parent_id = ?';
    final r = db.select('SELECT * FROM categories WHERE lower(name) = lower(?)$scope ORDER BY parent_id IS NOT NULL, archived, id LIMIT 1', [name.trim(), ?parentId]);
    return r.isEmpty ? null : Category.fromRow(r.first);
  }

  int _nextOrder() => db.select('SELECT coalesce(max(sort_order), 0) + 1 AS n FROM categories').first['n'] as int;

  /// Adds a category. With [parentId] it becomes a sub-category and takes the
  /// parent's kind; the parent must be top-level.
  int addCategory({required String name, required CategoryKind kind, required String icon, required int color, int? parentId}) {
    if (parentId != null) {
      final parent = category(parentId);
      if (parent.isChild) throw ArgumentError.value(parentId, 'parentId', 'Sub-categories cannot have sub-categories');
      kind = parent.kind;
    }
    db.execute('INSERT INTO categories(name, kind, icon, color, sort_order, parent_id) VALUES (?, ?, ?, ?, ?, ?)', [name.trim(), kind.name, icon, color, _nextOrder(), parentId]);
    return db.lastInsertRowId;
  }

  /// Moves [id] under [parentId], or to the top level when null. Returns false
  /// when the move would break the one-level, same-kind rule or the default
  /// category would become a child.
  bool setParent(int id, int? parentId) {
    final c = category(id);
    if (parentId != null) {
      final parent = category(parentId);
      final hasKids = db.select('SELECT 1 FROM categories WHERE parent_id = ? AND archived = 0 LIMIT 1', [id]).isNotEmpty;
      if (c.isDefault || parent.id == id || parent.isChild || parent.kind != c.kind || hasKids) return false;
    }
    db.execute('UPDATE categories SET parent_id = ?, sort_order = ? WHERE id = ?', [parentId, _nextOrder(), id]);
    return true;
  }

  void renameCategory(int id, String name) => db.execute('UPDATE categories SET name = ? WHERE id = ?', [name.trim(), id]);

  /// Archives a category and its sub-categories. The default category cannot be archived.
  bool archiveCategory(int id) => archiveCategoryIds(id).isNotEmpty;

  /// Archives a category and its active sub-categories and returns their ids
  /// (for undo); empty for the default category.
  List<int> archiveCategoryIds(int id) {
    final c = category(id);
    if (c.isDefault) return const [];
    final ids = [
      for (final r in db.select('SELECT id FROM categories WHERE (id = ? OR parent_id = ?) AND archived = 0', [id, id])) r['id'] as int,
    ];
    db.execute('UPDATE categories SET archived = 1 WHERE id = ? OR parent_id = ?', [id, id]);
    return ids;
  }

  /// Archived categories, parents first, then by name.
  List<Category> archivedCategories() => db.select('SELECT * FROM categories WHERE archived = 1 ORDER BY kind, parent_id IS NOT NULL, lower(name)').map(Category.fromRow).toList();

  /// Brings archived categories back. A sub-category whose parent is
  /// archived brings the parent back too, so it is never hidden.
  void restoreCategories(Iterable<int> ids) {
    for (final id in ids) {
      final c = category(id);
      db.execute('UPDATE categories SET archived = 0 WHERE id = ? OR id = ?', [id, c.parentId ?? id]);
    }
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

  int addSource({required String name, required SourceKind kind, String? last4, int? creditLimit, int openingBalance = 0, bool makeDefault = false}) {
    db.execute('INSERT INTO sources(name, kind, last4, credit_limit, opening_balance) VALUES (?, ?, ?, ?, ?)', [name.trim(), kind.name, last4, creditLimit, openingBalance]);
    final id = db.lastInsertRowId;
    if (makeDefault) setDefaultSource(id);
    return id;
  }

  /// Brings an archived source back; it does not become the default.
  void restoreSource(int id) {
    db.execute('UPDATE sources SET archived = 0 WHERE id = ?', [id]);
    if (defaultSource() == null) setDefaultSource(id);
  }

  void setOpeningBalance(int id, int balance) => db.execute('UPDATE sources SET opening_balance = ? WHERE id = ?', [balance, id]);

  /// Current balance of every source: opening balance + money in − money out.
  Map<int, int> balances() {
    final r = db.select('''
SELECT s.id, s.opening_balance + coalesce(sum(CASE WHEN t.inflow = 1 THEN t.amount ELSE -t.amount END), 0) AS balance
FROM sources s LEFT JOIN transactions t ON t.source_id = s.id AND t.deleted = 0
GROUP BY s.id''');
    return {for (final row in r) row['id'] as int: row['balance'] as int};
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
