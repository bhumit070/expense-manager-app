import 'package:sqlite3/sqlite3.dart';

import '../core/dates.dart';
import 'models.dart';

/// Budgets, investments and debts.
class PlanningRepo {
  PlanningRepo(this.db);

  final Database db;

  // ---- Budgets -------------------------------------------------------------

  List<Budget> budgets({BudgetPeriod? period}) =>
      db.select('SELECT * FROM budgets${period == null ? '' : ' WHERE period = ?'} ORDER BY is_goal, id', [if (period != null) period.name]).map(Budget.fromRow).toList();

  List<Object?> _budgetValues(Budget b) => [b.name.trim(), b.period.name, b.limit, b.categoryIds.join(','), b.rollover ? 1 : 0, b.alert80 ? 1 : 0, b.alert100 ? 1 : 0, b.isGoal ? 1 : 0];

  int addBudget(Budget b) {
    db.execute('INSERT INTO budgets(name, period, limit_amount, category_ids, rollover, alert80, alert100, is_goal) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', _budgetValues(b));
    return db.lastInsertRowId;
  }

  void updateBudget(Budget b) =>
      db.execute('UPDATE budgets SET name = ?, period = ?, limit_amount = ?, category_ids = ?, rollover = ?, alert80 = ?, alert100 = ?, is_goal = ? WHERE id = ?', [..._budgetValues(b), b.id]);

  void deleteBudget(int id) => db.execute('DELETE FROM budgets WHERE id = ?', [id]);

  Period cycleFor(Budget b, DateTime now) => Period.of(b.period == BudgetPeriod.weekly ? PeriodKind.week : PeriodKind.month, now);

  int _used(Budget b, Period p) {
    final type = b.isGoal ? 'invest' : 'spend';
    final args = <Object?>[type, p.start.millisecondsSinceEpoch, p.end.millisecondsSinceEpoch, ...b.categoryIds];
    final cats = b.categoryIds.isEmpty ? '' : ' AND category_id IN (${List.filled(b.categoryIds.length, '?').join(',')})';
    return db.select('SELECT coalesce(sum(amount), 0) AS s FROM transactions WHERE deleted = 0 AND type = ? AND occurred_at >= ? AND occurred_at < ?$cats', args).first['s'] as int;
  }

  /// Progress of [b] in the cycle containing [now]. With rollover, unspent
  /// money from the previous cycle is added to the limit.
  BudgetProgress progress(Budget b, DateTime now) {
    final cycle = cycleFor(b, now);
    var limit = b.limit;
    if (b.rollover && !b.isGoal) {
      final leftover = b.limit - _used(b, cycle.previous);
      if (leftover > 0) limit += leftover;
    }
    return BudgetProgress(budget: b, used: _used(b, cycle), limit: limit, daysLeft: cycle.daysLeft(now), elapsed: cycle.elapsed(now));
  }

  /// Average monthly spend over the 3 months before [now] for categories.
  int suggestedLimit(List<int> categoryIds, DateTime now) {
    var p = Period.of(PeriodKind.month, now).previous;
    var total = 0;
    final b = Budget(name: '', period: BudgetPeriod.monthly, limit: 0, categoryIds: categoryIds);
    for (var i = 0; i < 3; i++) {
      total += _used(b, p);
      p = p.previous;
    }
    return total ~/ 3;
  }

  // ---- Investments ---------------------------------------------------------

  List<Object?> _invValues(Investment i) => [
    i.kind.name,
    i.name.trim(),
    i.institution.trim(),
    i.rate,
    i.startAt?.millisecondsSinceEpoch,
    i.maturityAt?.millisecondsSinceEpoch,
    i.note.trim(),
    i.status.name,
  ];

  int addInvestment(Investment i) {
    db.execute('INSERT INTO investments(kind, name, institution, rate, start_at, maturity_at, note, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', _invValues(i));
    return db.lastInsertRowId;
  }

  void updateInvestment(Investment i) =>
      db.execute('UPDATE investments SET kind = ?, name = ?, institution = ?, rate = ?, start_at = ?, maturity_at = ?, note = ?, status = ? WHERE id = ?', [..._invValues(i), i.id]);

  void setInvestmentStatus(int id, InvestmentStatus s) => db.execute('UPDATE investments SET status = ? WHERE id = ?', [s.name, id]);

  Investment investment(int id) => Investment.fromRow(db.select('SELECT * FROM investments WHERE id = ?', [id]).first);

  /// Holdings with the total invested and number of entries. Only what the
  /// user put in is tracked — there is no market value.
  List<Holding> holdings({bool activeOnly = true}) {
    final r = db.select('''
SELECT i.*, coalesce(sum(t.amount), 0) AS invested, count(t.id) AS entries
FROM investments i
LEFT JOIN transactions t ON t.investment_id = i.id AND t.deleted = 0 AND t.type = 'invest'
${activeOnly ? "WHERE i.status = 'active'" : ''}
GROUP BY i.id ORDER BY i.kind, invested DESC''');
    return r.map((row) => Holding(investment: Investment.fromRow(row), invested: row['invested'] as int, entries: row['entries'] as int)).toList();
  }

  /// Active investments maturing within [days] of [now], soonest first.
  List<Investment> maturingSoon(DateTime now, {int days = 30}) => db
      .select("SELECT * FROM investments WHERE status = 'active' AND maturity_at IS NOT NULL AND maturity_at >= ? AND maturity_at <= ? ORDER BY maturity_at", [
        dayStart(now).millisecondsSinceEpoch,
        now.add(Duration(days: days)).millisecondsSinceEpoch,
      ])
      .map(Investment.fromRow)
      .toList();

  // ---- Debts ---------------------------------------------------------------

  List<Object?> _debtValues(Debt d) => [d.direction.name, d.kind.name, d.name.trim(), d.counterparty.trim(), d.principal, d.rate, d.emi, d.totalEmis, d.dueDay, d.settled ? 1 : 0];

  int addDebt(Debt d) {
    db.execute('INSERT INTO debts(direction, kind, name, counterparty, principal, rate, emi, total_emis, due_day, settled) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', _debtValues(d));
    return db.lastInsertRowId;
  }

  void setDebtSettled(int id, bool settled) => db.execute('UPDATE debts SET settled = ? WHERE id = ?', [settled ? 1 : 0, id]);

  Debt debt(int id) => Debt.fromRow(db.select('SELECT * FROM debts WHERE id = ?', [id]).first);

  List<DebtStatus> debts({DebtDirection? direction, bool settled = false}) {
    final r = db.select(
      '''
SELECT d.*, coalesce(sum(t.amount), 0) AS paid, count(t.id) AS payments
FROM debts d LEFT JOIN transactions t ON t.debt_id = d.id AND t.deleted = 0
WHERE d.settled = ?${direction == null ? '' : ' AND d.direction = ?'}
GROUP BY d.id ORDER BY d.id''',
      [settled ? 1 : 0, if (direction != null) direction.name],
    );
    return r.map((row) => DebtStatus(debt: Debt.fromRow(row), paid: row['paid'] as int, payments: row['payments'] as int)).toList();
  }

  /// Outstanding amount in each direction for unsettled debts.
  ({int owe, int owed, int monthlyEmi}) debtSummary() {
    var owe = 0, owed = 0, emi = 0;
    for (final s in debts()) {
      if (s.debt.direction == DebtDirection.iOwe) {
        owe += s.remaining;
        emi += s.debt.emi ?? 0;
      } else {
        owed += s.remaining;
      }
    }
    return (owe: owe, owed: owed, monthlyEmi: emi);
  }
}
