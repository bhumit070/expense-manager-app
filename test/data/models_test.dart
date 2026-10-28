import 'package:expense_manager/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('enumByName', () {
    expect(enumByName(TxnType.values, 'invest'), TxnType.invest);
    expect(() => enumByName(TxnType.values, 'x'), throwsStateError);
  });

  test('PaymentSource.display', () {
    expect(const PaymentSource(id: 1, name: 'Cash', kind: SourceKind.cash).display, 'Cash');
    expect(const PaymentSource(id: 1, name: 'HDFC', kind: SourceKind.bank, last4: '').display, 'HDFC');
    expect(const PaymentSource(id: 1, name: 'HDFC', kind: SourceKind.bank, last4: '42').display, 'HDFC ••42');
  });

  test('Txn.titleOr and copyWith', () {
    final t = Txn(type: TxnType.spend, amount: 100, categoryId: 1, sourceId: null, occurredAt: DateTime(2026), note: 'lunch');
    expect(t.titleOr('Food'), 'lunch');
    expect(Txn(type: TxnType.spend, amount: 1, categoryId: 1, sourceId: null, occurredAt: DateTime(2026)).titleOr('Food'), 'Food');
    final c = Txn(
      type: TxnType.spend,
      amount: 1,
      categoryId: 1,
      sourceId: 2,
      occurredAt: DateTime(2026),
      merchant: 'Uber',
      tags: const ['#a'],
      place: 'X',
      lat: 1,
      lng: 2,
      investmentId: 3,
      debtId: 4,
      receipt: '/r.jpg',
      recurringId: 7,
    ).copyWith(id: 9, occurredAt: DateTime(2027));
    expect([c.receipt, c.recurringId, c.amount], ['/r.jpg', 7, 1]);
    final d = c.copyWith(amount: 5, receipt: () => null, recurringId: () => null);
    expect([d.receipt, d.recurringId, d.amount], [null, null, 5]);
    expect(c.id, 9);
    expect(c.occurredAt, DateTime(2027));
    expect(c.titleOr(''), 'Uber');
    expect(
      [c.sourceId, c.tags, c.place, c.lat, c.lng, c.investmentId, c.debtId],
      [
        2,
        ['#a'],
        'X',
        1,
        2,
        3,
        4,
      ],
    );
    final same = c.copyWith();
    expect(same.id, 9);
  });

  test('BudgetProgress math', () {
    const b = Budget(name: 'Food', period: BudgetPeriod.monthly, limit: 1000);
    const p = BudgetProgress(budget: b, used: 850, limit: 1000, daysLeft: 3, elapsed: 0.9);
    expect(p.fraction, 0.85);
    expect(p.remaining, 150);
    expect(p.isOver, isFalse);
    expect(p.isNear, isTrue);
    expect(p.aheadOfPace, isFalse);
    expect(p.perDayLeft, 50);
    const over = BudgetProgress(budget: b, used: 1200, limit: 1000, daysLeft: 3, elapsed: 0.5);
    expect(over.isOver, isTrue);
    expect(over.isNear, isFalse);
    expect(over.aheadOfPace, isTrue);
    expect(over.perDayLeft, 0);
    expect(const BudgetProgress(budget: b, used: 1, limit: 0, daysLeft: 0, elapsed: 1).fraction, 0);
    expect(const BudgetProgress(budget: b, used: 1, limit: 10, daysLeft: 0, elapsed: 1).perDayLeft, 0);
    const goal = Budget(name: 'SIP', period: BudgetPeriod.monthly, limit: 1000, isGoal: true);
    expect(const BudgetProgress(budget: goal, used: 2000, limit: 1000, daysLeft: 1, elapsed: 1).isOver, isFalse);
  });

  test('DebtStatus math', () {
    const d = Debt(direction: DebtDirection.iOwe, kind: DebtKind.loan, name: 'L', principal: 1000);
    expect(const DebtStatus(debt: d, paid: 250, payments: 1).remaining, 750);
    expect(const DebtStatus(debt: d, paid: 250, payments: 1).fraction, 0.25);
    expect(const DebtStatus(debt: d, paid: 5000, payments: 2).remaining, 0);
    expect(const DebtStatus(debt: d, paid: 5000, payments: 2).fraction, 1);
    const zero = Debt(direction: DebtDirection.iOwe, kind: DebtKind.loan, name: 'Z', principal: 0);
    expect(const DebtStatus(debt: zero, paid: 0, payments: 0).fraction, 1);
  });

  test('Totals math', () {
    const t = Totals(spend: 300, invest: 200, income: 1000, debtOut: 100, debtIn: 50, count: 5);
    expect(t.moneyOut, 500);
    expect(t.allOut, 600);
    expect(t.allIn, 1050);
    expect(t.left, 400);
    expect(t.savingsRate, 0.6);
    expect(const Totals().savingsRate, 0);
    expect(const Totals(spend: 2000, income: 1000).savingsRate, 0);
  });
}
