import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/ui/screens/debts_screen.dart';
import 'package:expense_manager/ui/screens/investments_screen.dart';
import 'package:expense_manager/ui/screens/txn_detail_screen.dart';
import 'package:expense_manager/ui/screens/txn_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('holdingSubtitle', () {
    expect(holdingSubtitle(const Investment(kind: InvestmentKind.gold, name: 'g')), 'Gold');
    expect(holdingSubtitle(Investment(kind: InvestmentKind.fd, name: 'f', institution: 'SBI', rate: 6.8, maturityAt: DateTime(2026, 11, 9))), 'SBI · 6.80% · matures 9 Nov 2026');
  });

  group('Investments', () {
    testWidgets('empty state then add an investment with an initial amount', (tester) async {
      final s = makeState();
      await pumpRoute(tester, s, inScaffold(const InvestmentsScreen()));
      expect(find.text('No investments yet'), findsOneWidget);
      await tester.tap(find.text('Add investment'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-investment')));
      await tester.pump();
      expect(find.text('Give the investment a name'), findsWidgets);
      await tester.tap(find.text('Stocks'));
      await tester.enterText(find.byKey(const Key('inv-name')), 'Infosys');
      await tester.enterText(find.byKey(const Key('inv-institution')), 'Zerodha');
      await tester.enterText(find.byKey(const Key('inv-rate')), 'x');
      await tester.enterText(find.byKey(const Key('inv-amount')), '112800');
      await tester.tap(find.byKey(const Key('inv-start')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('inv-maturity')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('inv-start')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('10 Oct 2026'), findsOneWidget);
      await tester.tap(find.byKey(const Key('inv-maturity')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-investment')));
      await tester.pumpAndSettle();
      final h = s.planning.holdings().single;
      expect([h.investment.name, h.investment.kind, h.investment.rate, h.invested, h.entries], ['Infosys', InvestmentKind.stock, null, 11280000, 1]);
      expect(h.investment.startAt, DateTime(2026, 10, 10));
      expect(find.text('₹1,12,800'), findsWidgets);
    });

    testWidgets('add without amount creates no contribution', (tester) async {
      final s = makeState();
      await pumpRoute(tester, s, const InvestmentFormScreen());
      await tester.enterText(find.byKey(const Key('inv-name')), 'PPF');
      await tester.enterText(find.byKey(const Key('inv-rate')), '7.1');
      await tester.tap(find.byKey(const Key('save-investment')));
      await tester.pumpAndSettle();
      expect(s.planning.holdings().single.entries, 0);
      expect(s.planning.holdings().single.investment.rate, 7.1);
    });

    testWidgets('portfolio groups, allocation, maturity banner and detail actions', (tester) async {
      final s = makeState();
      final ids = seed(s);
      await pumpRoute(tester, s, inScaffold(const InvestmentsScreen()));
      expect(find.text('₹60,000'), findsWidgets);
      expect(find.text('+₹50,000 this month · 2 holdings'), findsOneWidget);
      expect(find.text('Fixed deposits 83%'), findsOneWidget);
      expect(find.text('HDFC FD matures on 12 Nov'), findsOneWidget);
      expect(find.text('1 entry'), findsNWidgets(2));
      await tester.tap(find.byKey(const Key('add-investment')));
      await tester.pumpAndSettle();
      expect(find.byType(InvestmentFormScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('HDFC FD matures on 12 Nov'));
      await tester.pumpAndSettle();
      expect(find.byType(InvestmentDetailScreen), findsOneWidget);
      expect(find.text('7.10%'), findsOneWidget);
      expect(find.text('15 days left'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsOneWidget);
      await tester.tap(find.byKey(const Key('add-money')));
      await tester.pumpAndSettle();
      expect(find.byType(TxnFormScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('HDFC FD').last);
      await tester.pumpAndSettle();
      expect(find.byType(TxnDetailScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('mark-matured')));
      await tester.pumpAndSettle();
      expect(s.planning.investment(ids.fd).status, InvestmentStatus.matured);

      await tester.tap(find.text('Nifty 50 Index'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('close-investment')));
      await tester.pumpAndSettle();
      expect(s.planning.investment(ids.sip).status, InvestmentStatus.closed);
    });

    testWidgets('inactive investment with notes and no contributions', (tester) async {
      final s = makeState();
      final id = s.planning.addInvestment(Investment(kind: InvestmentKind.gold, name: 'SGB', note: '20 g', startAt: DateTime(2026), maturityAt: DateTime(2025), status: InvestmentStatus.matured));
      await pumpRoute(tester, s, InvestmentDetailScreen(id: id));
      expect(find.text('MATURED'), findsOneWidget);
      expect(find.text('20 g'), findsOneWidget);
      expect(find.text('No money added yet.'), findsOneWidget);
      expect(find.textContaining('days left'), findsNothing);
      await tester.tap(find.byKey(const Key('reactivate')));
      await tester.pumpAndSettle();
      expect(s.planning.investment(id).status, InvestmentStatus.active);
    });
  });

  group('Debts', () {
    testWidgets('summary, tabs, settle/reopen and record payment', (tester) async {
      final s = makeState();
      final ids = seed(s);
      s.planning.addDebt(const Debt(direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'ICICI card', principal: 2230000));
      await pumpRoute(tester, s, inScaffold(const DebtsScreen()));
      expect(find.text('₹4,29,900'), findsOneWidget);
      expect(find.text('₹12,400/mo in EMIs'), findsOneWidget);
      expect(find.text('₹6,000'), findsOneWidget);
      expect(find.text('HDFC · 9.2% · EMI ₹12,400 · due on 5'), findsOneWidget);
      expect(find.text('1 of 36 EMIs paid'), findsOneWidget);
      expect(find.text('0 payments recorded'), findsOneWidget);

      await tester.tap(find.byKey(Key('pay-${ids.loan}')));
      await tester.pumpAndSettle();
      expect(find.byType(TxnFormScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Owed to me'));
      await tester.pump();
      expect(find.text('Rahul'), findsOneWidget);
      expect(find.text('1 payment recorded'), findsOneWidget);
      expect(find.text('Record repayment'), findsOneWidget);
      await tester.tap(find.byKey(Key('settle-${ids.lent}')));
      await tester.pump();
      expect(find.text('Nothing here'), findsOneWidget);
      await tester.tap(find.text('Settled'));
      await tester.pump();
      expect(find.text('Reopen'), findsOneWidget);
      expect(find.byKey(Key('pay-${ids.lent}')), findsNothing);
      await tester.tap(find.text('Reopen'));
      await tester.pump();
      expect(s.planning.debt(ids.lent).settled, isFalse);
      await tester.tap(find.text('I owe'));
      await tester.pump();
    });

    testWidgets('add debt form validates and saves', (tester) async {
      final s = makeState();
      await pumpRoute(tester, s, inScaffold(const DebtsScreen()));
      await tester.tap(find.byKey(const Key('add-debt')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-debt')));
      await tester.pump();
      expect(find.text('Add a name and the amount'), findsWidgets);
      await tester.tap(find.text('Owed to me'));
      await tester.tap(find.text('Credit card'));
      await tester.tap(find.text('Personal'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('debt-name')), 'Goa trip');
      await tester.enterText(find.byKey(const Key('debt-party')), 'Priya');
      await tester.enterText(find.byKey(const Key('debt-principal')), '10000');
      await tester.enterText(find.byKey(const Key('debt-due')), '40');
      await tester.tap(find.byKey(const Key('save-debt')));
      await tester.pumpAndSettle();
      final d = s.planning.debts().single.debt;
      expect([d.name, d.counterparty, d.direction, d.kind, d.principal, d.dueDay, d.emi], ['Goa trip', 'Priya', DebtDirection.owedToMe, DebtKind.personal, 1000000, null, null]);
      expect(find.text('Priya'), findsNothing);

      await tester.tap(find.byKey(const Key('add-debt')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Loan'));
      await tester.tap(find.text('I owe'));
      await tester.enterText(find.byKey(const Key('debt-name')), 'Bike');
      await tester.enterText(find.byKey(const Key('debt-principal')), '50000');
      await tester.enterText(find.byKey(const Key('debt-rate')), '10');
      await tester.enterText(find.byKey(const Key('debt-emi')), '2500');
      await tester.enterText(find.byKey(const Key('debt-emis')), '24');
      await tester.enterText(find.byKey(const Key('debt-due')), '7');
      await tester.tap(find.byKey(const Key('save-debt')));
      await tester.pumpAndSettle();
      expect(s.planning.debts(direction: DebtDirection.iOwe).single.debt.dueDay, 7);
    });
  });
}
