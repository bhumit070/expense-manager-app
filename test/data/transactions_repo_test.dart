import 'package:expense_manager/core/dates.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late final s = makeState();
  late final ids = seed(s);

  setUpAll(() => ids);

  test('ftsQuery tokenizes into prefix terms', () {
    expect(ftsQuery('Team din'), '"team"* "din"*');
    expect(ftsQuery('#work'), '"work"*');
    expect(ftsQuery('  ,. '), isNull);
  });

  test('ftsQuery can restrict words to columns', () {
    expect(ftsQuery('team din', columns: ['merchant']), 'merchant : "team"* merchant : "din"*');
    expect(ftsQuery('work', columns: ['note', 'tags']), '{note tags} : "work"*');
    expect(searchWords(' Team, #Din '), ['team', 'din']);
  });

  test('search scopes and sort orders', () {
    List<String> find(String q, SearchScope scope) => s.txns.list(TxnFilter(search: q, scope: scope)).map((e) => e.txn.merchant).toList();
    expect(find('dinner', SearchScope.all), containsAll(['Swiggy', 'Toit']));
    expect(find('dinner', SearchScope.notes), containsAll(['Swiggy', 'Toit']));
    expect(find('work', SearchScope.notes), ['Swiggy']); // #tag
    expect(find('dinner', SearchScope.merchant), isEmpty);
    expect(find('swig', SearchScope.merchant), ['Swiggy']);
    expect(find('indira', SearchScope.place), ['Swiggy']);
    expect(find('swiggy', SearchScope.place), isEmpty);
    expect(find('486', SearchScope.amount), ['Swiggy']);
    expect(find('₹4,200', SearchScope.amount), ['Toit']);
    expect(find('abc', SearchScope.amount), isEmpty);
    expect(s.txns.list(const TxnFilter(scope: SearchScope.amount)).length, s.txns.list(const TxnFilter()).length);
    expect(find('486', SearchScope.notes), isEmpty); // amount only matches in All / Amount

    final all = s.txns.list(const TxnFilter());
    final oldest = s.txns.list(const TxnFilter(sort: TxnSort.oldest));
    expect(oldest.map((e) => e.txn.id), all.reversed.map((e) => e.txn.id));
    final high = s.txns.list(const TxnFilter(sort: TxnSort.amountDesc)).map((e) => e.txn.amount).toList();
    expect(high, [...high]..sort((a, b) => b.compareTo(a)));
    final low = s.txns.list(const TxnFilter(sort: TxnSort.amountAsc)).map((e) => e.txn.amount).toList();
    expect(low, [...low]..sort());
    final f = const TxnFilter().copyWith(scope: SearchScope.place, sort: TxnSort.oldest);
    expect([f.scope, f.sort, f.copyWith().scope, f.copyWith().sort], [SearchScope.place, TxnSort.oldest, SearchScope.place, TxnSort.oldest]);
  });

  test('TxnFilter.activeCount and copyWith', () {
    const f = TxnFilter();
    expect(f.activeCount, 0);
    final g = f.copyWith(types: {TxnType.spend}, categoryIds: {1}, sourceIds: {2}, minAmount: () => 5, search: 'x');
    expect(g.activeCount, 4);
    expect(g.copyWith(maxAmount: () => 9).maxAmount, 9);
    expect(g.copyWith(minAmount: () => null).minAmount, isNull);
    expect(g.copyWith().search, 'x');
    final from = DateTime(2026), to = DateTime(2027);
    final h = f.copyWith(from: from, to: to);
    expect([h.from, h.to], [from, to]);
    expect(const TxnFilter(maxAmount: 1).activeCount, 1);
  });

  test('inflow is derived from type and debt direction', () {
    final all = s.txns.list(const TxnFilter());
    bool inflow(String m) => all.firstWhere((v) => v.txn.merchant == m).inflow;
    expect(inflow('Salary'), isTrue);
    expect(inflow('Rahul paid back'), isTrue);
    expect(inflow('Car EMI'), isFalse);
    expect(inflow('Swiggy'), isFalse);
    // a debt payment must reference an existing debt
    expect(() => s.txns.insert(Txn(type: TxnType.debt, amount: 1, categoryId: 1, sourceId: null, occurredAt: DateTime(2020), debtId: 9999)), throwsA(isA<StateError>()));
  });

  test('list orders newest first and joins display data', () {
    final rows = s.txns.list(TxnFilter(from: month(kNow).start, to: month(kNow).end));
    expect(rows.first.txn.merchant, 'Swiggy');
    expect(rows.first.category.name, 'Food & dining');
    expect(rows.first.source!.display, 'HDFC Savings ••42');
    expect(rows.first.txn.tags, ['#work', '#split']);
    expect(rows.first.txn.place, 'Indiranagar');
    expect(rows.length, 7);
    expect(s.txns.list(const TxnFilter(), limit: 2, offset: 1).length, 2);
  });

  test('filters: type, category, source, amount, investment, debt', () {
    expect(s.txns.list(const TxnFilter(types: {TxnType.invest})).length, 2);
    expect(s.txns.list(TxnFilter(categoryIds: {catId(s, 'Food & dining')})).length, 2);
    expect(s.txns.list(TxnFilter(sourceIds: {ids.card})).single.txn.merchant, 'Uber');
    expect(s.txns.list(const TxnFilter(minAmount: 1000000, maxAmount: 1500000)).map((e) => e.txn.amount).toSet(), {1000000, 1240000, 1500000});
    expect(s.txns.list(TxnFilter(investmentId: ids.fd)).single.txn.amount, 5000000);
    expect(s.txns.list(TxnFilter(debtId: ids.loan)).single.txn.merchant, 'Car EMI');
  });

  test('full-text search over merchant, note, tags and place, plus amount', () {
    List<String> find(String q) => s.txns.list(TxnFilter(search: q)).map((e) => e.txn.merchant).toList();
    expect(find('dinner'), ['Swiggy', 'Toit']);
    expect(find('#split'), ['Swiggy']);
    expect(find('indira'), ['Swiggy']);
    expect(find('ube'), ['Uber']);
    expect(find('486'), ['Swiggy']);
    expect(find('nothing-matches'), isEmpty);
    expect(find('  '), hasLength(9));
  });

  test('update keeps FTS in sync; delete/restore/purge', () {
    final id = s.txns.list(const TxnFilter(search: 'uber')).single.txn.id!;
    final v = s.txns.byId(id)!;
    s.txns.update(Txn(id: id, type: TxnType.spend, amount: v.txn.amount, categoryId: v.txn.categoryId, sourceId: v.txn.sourceId, occurredAt: v.txn.occurredAt, merchant: 'Ola', place: '  '));
    expect(s.txns.list(const TxnFilter(search: 'uber')), isEmpty);
    expect(s.txns.list(const TxnFilter(search: 'ola')).single.txn.place, isNull);
    s.txns.delete(id);
    expect(s.txns.byId(id), isNull);
    s.txns.restore(id);
    expect(s.txns.byId(id), isNotNull);
    final tmp = s.txns.insert(Txn(type: TxnType.spend, amount: 5, categoryId: 1, sourceId: null, occurredAt: DateTime(2020)));
    s.txns.delete(tmp);
    s.txns.purgeDeleted();
    expect(s.db.select('SELECT count(*) AS n FROM transactions WHERE id = ?', [tmp]).single['n'], 0);
    expect(s.txns.list(const TxnFilter(search: 'zzz')), isEmpty);
  });

  test('totals and per-category / per-bucket aggregates', () {
    final t = s.txns.totalsIn(month(kNow));
    expect(t.spend, 1500000 + 48600 + 31200);
    expect(t.invest, 5000000);
    expect(t.income, 11000000);
    expect(t.debtOut, 1240000);
    expect(t.debtIn, 250000);
    expect(t.count, 7);

    final cats = s.txns.byCategory(month(kNow), TxnType.spend);
    expect(cats.first.category.name, 'Rent');
    expect(cats.map((c) => c.count).reduce((a, b) => a + b), 3);

    final weeks = s.txns.buckets(month(kNow));
    expect(weeks.first.start, DateTime(2026, 9, 28));
    expect(weeks.length, 5);
    expect(weeks.last.spend, 48600 + 31200);
    expect(weeks.last.invest, 5000000);

    final months = s.txns.buckets(Period.of(PeriodKind.year, kNow));
    expect(months.length, 12);
    expect(months[8].invest, 1000000);

    final days = s.txns.buckets(Period.of(PeriodKind.week, kNow));
    expect(days.length, 7);
    expect(days[2].spend, 48600);
  });

  test('spentIn for spend and invest', () {
    expect(s.txns.spentIn(month(kNow), categoryIds: [catId(s, 'Food & dining')]), 48600);
    expect(s.txns.spentIn(month(kNow), type: TxnType.invest), 5000000);
  });

  test('duplicate detection matches day, amount and merchant', () {
    expect(s.txns.isDuplicate(Txn(type: TxnType.spend, amount: 48600, categoryId: 1, sourceId: null, occurredAt: DateTime(2026, 10, 28, 8), merchant: ' swiggy ')), isTrue);
    expect(s.txns.isDuplicate(Txn(type: TxnType.spend, amount: 48600, categoryId: 1, sourceId: null, occurredAt: DateTime(2026, 10, 29), merchant: 'Swiggy')), isFalse);
  });

  test('insertAll and tags ranking', () {
    final n = s.txns.insertAll([
      for (var i = 0; i < 3; i++) Txn(type: TxnType.spend, amount: 100 + i, categoryId: 1, sourceId: null, occurredAt: DateTime(2025, 1, i + 1), tags: const ['#work']),
    ]);
    expect(n, 3);
    expect(s.txns.tags(), ['#work', '#split']);
  });
}
