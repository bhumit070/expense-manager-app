import 'package:expense_manager/app.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:expense_manager/ui/screens/budgets_screen.dart';
import 'package:expense_manager/ui/screens/insights_screen.dart';
import 'package:expense_manager/ui/screens/onboarding_screen.dart';
import 'package:expense_manager/ui/screens/shell.dart';
import 'package:expense_manager/ui/screens/transactions_screen.dart';
import 'package:expense_manager/ui/screens/txn_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end: skip onboarding, add a ₹450 spend, then find it in the
/// transaction list, the insights totals and a budget's used amount.
///
/// Shared by `integration_test/app_test.dart` (on a device) and
/// `test/ui/app_flow_test.dart` (headless, in CI).
Future<void> addSpendFlow(WidgetTester tester, AppState s) async {
  s.planning.addBudget(const Budget(name: 'All spending', period: BudgetPeriod.monthly, limit: 2000000));
  await tester.pumpWidget(ExpenseApp(state: s));
  await tester.pumpAndSettle();

  // Onboarding: skip every step.
  expect(find.byType(OnboardingScreen), findsOneWidget);
  for (var i = 0; i < 10 && find.byType(OnboardingScreen).evaluate().isNotEmpty; i++) {
    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();
  }
  expect(s.onboarded, isTrue);
  expect(find.byType(HomeShell), findsOneWidget);

  // Add a spend with the keypad; category defaults to Others.
  await tester.tap(find.byKey(const Key('add-txn')));
  await tester.pumpAndSettle();
  for (final k in ['4', '5', '0']) {
    await tester.tap(find.byKey(Key('key-$k')));
    await tester.pump();
  }
  final form = find.descendant(of: find.byType(TxnFormScreen), matching: find.byType(Scrollable)).first;
  await tester.scrollUntilVisible(find.byKey(const Key('save-txn')), 300, scrollable: form);
  await tester.tap(find.byKey(const Key('save-txn')));
  await tester.pumpAndSettle();
  final saved = s.txns.list(const TxnFilter()).single.txn;
  expect([saved.type, saved.amount], [TxnType.spend, 45000]);

  // 1. Transaction list.
  await tester.scrollUntilVisible(find.text('View all'), 200, scrollable: find.byType(Scrollable).first);
  await tester.tap(find.text('View all'));
  await tester.pumpAndSettle();
  expect(find.byType(TransactionsScreen), findsOneWidget);
  expect(find.descendant(of: find.byKey(const Key('txn-list')), matching: find.text('−₹450')), findsNWidgets(2)); // row + day total
  await tester.pageBack();
  await tester.pumpAndSettle();

  // 2. Insights totals.
  await tester.tap(find.byKey(const Key('tab-Insights')));
  await tester.pumpAndSettle();
  expect(find.byType(InsightsScreen), findsOneWidget);
  expect(find.text('₹450'), findsWidgets);

  // 3. Budget used amount.
  await tester.tap(find.byKey(const Key('tab-Home')));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text('Budgets'), 200, scrollable: find.byType(Scrollable).first);
  await tester.tap(find.text('Budgets'));
  await tester.pumpAndSettle();
  expect(find.byType(BudgetsScreen), findsOneWidget);
  expect(find.text('₹450'), findsWidgets);
  expect(s.planning.progress(s.planning.budgets().single, s.now()).used, 45000);
}
