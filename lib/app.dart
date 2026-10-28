import 'package:flutter/material.dart';

import 'core/flavor.dart';
import 'l10n/l10n.dart';
import 'state/app_state.dart';
import 'ui/screens/shell.dart';
import 'ui/theme/tokens.dart';

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key, required this.state, this.flavor});

  final AppState state;

  /// Defaults to the build's flavor; dev builds get a DEV corner banner.
  final Flavor? flavor;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: Builder(
        builder: (context) => MaterialApp(
          onGenerateTitle: (context) => context.l10n.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: AppScope.of(context).themeMode,
          home: const HomeShell(),
          builder: (context, child) => (flavor ?? currentFlavor) == Flavor.dev ? Banner(message: 'DEV', location: BannerLocation.topEnd, child: child!) : child!,
        ),
      ),
    );
  }
}
