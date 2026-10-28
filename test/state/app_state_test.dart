import 'package:expense_manager/core/money.dart';
import 'package:expense_manager/data/database.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('settings-backed properties notify listeners', () {
    final s = makeState();
    var n = 0;
    s.addListener(() => n++);
    expect(s.themeMode, ThemeMode.system);
    s.themeMode = ThemeMode.dark;
    expect(s.themeMode, ThemeMode.dark);
    expect(s.userName, '');
    s.userName = '  Bhumit ';
    expect(s.userName, 'Bhumit');
    expect(s.locationEnabled, isTrue);
    s.locationEnabled = false;
    expect(s.locationEnabled, isFalse);
    s.changed();
    expect(n, 4);
    expect(s.now(), kNow);
    s.dispose();
  });

  test('currency is persisted and applied when the state is created', () {
    addTearDown(() => currentCurrency = inr);
    final s = makeState();
    var n = 0;
    s.addListener(() => n++);
    expect(s.currency, same(inr));
    s.currency = currencyByCode('GBP');
    expect(n, 1);
    expect(formatInr(100), '£1');
    currentCurrency = inr;
    AppState(db: s.db, files: FakeFiles(), location: FakeLocation());
    expect(currentCurrency.code, 'GBP');
    // a fresh database resets to INR
    makeState();
    expect(currentCurrency, same(inr));
  });

  test('default clock is the wall clock', () {
    final s = AppState(db: openAppDatabase(null), files: FakeFiles(), location: FakeLocation());
    expect(s.now().difference(DateTime.now()).inSeconds.abs(), lessThan(5));
  });

  testWidgets('AppScope.of subscribes and read does not', (tester) async {
    final s = makeState();
    var builds = 0;
    await tester.pumpWidget(
      AppScope(
        state: s,
        child: Builder(
          builder: (context) {
            builds++;
            expect(AppScope.read(context), same(s));
            return Text(AppScope.of(context).userName, textDirection: TextDirection.ltr);
          },
        ),
      ),
    );
    s.userName = 'A';
    await tester.pump();
    expect(find.text('A'), findsOneWidget);
    expect(builds, 2);
  });
}
