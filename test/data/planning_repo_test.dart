import 'package:expense_manager/core/dates.dart';
import 'package:expense_manager/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('budgets', () {
    test('CRUD and filtering by period', () {
      final s = makeState();
      final id = s.planning.addBudget(const Budget(name: ' Food ', period: BudgetPeriod.monthly, limit: 100, categoryIds: [1, 2], rollover: true, alert80: false, alert100: false));
      s.planning.addBudget(const Budget(name: 'Weekly', period: BudgetPeriod.weekly, limit: 50));
      final b = s.planning.budgets(period: BudgetPeriod.monthly).single;
      expect(
        [b.name, b.categoryIds, b.rollover, b.alert80, b.alert100, b.isGoal],
        [
          'Food',
          [1, 2],
          true,
          false,
          false,
          false,
        ],
      );
      expect(s.planning.budgets().length, 2);
      s.planning.updateBudget(Budget(id: id, name: 'Food+', period: BudgetPeriod.weekly, limit: 200, isGoal: true));
      expect(s.planning.budgets(period: BudgetPeriod.weekly).map((e) => e.name), ['Weekly', 'Food+']);
      s.planning.deleteBudget(id);
      expect(s.planning.budgets().length, 1);
    });

    test('progress per cycle with categories, rollover and goals', () {
      final s = makeState();
      seed(s);
      final food = catId(s, 'Food & dining');
      final monthly = Budget(id: 1, name: 'Food', period: BudgetPeriod.monthly, limit: 1000000, categoryIds: [food]);
      final p = s.planning.progress(monthly, kNow);
      expect(p.used, 48600);
      expect(p.limit, 1000000);
      expect(p.daysLeft, 4);

      // September food spend 4200 of 10000 → 5800 rolls over
      final roll = Budget(name: 'Food', period: BudgetPeriod.monthly, limit: 1000000, categoryIds: [food], rollover: true);
      expect(s.planning.progress(roll, kNow).limit, 1000000 + 1000000 - 420000);
      // overspent previous cycle adds nothing
      final tight = Budget(name: 'Food', period: BudgetPeriod.monthly, limit: 100000, categoryIds: [food], rollover: true);
      expect(s.planning.progress(tight, kNow).limit, 100000);

      final weekly = s.planning.progress(const Budget(name: 'All', period: BudgetPeriod.weekly, limit: 500000), kNow);
      expect(weekly.used, 48600 + 31200);
      expect(s.planning.cycleFor(const Budget(name: '', period: BudgetPeriod.weekly, limit: 1), kNow).start, DateTime(2026, 10, 26));

      final goal = s.planning.progress(const Budget(name: 'Invest', period: BudgetPeriod.monthly, limit: 2500000, isGoal: true, rollover: true), kNow);
      expect(goal.used, 5000000);
      expect(goal.limit, 2500000);
    });

    test('suggested limit averages the previous 3 months', () {
      final s = makeState();
      seed(s);
      expect(s.planning.suggestedLimit([catId(s, 'Food & dining')], kNow), 420000 ~/ 3);
      expect(s.planning.suggestedLimit([], DateTime(2020)), 0);
    });
  });

  group('investments', () {
    test('holdings track invested amounts only', () {
      final s = makeState();
      final ids = seed(s);
      final h = s.planning.holdings();
      expect(h.map((e) => e.investment.name), ['HDFC FD', 'Nifty 50 Index']);
      expect(h.first.invested, 5000000);
      expect(h.first.entries, 1);
      expect(h.first.investment.rate, 7.1);
      expect(h.first.investment.institution, 'HDFC Bank');
      expect(s.planning.investment(ids.fd).maturityAt, DateTime(2026, 11, 12));

      s.planning.setInvestmentStatus(ids.sip, InvestmentStatus.closed);
      expect(s.planning.holdings().length, 1);
      expect(s.planning.holdings(activeOnly: false).length, 2);

      s.planning.updateInvestment(Investment(id: ids.fd, kind: InvestmentKind.fd, name: 'HDFC FD 2', note: 'renewed'));
      final fd = s.planning.investment(ids.fd);
      expect([fd.name, fd.note, fd.rate, fd.maturityAt], ['HDFC FD 2', 'renewed', null, null]);
    });

    test('maturingSoon window', () {
      final s = makeState();
      seed(s);
      expect(s.planning.maturingSoon(kNow).single.name, 'HDFC FD');
      expect(s.planning.maturingSoon(kNow, days: 7), isEmpty);
      expect(s.planning.maturingSoon(DateTime(2026, 12)), isEmpty);
    });
  });

  group('debts', () {
    test('status, summary and settling', () {
      final s = makeState();
      final ids = seed(s);
      final owe = s.planning.debts(direction: DebtDirection.iOwe).single;
      expect(owe.paid, 1240000);
      expect(owe.payments, 1);
      expect(owe.remaining, 42000000 - 1240000);
      expect(owe.debt.totalEmis, 36);
      expect(s.planning.debt(ids.lent).counterparty, '');
      final sum = s.planning.debtSummary();
      expect(sum.owe, 42000000 - 1240000);
      expect(sum.owed, 850000 - 250000);
      expect(sum.monthlyEmi, 1240000);

      s.planning.setDebtSettled(ids.lent, true);
      expect(s.planning.debts(settled: true).single.debt.settled, isTrue);
      expect(s.planning.debts().length, 1);
      s.planning.setDebtSettled(ids.lent, false);
      expect(s.planning.debts().length, 2);
    });

    test('debt without EMI adds nothing to monthly EMI', () {
      final s = makeState();
      s.planning.addDebt(const Debt(direction: DebtDirection.iOwe, kind: DebtKind.personal, name: 'Dad', principal: 100));
      expect(s.planning.debtSummary(), (owe: 100, owed: 0, monthlyEmi: 0));
    });
  });

  test('period kinds used by cycles', () {
    expect(Period.of(PeriodKind.month, kNow).kind, PeriodKind.month);
  });
}
