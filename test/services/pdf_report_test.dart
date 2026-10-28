import 'dart:convert';

import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/services/pdf_report.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('pdfMoney avoids the rupee glyph', () => expect(pdfMoney(-48600), '−Rs 486'));

  test('buildPdfReport produces a PDF document', () async {
    final s = makeState();
    seed(s);
    final p = month(kNow);
    final bytes = await buildPdfReport(
      period: p,
      totals: s.txns.totalsIn(p),
      spendByCategory: s.txns.byCategory(p, TxnType.spend),
      transactions: s.txns.list(TxnFilter(from: p.start, to: p.end)),
    );
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(1000));
  });
}
