import 'package:expense_manager/core/dates.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/services/csv.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('sub-categories: tree order, kind from parent, one level only', () {
    final s = makeState();
    final food = catId(s, 'Food & dining');
    final groceries = s.catalog.addCategory(name: 'Groceries', kind: CategoryKind.income, icon: 'cart', color: 1, parentId: food);
    final coffee = s.catalog.addCategory(name: 'Coffee', kind: CategoryKind.spend, icon: 'food', color: 2, parentId: food);
    final g = s.catalog.category(groceries);
    expect([g.kind, g.parentId, g.isChild], [CategoryKind.spend, food, true]);
    expect(s.catalog.category(food).isChild, isFalse);
    final spend = s.catalog.categories(kind: CategoryKind.spend).map((c) => c.id).toList();
    expect(spend.sublist(spend.indexOf(food), spend.indexOf(food) + 3), [food, groceries, coffee]);
    expect(s.catalog.children(food).map((c) => c.name), ['Groceries', 'Coffee']);
    expect(s.catalog.parents(CategoryKind.spend).any((c) => c.isChild), isFalse);
    expect(() => s.catalog.addCategory(name: 'Deep', kind: CategoryKind.spend, icon: 'grid', color: 0, parentId: groceries), throwsArgumentError);
    // lookups prefer top-level; scoped lookups find the child
    final other = s.catalog.addCategory(name: 'Coffee', kind: CategoryKind.spend, icon: 'grid', color: 0);
    expect(s.catalog.findCategoryByName('coffee')!.id, other);
    expect(s.catalog.findCategoryByName('coffee', parentId: food)!.id, coffee);
    // a child whose parent is archived (but itself is not) shows as top-level
    s.db.execute('UPDATE categories SET archived = 1 WHERE id = ?', [food]);
    expect(s.catalog.categories(kind: CategoryKind.spend).where((c) => c.id == groceries).length, 1);
  });

  test('setParent rules and archiving cascades to children', () {
    final s = makeState();
    final food = catId(s, 'Food & dining');
    final travel = catId(s, 'Travel');
    final rent = catId(s, 'Rent');
    final others = s.catalog.defaultCategory().id;
    final coffee = s.catalog.addCategory(name: 'Coffee', kind: CategoryKind.spend, icon: 'food', color: 2, parentId: food);
    expect(s.catalog.setParent(others, food), isFalse, reason: 'Others stays top-level');
    expect(s.catalog.setParent(food, food), isFalse);
    expect(s.catalog.setParent(rent, coffee), isFalse, reason: 'no grandchildren');
    expect(s.catalog.setParent(rent, catId(s, 'Salary')), isFalse, reason: 'same kind only');
    expect(s.catalog.setParent(food, travel), isFalse, reason: 'a parent with children cannot become a child');
    expect(s.catalog.setParent(rent, travel), isTrue);
    expect(s.catalog.category(rent).parentId, travel);
    expect(s.catalog.setParent(coffee, null), isTrue);
    expect(s.catalog.category(coffee).isChild, isFalse);
    expect(s.catalog.archiveCategory(travel), isTrue);
    expect(s.catalog.category(rent).archived, isTrue);
  });

  test('aggregates, filters and budgets roll sub-categories into the parent', () {
    final s = makeState();
    seed(s);
    final food = catId(s, 'Food & dining');
    final coffee = s.catalog.addCategory(name: 'Coffee', kind: CategoryKind.spend, icon: 'food', color: 2, parentId: food);
    s.txns.insert(Txn(type: TxnType.spend, amount: 25000, categoryId: coffee, sourceId: null, occurredAt: DateTime(2026, 10, 20, 9), merchant: 'Third Wave'));
    final month = Period.of(PeriodKind.month, kNow);
    final top = s.txns.byCategory(month, TxnType.spend);
    final foodRow = top.firstWhere((c) => c.category.id == food);
    expect([foodRow.total, foodRow.count, foodRow.subCount], [48600 + 25000, 2, 1]);
    expect(top.any((c) => c.category.id == coffee), isFalse);
    expect(top.firstWhere((c) => c.category.name == 'Rent').subCount, 0);
    final split = s.txns.byCategory(month, TxnType.spend, parentId: food);
    expect({for (final c in split) c.category.id: c.total}, {food: 48600, coffee: 25000});

    final list = s.txns.list(TxnFilter(categoryIds: {food}, from: month.start, to: month.end));
    expect(list.map((t) => t.txn.merchant), containsAll(['Swiggy', 'Third Wave']));
    final view = list.firstWhere((t) => t.txn.merchant == 'Third Wave');
    expect([view.category.parentId, view.parentName, view.categoryPath], [food, 'Food & dining', 'Food & dining / Coffee']);
    expect(list.firstWhere((t) => t.txn.merchant == 'Swiggy').categoryPath, 'Food & dining');
    expect(s.txns.list(TxnFilter(categoryIds: {coffee})).single.txn.merchant, 'Third Wave');

    final budget = Budget(name: 'Food', period: BudgetPeriod.monthly, limit: 1000000, categoryIds: [food]);
    expect(s.planning.progress(budget, kNow).used, 48600 + 25000);
  });

  test('CSV: exports Parent / Child and imports it, creating missing sub-categories once', () {
    final s = makeState();
    final food = catId(s, 'Food & dining');
    final coffee = s.catalog.addCategory(name: 'Coffee', kind: CategoryKind.spend, icon: 'food', color: 2, parentId: food);
    s.txns.insert(Txn(type: TxnType.spend, amount: 25000, categoryId: coffee, sourceId: null, occurredAt: DateTime(2026, 10, 20, 9), merchant: 'Third Wave'));
    final csv = encodeCsv(s.txns.list(const TxnFilter()));
    expect(csv, contains('Food & dining / Coffee'));

    final rows = buildImport(
      parseCsv(
        'date,amount,category,merchant\n'
        '2026-10-01,100,Food & dining / Coffee,A\n'
        '2026-10-02,200,Food & dining / Snacks,B\n'
        '2026-10-03,300,food & dining/snacks,C\n'
        '2026-10-04,400,Nowhere / Thing,D\n'
        '2026-10-05,500,Coffee / Beans,E\n'
        '2026-10-06,600,Rent,F\n',
      ),
      s.catalog,
      s.txns,
    );
    expect(rows[0].txn!.categoryId, coffee);
    expect(rows[0].newSubcategory, isNull);
    expect([rows[1].txn!.categoryId, rows[1].newSubcategory], [food, 'Snacks']);
    expect([rows[2].txn!.categoryId, rows[2].newSubcategory], [food, 'snacks']);
    expect([rows[3].needsReview, rows[3].txn!.categoryId], [true, s.catalog.defaultCategory().id]);
    // "Coffee" resolves to the existing sub-category, which can't take children
    expect([rows[4].txn!.categoryId, rows[4].newSubcategory], [coffee, null]);
    expect(rows[5].txn!.categoryId, catId(s, 'Rent'));

    final txns = resolveImport(rows, s.catalog);
    final snacks = s.catalog.findCategoryByName('Snacks', parentId: food)!;
    expect([txns[1].categoryId, txns[2].categoryId], [snacks.id, snacks.id]);
    expect(s.catalog.children(food).where((c) => c.name.toLowerCase() == 'snacks').length, 1);
    expect([snacks.kind, snacks.icon, snacks.color], [CategoryKind.spend, s.catalog.category(food).icon, s.catalog.category(food).color]);
    expect(txns[0].categoryId, coffee);
  });
}
