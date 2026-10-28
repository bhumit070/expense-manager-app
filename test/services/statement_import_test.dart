import 'package:expense_manager/services/csv.dart';
import 'package:expense_manager/services/statement_import.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

// Synthetic text, shaped like what extractPdfLines produces for each bank.
const hdfc = '''
HDFC BANK Ltd.  Page No .: 1  Statement of account
Account No : 50100123456789
Date  Narration  Chq./Ref.No.  Value Dt  Withdrawal Amt.  Deposit Amt.  Closing Balance
01/10/26  UPI-SWIGGY-SWIGGY8@ICICI-BANGALORE  0000427412345678  01/10/26  486.00  12,345.67
UPI-NOTE DINNER
02/10/26  SALARY OCT 2026 ACME CORP  0000000000000001  02/10/26  1,10,000.00  1,22,345.67
05/10/26  EMI 12345 CHQ S1234  0000000000000002  05/10/26  12,400.00  1,09,945.67
STATEMENT SUMMARY :-
Opening Balance  Dr Count  Cr Count  Debits  Credits  Closing Bal
01/11/26  NOT A ROW AFTER SUMMARY  1.00  2.00
''';

const sbi = '''
State Bank of India
Account Number 00000012345678901  IFSC SBIN0001234
Txn Date  Value Date  Description  Ref No./Cheque No.  Debit  Credit  Balance
Balance as on 1 Oct 2026  50,000.00
1 Oct 2026  1 Oct 2026  TO TRANSFER-UPI/DR/123/ZOMATO  TRANSFER TO 4897  350.00  49,650.00
3 Oct 2026  3 Oct 2026  BY TRANSFER-NEFT*HDFC*REFUND  TRANSFER FROM 1234  1,200.00  50,850.00
5 Oct 2026  5 Oct 2026  ATM WDL ATM CASH 1234 MG ROAD  2,000.00  48,850.00
**This is a computer generated statement**
''';

const icici = '''
ICICI Bank Limited
Statement of Transactions in Savings Account Number: 000401234567
S No.  Value Date  Transaction Date  Cheque Number  Transaction Remarks  Withdrawal Amount (INR )  Deposit Amount (INR )  Balance (INR )
1  01/10/2026  01/10/2026  -  UPI/123456/AMAZON/amazon@apl  1,499.00  0.00  20,501.00
2  02/10/2026  02/10/2026  -  NEFT-INTEREST CREDIT  0.00  101.50  20,602.50
3  04/10/2026  04/10/2026  -  BIL/ONL/ELECTRICITY  899.00  0.00  19,703.50
Total  2,398.00  101.50
Legends for transaction remarks
''';

const generic = '''
Kotak Mahindra Bank
Page 1 of 2
12-Oct-2026  POS AMAZON  549.00 Dr  10,451.00 Cr
13-Oct-26  INTEREST PAID  12.00 Cr  10,463.00 Cr
14/10/2026  SOMETHING WITH NO AMOUNT
15/10/2026  ZERO ENTRY  0.00
32/13/2026  BAD DATE  10.00
continuation line with no row before it is ignored only if nothing is open
16/10/2026  CREDIT CARD BILL REFUND  250.00
17/10/2026  GROCERIES  320.00
''';

List<String> lines(String s) => s.trim().split('\n');

void main() {
  test('detects the bank from the header', () {
    expect(detectBank(lines(hdfc)), StatementBank.hdfc);
    expect(detectBank(lines(sbi)), StatementBank.sbi);
    expect(detectBank(lines(icici)), StatementBank.icici);
    expect(detectBank(lines(generic)), StatementBank.generic);
    expect(StatementBank.values.map(bankLabel), ['HDFC Bank', 'SBI', 'ICICI Bank', 'Bank statement']);
  });

  test('HDFC: balance decides debit/credit, narration continues, summary ends the table', () {
    final r = parseStatement(lines(hdfc));
    expect(r.map((x) => (x.date, x.amount, x.credit)).toList(), [(DateTime(2026, 10, 1), 48600, false), (DateTime(2026, 10, 2), 11000000, true), (DateTime(2026, 10, 5), 1240000, false)]);
    expect(r.first.description, 'UPI-SWIGGY-SWIGGY8@ICICI-BANGALORE UPI-NOTE DINNER');
    expect(r[1].description, 'SALARY OCT 2026 ACME CORP');
  });

  test('SBI: opening balance seeds the running balance', () {
    final r = parseStatement(lines(sbi));
    expect(r.map((x) => (x.date.day, x.amount, x.credit)).toList(), [(1, 35000, false), (3, 120000, true), (5, 200000, false)]);
    expect(r.first.description, 'TO TRANSFER-UPI/DR/123/ZOMATO TRANSFER TO 4897');
  });

  test('ICICI: serial numbers and 0.00 columns', () {
    final r = parseStatement(lines(icici), bank: StatementBank.icici);
    expect(r.map((x) => (x.amount, x.credit)).toList(), [(149900, false), (10150, true), (89900, false)]);
    expect(r[1].description, '- NEFT-INTEREST CREDIT');
  });

  test('generic fallback: Dr/Cr markers, keywords, skips junk', () {
    final r = parseStatement(lines(generic));
    expect(r.map((x) => (x.date, x.description, x.amount, x.credit)).toList(), [
      (DateTime(2026, 10, 12), 'POS AMAZON', 54900, false),
      (DateTime(2026, 10, 13), 'INTEREST PAID', 1200, true),
      (DateTime(2026, 10, 16), 'CREDIT CARD BILL REFUND', 25000, true),
      (DateTime(2026, 10, 17), 'GROCERIES', 32000, false),
    ]);
  });

  test('statementToRows feeds buildImport as debit/credit rows', () {
    final s = makeState();
    final rows = statementToRows(parseStatement(lines(sbi)));
    expect(rows.first, ['date', 'description', 'debit', 'credit']);
    expect(rows[2], ['2026-10-03', 'BY TRANSFER-NEFT*HDFC*REFUND TRANSFER FROM 1234', '', '1200.00']);
    final imp = buildImport(rows, s.catalog, s.txns);
    expect(imp.map((r) => (r.txn!.amount, r.txn!.type.name)).toList(), [(35000, 'spend'), (120000, 'income'), (200000, 'spend')]);
  });
}
