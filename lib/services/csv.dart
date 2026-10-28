import '../core/dates.dart';
import '../core/money.dart';
import '../data/catalog_repo.dart';
import '../data/models.dart';
import '../data/transactions_repo.dart';

const exportHeader = ['date', 'type', 'amount', 'category', 'source', 'merchant', 'note', 'tags', 'place'];

String _escape(String v) => v.contains(RegExp(r'[",\n\r]')) ? '"${v.replaceAll('"', '""')}"' : v;

/// Encodes a table as CSV with a UTF-8 BOM so Excel detects the encoding.
String encodeTable(List<String> header, Iterable<List<String>> rows) {
  final b = StringBuffer('\uFEFF')..writeln(header.join(','));
  for (final r in rows) {
    b.writeln(r.map(_escape).join(','));
  }
  return b.toString();
}

/// Encodes transactions as CSV.
String encodeCsv(List<TxnView> rows) => encodeTable(exportHeader, [
  for (final r in rows)
    [
      isoDateTime(r.txn.occurredAt),
      r.txn.type.name,
      (r.txn.amount / paisePerRupee).toStringAsFixed(2),
      r.category.name,
      r.source?.name ?? '',
      r.txn.merchant,
      r.txn.note,
      r.txn.tags.join(' '),
      r.txn.place ?? '',
    ],
]);

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
  const ImportRow({required this.line, this.txn, this.duplicate = false, this.needsReview = false, this.error});

  final int line;
  final Txn? txn;
  final bool duplicate;

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
    final catName = cell(r, map.category);
    var category = catName.isEmpty ? null : catalog.findCategoryByName(catName);
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
    out.add(ImportRow(line: line, txn: txn, duplicate: txns.isDuplicate(txn), needsReview: needsReview));
  }
  return out;
}
