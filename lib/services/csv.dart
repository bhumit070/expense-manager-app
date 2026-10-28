import '../core/dates.dart';
import '../core/money.dart';
import '../data/catalog_repo.dart';
import '../data/models.dart';
import '../data/transactions_repo.dart';

const exportHeader = ['date', 'type', 'amount', 'category', 'source', 'merchant', 'note', 'tags', 'place'];

String _escape(String v) => v.contains(RegExp(r'[",\n\r]')) ? '"${v.replaceAll('"', '""')}"' : v;

/// Encodes transactions as CSV with a UTF-8 BOM so Excel detects the encoding.
String encodeCsv(List<TxnView> rows) {
  final b = StringBuffer('﻿')..writeln(exportHeader.join(','));
  for (final r in rows) {
    final t = r.txn;
    b.writeln(
      [
        isoDateTime(t.occurredAt),
        t.type.name,
        (t.amount / paisePerRupee).toStringAsFixed(2),
        r.categoryPath,
        r.source?.name ?? '',
        t.merchant,
        t.note,
        t.tags.join(' '),
        t.place ?? '',
      ].map(_escape).join(','),
    );
  }
  return b.toString();
}

/// RFC 4180 CSV parser supporting quoted fields, escaped quotes and CRLF.
List<List<String>> parseCsv(String input) {
  final text = input.startsWith('﻿') ? input.substring(1) : input;
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == ',') {
      row.add(field.toString());
      field.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(field.toString());
      field.clear();
      if (row.any((f) => f.isNotEmpty)) rows.add(row);
      row = <String>[];
    } else {
      field.write(c);
    }
  }
  row.add(field.toString());
  if (row.any((f) => f.isNotEmpty)) rows.add(row);
  return rows;
}

/// Which CSV column holds which field. -1 means "not present".
class CsvMapping {
  const CsvMapping({required this.date, this.amount = -1, this.debit = -1, this.credit = -1, this.type = -1, this.category = -1, this.merchant = -1, this.note = -1, this.tags = -1, this.place = -1});

  final int date, amount, debit, credit, type, category, merchant, note, tags, place;

  bool get isValid => date >= 0 && (amount >= 0 || debit >= 0 || credit >= 0);

  /// Guesses columns from common header names (our own export, bank statements).
  static CsvMapping detect(List<String> header) {
    final h = header.map((e) => e.trim().toLowerCase()).toList();
    int find(List<String> names) => h.indexWhere((col) => names.any((n) => col == n || col.contains(n)));
    return CsvMapping(
      date: find(['date', 'txn date', 'value date']),
      amount: find(['amount']),
      debit: find(['debit', 'withdrawal']),
      credit: find(['credit', 'deposit']),
      type: find(['type']),
      category: find(['category']),
      merchant: find(['merchant', 'description', 'narration', 'payee']),
      note: find(['note', 'remarks']),
      tags: find(['tags']),
      place: find(['place', 'location']),
    );
  }
}

class ImportRow {
  const ImportRow({required this.line, this.txn, this.duplicate = false, this.needsReview = false, this.error, this.newSubcategory});

  final int line;
  final Txn? txn;
  final bool duplicate;

  /// Sub-category to create under the txn's category when imported
  /// (from a "Parent / Child" cell whose child doesn't exist yet).
  final String? newSubcategory;

  /// Category could not be matched; the default was used.
  final bool needsReview;
  final String? error;

  /// Selected for import by default when valid and not a duplicate.
  bool get importable => txn != null && !duplicate;
}

/// Turns parsed CSV rows into import candidates.
List<ImportRow> buildImport(List<List<String>> rows, CatalogRepo catalog, TransactionsRepo txns, {int? sourceId}) {
  if (rows.isEmpty) return const [];
  final map = CsvMapping.detect(rows.first);
  if (!map.isValid) return const [ImportRow(line: 1, error: 'Need a date column and an amount (or debit/credit) column')];
  String cell(List<String> r, int i) => i >= 0 && i < r.length ? r[i].trim() : '';
  final out = <ImportRow>[];
  for (var i = 1; i < rows.length; i++) {
    final r = rows[i];
    final line = i + 1;
    final date = parseFlexibleDate(cell(r, map.date));
    if (date == null) {
      out.add(ImportRow(line: line, error: 'Invalid date "${cell(r, map.date)}"'));
      continue;
    }
    int? amount;
    TxnType? type = TxnType.values.where((t) => t.name == cell(r, map.type).toLowerCase()).firstOrNull;
    if (map.amount >= 0) {
      amount = parseInr(cell(r, map.amount));
    } else {
      final credit = parseInr(cell(r, map.credit));
      final debit = parseInr(cell(r, map.debit));
      if (credit != null && credit != 0) {
        amount = credit;
        type ??= TxnType.income;
      } else {
        amount = debit;
      }
    }
    if (amount == null || amount == 0) {
      out.add(ImportRow(line: line, error: 'Invalid amount'));
      continue;
    }
    if (amount < 0) {
      amount = -amount;
    }
    type ??= TxnType.spend;
    final (category: matched, newChild: newSubcategory) = _matchCategory(cell(r, map.category), catalog);
    var category = matched;
    final needsReview = category == null && type == TxnType.spend;
    category ??= catalog.firstOf(
      type == TxnType.invest
          ? CategoryKind.invest
          : type == TxnType.income
          ? CategoryKind.income
          : CategoryKind.spend,
    );
    final tags = cell(r, map.tags);
    final txn = Txn(
      type: type,
      amount: amount,
      categoryId: category.id,
      sourceId: sourceId,
      occurredAt: date,
      merchant: cell(r, map.merchant),
      note: cell(r, map.note),
      tags: tags.isEmpty ? const [] : tags.split(RegExp(r'\s+')),
      place: cell(r, map.place),
    );
    out.add(ImportRow(line: line, txn: txn, duplicate: txns.isDuplicate(txn), needsReview: needsReview, newSubcategory: newSubcategory));
  }
  return out;
}

/// Matches "Name" or "Parent / Child". A missing child of a known parent is
/// reported as [newChild] so it can be created on import.
({Category? category, String? newChild}) _matchCategory(String value, CatalogRepo catalog) {
  if (value.isEmpty) return (category: null, newChild: null);
  final parts = value.split('/').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  if (parts.length < 2) return (category: catalog.findCategoryByName(value), newChild: null);
  final parent = catalog.findCategoryByName(parts.first);
  if (parent == null) return (category: catalog.findCategoryByName(value), newChild: null);
  final childName = parts.sublist(1).join(' / ');
  final child = catalog.findCategoryByName(childName, parentId: parent.id);
  if (child != null) return (category: child, newChild: null);
  return (category: parent, newChild: parent.isChild ? null : childName);
}

/// Transactions to insert for the chosen rows, creating any new
/// sub-categories once (rows sharing a new "Parent / Child" share it).
List<Txn> resolveImport(Iterable<ImportRow> rows, CatalogRepo catalog) {
  final created = <String, int>{};
  return [
    for (final r in rows)
      if (r.newSubcategory == null)
        r.txn!
      else
        r.txn!.copyWith(
          categoryId: created.putIfAbsent('${r.txn!.categoryId}/${r.newSubcategory!.toLowerCase()}', () {
            final parent = catalog.category(r.txn!.categoryId);
            return catalog.addCategory(name: r.newSubcategory!, kind: parent.kind, icon: parent.icon, color: parent.color, parentId: parent.id);
          }),
        ),
  ];
}
