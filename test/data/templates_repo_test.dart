import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/templates_repo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('add, list and delete templates', () {
    final s = makeState();
    final b = s.templates.add(const TxnTemplate(name: ' Rent ', type: TxnType.spend, amount: 1500000, categoryId: 2, sourceId: 1, merchant: ' Landlord ', note: 'flat', tags: ['#home']));
    s.templates.add(const TxnTemplate(name: 'auto', type: TxnType.spend, amount: 9000, categoryId: 1));
    final list = s.templates.list();
    expect(list.map((t) => t.name), ['auto', 'Rent']);
    final rent = list.last;
    expect(
      [rent.id, rent.merchant, rent.note, rent.tags, rent.sourceId, rent.type],
      [
        b,
        'Landlord',
        'flat',
        ['#home'],
        1,
        TxnType.spend,
      ],
    );
    expect(list.first.tags, isEmpty);
    s.templates.delete(b);
    expect(s.templates.list().single.name, 'auto');
  });

  test('frequent merchants: used twice recently, latest values, templates excluded', () {
    final s = makeState();
    void add(String m, int amount, DateTime at) => s.txns.insert(Txn(type: TxnType.spend, amount: amount, categoryId: 1, sourceId: 1, occurredAt: at, merchant: m, tags: const ['#x']));
    add('Chai Point', 2000, DateTime(2026, 10, 1));
    add('chai point', 2500, DateTime(2026, 10, 20));
    add('Uber', 100, DateTime(2026, 10, 2));
    add('Uber', 200, DateTime(2026, 10, 3));
    add('Uber', 300, DateTime(2026, 10, 4));
    add('Once', 1, DateTime(2026, 10, 4));
    add('Old', 1, DateTime(2026, 1, 4));
    add('Old', 1, DateTime(2026, 1, 5));
    add('Rent', 1, DateTime(2026, 10, 5));
    add('Rent', 1, DateTime(2026, 10, 6));
    s.templates.add(const TxnTemplate(name: 'Rent', type: TxnType.spend, amount: 1, categoryId: 1, merchant: 'rent'));
    final f = s.templates.frequent(kNow);
    expect(f.map((t) => (t.name, t.amount, t.id)), [('Uber', 300, null), ('chai point', 2500, null)]);
    expect(f.first.tags, ['#x']);
    expect(s.templates.frequent(kNow, limit: 1).length, 1);
  });
}
