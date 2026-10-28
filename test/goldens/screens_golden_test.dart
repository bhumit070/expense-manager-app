@Tags(['golden'])
library;

import 'package:expense_manager/app.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:expense_manager/ui/screens/budgets_screen.dart';
import 'package:expense_manager/ui/screens/debts_screen.dart';
import 'package:expense_manager/ui/screens/insights_screen.dart';
import 'package:expense_manager/ui/screens/investments_screen.dart';
import 'package:expense_manager/ui/screens/onboarding_screen.dart';
import 'package:expense_manager/ui/screens/settings_screen.dart';
import 'package:expense_manager/ui/screens/shell.dart';
import 'package:expense_manager/ui/screens/transactions_screen.dart';
import 'package:expense_manager/ui/screens/txn_form_screen.dart';
import 'package:expense_manager/ui/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers.dart';
import '../security_fakes.dart';

/// A 390×844 phone at 2× density.
void _phone(WidgetTester tester) {
  // Real shadows instead of flutter_test's solid outlines; [_match] resets it.
  debugDisableShadows = false;
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

Future<void> _match(String file) async {
  try {
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(file));
  } finally {
    debugDisableShadows = true;
  }
}

AppState _seeded() {
  final s = makeState()..userName = 'Bhumit';
  seed(s);
  s.planning.addBudget(Budget(name: 'Food', period: BudgetPeriod.monthly, limit: 800000, categoryIds: [catId(s, 'Food & dining')]));
  s.planning.addBudget(const Budget(name: 'All spending', period: BudgetPeriod.monthly, limit: 2500000));
  return s;
}

Future<void> _pump(WidgetTester tester, AppState s, Widget child, Brightness b) async {
  _phone(tester);
  await tester.pumpWidget(
    AppScope(
      state: s,
      child: MaterialApp(debugShowCheckedModeBanner: false, theme: buildTheme(b), home: child),
    ),
  );
  // Settle without waiting on endless animations (e.g. cursors).
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() => PackageInfo.setMockInitialValues(appName: 'Expense Manager', packageName: 'x', version: '0.1.0', buildNumber: '1', buildSignature: ''));

  final screens = <String, Widget Function()>{
    'home': () => const HomeShell(),
    'transactions': () => const TransactionsScreen(),
    'add_transaction': () => const TxnFormScreen(),
    'insights_month': () => inScaffold(const InsightsScreen()),
    'budgets': () => const BudgetsScreen(),
    'investments': () => inScaffold(const InvestmentsScreen()),
    'debts': () => inScaffold(const DebtsScreen()),
    'settings': () => const SettingsScreen(),
  };

  for (final b in Brightness.values) {
    final mode = b.name;
    for (final e in screens.entries) {
      testWidgets('${e.key} · $mode', (tester) async {
        final s = _seeded()..locationEnabled = false;
        await _pump(tester, s, e.value(), b);
        await _match('${e.key}_$mode.png');
      });
    }

    testWidgets('onboarding_welcome · $mode', (tester) async {
      final s = makeState(onboarded: false);
      await _pump(tester, s, const OnboardingScreen(), b);
      await _match('onboarding_welcome_$mode.png');
    });

    testWidgets('lock_screen · $mode', (tester) async {
      final f = makeSecureState(bio: FakeBiometrics(isAvailable: false));
      f.state.security.setPin('2468');
      f.state.themeMode = b == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      final cold = makeSecureState(db: f.state.db, bio: f.bio);
      _phone(tester);
      await tester.pumpWidget(ExpenseApp(state: cold.state));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byKey(const Key('lock-screen')), findsOneWidget);
      await _match('lock_screen_$mode.png');
    });
  }
}
