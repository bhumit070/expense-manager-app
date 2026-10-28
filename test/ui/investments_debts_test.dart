import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
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

    test('statement labels and reminder message', () {
      // Runtime (non-const) construction keeps constructor lines covered.
      expect(InvestmentsScreen(key: UniqueKey()).key, isNotNull);
      expect(
        [
          for (final d in [3, 1, 0, -1, -4]) statementDueLabel(d),
        ],
        ['Due in 3 days', 'Due tomorrow', 'Due today', 'Overdue by 1 day', 'Overdue by 4 days'],
      );
      const plain = DebtStatus(
        debt: Debt(direction: DebtDirection.owedToMe, kind: DebtKind.personal, name: 'Rahul', principal: 850000),
        paid: 250000,
        payments: 1,
      );
      expect(remindMessage(plain), 'Hi Rahul, just a friendly reminder about the ₹6,000. Whenever it suits you is fine. Thanks!');
      const trip = DebtStatus(
        debt: Debt(direction: DebtDirection.owedToMe, kind: DebtKind.personal, name: 'Goa trip', counterparty: 'Priya', principal: 300000),
        paid: 0,
        payments: 0,
      );
      expect(remindMessage(trip), 'Hi Priya, just a friendly reminder about the ₹3,000 for Goa trip. Whenever it suits you is fine. Thanks!');
    });

    testWidgets('urgent card statement: Pay now records a debt payment', (tester) async {
      final s = makeState();
      seed(s);
      final card = s.planning.addDebt(
        Debt(direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'ICICI card', principal: 2230000, statementAmount: 1850000, statementDueAt: DateTime(2026, 10, 30)),
      );
      final later = s.planning.addDebt(Debt(direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'Amex', principal: 100000, statementAmount: 50000, statementDueAt: DateTime(2026, 11, 20)));
      final undated = s.planning.addDebt(const Debt(direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'SBI card', principal: 100000, statementAmount: 25000));
      final overdue = s.planning.addDebt(Debt(direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'Axis', principal: 100000, statementAmount: 10000, statementDueAt: DateTime(2026, 10, 26)));
      await pumpRoute(tester, s, inScaffold(const DebtsScreen()));
      expect(find.text('Statement ₹18,500 · due 30 Oct'), findsOneWidget);
      expect(find.text('Due in 2 days'), findsOneWidget);
      expect(find.text('Due in 23 days'), findsOneWidget);
      expect(find.text('Unpaid ₹250'), findsOneWidget);
      expect(find.text('Overdue by 2 days'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byKey(Key('pay-now-$card'))).style!.backgroundColor!.resolve({}),
        isNot(tester.widget<FilledButton>(find.byKey(Key('pay-now-$later'))).style!.backgroundColor!.resolve({})),
      );
      expect(find.byKey(Key('pay-now-$undated')), findsOneWidget);
      expect(find.byKey(Key('pay-now-$overdue')), findsOneWidget);

      await tester.ensureVisible(find.byKey(Key('pay-now-$card')));
      await tester.tap(find.byKey(Key('pay-now-$card')));
      await tester.pumpAndSettle();
      expect(find.textContaining('₹18,500 card payment from HDFC Savings ••42'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(s.planning.debts().firstWhere((d) => d.debt.id == card).statementLeft, 1850000);

      await tester.tap(find.byKey(Key('pay-now-$card')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-pay-now')));
      await tester.pumpAndSettle();
      expect(find.text('Card payment of ₹18,500 recorded'), findsOneWidget);
      final st = s.planning.debts().firstWhere((d) => d.debt.id == card);
      expect([st.statementLeft, st.paid], [0, 1850000]);
      final t = s.txns.list(TxnFilter(debtId: card)).single.txn;
      expect([t.type, t.amount, t.merchant, t.sourceId], [TxnType.debt, 1850000, 'ICICI card bill', s.catalog.defaultSource()!.id]);
      expect(find.byKey(Key('pay-now-$card')), findsNothing);
      expect(find.text('Paid'), findsOneWidget);
    });

    testWidgets('Pay now without a default source', (tester) async {
      final s = makeState();
      s.catalog.archiveSource(s.catalog.defaultSource()!.id);
      final card = s.planning.addDebt(const Debt(direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'ICICI', principal: 100000, statementAmount: 25000));
      await pumpRoute(tester, s, inScaffold(const DebtsScreen()));
      await tester.tap(find.byKey(Key('pay-now-$card')));
      await tester.pumpAndSettle();
      expect(find.text('Records a ₹250 card payment. It counts as Debt, not Spend.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm-pay-now')));
      await tester.pumpAndSettle();
      expect(s.txns.list(TxnFilter(debtId: card)).single.txn.sourceId, isNull);
    });

    testWidgets('Remind shares a message for money owed to me', (tester) async {
      final files = FakeFiles();
      final s = makeState(files: files);
      final ids = seed(s);
      await pumpRoute(tester, s, inScaffold(DebtsScreen(key: UniqueKey())));
      expect(find.byKey(Key('remind-${ids.lent}')), findsNothing);
      await tester.tap(find.text('Owed to me'));
      await tester.pump();
      await tester.tap(find.byKey(Key('remind-${ids.lent}')));
      await tester.pump();
      expect(files.shared.single, ('Hi Rahul, just a friendly reminder about the ₹6,000. Whenever it suits you is fine. Thanks!', 'Friendly reminder'));
    });

    testWidgets('edit a debt and set a card statement with a due date', (tester) async {
      final s = makeState();
      final ids = seed(s);
      await pumpRoute(tester, s, inScaffold(const DebtsScreen()));
      await tester.tap(find.byKey(Key('edit-debt-${ids.loan}')));
      await tester.pumpAndSettle();
      expect(find.text('Edit debt'), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const Key('debt-principal'))).controller!.text, '420000');
      expect(tester.widget<TextField>(find.byKey(const Key('debt-emi'))).controller!.text, '12400');
      expect(tester.widget<TextField>(find.byKey(const Key('debt-rate'))).controller!.text, '9.2');
      expect(find.byKey(const Key('debt-statement')), findsNothing);

      await tester.tap(find.text('Credit card'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('debt-name')), 'HDFC Millennia');
      await tester.enterText(find.byKey(const Key('debt-statement')), '12345.50');
      expect(find.text('Statement due date'), findsOneWidget);
      await tester.tap(find.byKey(const Key('debt-statement-due')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Due Wed, 28 Oct 2026'), findsOneWidget);
      await tester.tap(find.byKey(const Key('clear-statement-due')));
      await tester.pump();
      expect(find.text('Statement due date'), findsOneWidget);
      await tester.tap(find.byKey(const Key('debt-statement-due')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Statement due date'), findsOneWidget);
      await tester.tap(find.byKey(const Key('debt-statement-due')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-debt')));
      await tester.pumpAndSettle();

      final d = s.planning.debt(ids.loan);
      expect([d.name, d.kind, d.statementAmount, d.statementDueAt, d.emi, d.settled], ['HDFC Millennia', DebtKind.card, 1234550, DateTime(2026, 10, 28), 1240000, false]);
      // The ₹12,400 paid on 5 Oct falls inside this statement's cycle and covers it.
      expect(find.text('Paid'), findsOneWidget);

      // Editing a card statement prefills the decimal amount and date; switching away from card drops it.
      await tester.tap(find.byKey(Key('edit-debt-${ids.loan}')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byKey(const Key('debt-statement'))).controller!.text, '12345.50');
      expect(find.text('Due Wed, 28 Oct 2026'), findsOneWidget);
      await tester.tap(find.text('Loan'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('save-debt')));
      await tester.pumpAndSettle();
      expect([s.planning.debt(ids.loan).statementAmount, s.planning.debt(ids.loan).statementDueAt], [null, null]);

      // A debt without optional fields edits cleanly.
      await tester.tap(find.text('Owed to me'));
      await tester.pump();
      await tester.tap(find.byKey(Key('edit-debt-${ids.lent}')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byKey(const Key('debt-emi'))).controller!.text, '');
      await tester.pageBack();
      await tester.pumpAndSettle();
    });
  });
}
