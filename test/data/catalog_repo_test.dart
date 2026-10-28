import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('categories by kind, defaults and lookups', () {
    final s = makeState();
    expect(s.catalog.categories(kind: CategoryKind.invest).map((c) => c.name).first, 'Fixed deposit');
    expect(s.catalog.categories().length, 16);
    expect(s.catalog.defaultCategory().name, 'Others');
    expect(s.catalog.firstOf(CategoryKind.spend).name, 'Others');
    expect(s.catalog.firstOf(CategoryKind.income).name, 'Salary');
    expect(s.catalog.findCategoryByName(' food & DINING ')!.icon, 'food');
    expect(s.catalog.findCategoryByName('nope'), isNull);
  });

  test('add, rename, archive and reorder categories', () {
    final s = makeState();
    final id = s.catalog.addCategory(name: ' Pets ', kind: CategoryKind.spend, icon: 'heart', color: 0xFF000000);
    expect(s.catalog.category(id).name, 'Pets');
    s.catalog.renameCategory(id, 'Pet care');
    expect(s.catalog.category(id).name, 'Pet care');
    expect(s.catalog.archiveCategory(id), isTrue);
    expect(s.catalog.categories().any((c) => c.id == id), isFalse);
    expect(s.catalog.categories(includeArchived: true).firstWhere((c) => c.id == id).archived, isTrue);
    expect(s.catalog.archiveCategory(s.catalog.defaultCategory().id), isFalse);
    final ids = s.catalog.categories(kind: CategoryKind.invest).map((c) => c.id).toList().reversed.toList();
    s.catalog.reorderCategories(ids);
    expect(s.catalog.categories(kind: CategoryKind.invest).map((c) => c.id).toList(), ids);
  });

  test('sources: add, default, archive and spending', () {
    final s = makeState();
    final ids = seed(s);
    expect(s.catalog.defaultSource()!.id, ids.hdfc);
    expect(s.catalog.sources().first.id, ids.hdfc);
    final card = s.catalog.sources().firstWhere((x) => x.id == ids.card);
    expect([card.kind, card.last4, card.creditLimit, card.isDefault], [SourceKind.card, '07', 15000000, false]);
    s.catalog.setDefaultSource(ids.card);
    expect(s.catalog.defaultSource()!.id, ids.card);
    s.catalog.archiveSource(ids.card);
    expect(s.catalog.defaultSource(), isNotNull);
    expect(s.catalog.sources().any((x) => x.id == ids.card), isFalse);
    expect(s.catalog.sources(includeArchived: true).any((x) => x.id == ids.card && x.archived), isTrue);
    final spent = s.catalog.spentBySource(month(kNow));
    expect(spent[ids.hdfc], 1500000 + 48600 + 5000000 + 1240000);
    expect(spent[ids.card], 31200);
    // archiving a non-default keeps the default
    final before = s.catalog.defaultSource()!.id;
    final extra = s.catalog.addSource(name: 'Wallet', kind: SourceKind.wallet);
    s.catalog.archiveSource(extra);
    expect(s.catalog.defaultSource()!.id, before);
    // restoring keeps the existing default
    s.catalog.restoreSource(extra);
    expect(s.catalog.defaultSource()!.id, before);
    expect(s.catalog.sources().any((x) => x.id == extra), isTrue);
  });

  test('balances: opening balance + money in − money out', () {
    final s = makeState();
    final ids = seed(s);
    final wallet = s.catalog.addSource(name: 'Paytm', kind: SourceKind.wallet, openingBalance: 250000);
    expect(s.catalog.sources().firstWhere((x) => x.id == wallet).openingBalance, 250000);
    final b = s.catalog.balances();
    expect(b[wallet], 250000);
    expect(b[ids.hdfc], s.txns.list(TxnFilter(sourceIds: {ids.hdfc})).fold<int>(0, (sum, t) => sum + t.signedAmount));
    expect(b[ids.card], -31200);
    s.catalog.setOpeningBalance(ids.card, -100000);
    expect(s.catalog.balances()[ids.card], -131200);
  });

  test('archiving the only source leaves no default', () {
    final s = makeState();
    s.catalog.archiveSource(s.catalog.defaultSource()!.id);
    expect(s.catalog.defaultSource(), isNull);
    // restoring it makes it the default again
    final cash = s.catalog.sources(includeArchived: true).single;
    s.catalog.restoreSource(cash.id);
    expect(s.catalog.defaultSource()!.id, cash.id);
    expect(s.catalog.sources().single.archived, isFalse);
  });
}
