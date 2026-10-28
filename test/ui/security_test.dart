import 'dart:io';

import 'package:expense_manager/app.dart';
import 'package:expense_manager/data/database.dart';
import 'package:expense_manager/ui/screens/lock_screen.dart';
import 'package:expense_manager/ui/screens/security_screen.dart';
import 'package:expense_manager/ui/screens/settings_screen.dart';
import 'package:expense_manager/ui/screens/shell.dart';
import 'package:expense_manager/state/security_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';
import '../security_fakes.dart';

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.byKey(Key('pin-$d')));
  }
  await tester.pump();
  await tester.tap(find.byKey(const Key('pin-ok')));
  await tester.pumpAndSettle();
}

Future<void> lifecycle(WidgetTester tester, AppLifecycleState state) async {
  tester.binding.handleAppLifecycleStateChanged(state);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('PinPad: 4–6 digits, backspace and submit', (tester) async {
    final s = makeState();
    String? got;
    await pumpScreen(
      tester,
      s,
      Scaffold(
        body: PinPad(title: 'PIN', onSubmit: (p) => got = p),
      ),
    );
    FilledButton ok() => tester.widget<FilledButton>(find.byKey(const Key('pin-ok')));
    for (final d in '123'.split('')) {
      await tester.tap(find.byKey(Key('pin-$d')));
    }
    await tester.pump();
    expect(ok().onPressed, isNull);
    for (final d in '4567890'.split('')) {
      await tester.tap(find.byKey(Key('pin-$d')));
    }
    await tester.tap(find.byKey(const Key('pin-back')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pin-ok')));
    await tester.pump();
    expect(got, '12345');
    // Empty after submit; backspace on empty is a no-op.
    await tester.tap(find.byKey(const Key('pin-back')));
    await tester.pump();
    expect(ok().onPressed, isNull);
    expect(find.byKey(const Key('pin-bio')), findsNothing);
    expect(find.text('Enter 4–6 digits'), findsOneWidget);
  });

  testWidgets('cold start shows the lock screen; wrong PINs, cooldown, then unlock', (tester) async {
    var now = kNow;
    final first = makeSecureState(bio: FakeBiometrics(isAvailable: false));
    first.state.security.setPin('2468');
    final f = makeSecureState(db: first.state.db, bio: first.bio, clock: () => now);
    await tester.pumpWidget(ExpenseApp(state: f.state));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
    expect(find.byType(HomeShell, skipOffstage: false), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
    expect(find.byKey(const Key('pin-bio')), findsNothing);
    expect(f.bio.prompts, 0, reason: 'biometrics not turned on');
    expect(f.window.calls, [true]);

    await enterPin(tester, '1111');
    expect(find.text('Wrong PIN · 4 attempts left'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await enterPin(tester, '1111');
    }
    expect(find.text('Too many attempts. Try again in 30 s'), findsOneWidget);
    await enterPin(tester, '2468');
    expect(find.text('Too many attempts. Try again in 30 s'), findsOneWidget);
    now = now.add(const Duration(seconds: 31));
    await enterPin(tester, '2468');
    expect(find.byKey(const Key('lock-screen')), findsNothing);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('background → privacy cover and relock; biometrics unlock', (tester) async {
    final f = makeSecureState();
    f.state.security
      ..setPin('1234')
      ..biometricsOn = true;
    f.bio.result = false;
    await tester.pumpWidget(ExpenseApp(state: f.state));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lock-screen')), findsNothing);

    await lifecycle(tester, AppLifecycleState.inactive);
    expect(find.byKey(const Key('privacy-cover')), findsOneWidget);
    await lifecycle(tester, AppLifecycleState.hidden);
    await lifecycle(tester, AppLifecycleState.paused);
    expect(find.byKey(const Key('privacy-cover')), findsOneWidget);
    await lifecycle(tester, AppLifecycleState.detached);
    await lifecycle(tester, AppLifecycleState.resumed);
    expect(find.byKey(const Key('privacy-cover')), findsNothing);
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
    expect(f.bio.prompts, 1, reason: 'offered on show');
    f.bio.result = true;
    await tester.tap(find.byKey(const Key('pin-bio')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lock-screen')), findsNothing);

    // With the privacy option off there is no cover.
    f.state.security.hideInSwitcher = false;
    await lifecycle(tester, AppLifecycleState.inactive);
    expect(find.byKey(const Key('privacy-cover')), findsNothing);
    await lifecycle(tester, AppLifecycleState.resumed);
  });

  testWidgets('Settings → App lock & privacy: turn on, change PIN, options, turn off', (tester) async {
    final f = makeSecureState(bio: FakeBiometrics(isAvailable: false));
    final sec = f.state.security;
    await pumpRoute(tester, f.state, const SettingsScreen());
    expect(find.descendant(of: find.byKey(const Key('open-security')), matching: find.text('Off')), findsOneWidget);
    await tester.tap(find.byKey(const Key('open-security')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('change-pin')), findsNothing);

    // Back out of PIN setup: stays off.
    await tester.tap(find.byKey(const Key('lock-switch')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(sec.lockEnabled, isFalse);

    await tester.tap(find.byKey(const Key('lock-switch')));
    await tester.pumpAndSettle();
    expect(find.text('Choose a PIN'), findsOneWidget);
    await enterPin(tester, '1234');
    expect(find.text('Confirm your PIN'), findsOneWidget);
    await enterPin(tester, '9999');
    expect(find.text("PINs didn't match. Try again."), findsOneWidget);
    await enterPin(tester, '1234');
    await enterPin(tester, '1234');
    expect(find.text('App lock is on'), findsOneWidget);
    expect(sec.lockEnabled, isTrue);
    expect(sec.checkPin('1234'), PinResult.ok);
    expect(find.text('Not available on this device'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('bio-switch'))).onChanged, isNull);

    await tester.tap(find.text('1 min'));
    await tester.pump();
    expect(sec.timeout, const Duration(minutes: 1));
    await tester.tap(find.byKey(const Key('hide-switch')));
    await tester.pump();
    expect(sec.hideInSwitcher, isFalse);

    // Change PIN: back out, then wrong, then right.
    await tester.tap(find.byKey(const Key('change-pin')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('change-pin')));
    await tester.pumpAndSettle();
    await enterPin(tester, '0000');
    expect(find.text('Wrong PIN'), findsOneWidget);
    await enterPin(tester, '1234');
    await enterPin(tester, '567890');
    await enterPin(tester, '567890');
    expect(find.text('PIN changed'), findsOneWidget);
    expect(sec.checkPin('567890'), PinResult.ok);

    // Turning off asks for the PIN.
    await tester.tap(find.byKey(const Key('lock-switch')));
    await tester.pumpAndSettle();
    await enterPin(tester, '567890');
    expect(sec.lockEnabled, isFalse);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const Key('open-security')), matching: find.text('Off')), findsOneWidget);
  });

  testWidgets('change PIN backed out after confirming keeps the old PIN', (tester) async {
    final f = makeSecureState();
    final sec = f.state.security..setPin('1234');
    await pumpRoute(tester, f.state, const SecurityScreen());
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('bio-switch'))).value, isFalse);
    await tester.tap(find.byKey(const Key('bio-switch')));
    await tester.pumpAndSettle();
    expect(sec.biometricsOn, isTrue);
    await tester.tap(find.byKey(const Key('change-pin')));
    await tester.pumpAndSettle();
    await enterPin(tester, '1234');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('PIN changed'), findsNothing);
    expect(sec.checkPin('1234'), PinResult.ok);
  });

  testWidgets('confirm PIN screen shows the cooldown', (tester) async {
    final f = makeSecureState();
    final sec = f.state.security..setPin('1234');
    for (var i = 0; i < 4; i++) {
      sec.checkPin('0000');
    }
    await pumpRoute(tester, f.state, const ConfirmPinScreen());
    await enterPin(tester, '0000');
    expect(find.text('Too many attempts. Try again in 30 s'), findsOneWidget);
    await enterPin(tester, '1234');
    expect(find.text('Too many attempts. Try again in 30 s'), findsOneWidget);
  });

  testWidgets('encryption is unavailable for an in-memory database', (tester) async {
    await pumpRoute(tester, makeSecureState().state, const SecurityScreen());
    expect(find.text('Not available for this database'), findsOneWidget);
  });

  testWidgets('encryption toggle: encrypt, decrypt, and errors', (tester) async {
    final dir = Directory.systemTemp.createTempSync('encui');
    final f = makeSecureState(db: openAppDatabase('${dir.path}/a.db'));
    await pumpRoute(tester, f.state, const SecurityScreen());
    await tester.tap(find.byKey(const Key('encrypt-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(f.state.security.encrypted, isFalse);
    await tester.tap(find.byKey(const Key('encrypt-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('encrypt-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Database encrypted'), findsOneWidget);
    expect(f.state.security.encrypted, isTrue);
    await tester.tap(find.byKey(const Key('encrypt-switch')));
    await tester.pumpAndSettle();
    expect(find.text('Database decrypted'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    f.state.db.close();

    final g = makeSecureState(db: openAppDatabase('${dir.path}/b.db'), keys: FailingKeys());
    await pumpRoute(tester, g.state, const SecurityScreen());
    await tester.tap(find.byKey(const Key('encrypt-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('encrypt-confirm')));
    await tester.pumpAndSettle();
    expect(find.textContaining("Couldn't change encryption"), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    g.state.db.close();
    dir.deleteSync(recursive: true);
  });

  test('timeout labels', () {
    expect([for (final d in SecurityState.timeouts) timeoutLabel(d)], ['Immediately', '30 s', '1 min', '5 min']);
  });
}
