import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/dates.dart';
import '../core/money.dart';
import '../data/models.dart';

/// Built-in PDF fonts have no ₹ glyph, so reports use "Rs".
String pdfMoney(int paise) => formatInr(paise).replaceAll('₹', 'Rs ');

/// Builds a shareable PDF report for a period.
Future<Uint8List> buildPdfReport({required Period period, required Totals totals, required List<CategoryTotal> spendByCategory, required List<TxnView> transactions}) {
  final doc = pw.Document(title: 'Expense report ${period.label}');
  const brand = PdfColor.fromInt(0xFF4F46E5);
  pw.Widget stat(String label, int value) => pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0xFFF5F6FA), borderRadius: pw.BorderRadius.circular(6)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(pdfMoney(value), style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ),
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (_) => [
        pw.Text(
          'Expense report',
          style: const pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: brand),
        ),
        pw.Text('${period.label} · ${period.rangeLabel}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
        pw.SizedBox(height: 16),
        pw.Row(
          children: [
            stat('Spent', totals.spend),
            pw.SizedBox(width: 8),
            stat('Invested', totals.invest),
            pw.SizedBox(width: 8),
            stat('Income', totals.income),
            pw.SizedBox(width: 8),
            stat('Debt paid', totals.debtOut),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text('Spend by category', style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: ['Category', 'Transactions', 'Amount'],
          data: [
            for (final c in spendByCategory) [c.category.name, '${c.count}', pdfMoney(c.total)],
          ],
          cellAlignments: {1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight},
        ),
        pw.SizedBox(height: 20),
        pw.Text('Transactions (${transactions.length})', style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: ['Date', 'Type', 'Category', 'Details', 'Amount'],
          data: [
            for (final t in transactions) [isoDateTime(t.txn.occurredAt), t.txn.type.name, t.category.name, t.txn.titleOr(''), pdfMoney(t.signedAmount)],
          ],
          cellStyle: const pw.TextStyle(fontSize: 8),
          headerStyle: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          cellAlignments: {4: pw.Alignment.centerRight},
        ),
      ],
    ),
  );
  return doc.save();
}
