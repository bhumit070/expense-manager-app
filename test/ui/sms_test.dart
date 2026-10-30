import 'package:expense_manager/app.dart';
import 'package:expense_manager/services/notifications.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:expense_manager/state/sms_inbox.dart';
import 'package:expense_manager/ui/screens/home_screen.dart';
import 'package:expense_manager/ui/screens/onboarding_screen.dart';
import 'package:expense_manager/ui/screens/settings_screen.dart';
import 'package:expense_manager/ui/screens/sms_screen.dart';
import 'package:expense_manager/ui/screens/txn_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/maps.dart';
import '../helpers.dart';

const _swiggy = 'Sent Rs.250.00 From HDFC Bank A/C *1242 To SWIGGY On 28/10/26 Ref 630212345678';
const _salary = 'Rs. 5,000.00 credited to a/c XX9999 on 28-10-26 by VPA rahul.k@okaxis';
final _at = DateTime(2026, 10, 28, 20, 15);

void main() {
  late FakeNotifications notes;
  late FakeSmsPlatform platform;
  late AppState s;

  setUp(() {
    notes = FakeNotifications();
    platform = FakeSmsPlatform();
    s = makeState(notifications: notes, sms: platform);
  });

  Future<int> capture([String body = _swiggy]) async {
    s.sms.enabled = true;
    return (await s.sms.receive('AD-HDFCBK', body, _at))!;
  }

  group('SmsScreen', () {
    testWidgets('turning it on explains, asks for SMS and notification permission', (tester) async {
      await pumpRoute(tester, s, const SmsScreen());
      expect(find.text('Nothing to review'), findsOneWidget);
      expect(find.textContaining('Turn this on'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sms-switch')));
      await tester.pumpAndSettle();
      expect(find.text('Read bank SMS?'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(platform.requests, 0);
      expect(s.sms.enabled, isFalse);

      platform.grant = false;
      await tester.tap(find.byKey(const Key('sms-switch')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sms-allow')));
      await tester.pumpAndSettle();
      expect(find.textContaining('SMS permission was denied'), findsOneWidget);
      expect(s.sms.enabled, isFalse);

      platform.grant = true;
      notes.grant = false;
      await tester.tap(find.byKey(const Key('sms-switch')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sms-allow')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Notifications are blocked'), findsOneWidget);
      expect(s.sms.enabled, isTrue);
      expect(find.textContaining('New bank and UPI transactions show up here'), findsOneWidget);
      expect(find.byKey(const Key('sms-permission')), findsNothing);

      await tester.tap(find.byKey(const Key('sms-switch')));
      await tester.pumpAndSettle();
      expect(s.sms.enabled, isFalse);
    });

    testWidgets('granting notifications too gives no warning', (tester) async {
      platform.grant = true;
      await pumpRoute(tester, s, const SmsScreen());
      await tester.tap(find.byKey(const Key('sms-switch')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sms-allow')));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(s.sms.enabled, isTrue);
    });

    testWidgets('warns when on but the permission was taken away', (tester) async {
      s.sms.enabled = true;
      platform.grant = false;
      await pumpRoute(tester, s, const SmsScreen());
      await tester.pumpAndSettle();
      expect(find.textContaining('SMS permission is off'), findsOneWidget);
      await tester.tap(find.byKey(const Key('sms-permission')));
      await tester.pumpAndSettle();
      expect(find.textContaining('SMS permission is off'), findsOneWidget);
      platform.grant = true;
      await tester.tap(find.byKey(const Key('sms-permission')));
      await tester.pumpAndSettle();
      expect(find.textContaining('SMS permission is off'), findsNothing);
    });

    testWidgets('review list: add, ignore and add with details', (tester) async {
      seed(s);
      final swiggy = await capture();
      final salary = await capture(_salary);
      final third = await capture('Rs 99 debited at CHAI POINT');
      await pumpRoute(tester, s, const SmsScreen());
      expect(find.text('To review (3)'), findsOneWidget);
      expect(find.text('₹250 at Swiggy'), findsOneWidget);
      expect(find.text('Food & dining · HDFC Savings ••42 · 28 Oct, 8:15 PM'), findsOneWidget);
      expect(find.text(_swiggy), findsOneWidget);

      await tester.tap(find.byKey(Key('sms-add-$swiggy')));
      await tester.pumpAndSettle();
      expect(find.text('Added ₹250 at Swiggy'), findsOneWidget);
      expect(s.sms.capture(swiggy)!.status, CaptureStatus.added);

      await tester.tap(find.byKey(Key('sms-ignore-$salary')));
      await tester.pumpAndSettle();
      expect(s.sms.capture(salary)!.status, CaptureStatus.ignored);
      expect(find.text('To review (1)'), findsOneWidget);

      await tester.tap(find.byKey(Key('sms-edit-$third')));
      await tester.pumpAndSettle();
      expect(find.byType(TxnFormScreen), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('save-txn')));
      await tester.tap(find.byKey(const Key('save-txn')));
      await tester.pumpAndSettle();
      expect(s.sms.capture(third)!.status, CaptureStatus.added);
      expect(s.txns.byId(s.sms.capture(third)!.txnId!)!.txn.merchant, 'Chai Point');
      expect(notes.cancelled, contains(smsNotificationBase + third));
      expect(find.text('Nothing to review'), findsOneWidget);
    });
  });

  group('iPhone', () {
    testWidgets('explains Shortcuts, turns on without an SMS permission and links to the guide', (tester) async {
      final maps = useFakeMaps(addTearDown);
      platform.shortcuts = true;
      await pumpRoute(tester, s, const SmsScreen());
      expect(find.byKey(const Key('sms-shortcuts-setup')), findsOneWidget);
      expect(find.text('Set up on iPhone'), findsOneWidget);
      expect(find.textContaining('Log bank SMS'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sms-switch')));
      await tester.pumpAndSettle();
      expect(find.textContaining('a Shortcuts automation hands each bank message'), findsOneWidget);
      await tester.tap(find.byKey(const Key('sms-allow')));
      await tester.pumpAndSettle();
      expect(s.sms.enabled, isTrue);

      await tester.tap(find.byKey(const Key('sms-open-shortcuts')));
      await tester.ensureVisible(find.byKey(const Key('sms-guide')));
      await tester.tap(find.byKey(const Key('sms-guide')));
      await tester.pumpAndSettle();
      expect(maps.links, [Uri.parse('shortcuts://'), Uri.parse(iosSmsGuideUrl)]);
      maps.linksOpen = false;
      await tester.tap(find.byKey(const Key('sms-guide')));
      await tester.pumpAndSettle();
      expect(find.text('Could not open $iosSmsGuideUrl'), findsOneWidget);
    });

    testWidgets('onboarding wording points to the Shortcuts setup', (tester) async {
      platform.shortcuts = true;
      final fresh = makeState(onboarded: false, sms: platform, notifications: notes);
      await pumpScreen(tester, fresh, OnboardingScreen(steps: [(_, next) => SmsStep(onNext: next)]));
      expect(find.textContaining('A Shortcuts automation can hand each bank'), findsOneWidget);
      await tester.tap(find.text('Turn on'));
      await tester.pumpAndSettle();
      expect([fresh.sms.enabled, fresh.onboarded], [true, true]);
    });
  });

  testWidgets('settings shows the entry only where SMS can be read', (tester) async {
    await pumpRoute(tester, s, const SettingsScreen());
    await tester.ensureVisible(find.byKey(const Key('open-sms')));
    expect(find.descendant(of: find.byKey(const Key('open-sms')), matching: find.text('Off')), findsOneWidget);
    await tester.tap(find.byKey(const Key('open-sms')));
    await tester.pumpAndSettle();
    expect(find.byType(SmsScreen), findsOneWidget);

    final ios = makeState(sms: FakeSmsPlatform(isSupported: false));
    await pumpRoute(tester, ios, const SettingsScreen());
    expect(find.byKey(const Key('open-sms')), findsNothing);
  });

  testWidgets('home shows a review banner while captures wait', (tester) async {
    await pumpScreen(tester, s, inScaffold(HomeScreen(onOpenInsights: () {}, onOpenInvestments: () {}, onOpenDebts: () {})));
    expect(find.byKey(const Key('home-sms-review')), findsNothing);
    await capture();
    s.changed();
    await tester.pump();
    expect(find.text('1 transaction from SMS to review'), findsOneWidget);
    await capture(_salary);
    s.changed();
    await tester.pump();
    expect(find.text('2 transactions from SMS to review'), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-sms-review')));
    await tester.pumpAndSettle();
    expect(find.byType(SmsScreen), findsOneWidget);
  });

  group('app', () {
    Future<void> pumpApp(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 9000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ExpenseApp(state: s));
      await tester.pumpAndSettle();
    }

    testWidgets('tapping an SMS notification opens the prefilled form', (tester) async {
      final id = await capture();
      await pumpApp(tester);
      notes.handler!(NotificationTap('sms:$id'));
      await tester.pumpAndSettle();
      expect(find.byType(TxnFormScreen), findsOneWidget);
      expect(find.text('Swiggy'), findsWidgets);
      await tester.ensureVisible(find.byKey(const Key('save-txn')));
      await tester.tap(find.byKey(const Key('save-txn')));
      await tester.pumpAndSettle();
      expect(s.sms.capture(id)!.status, CaptureStatus.added);
      expect(s.txns.byId(s.sms.capture(id)!.txnId!)!.txn.occurredAt, _at);
    });

    testWidgets('the "Add" button saves without opening anything', (tester) async {
      final id = await capture();
      await pumpApp(tester);
      notes.handler!(NotificationTap('sms:$id', smsActionAdd));
      await tester.pumpAndSettle();
      expect(find.byType(TxnFormScreen), findsNothing);
      expect(s.sms.capture(id)!.status, CaptureStatus.added);
    });

    testWidgets('a capture waiting before launch opens once the app is up', (tester) async {
      final id = await capture();
      notes.launch = NotificationTap('sms:$id', smsActionEdit);
      await s.startup();
      expect(s.smsToOpen.value?.id, id);
      await pumpApp(tester);
      expect(find.byType(TxnFormScreen), findsOneWidget);
      expect(s.smsToOpen.value, isNull);
    });

    testWidgets('nothing opens before onboarding; coming back refreshes', (tester) async {
      final fresh = makeState(notifications: notes, onboarded: false);
      fresh.sms.enabled = true;
      final id = (await fresh.sms.receive('AD-HDFCBK', _swiggy, _at))!;
      fresh.smsToOpen.value = fresh.sms.capture(id);
      s = fresh;
      await pumpApp(tester);
      expect(find.byType(TxnFormScreen), findsNothing);
      var refreshed = 0;
      fresh.addListener(() => refreshed++);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(refreshed, 1);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
