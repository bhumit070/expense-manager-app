import 'package:expense_manager/services/bank_sms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void expectSms(String body, {required int amount, bool credit = false, String merchant = '', String? last4}) {
    final s = parseBankSms(body);
    expect(s, isNotNull, reason: body);
    expect([s!.amount, s.credit, s.merchant, s.last4], [amount, credit, merchant, last4], reason: body);
  }

  group('debits', () {
    test('HDFC UPI', () {
      expectSms(
        'Sent Rs.250.00 From HDFC Bank A/C *1234 To SWIGGY On 29/10/26 Ref 630212345678 Not You? Call 18002586161/SMS BLOCK UPI to 7308080808',
        amount: 25000,
        merchant: 'Swiggy',
        last4: '1234',
      );
    });

    test('HDFC card', () {
      expectSms(
        'Spent Rs.1,299 On HDFC Bank Card 5678 At AMAZON PAY INDIA On 2026-10-29:14:22:10 Bal Rs.45,000.00 Not You? Call 18002586161',
        amount: 129900,
        merchant: 'Amazon Pay India',
        last4: '5678',
      );
    });

    test('SBI UPI without a currency word', () {
      expectSms('Dear UPI user A/C X4321 debited by 120.0 on date 29Oct26 trf to ZOMATO LTD Refno 630298765432. If not u? call 1800111109. -SBI', amount: 12000, merchant: 'Zomato Ltd', last4: '4321');
    });

    test('ICICI account names the payee before "credited"', () {
      expectSms(
        'ICICI Bank Acct XX123 debited for Rs 540.00 on 29-Oct-26; UBER INDIA credited. UPI:630211112222. Call 18002662 for dispute. SMS BLOCK 123 to 9215676766.',
        amount: 54000,
        merchant: 'Uber India',
        last4: '123',
      );
    });

    test('ICICI card', () {
      expectSms(
        'INR 2,450.00 spent using ICICI Bank Card XX9012 on 29-Oct-26 on BIGBASKET. Avl Limit: INR 1,50,000.00. If not you, call 1800 2662.',
        amount: 245000,
        merchant: 'Bigbasket',
        last4: '9012',
      );
    });

    test('Axis UPI reference path', () {
      expectSms(
        'INR 89.00 debited A/c no. XX7788 29-10-26 14:22:10 UPI/P2M/630233334444/RAPIDO Not you? SMS BLOCKUPI Cust ID to 919951860002 Axis Bank',
        amount: 8900,
        merchant: 'Rapido',
        last4: '7788',
      );
    });

    test('Kotak to a VPA keeps the name before the @', () {
      expectSms(
        'Sent Rs.300.00 from Kotak Bank AC X5566 to blinkit.payu@hdfcbank on 29-10-26.UPI Ref 630255556666. Not you, https://kotak.com/KBANKT/Fraud',
        amount: 30000,
        merchant: 'Blinkit Payu',
        last4: '5566',
      );
    });

    test('a balance before the amount is skipped', () {
      expectSms('Avl Bal Rs 9,000.00. Rs 75 debited from a/c XX1111 at CHAI POINT.', amount: 7500, merchant: 'Chai Point', last4: '1111');
    });

    test('no counterparty and no account still parses', () {
      expectSms('Rs.500 withdrawn at ATM', amount: 50000, merchant: 'Atm');
      expectSms('₹ 60 paid.', amount: 6000);
    });
  });

  group('credits', () {
    test('HDFC credit from a VPA', () {
      expectSms('Rs. 5,000.00 credited to HDFC Bank A/c XX1234 on 29-10-26 by VPA rahul.k@okaxis (UPI 630277778888)', amount: 500000, credit: true, merchant: 'Rahul K', last4: '1234');
    });

    test('Kotak received from a person', () {
      expectSms('Received Rs.1,200.00 in your Kotak Bank AC X5566 from Priya Shah on 29-10-26.UPI Ref:630299990000.', amount: 120000, credit: true, merchant: 'Priya Shah', last4: '5566');
    });

    test('salary with an Info field', () {
      expectSms('Your a/c no. XXXXXXXX2345 is credited by Rs.85,000.00 on 31-10-26 Info: SALARY OCT. -Canara Bank', amount: 8500000, credit: true, merchant: 'Salary Oct', last4: '2345');
    });

    test('a refund whose only text is the account', () {
      expectSms('Refund of INR 199.00 credited to your account', amount: 19900, credit: true);
    });
  });

  group('ignored', () {
    for (final body in [
      'Your OTP for txn of Rs 500 at AMAZON is 123456. Do not share.',
      'Rs 1,500 will be debited from your a/c on 05-11-26 towards NETFLIX e-mandate.',
      'Your HDFC Bank Credit Card bill of Rs 12,000 is due on 05-11-26. Min amt due Rs 600.',
      'You have a pre-approved loan offer of Rs 5,00,000! Apply now.',
      'Txn of Rs 250 at SWIGGY declined due to insufficient balance.',
      'Rahul has requested Rs 400 from you on GPay.',
      'Your a/c XX1234 balance is Rs 10,000.',
      'Your parcel is out for delivery.',
      'Rs spent',
      '',
    ]) {
      test(body.isEmpty ? '(empty)' : body, () => expect(parseBankSms(body), isNull));
    }
  });

  test('cleanMerchant', () {
    expect(cleanMerchant('VPA swiggy@icici'), 'Swiggy');
    expect(cleanMerchant('M/s. Reliance Fresh'), 'Reliance Fresh');
    expect(cleanMerchant('your a/c'), '');
    expect(cleanMerchant('XX1234'), '');
    expect(cleanMerchant('1234'), '');
    expect(cleanMerchant('Rs.85,000.00'), '');
    expect(cleanMerchant('Café Coffee Day'), 'Caf Coffee Day');
    expect(cleanMerchant('a' * 60).length, 40);
    expect(cleanMerchant('McDonalds India'), 'McDonalds India');
  });

  test('toString', () {
    expect(const BankSms(amount: 100, credit: false, merchant: 'X', last4: '1').toString(), 'BankSms(-100, "X", 1)');
    expect(const BankSms(amount: 100, credit: true).toString(), 'BankSms(+100, "", -)');
  });
}
