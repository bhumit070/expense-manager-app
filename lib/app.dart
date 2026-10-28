import 'package:flutter/material.dart';

import 'state/app_state.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/lock_screen.dart';
import 'ui/screens/shell.dart';
import 'ui/theme/tokens.dart';

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: Builder(
        builder: (context) => MaterialApp(
          title: 'Expense Manager',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: AppScope.of(context).themeMode,
          home: AppScope.of(context).onboarded ? const HomeShell() : const OnboardingScreen(),
          builder: (context, child) => SecurityGate(child: child!),
        ),
      ),
    );
  }
}
