import 'package:expense_manager/core/dates.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/ui/screens/transactions_screen.dart';
import 'package:expense_manager/ui/screens/txn_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('lists current month grouped by day with totals', (tester) async {
    final s = makeState();
    seed(s);
    await pumpScreen(tester, s, const TransactionsScreen());
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('7 transactions'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('−₹486'), findsWidgets);
    expect(find.text('Out ₹78,198'), findsOneWidget);
    expect(find.text('In ₹1,12,500'), findsOneWidget);

    await tester.tap(find.byKey(const Key('prev-period')));
    await tester.pump();
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Toit'), findsOneWidget);
    await tester.tap(find.byKey(const Key('prev-period')));
    await tester.pump();
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('No transactions in this period.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('next-period')));
    await tester.tap(find.byKey(const Key('next-period')));
    await tester.pump();
    expect(find.text('October 2026'), findsOneWidget);

    await tester.tap(find.text('Swiggy'));
    await tester.pumpAndSettle();
    expect(find.byType(TxnDetailScreen), findsOneWidget);
  });

  testWidgets('type tabs and category chips filter', (tester) async {
    final s = makeState();
    seed(s);
    await pumpScreen(tester, s, const TransactionsScreen());
    await tester.tap(find.text('Invest').first);
    await tester.pump();
    expect(find.text('1 transactions'), findsOneWidget);
    await tester.tap(find.text('All').first);
    await tester.pump();
    await tester.dragUntilVisible(find.text('Transport'), find.byKey(const Key('category-chips')), const Offset(-150, 0));
    await tester.ensureVisible(find.text('Transport'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transport'));
    await tester.pump();
    expect(find.text('Uber'), findsOneWidget);
    expect(find.text('Swiggy'), findsNothing);
    await tester.tap(find.text('Transport'));
    await tester.pump();
    expect(find.text('Swiggy'), findsOneWidget);
    await tester.tap(find.text('Transport'));
    await tester.pump();
    expect(find.text('1 transactions'), findsOneWidget);
  });

  testWidgets('All categories chip clears the category filter', (tester) async {
    final s = makeState();
    seed(s);
    await pumpScreen(tester, s, TransactionsScreen(initialFilter: TxnFilter(categoryIds: {catId(s, 'Rent')})));
    expect(find.text('1 transactions'), findsOneWidget);
    await tester.tap(find.text('All categories'));
    await tester.pump();
    expect(find.text('7 transactions'), findsOneWidget);
  });

  testWidgets('search spans all time and can be cleared', (tester) async {
    final s = makeState();
    seed(s);
    await pumpScreen(tester, s, const TransactionsScreen());
    await tester.enterText(find.byKey(const Key('search')), 'dinner');
    await tester.pump();
    expect(find.text('All time'), findsOneWidget);
    expect(find.byKey(const Key('prev-period')), findsNothing);
    expect(find.text('Toit'), findsOneWidget);
    expect(find.text('Swiggy'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search')), 'zzz');
    await tester.pump();
    expect(find.text('No transactions match "zzz".'), findsOneWidget);
    await tester.tap(find.byKey(const Key('clear-search')));
    await tester.pump();
    expect(find.text('October 2026'), findsOneWidget);
  });

  testWidgets('filter sheet applies, resets and searches categories', (tester) async {
    final s = makeState();
    final ids = seed(s);
    await pumpScreen(tester, s, const TransactionsScreen(initialFilter: TxnFilter(minAmount: 10000, maxAmount: 5000000)));
    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('min-amount'))).controller!.text, '100');
    await tester.tap(find.byKey(const Key('reset-filters')));
    await tester.pump();
    await tester.tap(find.descendant(of: find.byType(FilterSheet), matching: find.text('Spend')));
    await tester.tap(find.descendant(of: find.byType(FilterSheet), matching: find.text('Spend')));
    await tester.tap(find.descendant(of: find.byType(FilterSheet), matching: find.text('Spend')));
    await tester.enterText(find.byKey(const Key('category-search')), 'tran');
    await tester.pump();
    expect(find.descendant(of: find.byType(FilterSheet), matching: find.text('Rent')), findsNothing);
    await tester.tap(find.descendant(of: find.byType(FilterSheet), matching: find.text('Transport')));
    await tester.tap(find.descendant(of: find.byType(FilterSheet), matching: find.text('ICICI Card')));
    await tester.enterText(find.byKey(const Key('min-amount')), '100');
    await tester.enterText(find.byKey(const Key('max-amount')), '');
    await tester.tap(find.byKey(const Key('apply-filters')));
    await tester.pumpAndSettle();
    expect(find.text('Uber'), findsOneWidget);
    expect(find.text('4'), findsOneWidget); // active filter badge
    expect(ids.card, isPositive);

    // dismissing the sheet keeps filters
    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Uber'), findsOneWidget);
  });

  testWidgets('initial period and type filter from insights', (tester) async {
    final s = makeState();
    seed(s);
    await pumpScreen(
      tester,
      s,
      TransactionsScreen(
        initialFilter: const TxnFilter(types: {TxnType.spend}),
        initialPeriod: Period.of(PeriodKind.month, DateTime(2026, 9)),
      ),
    );
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Toit'), findsOneWidget);
  });
}
