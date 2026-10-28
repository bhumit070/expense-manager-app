import 'dart:async';

import 'package:expense_manager/app.dart';
import 'package:expense_manager/core/money.dart';
import 'package:expense_manager/data/database.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:expense_manager/ui/screens/onboarding_screen.dart';
import 'package:expense_manager/ui/screens/shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Future<void> next(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('onboarding-next')));
  await tester.pumpAndSettle();
}

Future<void> pumpApp(WidgetTester tester, AppState s) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ExpenseApp(state: s));
  await tester.pump();
}

void main() {
  tearDown(() => currentCurrency = inr);

  test('a fresh install needs onboarding; one with data does not', () {
    final fresh = makeState(onboarded: false);
    expect(fresh.onboarded, isFalse);
    var n = 0;
    fresh.addListener(() => n++);
    fresh.completeOnboarding();
    expect(fresh.onboarded, isTrue);
    expect(n, 1);

    final db = openAppDatabase(null);
    final old = AppState(db: db, files: FakeFiles(), location: FakeLocation(), clock: () => kNow);
    expect(old.onboarded, isFalse);
    seed(old);
    expect(AppState(db: db, files: FakeFiles(), location: FakeLocation(), clock: () => kNow).onboarded, isTrue);
    expect(makeState().onboarded, isTrue);
  });

  testWidgets('full flow: name, currency, first source, location', (tester) async {
    final loc = FakeLocation();
    final s = makeState(onboarded: false, location: loc);
    await pumpApp(tester, s);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Your money, on your phone'), findsOneWidget);
    expect(find.textContaining('Your data stays on this phone'), findsOneWidget);
    await next(tester);

    await tester.enterText(find.byKey(const Key('onboarding-name')), '  Bhumit ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(s.userName, 'Bhumit');

    expect(find.byKey(const Key('onboarding-currency-sample')), findsOneWidget);
    expect(find.text('Indian rupee · e.g. ₹1,23,456'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding-currency-USD')));
    await tester.pump();
    expect(s.currency.code, 'USD');
    expect(find.text(r'US dollar · e.g. $123,456'), findsOneWidget);
    await next(tester);

    expect(find.textContaining('start with Cash'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding-kind-card')));
    await tester.pump();
    expect(find.text(r'Outstanding now ($)'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding-kind-bank')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('onboarding-source-name')), 'HDFC Savings');
    await tester.enterText(find.byKey(const Key('onboarding-source-balance')), '25,000');
    await next(tester);
    final hdfc = s.catalog.defaultSource()!;
    expect([hdfc.name, hdfc.kind, hdfc.openingBalance], ['HDFC Savings', SourceKind.bank, 2500000]);

    await next(tester);
    expect(loc.requests, 1);
    expect(s.locationEnabled, isTrue);

    expect(find.text('Finish'), findsOneWidget);
    expect(find.text('Lock the app?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding-lock-skip')));
    await tester.pumpAndSettle();
    expect(s.security.lockEnabled, isFalse);
    expect(s.onboarded, isTrue);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('every step can be skipped', (tester) async {
    final s = makeState(onboarded: false);
    await pumpApp(tester, s);
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byKey(const Key('onboarding-skip')));
      await tester.pumpAndSettle();
    }
    expect(s.onboarded, isTrue);
    expect(s.userName, '');
    expect(s.catalog.defaultSource()!.name, 'Cash');
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('card source is stored as outstanding; blank name adds nothing', (tester) async {
    final s = makeState(onboarded: false);
    await pumpScreen(
      tester,
      s,
      OnboardingScreen(
        steps: [
          (_, n) => SourceStep(onNext: n),
          (_, n) => SourceStep(onNext: n),
        ],
      ),
    );
    await tester.enterText(find.byKey(const Key('onboarding-source-balance')), '500');
    await next(tester);
    expect(s.catalog.sources().length, 1);
    await tester.tap(find.byKey(const Key('onboarding-kind-card')).last);
    await tester.pump();
    await tester.enterText(find.byKey(const Key('onboarding-source-name')).last, 'Amex');
    await tester.enterText(find.byKey(const Key('onboarding-source-balance')).last, '1200');
    await tester.tap(find.byKey(const Key('onboarding-next')).last);
    await tester.pumpAndSettle();
    final amex = s.catalog.defaultSource()!;
    expect([amex.name, amex.kind, amex.openingBalance], ['Amex', SourceKind.card, -120000]);
    expect(s.onboarded, isTrue);
  });

  testWidgets('location: not now turns it off; denied shows a note then continues', (tester) async {
    final loc = FakeLocation()..grant = false;
    final s = makeState(onboarded: false, location: loc);
    await pumpScreen(
      tester,
      s,
      OnboardingScreen(
        steps: [
          (_, n) => LocationStep(onNext: n),
          (_, n) => LocationStep(onNext: n),
        ],
      ),
    );
    await tester.tap(find.byKey(const Key('onboarding-location-skip')));
    await tester.pumpAndSettle();
    expect(s.locationEnabled, isFalse);
    expect(loc.requests, 0);

    await tester.tap(find.byKey(const Key('onboarding-next')).last);
    await tester.pumpAndSettle();
    expect(loc.requests, 1);
    expect(s.locationEnabled, isFalse);
    expect(find.byKey(const Key('onboarding-location-denied')), findsOneWidget);
    expect(find.text('Continue without location'), findsOneWidget);
    expect(s.onboarded, isFalse);
    await tester.tap(find.byKey(const Key('onboarding-next')).last);
    await tester.pumpAndSettle();
    expect(s.onboarded, isTrue);
  });

  testWidgets('denied after leaving the page does not touch disposed state', (tester) async {
    final loc = _SlowLocation();
    final s = makeState(onboarded: false, location: loc);
    await pumpScreen(tester, s, OnboardingScreen(steps: [(_, n) => LocationStep(onNext: n)]));
    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    loc.answer(false);
    await tester.pump();
    expect(s.locationEnabled, isFalse);
  });

  testWidgets('app lock step runs set-up then moves on', (tester) async {
    final s = makeState(onboarded: false);
    var calls = 0;
    await pumpScreen(
      tester,
      s,
      OnboardingScreen(
        steps: [
          (_, n) => AppLockStep(
            onNext: n,
            setUp: (_) async {
              calls++;
              return true;
            },
          ),
        ],
      ),
    );
    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(s.onboarded, isTrue);
  });

  testWidgets('renders in dark mode', (tester) async {
    final s = makeState(onboarded: false);
    await pumpScreen(tester, s, const OnboardingScreen(), brightness: Brightness.dark);
    expect(find.byKey(const Key('onboarding-dots')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _SlowLocation extends FakeLocation {
  final _answer = Completer<bool>();

  void answer(bool v) => _answer.complete(v);

  @override
  Future<bool> requestPermission() {
    requests++;
    return _answer.future;
  }
}
