import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/services/csv.dart';
import 'package:expense_manager/ui/screens/budgets_screen.dart';
import 'package:expense_manager/ui/screens/categories_screen.dart';
import 'package:expense_manager/ui/screens/import_screen.dart';
import 'package:expense_manager/ui/screens/insights_screen.dart';
import 'package:expense_manager/ui/screens/transactions_screen.dart';
import 'package:expense_manager/ui/screens/txn_form_screen.dart';
import 'package:expense_manager/ui/widgets/category_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Future<void> _menu(WidgetTester tester, int id, String item) async {
  await tester.tap(find.byKey(Key('cat-menu-$id')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item));
  await tester.pumpAndSettle();
}

void main() {
  test('categoryLabel', () {
    const parent = Category(id: 1, name: 'Food', kind: CategoryKind.spend, icon: 'food', color: 0);
    const child = Category(id: 2, name: 'Coffee', kind: CategoryKind.spend, icon: 'food', color: 0, parentId: 1);
    const orphan = Category(id: 3, name: 'Lost', kind: CategoryKind.spend, icon: 'food', color: 0, parentId: 9);
    expect(categoryLabel(parent, [parent, child]), 'Food');
    expect(categoryLabel(child, [parent, child]), 'Food › Coffee');
    expect(categoryLabel(orphan, [parent]), 'Lost');
  });

  group('Categories screen', () {
    testWidgets('add a sub-category, move it, move a top-level under a parent, reorder children', (tester) async {
      final s = makeState();
      final food = catId(s, 'Food & dining');
      final rent = catId(s, 'Rent');
      final travel = catId(s, 'Travel');
      await pumpRoute(tester, s, const CategoriesScreen());

      await _menu(tester, food, 'Add sub-category');
      expect(find.text('New sub-category in Food & dining'), findsOneWidget);
      expect(find.text('Invest'), findsNothing, reason: 'kind comes from the parent');
      await tester.enterText(find.byKey(const Key('cat-name')), 'Coffee');
      await tester.tap(find.byKey(const Key('cat-save')));
      await tester.pumpAndSettle();
      final coffee = s.catalog.findCategoryByName('Coffee')!;
      expect([coffee.parentId, coffee.kind, coffee.icon], [food, CategoryKind.spend, 'food']);
      expect(find.byKey(Key('reorder-sub-$food')), findsOneWidget);

      // A parent with children can't be moved; a plain one can.
      await tester.tap(find.byKey(Key('cat-menu-$food')));
      await tester.pumpAndSettle();
      expect(find.text('Move under…'), findsNothing);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await _menu(tester, rent, 'Move under…');
      expect(find.byKey(const Key('move-top')), findsNothing);
      await tester.tap(find.byKey(Key('move-to-$travel')));
      await tester.pumpAndSettle();
      expect(s.catalog.category(rent).parentId, travel);

      // Child: move back to top level; cancel first.
      await _menu(tester, rent, 'Move…');
      expect(find.byKey(Key('move-to-$travel')), findsNothing, reason: 'current parent is not offered');
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(s.catalog.category(rent).parentId, travel);
      await _menu(tester, rent, 'Move…');
      await tester.tap(find.byKey(const Key('move-top')));
      await tester.pumpAndSettle();
      expect(s.catalog.category(rent).isChild, isFalse);

      // Reorder within a parent.
      final tea = s.catalog.addCategory(name: 'Tea', kind: CategoryKind.spend, icon: 'food', color: 0, parentId: food);
      s.changed();
      await tester.pumpAndSettle();
      final handle = find.descendant(of: find.byKey(ValueKey(coffee.id)), matching: find.byIcon(Icons.drag_handle));
      await tester.drag(handle, const Offset(0, 120));
      await tester.pumpAndSettle();
      expect(s.catalog.children(food).map((c) => c.id), [tea, coffee.id]);

      // Archiving the parent hides its children.
      await tester.tap(find.byKey(Key('archive-$food')));
      await tester.pumpAndSettle();
      expect(find.text('Coffee'), findsNothing);
      expect(s.catalog.category(tea).archived, isTrue);
    });

    testWidgets('a move that becomes invalid shows a message', (tester) async {
      final s = makeState();
      final rent = catId(s, 'Rent');
      final travel = catId(s, 'Travel');
      await pumpRoute(tester, s, CategoriesScreen(key: UniqueKey()));
      await _menu(tester, rent, 'Move under…');
      s.catalog.addCategory(name: 'Deposit', kind: CategoryKind.spend, icon: 'grid', color: 0, parentId: rent);
      await tester.tap(find.byKey(Key('move-to-$travel')));
      await tester.pumpAndSettle();
      expect(find.text('Only categories without sub-categories can be moved under another'), findsOneWidget);
      expect(s.catalog.category(rent).isChild, isFalse);
    });
  });

  testWidgets('form picker: parent tiles, then sub-category chips', (tester) async {
    final s = makeState()..locationEnabled = false;
    final food = catId(s, 'Food & dining');
    final coffee = s.catalog.addCategory(name: 'Coffee', kind: CategoryKind.spend, icon: 'food', color: 2, parentId: food);
    await pumpRoute(tester, s, const TxnFormScreen());
    expect(find.byKey(Key('cat-$coffee')), findsNothing);
    expect(find.byKey(const Key('sub-categories')), findsNothing);
    await tester.tap(find.byKey(Key('cat-$food')));
    await tester.pump();
    expect(find.text('All Food & dining'), findsOneWidget);
    await tester.tap(find.byKey(Key('sub-$coffee')));
    await tester.pump();
    await tester.tap(find.text('All Food & dining'));
    await tester.pump();
    await tester.tap(find.byKey(Key('sub-$coffee')));
    await tester.pump();
    await typeAmount(tester, '180');
    await tester.tap(find.byKey(const Key('save-txn')));
    await tester.pumpAndSettle();
    expect(s.txns.list(const TxnFilter()).single.txn.categoryId, coffee);
  });

  testWidgets('insights: parent row expands into its sub-category split', (tester) async {
    final s = makeState();
    seed(s);
    final food = catId(s, 'Food & dining');
    final coffee = s.catalog.addCategory(name: 'Coffee', kind: CategoryKind.spend, icon: 'food', color: 2, parentId: food);
    s.txns.insert(Txn(type: TxnType.spend, amount: 25000, categoryId: coffee, sourceId: null, occurredAt: DateTime(2026, 10, 20, 9), merchant: 'Third Wave'));
    await pumpScreen(tester, s, inScaffold(const InsightsScreen()));
    expect(find.text('Food & dining  ·  2 txns'), findsOneWidget);
    expect(find.byKey(Key('expand-cat-${catId(s, 'Rent')}')), findsNothing);
    await tester.tap(find.byKey(Key('expand-cat-$food')));
    await tester.pump();
    expect(find.text('Food & dining (direct)  ·  1 txn'), findsOneWidget);
    expect(find.text('Coffee  ·  1 txn'), findsOneWidget);
    await tester.tap(find.byKey(Key('cat-row-$coffee')));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);
    expect(find.text('Third Wave'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('expand-cat-$food')));
    await tester.pump();
    expect(find.text('Coffee  ·  1 txn'), findsNothing);
  });

  testWidgets('filter sheet and budget form label sub-categories with their parent', (tester) async {
    final s = makeState();
    final food = catId(s, 'Food & dining');
    s.catalog.addCategory(name: 'Coffee', kind: CategoryKind.spend, icon: 'food', color: 2, parentId: food);
    await pumpRoute(tester, s, const BudgetFormScreen());
    expect(find.text('Food & dining › Coffee'), findsOneWidget);

    await pumpScreen(tester, s, inScaffold(const TransactionsScreen()));
    expect(find.descendant(of: find.byKey(const Key('category-chips')), matching: find.text('Coffee')), findsNothing);
    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('category-search')), 'dining › cof');
    await tester.pump();
    expect(find.text('Food & dining › Coffee'), findsOneWidget);
    expect(find.text('Rent'), findsNothing);
  });

  testWidgets('import preview flags new sub-categories and creates them', (tester) async {
    final s = makeState();
    final food = catId(s, 'Food & dining');
    await pumpRoute(tester, s, const ImportScreen(csvText: 'date,amount,category,merchant\n2026-10-01,100,Food & dining / Snacks,A\n2026-10-02,50,Food & dining / Snacks,B\n'));
    expect(find.textContaining('New sub-category: Snacks'), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('do-import')));
    await tester.pumpAndSettle();
    final snacks = s.catalog.findCategoryByName('Snacks', parentId: food)!;
    expect(s.txns.list(const TxnFilter()).map((t) => t.txn.categoryId), [snacks.id, snacks.id]);
    expect(resolveImport(const [], s.catalog), isEmpty);
  });
}
