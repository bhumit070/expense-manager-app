import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/ui/screens/budgets_screen.dart';
import 'package:expense_manager/ui/screens/categories_screen.dart';
import 'package:expense_manager/ui/screens/debts_screen.dart';
import 'package:expense_manager/ui/screens/home_screen.dart';
import 'package:expense_manager/ui/screens/insights_screen.dart';
import 'package:expense_manager/ui/screens/investments_screen.dart';
import 'package:expense_manager/ui/screens/reminders_screen.dart';
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

  testWidgets('month picker moves back and forward but not past this month', (tester) async {
    final s = makeState();
    seed(s);
    await pumpScreen(tester, s, const HomeShell());
    expect(find.text('October 2026'), findsOneWidget);
    expect(tester.widget<IconButton>(find.byKey(const Key('home-next-month'))).onPressed, isNull);
    expect(find.text('Money out this month'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-prev-month')));
    await tester.pump();
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Money out in Sep'), findsOneWidget);
    // September: Toit ₹4,200 spend + ₹10,000 SIP.
    expect(find.text('₹14,200'), findsOneWidget);
    expect(find.text('Toit'), findsOneWidget);
    expect(find.text('Swiggy'), findsNothing);
    expect(find.textContaining('in Sep'), findsWidgets);

    await tester.tap(find.byKey(const Key('home-prev-month')));
    await tester.pump();
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('No spending in August 2026.'), findsOneWidget);
    expect(find.text('Nothing in August 2026'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-next-month')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('home-next-month')));
    await tester.pump();
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('Money out this month'), findsOneWidget);
    expect(find.text('Swiggy'), findsOneWidget);
  });

  testWidgets('coming up card and bell open reminders grouped by date', (tester) async {
    final s = makeState();
    seed(s);
    s.planning.addDebt(const Debt(direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'ICICI bill', principal: 500000, dueDay: 28));
    s.planning.addDebt(const Debt(direction: DebtDirection.iOwe, kind: DebtKind.loan, name: 'Bike loan', principal: 500000, emi: 300000, dueDay: 29));
    await pumpScreen(tester, s, const HomeShell());
    expect(find.byKey(const Key('coming-up')), findsOneWidget);
    // Only the first three of four show on Home.
    expect(find.descendant(of: find.byKey(const Key('coming-up')), matching: find.byType(UpcomingTile)), findsNWidgets(3));
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('in 8 days'), findsOneWidget);

    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.byType(RemindersScreen), findsOneWidget);
    expect(find.byType(UpcomingTile), findsNWidgets(4));
    expect(find.text('Thu, 5 Nov'), findsOneWidget);
    expect(find.text('Thu, 12 Nov'), findsOneWidget);
    expect(find.text('Card bill due · 28 Oct'), findsOneWidget);
    expect(find.text('Matures · 12 Nov'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-reminders')));
    await tester.pumpAndSettle();
    expect(find.byType(RemindersScreen), findsOneWidget);
  });

  testWidgets('no upcoming items: no card, empty reminders screen', (tester) async {
    final s = makeState();
    await pumpScreen(tester, s, HomeShell(key: UniqueKey()));
    expect(find.byKey(const Key('coming-up')), findsNothing);
    await tester.tap(find.byKey(const Key('open-reminders')));
    await tester.pumpAndSettle();
    expect(find.text('Nothing coming up'), findsOneWidget);
  });

  test('reminder date labels', () {
    expect(dueDayLabel(DateTime(2027, 1, 4), kNow), 'Mon, 4 Jan 2027');
    expect(dueIn(DateTime(2026, 11, 7), kNow), 'in 10 days');
    expect(upcomingIcon(UpcomingKind.emi), isNot(upcomingIcon(UpcomingKind.maturity)));
  });
}
