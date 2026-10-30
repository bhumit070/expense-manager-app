import 'package:flutter/material.dart';

import 'core/flavor.dart';
import 'l10n/l10n.dart';
import 'state/app_state.dart';
import 'state/sms_inbox.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/lock_screen.dart';
import 'ui/screens/shell.dart';
import 'ui/screens/txn_form_screen.dart';
import 'ui/theme/tokens.dart';

class ExpenseApp extends StatelessWidget {
  ExpenseApp({super.key, required this.state, this.flavor});

  final AppState state;

  /// Defaults to the build's flavor; dev builds get a DEV corner banner.
  final Flavor? flavor;

  final _navigator = GlobalKey<NavigatorState>();

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
          navigatorKey: _navigator,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: AppScope.of(context).themeMode,
          home: AppScope.of(context).onboarded ? const HomeShell() : const OnboardingScreen(),
          builder: (context, child) {
            final gated = SecurityGate(
              child: AppEvents(navigator: _navigator, child: child!),
            );
            return (flavor ?? currentFlavor) == Flavor.dev ? Banner(message: 'DEV', location: BannerLocation.topEnd, child: gated) : gated;
          },
        ),
      ),
    );
  }
}

/// Refreshes screens when the app comes back to the foreground (a
/// notification button may have added a transaction in the background) and
/// opens SMS captures in the add form when their notification is tapped.
class AppEvents extends StatefulWidget {
  const AppEvents({super.key, required this.navigator, required this.child});

  final GlobalKey<NavigatorState> navigator;
  final Widget child;

  @override
  State<AppEvents> createState() => _AppEventsState();
}

class _AppEventsState extends State<AppEvents> with WidgetsBindingObserver {
  late final AppState _app;

  @override
  void initState() {
    super.initState();
    _app = AppScope.read(context);
    WidgetsBinding.instance.addObserver(this);
    _app.smsToOpen.addListener(_openSms);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openSms());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _app.smsToOpen.removeListener(_openSms);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _app.changed();
  }

  void _openSms() {
    final c = _app.smsToOpen.value;
    final nav = widget.navigator.currentState;
    if (c == null || nav == null || !_app.onboarded) return;
    _app.smsToOpen.value = null;
    nav.push(MaterialPageRoute<bool>(builder: (_) => smsForm(_app, c)));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The add form prefilled from an SMS capture; saving marks it added.
Widget smsForm(AppState app, SmsCapture c) => TxnFormScreen(
  prefill: app.sms.draft(c),
  onSaved: (id) {
    app.sms.markAdded(c.id, id);
    app.reminders.service.cancel(smsNotificationBase + c.id);
  },
);
