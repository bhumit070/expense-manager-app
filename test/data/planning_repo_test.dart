import 'package:expense_manager/core/dates.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/planning_repo.dart';
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

    test('card statements: update, cycle payments, upcoming', () {
      final s = makeState();
      final id = s.planning.addDebt(
        Debt(direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'ICICI', principal: 5000000, dueDay: 2, statementAmount: 1200000, statementDueAt: DateTime(2026, 11, 2)),
      );
      var st = s.planning.debts().single;
      expect([st.debt.statementAmount, st.debt.statementDueAt, st.statementLeft, st.statementDueIn(kNow), st.isUrgent(kNow)], [1200000, DateTime(2026, 11, 2), 1200000, 5, false]);
      expect(s.planning.upcoming(kNow).single.amount, 1200000);
      expect(s.planning.upcoming(kNow).single.date, DateTime(2026, 11, 2));
      // A payment from before the cycle doesn't count; one inside it does.
      void pay(int amount, DateTime at) => s.txns.insert(Txn(type: TxnType.debt, amount: amount, categoryId: s.catalog.defaultCategory().id, sourceId: null, occurredAt: at, debtId: id));
      pay(100000, DateTime(2026, 9, 1));
      pay(200000, DateTime(2026, 10, 20));
      st = s.planning.debts().single;
      expect(st.statementPaid, 200000);
      expect(st.statementLeft, 1000000);
      expect(st.isUrgent(DateTime(2026, 10, 30)), isTrue);
      expect(st.statementDueIn(DateTime(2026, 11, 4)), -2);
      pay(1000000, DateTime(2026, 10, 28));
      st = s.planning.debts().single;
      expect([st.statementLeft, st.statementDueIn(kNow), st.isUrgent(kNow)], [0, null, false]);
      expect(s.planning.upcoming(kNow), isEmpty);

      s.planning.updateDebt(
        Debt(id: id, direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'ICICI Amazon', principal: 5000000, statementAmount: 300000, statementDueAt: DateTime(2026, 12, 2), settled: true),
      );
      final d = s.planning.debt(id);
      expect([d.name, d.statementAmount, d.statementDueAt, d.dueDay, d.settled], ['ICICI Amazon', 300000, DateTime(2026, 12, 2), null, true]);
      // Paying before this statement's cycle (> 30 days earlier) doesn't count.
      expect(s.planning.debts(settled: true).single.statementLeft, 300000);
      // No statement: nothing left, no due.
      expect(
        const DebtStatus(
          debt: Debt(direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'x', principal: 1),
          paid: 0,
          payments: 0,
        ).statementDueIn(kNow),
        isNull,
      );
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

  group('upcoming', () {
    test('nextDueDate clamps short months and rolls into next month/year', () {
      expect(nextDueDate(5, DateTime(2026, 10, 28)), DateTime(2026, 11, 5));
      expect(nextDueDate(28, DateTime(2026, 10, 28, 21)), DateTime(2026, 10, 28));
      expect(nextDueDate(31, DateTime(2026, 11, 2)), DateTime(2026, 11, 30));
      expect(nextDueDate(31, DateTime(2027, 2, 1)), DateTime(2027, 2, 28));
      expect(nextDueDate(30, DateTime(2028, 2, 1)), DateTime(2028, 2, 29));
      expect(nextDueDate(3, DateTime(2026, 12, 20)), DateTime(2027, 1, 3));
    });

    test('EMIs, card dues and maturities, soonest first, skipping paid cycles', () {
      final s = makeState();
      final ids = seed(s);
      // Paid Oct 5 already, so the car loan shows Nov 5; FD matures Nov 12.
      var items = s.planning.upcoming(kNow);
      expect(items.map((u) => (u.kind, u.date, u.title, u.amount)).toList(), [
        (UpcomingKind.emi, DateTime(2026, 11, 5), 'Car loan', 1240000),
        (UpcomingKind.maturity, DateTime(2026, 11, 12), 'HDFC FD', 5000000),
      ]);
      expect(items.first.debtId, ids.loan);
      expect(items.last.investmentId, ids.fd);

      final card = s.planning.addDebt(const Debt(direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'ICICI bill', principal: 500000, dueDay: 30));
      // No EMI amount falls back to what's left; personal debts and debts without a due day are ignored.
      s.planning.addDebt(const Debt(direction: DebtDirection.iOwe, kind: DebtKind.loan, name: 'Gold loan', principal: 90000, dueDay: 1));
      s.planning.addDebt(const Debt(direction: DebtDirection.iOwe, kind: DebtKind.personal, name: 'Amit', principal: 100, dueDay: 2));
      s.planning.addDebt(const Debt(direction: DebtDirection.iOwe, kind: DebtKind.loan, name: 'No date', principal: 100));
      items = s.planning.upcoming(kNow);
      expect(items.map((u) => u.title).toList(), ['ICICI bill', 'Gold loan', 'Car loan', 'HDFC FD']);
      expect(items.first.kind, UpcomingKind.cardDue);
      expect(items.first.amount, isNull);
      expect(items.first.debtId, card);
      expect(items[1].amount, 90000);

      // The window is inclusive of the last day and excludes later items.
      expect(s.planning.upcoming(kNow, days: 8).map((u) => u.title), ['ICICI bill', 'Gold loan', 'Car loan']);

      // Fully paid or settled debts and matured investments drop out.
      s.planning.setDebtSettled(ids.loan, true);
      s.planning.setInvestmentStatus(ids.fd, InvestmentStatus.matured);
      s.txns.insert(Txn(type: TxnType.debt, amount: 90000, categoryId: s.catalog.defaultCategory().id, sourceId: null, occurredAt: kNow, debtId: items[1].debtId));
      expect(s.planning.upcoming(kNow).map((u) => u.title), ['ICICI bill']);
      // Past maturities are not "coming up".
      s.planning.addInvestment(Investment(kind: InvestmentKind.fd, name: 'Old FD', maturityAt: DateTime(2026, 1, 1)));
      expect(s.planning.upcoming(kNow).map((u) => u.title), ['ICICI bill']);
    });
  });
}
