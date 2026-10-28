import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/ui/screens/transactions_screen.dart';
import 'package:expense_manager/ui/screens/txn_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('loads the next page near the end; day totals cover every row', (tester) async {
    final s = makeState();
    final other = s.catalog.defaultCategory().id;
    final day = DateTime(2026, 10, 20, 12);
    // More rows than one page, all on one day, so the day header total must
    // include rows that aren't loaded yet.
    s.txns.insertAll([
      for (var i = 0; i < txnPageSize + 50; i++)
        Txn(
          type: TxnType.spend,
          amount: 10000,
          categoryId: other,
          sourceId: null,
          occurredAt: day.add(Duration(seconds: i)),
          merchant: 'Row $i',
        ),
    ]);
    await pumpScreen(tester, s, const TransactionsScreen());
    // Out total (card) and the day header both cover all 250 rows.
    expect(find.text('−₹25,000'), findsOneWidget, reason: 'day total of all 250 rows');
    expect(find.text('Row 0'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Row 0'),
      600,
      scrollable: find.descendant(of: find.byKey(const Key('txn-list')), matching: find.byType(Scrollable)),
    );
    expect(find.text('Row 0'), findsOneWidget, reason: 'oldest row is on the second page');
  });

  testWidgets('screen-reader actions edit and delete a row', (tester) async {
    final s = makeState();
    seed(s);
    await pumpRoute(tester, s, const TransactionsScreen());
    final swiggy = s.txns.list(const TxnFilter(search: 'Swiggy')).single.txn.id!;
    Map<CustomSemanticsAction, VoidCallback> actions() => tester.widget<Semantics>(find.byKey(Key('row-actions-$swiggy'))).properties.customSemanticsActions!;
    actions().entries.firstWhere((e) => e.key.label == 'Edit').value();
    await tester.pumpAndSettle();
    expect(find.byType(TxnFormScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    actions().entries.firstWhere((e) => e.key.label == 'Delete').value();
    await tester.pumpAndSettle();
    expect(s.txns.list(const TxnFilter(search: 'Swiggy')), isEmpty);
  });
}
