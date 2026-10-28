import 'package:sqlite3/sqlite3.dart';

import '../core/dates.dart';
import 'models.dart';
import 'recurring_repo.dart' show RecurringRepo;
import 'transactions_repo.dart';

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
    final args = <Object?>[type, p.start.millisecondsSinceEpoch, p.end.millisecondsSinceEpoch];
    var cats = '';
    if (b.categoryIds.isNotEmpty) {
      final (sql, ids) = categoryClause('category_id', b.categoryIds);
      cats = ' AND $sql';
      args.addAll(ids);
    }
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

  /// Payments up to 30 days before a statement's due date count towards it.
  static const _statementCycleMs = 30 * Duration.millisecondsPerDay;

  List<Object?> _debtValues(Debt d) => [
    d.direction.name,
    d.kind.name,
    d.name.trim(),
    d.counterparty.trim(),
    d.principal,
    d.rate,
    d.emi,
    d.totalEmis,
    d.dueDay,
    d.settled ? 1 : 0,
    d.statementAmount,
    d.statementDueAt?.millisecondsSinceEpoch,
  ];

  int addDebt(Debt d) {
    db.execute(
      'INSERT INTO debts(direction, kind, name, counterparty, principal, rate, emi, total_emis, due_day, settled, statement_amount, statement_due_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      _debtValues(d),
    );
    return db.lastInsertRowId;
  }

  void updateDebt(Debt d) => db.execute(
    'UPDATE debts SET direction = ?, kind = ?, name = ?, counterparty = ?, principal = ?, rate = ?, emi = ?, total_emis = ?, due_day = ?, settled = ?, statement_amount = ?, statement_due_at = ? WHERE id = ?',
    [..._debtValues(d), d.id],
  );

  void setDebtSettled(int id, bool settled) => db.execute('UPDATE debts SET settled = ? WHERE id = ?', [settled ? 1 : 0, id]);

  Debt debt(int id) => Debt.fromRow(db.select('SELECT * FROM debts WHERE id = ?', [id]).first);

  List<DebtStatus> debts({DebtDirection? direction, bool settled = false}) {
    final r = db.select(
      '''
SELECT d.*, coalesce(sum(t.amount), 0) AS paid, count(t.id) AS payments,
  coalesce(sum(CASE WHEN d.statement_due_at IS NOT NULL AND t.occurred_at > d.statement_due_at - $_statementCycleMs THEN t.amount END), 0) AS statement_paid
FROM debts d LEFT JOIN transactions t ON t.debt_id = d.id AND t.deleted = 0
WHERE d.settled = ?${direction == null ? '' : ' AND d.direction = ?'}
GROUP BY d.id ORDER BY d.id''',
      [settled ? 1 : 0, if (direction != null) direction.name],
    );
    return r.map((row) => DebtStatus(debt: Debt.fromRow(row), paid: row['paid'] as int, payments: row['payments'] as int, statementPaid: row['statement_paid'] as int)).toList();
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

  // ---- Upcoming ------------------------------------------------------------

  /// Dated obligations from [now] (start of today) through [days] ahead,
  /// soonest first. Each generator contributes one kind; add recurring rules
  /// or SIPs by appending another generator to the list below.
  List<Upcoming> upcoming(DateTime now, {int days = 30}) {
    final from = dayStart(now);
    final until = from.add(Duration(days: days + 1));
    final items = [..._debtDues(from), ..._maturities(from), ..._sips(), ..._followUps()].where((u) => !u.date.isBefore(from) && u.date.isBefore(until)).toList();
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  /// Next due date of every unsettled loan/card I owe that has a due day.
  /// A cycle already paid (a payment dated in that calendar month) is skipped.
  /// Cards with a statement use its due date and unpaid amount instead.
  Iterable<Upcoming> _debtDues(DateTime today) sync* {
    for (final s in debts(direction: DebtDirection.iOwe)) {
      final d = s.debt;
      if (d.kind == DebtKind.card && d.statementDueAt != null) {
        if (s.statementLeft > 0) yield Upcoming(kind: UpcomingKind.cardDue, date: dayStart(d.statementDueAt!), title: d.name, amount: s.statementLeft, debtId: d.id);
        continue;
      }
      if (d.dueDay == null || d.kind == DebtKind.personal || s.remaining <= 0) continue;
      var due = nextDueDate(d.dueDay!, today);
      if (_paidInMonth(d.id!, due)) due = nextDueDate(d.dueDay!, DateTime(due.year, due.month + 1));
      yield Upcoming(kind: d.kind == DebtKind.card ? UpcomingKind.cardDue : UpcomingKind.emi, date: due, title: d.name, amount: d.kind == DebtKind.card ? null : (d.emi ?? s.remaining), debtId: d.id);
    }
  }

  bool _paidInMonth(int debtId, DateTime d) {
    final m = Period.of(PeriodKind.month, d);
    return db.select('SELECT 1 FROM transactions WHERE deleted = 0 AND debt_id = ? AND occurred_at >= ? AND occurred_at < ? LIMIT 1', [
      debtId,
      m.start.millisecondsSinceEpoch,
      m.end.millisecondsSinceEpoch,
    ]).isNotEmpty;
  }

  Iterable<Upcoming> _maturities(DateTime today) sync* {
    for (final h in holdings()) {
      final m = h.investment.maturityAt;
      if (m == null) continue;
      yield Upcoming(kind: UpcomingKind.maturity, date: dayStart(m), title: h.investment.name, amount: h.invested, investmentId: h.investment.id);
    }
  }

  /// Next date of each active reminder-only SIP (auto-created SIPs simply
  /// appear as transactions).
  Iterable<Upcoming> _sips() sync* {
    final names = {for (final r in db.select('SELECT id, name FROM investments')) r['id'] as int: r['name'] as String};
    for (final r in RecurringRepo(db).rules()) {
      final inv = r.template.investmentId;
      if (r.autoCreate || r.paused || r.ended || inv == null) continue;
      yield Upcoming(kind: UpcomingKind.sip, date: dayStart(r.nextRun), title: names[inv] ?? r.template.merchant, amount: r.template.amount, investmentId: inv);
    }
  }

  // ---- Follow-up reminders on money owed to me ------------------------------

  static const _followUpKey = 'debt_remind:';

  /// The "remind me" date set on debt [id], if any.
  DateTime? followUpFor(int id) {
    final r = db.select('SELECT value FROM settings WHERE key = ?', ['$_followUpKey$id']);
    return r.isEmpty ? null : DateTime.fromMillisecondsSinceEpoch(int.parse(r.first['value'] as String));
  }

  /// Sets (or with null clears) the day to be reminded about debt [id].
  void setFollowUp(int id, DateTime? day) {
    if (day == null) {
      db.execute('DELETE FROM settings WHERE key = ?', ['$_followUpKey$id']);
    } else {
      db.execute('INSERT INTO settings(key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value', ['$_followUpKey$id', '${dayStart(day).millisecondsSinceEpoch}']);
    }
  }

  Iterable<Upcoming> _followUps() sync* {
    for (final s in debts(direction: DebtDirection.owedToMe)) {
      final at = followUpFor(s.debt.id!);
      if (at == null || s.remaining <= 0) continue;
      final who = s.debt.counterparty.isEmpty ? s.debt.name : s.debt.counterparty;
      yield Upcoming(kind: UpcomingKind.followUp, date: at, title: who, amount: s.remaining, debtId: s.debt.id);
    }
  }
}

/// The first date on or after [from] falling on [day] of a month. Short months
/// clamp to their last day (31 → 30 Nov, 28/29 Feb).
DateTime nextDueDate(int day, DateTime from) {
  DateTime inMonth(int y, int m) => DateTime(y, m, day.clamp(1, DateTime(y, m + 1, 0).day));
  final start = dayStart(from);
  final here = inMonth(start.year, start.month);
  return here.isBefore(start) ? inMonth(start.year, start.month + 1) : here;
}
