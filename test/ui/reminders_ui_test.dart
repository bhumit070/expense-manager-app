import 'dart:async';

import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/recurring_repo.dart';
import 'package:expense_manager/state/reminders.dart';
import 'package:expense_manager/ui/screens/debts_screen.dart';
import 'package:expense_manager/ui/screens/onboarding_screen.dart';
import 'package:expense_manager/ui/screens/reminder_settings_screen.dart';
import 'package:expense_manager/ui/screens/reminders_screen.dart';
import 'package:expense_manager/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('Settings › Reminders & alerts', () {
    testWidgets('opens from Settings and shows On/Off', (tester) async {
      final s = makeState(notifications: FakeNotifications());
      await pumpRoute(tester, s, SettingsScreen(key: UniqueKey()));
      expect(find.descendant(of: find.byKey(const Key('open-reminders')), matching: find.text('Off')), findsOneWidget);
      await tester.tap(find.byKey(const Key('open-reminders')));
      await tester.pumpAndSettle();
      expect(find.byType(ReminderSettingsScreen), findsOneWidget);
    });

    testWidgets('master switch, per-type switches, FD lead days and a test notification', (tester) async {
      final n = FakeNotifications(grant: false);
      final s = makeState(notifications: n);
      seed(s);
      await pumpRoute(tester, s, ReminderSettingsScreen(key: UniqueKey()));
      // Off: type switches and the test button are disabled.
      expect(tester.widget<SwitchListTile>(find.byKey(const Key('notif-budget'))).onChanged, isNull);
      expect(tester.widget<OutlinedButton>(find.byKey(const Key('notif-test'))).onPressed, isNull);

      await tester.tap(find.byKey(const Key('notif-master')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Notifications are blocked'), findsOneWidget);
      expect(s.reminders.enabled, isFalse);

      n.grant = true;
      await tester.tap(find.byKey(const Key('notif-master')));
      await tester.pumpAndSettle();
      expect(s.reminders.enabled, isTrue);
      expect(n.scheduled, isNotEmpty);

      await tester.tap(find.byKey(const Key('notif-sip')));
      await tester.pumpAndSettle();
      expect(s.reminders.isOn(ReminderType.sip), isFalse);

      expect(find.text('3 days before'), findsOneWidget);
      await tester.tap(find.byKey(const Key('fd-lead-7')));
      await tester.pumpAndSettle();
      expect(s.reminders.maturityLeadDays, 7);
      expect([0, 1, 14].map(leadDaysLabel), ['On the day', '1 day before', '14 days before']);

      await tester.tap(find.byKey(const Key('notif-test')));
      await tester.pumpAndSettle();
      expect(n.shown.single.$1, testNotificationId);
      expect(find.text('Test notification sent'), findsOneWidget);

      await tester.tap(find.byKey(const Key('notif-master')));
      await tester.pumpAndSettle();
      expect(s.reminders.enabled, isFalse);
      expect(n.scheduled, isEmpty);
    });
  });

  group('Onboarding notifications step', () {
    testWidgets('granted turns reminders on and moves on', (tester) async {
      final n = FakeNotifications();
      final s = makeState(onboarded: false, notifications: n);
      await pumpScreen(tester, s, OnboardingScreen(steps: [(_, next) => NotificationsStep(onNext: next)]));
      expect(find.text('Get reminders?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('onboarding-next')));
      await tester.pumpAndSettle();
      expect(s.reminders.enabled, isTrue);
      expect(s.onboarded, isTrue);
    });

    testWidgets('denied explains and continues without reminders', (tester) async {
      final s = makeState(onboarded: false, notifications: FakeNotifications(grant: false));
      await pumpScreen(tester, s, OnboardingScreen(steps: [(_, next) => NotificationsStep(onNext: next)]));
      await tester.tap(find.byKey(const Key('onboarding-next')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('onboarding-notif-denied')), findsOneWidget);
      expect(find.byKey(const Key('onboarding-notif-skip')), findsNothing);
      await tester.tap(find.text('Continue without reminders'));
      await tester.pumpAndSettle();
      expect(s.onboarded, isTrue);
      expect(s.reminders.enabled, isFalse);
    });

    testWidgets('answer after leaving the page is ignored', (tester) async {
      final n = _SlowNotifications();
      final s = makeState(onboarded: false, notifications: n);
      await pumpScreen(tester, s, OnboardingScreen(steps: [(_, next) => NotificationsStep(onNext: next)]));
      await tester.tap(find.byKey(const Key('onboarding-next')));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      n.answer(false);
      await tester.pump();
      expect(s.reminders.enabled, isFalse);
    });
  });

  group('Follow-up on money owed to me', () {
    testWidgets('pick a date, change it, then remove it', (tester) async {
      final s = makeState(notifications: FakeNotifications());
      final ids = seed(s);
      await pumpRoute(tester, s, inScaffold(DebtsScreen(key: UniqueKey())));
      await tester.tap(find.text('Owed to me'));
      await tester.pump();
      final button = find.byKey(Key('follow-up-${ids.lent}'));
      expect(find.descendant(of: button, matching: find.text('Remind me')), findsOneWidget);

      // Cancel the picker: nothing saved.
      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(s.planning.followUpFor(ids.lent), isNull);

      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Remind me on'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(s.planning.followUpFor(ids.lent), DateTime(2026, 11, 4));
      expect(find.text('Saved. Turn on Settings › Reminders & alerts to get a notification.'), findsOneWidget);
      expect(find.descendant(of: button, matching: find.text('4 Nov')), findsOneWidget);

      // With reminders on, the snack confirms the date.
      s.settings.set('notif_on', '1');
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Reminder on 4 Nov'), findsOneWidget);
      await tester.tap(find.byKey(const Key('follow-up-change')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(s.planning.followUpFor(ids.lent), DateTime(2026, 11, 20));
      expect(find.text("We'll remind you on 20 Nov"), findsOneWidget);

      // Dismissing the dialog keeps it.
      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(s.planning.followUpFor(ids.lent), DateTime(2026, 11, 20));

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('follow-up-remove')));
      await tester.pumpAndSettle();
      expect(s.planning.followUpFor(ids.lent), isNull);
      expect(find.descendant(of: button, matching: find.text('Remind me')), findsOneWidget);
    });
  });

  group('Coming up', () {
    test('reminder-only SIPs and follow-ups are listed; settled or paid-off ones are not', () {
      final s = makeState();
      final ids = seed(s);
      final rule = s.recurring.add(
        RecurringRule(
          template: Txn(type: TxnType.invest, amount: 500000, categoryId: catId(s, 'Mutual funds / SIP'), sourceId: null, occurredAt: kNow, investmentId: ids.sip),
          frequency: Frequency.monthly,
          startAt: DateTime(2026, 11, 2, 10),
          autoCreate: false,
        ),
      );
      // Auto-created and paused SIPs don't count.
      s.recurring.add(
        RecurringRule(
          template: Txn(type: TxnType.invest, amount: 1, categoryId: catId(s, 'Mutual funds / SIP'), sourceId: null, occurredAt: kNow, investmentId: ids.fd),
          frequency: Frequency.monthly,
          startAt: DateTime(2026, 11, 3),
        ),
      );
      s.recurring.add(
        RecurringRule(
          template: Txn(type: TxnType.invest, amount: 2, categoryId: catId(s, 'Mutual funds / SIP'), sourceId: null, occurredAt: kNow, investmentId: ids.fd),
          frequency: Frequency.monthly,
          startAt: DateTime(2026, 11, 3),
          autoCreate: false,
          paused: true,
        ),
      );
      s.planning.setFollowUp(ids.lent, DateTime(2026, 11, 6, 18));
      final items = s.planning.upcoming(kNow);
      final sip = items.singleWhere((u) => u.kind == UpcomingKind.sip);
      expect([sip.date, sip.title, sip.amount, sip.investmentId], [DateTime(2026, 11, 2), 'Nifty 50 Index', 500000, ids.sip]);
      final follow = items.singleWhere((u) => u.kind == UpcomingKind.followUp);
      expect([follow.date, follow.title, follow.amount, follow.debtId], [DateTime(2026, 11, 6), 'Rahul', 600000, ids.lent]);
      expect(rule, isPositive);

      // Named counterparty wins over the debt name; a paid-off debt drops out.
      final paid = s.planning.addDebt(const Debt(direction: DebtDirection.owedToMe, kind: DebtKind.personal, name: 'Trip', counterparty: 'Asha', principal: 1000));
      s.planning.setFollowUp(paid, DateTime(2026, 11, 7));
      expect(s.planning.upcoming(kNow).where((u) => u.kind == UpcomingKind.followUp).map((u) => u.title), ['Rahul', 'Asha']);
      s.txns.insert(
        Txn(type: TxnType.debt, amount: 1000, categoryId: s.catalog.defaultCategory().id, sourceId: null, occurredAt: kNow, debtId: paid),
        now: kNow,
      );
      expect(s.planning.upcoming(kNow).where((u) => u.kind == UpcomingKind.followUp).map((u) => u.title), ['Rahul']);
    });

    testWidgets('Reminders screen shows SIP and follow-up rows', (tester) async {
      final s = makeState();
      final ids = seed(s);
      s.recurring.add(
        RecurringRule(
          template: Txn(type: TxnType.invest, amount: 500000, categoryId: catId(s, 'Mutual funds / SIP'), sourceId: null, occurredAt: kNow, investmentId: ids.sip),
          frequency: Frequency.monthly,
          startAt: DateTime(2026, 11, 2, 10),
          autoCreate: false,
        ),
      );
      s.planning.setFollowUp(ids.lent, DateTime(2026, 11, 6));
      await pumpRoute(tester, s, RemindersScreen(key: UniqueKey()));
      expect(find.textContaining('SIP due'), findsOneWidget);
      expect(find.textContaining('Follow up'), findsOneWidget);
      expect(find.byIcon(upcomingIcon(UpcomingKind.sip)), findsOneWidget);
      expect(find.byIcon(upcomingIcon(UpcomingKind.followUp)), findsOneWidget);
    });
  });
}

class _SlowNotifications extends FakeNotifications {
  final _answer = <void Function(bool)>[];

  void answer(bool granted) => _answer.single(granted);

  @override
  Future<bool> requestPermission() {
    final c = Completer<bool>();
    _answer.add(c.complete);
    return c.future;
  }
}
