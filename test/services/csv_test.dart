import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/services/csv.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('parseCsv', () {
    test('quotes, escaped quotes, commas, newlines and CRLF', () {
      final rows = parseCsv('﻿a,b,c\r\n"x, y","he said ""hi""","multi\nline"\n\n1,2,3');
      expect(rows, [
        ['a', 'b', 'c'],
        ['x, y', 'he said "hi"', 'multi\nline'],
        ['1', '2', '3'],
      ]);
    });
    test('trailing row without newline and blank input', () {
      expect(parseCsv('a,b\n1,2'), [
        ['a', 'b'],
        ['1', '2'],
      ]);
      expect(parseCsv(''), isEmpty);
      expect(parseCsv('\r\n'), isEmpty);
    });
  });

  test('encodeCsv round-trips through parseCsv', () {
    final s = makeState();
    seed(s);
    final rows = s.txns.list(const TxnFilter());
    final csv = encodeCsv(rows);
    expect(csv.startsWith('﻿'), isTrue);
    final parsed = parseCsv(csv);
    expect(parsed.first, exportHeader);
    final swiggy = parsed.firstWhere((r) => r[5] == 'Swiggy');
    expect(swiggy, ['2026-10-28 20:00', 'spend', '486.00', 'Food & dining', 'HDFC Savings', 'Swiggy', 'Team dinner after sprint demo', '#work #split', 'Indiranagar']);
    final sip = parsed.firstWhere((r) => r[1] == 'invest' && r[5] == '');
    expect(sip[8], '');
  });

  test('CsvMapping.detect for bank statements', () {
    final m = CsvMapping.detect(['Txn Date', 'Narration', 'Withdrawal Amt', 'Deposit Amt']);
    expect([m.date, m.merchant, m.debit, m.credit, m.amount], [0, 1, 2, 3, -1]);
    expect(m.isValid, isTrue);
    expect(CsvMapping.detect(['foo', 'bar']).isValid, isFalse);
    expect(CsvMapping.detect(['date', 'x']).isValid, isFalse);
  });

  group('buildImport', () {
    test('empty and invalid header', () {
      final s = makeState();
      expect(buildImport([], s.catalog, s.txns), isEmpty);
      final bad = buildImport(
        [
          ['foo'],
          ['1'],
        ],
        s.catalog,
        s.txns,
      );
      expect(bad.single.error, contains('date column'));
      expect(bad.single.importable, isFalse);
    });

    test('own export format with types, categories, tags and duplicates', () {
      final s = makeState();
      seed(s);
      final rows = parseCsv('''date,type,amount,category,source,merchant,note,tags,place
2026-10-28 20:00,spend,486.00,Food & dining,HDFC,Swiggy,dup,#work,
2026-10-20,invest,1000,,, SIP ,,,
2026-10-21,income,500,,,Bonus,,,
2026-10-22,spend,-250,Mystery,,Shop,,#a #b,Mall
2026-10-23,debt,100,,,EMI,,,
bad-date,spend,1,,,,,,
2026-10-24,spend,abc,,,,,,
''');
      final out = buildImport(rows, s.catalog, s.txns, sourceId: 7);
      expect(out.length, 7);
      expect(out[0].duplicate, isTrue);
      expect(out[0].importable, isFalse);
      expect(out[1].txn!.type, TxnType.invest);
      expect(s.catalog.category(out[1].txn!.categoryId).name, 'Fixed deposit');
      expect(out[1].needsReview, isFalse);
      expect(s.catalog.category(out[2].txn!.categoryId).name, 'Salary');
      expect(out[3].txn!.amount, 25000);
      expect(out[3].needsReview, isTrue);
      expect(out[3].txn!.tags, ['#a', '#b']);
      expect(out[3].txn!.place, 'Mall');
      expect(out[3].txn!.sourceId, 7);
      expect(out[4].txn!.type, TxnType.debt);
      expect(s.catalog.category(out[4].txn!.categoryId).name, 'Others');
      expect(out[5].error, contains('Invalid date'));
      expect(out[6].error, 'Invalid amount');
      expect(out[0].line, 2);
    });

    test('debit/credit bank columns', () {
      final s = makeState();
      final rows = parseCsv('Date,Narration,Debit,Credit\n01/10/2026,SALARY,,"1,10,000"\n02/10/2026,AMAZON,"1,299.00",\n03/10/2026,ZERO,0,0\n');
      final out = buildImport(rows, s.catalog, s.txns);
      expect(out[0].txn!.type, TxnType.income);
      expect(out[0].txn!.amount, 11000000);
      expect(out[1].txn!.type, TxnType.spend);
      expect(out[1].txn!.amount, 129900);
      expect(out[1].txn!.merchant, 'AMAZON');
      expect(out[2].error, 'Invalid amount');
    });
  });
}
