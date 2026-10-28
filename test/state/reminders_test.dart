import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/recurring_repo.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:expense_manager/state/reminders.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// A reminder-only SIP on the 2nd of each month into [investment].
int reminderSip(AppState s, int investment, {DateTime? start}) => s.recurring.add(
  RecurringRule(
    template: Txn(type: TxnType.invest, amount: 500000, categoryId: catId(s, 'Mutual funds / SIP'), sourceId: s.catalog.defaultSource()!.id, occurredAt: kNow, investmentId: investment),
    frequency: Frequency.monthly,
    startAt: start ?? DateTime(2026, 11, 2, 10),
    autoCreate: false,
  ),
);

void main() {
  test('preferences: off by default, every type on, FD lead 3 days', () {
    final s = makeState(notifications: FakeNotifications());
    final r = s.reminders;
    expect(r.enabled, isFalse);
    expect(ReminderType.values.every(r.isOn), isTrue);
    expect(r.maturityLeadDays, 3);
    r.setOn(ReminderType.sip, false);
    expect(r.isOn(ReminderType.sip), isFalse);
    r.setOn(ReminderType.sip, true);
    expect(r.isOn(ReminderType.sip), isTrue);
    r.maturityLeadDays = 7;
    expect(r.maturityLeadDays, 7);
    expect(ReminderType.values.map(reminderTypeLabel).toSet(), hasLength(ReminderType.values.length));
    expect(followUpLabel(DateTime(2026, 11, 5)), '5 Nov');
  });

  test('enable asks for permission; denied stays off and schedules nothing', () async {
    final n = FakeNotifications(grant: false);
    final s = makeState(notifications: n);
    seed(s);
    expect(await s.reminders.enable(), isFalse);
    expect(s.reminders.enabled, isFalse);
    expect(n.scheduled, isEmpty);
    expect(await s.reminders.sync(), isEmpty);
    expect(await s.reminders.checkBudgets(), isEmpty);
    n.grant = true;
    expect(await s.reminders.enable(), isTrue);
    expect(n.permissionRequests, 2);
    expect(n.scheduled, isNotEmpty);
  });

  test('plan: EMI the day before and on the day, FD lead days, SIP and follow-ups at 9 AM', () async {
    final s = makeState(notifications: FakeNotifications());
    final ids = seed(s);
    reminderSip(s, ids.sip);
    s.planning.setFollowUp(ids.lent, DateTime(2026, 11, 20, 15));
    final card = s.planning.addDebt(const Debt(direction: DebtDirection.iOwe, kind: DebtKind.card, name: 'Amex', principal: 100000, dueDay: 30));
    final plan = s.reminders.plan();
    String at(PlannedReminder r) => '${r.at.month}/${r.at.day} ${r.at.hour}:${r.at.minute.toString().padLeft(2, '0')}';
    final lines = [for (final r in plan) '${at(r)} ${r.title} | ${r.body}'];
    expect(lines, [
      '10/29 9:00 Card bill due tomorrow | Amex: Card bill is due tomorrow.',
      '10/30 9:00 Card bill due today | Amex: Card bill is due today.',
      '11/2 9:00 SIP due today | Nifty 50 Index: invest ₹5,000 today.',
      '11/4 9:00 EMI due tomorrow | Car loan: EMI of ₹12,400 is due tomorrow.',
      '11/5 9:00 EMI due today | Car loan: EMI of ₹12,400 is due today.',
      '11/9 9:00 FD matures in 3 days | HDFC FD (₹50,000 invested) matures on 12 Nov.',
      '11/20 9:00 Follow up with Rahul | Rahul still owes you ₹6,000.',
    ]);
    expect([for (final r in plan) r.id], List.generate(plan.length, (i) => i + 1));
    expect(plan.first.toString(), startsWith('1 @ 2026-10-29 09:00'));
    expect(card, isPositive);

    s.reminders.maturityLeadDays = 1;
    expect(s.reminders.plan().map((r) => r.title), contains('FD matures tomorrow'));
    s.reminders.maturityLeadDays = 0;
    expect(s.reminders.plan().map((r) => r.title), contains('FD matures today'));

    for (final t in ReminderType.values) {
      s.reminders.setOn(t, false);
    }
    expect(s.reminders.plan(), isEmpty);
  });

  test('plan keeps at most $maxScheduled reminders, soonest first', () {
    final s = makeState(notifications: FakeNotifications());
    for (var i = 0; i < 40; i++) {
      s.planning.addDebt(Debt(direction: DebtDirection.iOwe, kind: DebtKind.loan, name: 'Loan $i', principal: 100000, emi: 1000, dueDay: 1 + i % 28));
    }
    final plan = s.reminders.plan();
    expect(plan, hasLength(maxScheduled));
    expect(plan.map((r) => r.at).toList(), [...plan.map((r) => r.at)]..sort());
  });

  test('sync replaces what was scheduled; disable cancels everything', () async {
    final n = FakeNotifications();
    final s = makeState(notifications: n);
    seed(s);
    await s.reminders.enable();
    final first = Map.of(n.scheduled);
    expect(first.values.map((v) => v.$2), contains('EMI due today'));
    s.reminders.setOn(ReminderType.dues, false);
    final second = await s.reminders.sync();
    expect(n.cancelled, containsAll(first.keys));
    expect(n.scheduled.keys, second.map((r) => r.id));
    expect(n.scheduled.values.map((v) => v.$2), isNot(contains('EMI due today')));
    await s.reminders.disable();
    expect(s.reminders.enabled, isFalse);
    expect(n.scheduled, isEmpty);
    expect(s.settings.get('notif_ids'), '');
  });

  test('budget alerts fire once at 80% and once at 100% per cycle', () async {
    final n = FakeNotifications();
    var now = kNow;
    final s = makeState(notifications: n, now: kNow);
    final r = Reminders(db: s.db, service: n, clock: () => now);
    s.settings.set('notif_on', '1');
    final food = catId(s, 'Food & dining');
    final b = s.planning.addBudget(Budget(name: 'Food', period: BudgetPeriod.monthly, limit: 1000000, categoryIds: [food]));
    s.planning.addBudget(const Budget(name: 'Goal', period: BudgetPeriod.monthly, limit: 100, isGoal: true));
    s.planning.addBudget(Budget(name: 'Quiet', period: BudgetPeriod.monthly, limit: 100, categoryIds: [food], alert80: false, alert100: false));
    void spend(int paise, DateTime at) => s.txns.insert(
      Txn(type: TxnType.spend, amount: paise, categoryId: food, sourceId: null, occurredAt: at),
      now: at,
    );

    spend(700000, kNow);
    expect(await r.checkBudgets(), isEmpty);
    spend(150000, kNow);
    expect(await r.checkBudgets(), ['80% of Food budget used']);
    expect(n.shown.single.$3, '₹8,500 of ₹10,000 spent · 4 days left');
    expect(await r.checkBudgets(), isEmpty);
    spend(200000, kNow);
    expect(await r.checkBudgets(), ['Food budget used up']);
    expect(await r.checkBudgets(), isEmpty);
    expect(n.shown.map((x) => x.$1).toSet(), hasLength(2));

    // Next month: a fresh cycle alerts again (straight to 100%). 1 day left.
    now = DateTime(2026, 11, 30, 10);
    spend(1200000, now);
    expect(await r.checkBudgets(), ['Food budget used up']);
    expect(n.shown.last.$3, endsWith('1 day left'));

    // Only 80% enabled: a budget over its limit still alerts at 80% once.
    s.planning.updateBudget(Budget(id: b, name: 'Food', period: BudgetPeriod.monthly, limit: 1000000, categoryIds: [food], alert100: false));
    s.settings.set('budget_alert:$b', '');
    expect(await r.checkBudgets(), ['80% of Food budget used']);

    s.reminders.setOn(ReminderType.budget, false);
    s.settings.set('budget_alert:$b', '');
    expect(await r.checkBudgets(), isEmpty);
  });

  test('test notification uses its own id', () async {
    final n = FakeNotifications();
    final s = makeState(notifications: n);
    await s.reminders.sendTest();
    expect(n.shown.single.$1, testNotificationId);
  });

  test('AppState: startup and changed() refresh reminders; errors are swallowed', () async {
    final n = FakeNotifications();
    final s = makeState(notifications: n);
    seed(s);
    s.settings.set('notif_on', '1');
    await s.startup();
    expect(n.scheduled, isNotEmpty);
    n.scheduled.clear();
    s.changed();
    await s.reminderWork;
    expect(n.scheduled, isNotEmpty);
    s.db.close();
    s.changed();
    await s.reminderWork;

    // Without a notification service nothing is queued.
    final quiet = makeState();
    quiet.changed();
    await quiet.reminderWork;
    expect(quiet.reminders.service.available, isFalse);
  });
}
