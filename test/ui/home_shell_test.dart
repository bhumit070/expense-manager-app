import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/ui/screens/budgets_screen.dart';
import 'package:expense_manager/ui/screens/categories_screen.dart';
import 'package:expense_manager/ui/screens/debts_screen.dart';
import 'package:expense_manager/ui/screens/home_screen.dart';
import 'package:expense_manager/ui/screens/insights_screen.dart';
import 'package:expense_manager/ui/screens/investments_screen.dart';
import 'package:expense_manager/ui/screens/settings_screen.dart';
import 'package:expense_manager/ui/screens/shell.dart';
import 'package:expense_manager/ui/screens/sources_screen.dart';
import 'package:expense_manager/ui/screens/transactions_screen.dart';
import 'package:expense_manager/ui/screens/txn_detail_screen.dart';
import 'package:expense_manager/ui/screens/txn_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('greeting and initials', () {
    expect(greeting(DateTime(2026, 1, 1, 8)), 'Good morning');
    expect(greeting(DateTime(2026, 1, 1, 13)), 'Good afternoon');
    expect(greeting(DateTime(2026, 1, 1, 20)), 'Good evening');
    expect(initials(''), '');
    expect(initials('bhumit'), 'B');
    expect(initials('  Bhumit  Kumar Ganatra'), 'BK');
  });

  testWidgets('empty home shows onboarding hints', (tester) async {
    final s = makeState();
    await pumpScreen(tester, s, const HomeShell());
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsWidgets);
    expect(find.text('No spending yet this month.'), findsOneWidget);
    expect(find.text('No transactions yet'), findsOneWidget);
    expect(find.text('₹0'), findsWidgets);
  });

  testWidgets('spend without income still renders the hero bar', (tester) async {
    final s = makeState();
    s.txns.insert(Txn(type: TxnType.spend, amount: 10000, categoryId: s.catalog.defaultCategory().id, sourceId: null, occurredAt: kNow));
    await pumpScreen(tester, s, const HomeShell());
    expect(find.byKey(const Key('hero-out')), findsOneWidget);
    expect(find.text('₹100'), findsWidgets);
  });

  testWidgets('seeded home shows totals, categories and recent; navigation works', (tester) async {
    final s = makeState();
    seed(s);
    s.userName = 'Bhumit Ganatra';
    await pumpScreen(tester, s, const HomeShell());
    expect(find.text('BG'), findsOneWidget);
    expect(find.text('Good evening'), findsOneWidget);
    expect(find.text('₹65,798'), findsOneWidget);
    expect(find.text('Rent'), findsWidgets);
    expect(find.text('Swiggy'), findsOneWidget);

    Future<void> openAndBack(Finder f, Type screen) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
      expect(find.byType(screen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await openAndBack(find.byKey(const Key('open-settings')), SettingsScreen);
    await openAndBack(find.text('Budgets'), BudgetsScreen);
    await openAndBack(find.text('Categories'), CategoriesScreen);
    await openAndBack(find.text('Payment sources'), SourcesScreen);
    await openAndBack(find.text('View all'), TransactionsScreen);
    await openAndBack(find.text('Swiggy'), TxnDetailScreen);
    await openAndBack(find.byKey(const Key('add-txn')), TxnFormScreen);

    await tester.tap(find.text('Insights').first);
    await tester.pumpAndSettle();
    expect(find.byType(InsightsScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-Home')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invested').last);
    await tester.pumpAndSettle();
    expect(find.byType(InvestmentsScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-Home')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('You owe'));
    await tester.pumpAndSettle();
    expect(find.byType(DebtsScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-Home')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Owed to you'));
    await tester.pumpAndSettle();
    expect(find.byType(DebtsScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-Invest')));
    await tester.pumpAndSettle();
    expect(find.byType(InvestmentsScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-Insights')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tab-Debts')));
    await tester.pumpAndSettle();
    expect(find.byType(DebtsScreen), findsOneWidget);
  });
}
