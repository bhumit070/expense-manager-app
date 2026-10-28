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

AppState _seeded() {
  final s = makeState()..locationEnabled = false;
  seed(s);
  s.planning.addBudget(Budget(name: 'Food', period: BudgetPeriod.monthly, limit: 800000, categoryIds: [catId(s, 'Food & dining')]));
  return s;
}

final _screens = <String, Widget Function()>{
  'home': () => const HomeShell(),
  'transactions': () => const TransactionsScreen(),
  'add transaction': () => const TxnFormScreen(),
  'insights': () => inScaffold(const InsightsScreen()),
  'budgets': () => const BudgetsScreen(),
  'investments': () => inScaffold(const InvestmentsScreen()),
  'debts': () => inScaffold(const DebtsScreen()),
  'settings': () => const SettingsScreen(),
  'onboarding': () => const OnboardingScreen(),
};

/// A 390-wide phone with the given text scale.
Future<void> _pump(WidgetTester tester, AppState s, Widget child, {Brightness brightness = Brightness.light, double textScale = 1, double height = 844}) async {
  tester.view.physicalSize = Size(390 * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AppScope(
      state: s,
      child: MaterialApp(
        theme: buildTheme(brightness),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: child,
      ),
    ),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() => PackageInfo.setMockInitialValues(appName: 'Expense Manager', packageName: 'x', version: '0.1.0', buildNumber: '1', buildSignature: ''));

  for (final b in Brightness.values) {
    for (final e in _screens.entries) {
      testWidgets('${e.key} meets tap-target, label and contrast guidelines · ${b.name}', (tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, _seeded(), e.value(), brightness: b);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  }

  for (final scale in [1.5, 2.0]) {
    for (final e in _screens.entries) {
      testWidgets('${e.key} lays out at $scale× text', (tester) async {
        await _pump(tester, _seeded(), e.value(), textScale: scale);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
