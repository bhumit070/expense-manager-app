import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/ui/screens/budgets_screen.dart';
import 'package:expense_manager/ui/screens/insights_screen.dart';
import 'package:expense_manager/ui/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('percentChange', () {
    expect(percentChange(0, 10), isNull);
    expect(percentChange(100, 90), -10);
    expect(percentChange(100, 125), 25);
  });

  group('InsightsScreen', () {
    testWidgets('month view: donut, comparison, chart and breakdown', (tester) async {
      final s = makeState();
      seed(s);
      await pumpScreen(tester, s, inScaffold(const InsightsScreen()));
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.text('1 Oct – 31 Oct'), findsOneWidget);
      expect(find.text('Week by week'), findsOneWidget);
      // Sep spend 4,200 → Oct 15,798 is more
      expect(find.text('276% more spent'), findsOneWidget);
      expect(find.textContaining('Saved '), findsOneWidget);
      expect(find.text('Rent  ·  1 txn'), findsOneWidget);
      expect(find.text('Food & dining  ·  1 txn'), findsOneWidget);

      await tester.tap(find.text('Invest').last);
      await tester.pump();
      expect(find.text('Fixed deposit  ·  1 txn'), findsOneWidget);

      await tester.tap(find.byKey(Key('cat-row-${catId(s, 'Fixed deposit')}')));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionsScreen), findsOneWidget);
      expect(find.text('HDFC FD'), findsOneWidget);
    });

    testWidgets('previous periods, year and week views, empty states', (tester) async {
      final s = makeState();
      seed(s);
      await pumpScreen(tester, s, inScaffold(const InsightsScreen()));
      await tester.tap(find.byKey(const Key('insights-prev')));
      await tester.tap(find.byKey(const Key('insights-prev')));
      await tester.pump();
      expect(find.text('August 2026'), findsOneWidget);
      expect(find.text('No earlier data'), findsOneWidget);
      expect(find.text('Nothing recorded in this period.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('insights-next')));
      await tester.pump();
      expect(find.text('September 2026'), findsOneWidget);
      expect(find.text('100% less spent'), findsNothing);

      await tester.tap(find.text('Year'));
      await tester.pump();
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('Month by month'), findsOneWidget);

      await tester.tap(find.text('Week'));
      await tester.pump();
      expect(find.text('Day by day'), findsOneWidget);
      expect(find.text('26 Oct – 1 Nov'), findsWidgets);
      await tester.tap(find.byKey(Key('cat-row-${catId(s, 'Food & dining')}')));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionsScreen), findsOneWidget);
    });

    testWidgets('a quieter period shows "less spent"', (tester) async {
      final s = makeState();
      s.txns.insert(Txn(type: TxnType.spend, amount: 10000, categoryId: 1, sourceId: null, occurredAt: DateTime(2026, 9, 3)));
      s.txns.insert(Txn(type: TxnType.spend, amount: 5000, categoryId: 1, sourceId: null, occurredAt: DateTime(2026, 10, 3)));
      await pumpScreen(tester, s, inScaffold(const InsightsScreen()));
      expect(find.text('50% less spent'), findsOneWidget);
    });

    testWidgets('PDF report export and budgets shortcut', (tester) async {
      final files = FakeFiles();
      final s = makeState(files: files);
      seed(s);
      await pumpScreen(tester, s, inScaffold(const InsightsScreen()));
      await tester.tap(find.byKey(const Key('export-pdf')));
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pumpAndSettle();
      expect(files.saved.single.$1, 'report-2026-10.pdf');
      expect(files.saved.single.$3, 'application/pdf');
      await tester.tap(find.byKey(const Key('open-budgets')));
      await tester.pumpAndSettle();
      expect(find.byType(BudgetsScreen), findsOneWidget);
    });
  });

  group('Budgets', () {
    testWidgets('empty state leads to the form; validation; create with suggestion', (tester) async {
      final s = makeState();
      seed(s);
      await pumpRoute(tester, s, const BudgetsScreen());
      expect(find.text('No monthly budgets'), findsOneWidget);
      await tester.tap(find.text('Create budget'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-budget')));
      await tester.pump();
      expect(find.text('Add a name and a limit'), findsWidgets);
      await tester.enterText(find.byKey(const Key('budget-name')), 'Food');
      await tester.tap(find.text('Food & dining'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('use-suggestion')));
      await tester.pump();
      expect(tester.widget<TextField>(find.byKey(const Key('budget-limit'))).controller!.text, '1400');
      await tester.enterText(find.byKey(const Key('budget-limit')), '10000');
      await tester.tap(find.text('Food & dining'));
      await tester.tap(find.text('Food & dining'));
      await tester.tap(find.byKey(const Key('rollover-switch')));
      await tester.tap(find.byKey(const Key('alert80-switch')));
      await tester.tap(find.byKey(const Key('alert100-switch')));
      await tester.tap(find.text('Week (Mon–Sun)'));
      await tester.tap(find.text('Month (1st → end)'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('save-budget')));
      await tester.pumpAndSettle();
      final b = s.planning.budgets().single;
      expect([b.name, b.limit, b.rollover, b.alert80, b.alert100, b.categoryIds.length], ['Food', 1000000, true, false, false, 1]);
      expect(find.text('Food'), findsOneWidget);
      expect(find.textContaining('left ·'), findsOneWidget);
      expect(find.text('1 category'), findsOneWidget);
      expect(find.byKey(const Key('pace-marker')), findsOneWidget);
    });

    testWidgets('over, near and goal states; edit and delete', (tester) async {
      final s = makeState();
      seed(s);
      s.planning.addBudget(const Budget(name: 'All spend', period: BudgetPeriod.monthly, limit: 1000000));
      s.planning.addBudget(Budget(name: 'Rent', period: BudgetPeriod.monthly, limit: 1800000, categoryIds: [catId(s, 'Rent')]));
      s.planning.addBudget(const Budget(name: 'Invest goal', period: BudgetPeriod.monthly, limit: 2500000, isGoal: true));
      s.planning.addBudget(const Budget(name: 'Big goal', period: BudgetPeriod.monthly, limit: 9000000, isGoal: true));
      s.planning.addBudget(const Budget(name: 'Weekly fun', period: BudgetPeriod.weekly, limit: 100000));
      await pumpRoute(tester, s, const BudgetsScreen());
      expect(find.text('All spend is over by ₹5,798'), findsOneWidget);
      expect(find.text('Over by ₹5,798'), findsOneWidget);
      expect(find.text('Goal reached'), findsOneWidget);
      expect(find.text('₹40,000 to reach goal'), findsOneWidget);
      expect(find.text('All investments'), findsNWidgets(2));
      expect(find.text('All spending'), findsOneWidget);

      await tester.tap(find.text('Weekly · Mon–Sun'));
      await tester.pump();
      expect(find.text('Weekly fun'), findsOneWidget);
      await tester.tap(find.text('Monthly · 1st–end'));
      await tester.pump();

      await tester.tap(find.text('Invest goal'));
      await tester.pumpAndSettle();
      expect(find.text('Edit budget'), findsOneWidget);
      expect(find.byKey(const Key('rollover-switch')), findsNothing);
      await tester.tap(find.byKey(const Key('goal-switch')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('save-budget')));
      await tester.pumpAndSettle();
      expect(s.planning.budgets().firstWhere((b) => b.name == 'Invest goal').isGoal, isFalse);

      await tester.tap(find.text('Rent').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete-budget')));
      await tester.pumpAndSettle();
      expect(s.planning.budgets().any((b) => b.name == 'Rent'), isFalse);

      await tester.tap(find.byKey(const Key('new-budget')));
      await tester.pumpAndSettle();
      expect(find.text('New budget'), findsOneWidget);
    });
  });
}
