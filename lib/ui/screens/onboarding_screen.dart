import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'sources_screen.dart';
import 'security_screen.dart';
import '../theme/icons.dart';

/// One page of the first-launch flow. [next] moves on (or finishes).
typedef OnboardingStep = Widget Function(BuildContext context, VoidCallback next);

/// Pages shown on first launch, in order. Features add their steps here.
List<OnboardingStep> defaultOnboardingSteps({bool sms = false}) => [
  (_, next) => WelcomeStep(onNext: next),
  (_, next) => NameStep(onNext: next),
  (_, next) => CurrencyStep(onNext: next),
  (_, next) => SourceStep(onNext: next),
  (_, next) => LocationStep(onNext: next),
  (_, next) => NotificationsStep(onNext: next),
  if (sms) (_, next) => SmsStep(onNext: next),
  (_, next) => AppLockStep(onNext: next),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.steps});

  /// Defaults to [defaultOnboardingSteps].
  final List<OnboardingStep>? steps;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final List<OnboardingStep> _steps = widget.steps ?? defaultOnboardingSteps(sms: AppScope.read(context).smsPlatform.supported);
  final _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_index == _steps.length - 1) {
      AppScope.read(context).completeOnboarding();
      return;
    }
    _pages.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  Row(
                    key: const Key('onboarding-dots'),
                    children: [
                      for (var i = 0; i < _steps.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 6),
                          width: i == _index ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(color: i == _index ? c.brand : c.track, borderRadius: BorderRadius.circular(4)),
                        ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(key: const Key('onboarding-skip'), onPressed: _next, child: Text(_index == _steps.length - 1 ? context.l10n.finish : context.l10n.skip)),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [for (final step in _steps) Builder(builder: (context) => step(context, _next))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared page layout: big icon, title, body, then a primary action.
class StepLayout extends StatelessWidget {
  const StepLayout({super.key, required this.icon, required this.title, required this.body, required this.action, required this.onAction, this.children = const [], this.secondary});

  final IconData icon;
  final String title;
  final String body;
  final List<Widget> children;
  final String action;
  final VoidCallback onAction;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        IconBadge(icon, color: c.brand, background: c.brandSoft, size: 64),
        const SizedBox(height: 24),
        Text(
          title,
          style: ts(26, weight: FontWeight.w800, color: c.text, spacing: -0.5),
        ),
        const SizedBox(height: 10),
        Text(body, style: ts(14, color: c.textMuted, height: 1.45)),
        const SizedBox(height: 24),
        ...children,
        const SizedBox(height: 24),
        FilledButton(key: const Key('onboarding-next'), onPressed: onAction, child: Text(action)),
        if (secondary != null) ...[const SizedBox(height: 8), secondary!],
      ],
    );
  }
}

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final app = AppScope.of(context);
    Widget point(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: c.positive),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: ts(14, weight: FontWeight.w600, color: c.text),
            ),
          ),
        ],
      ),
    );
    return StepLayout(
      icon: AppIcons.shield,
      title: l.onbWelcomeTitle,
      body: l.onbWelcomeBody,
      action: l.onbGetStarted,
      onAction: onNext,
      children: [
        point(AppIcons.lock, l.onbPointLocal),
        point(AppIcons.offline, l.onbPointOffline),
        point(AppIcons.download, l.onbPointExport),
        const SizedBox(height: 8),
        Wrap(
          key: const Key('onboarding-languages'),
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final lang in appLanguages)
              Pill(lang.name, key: Key('onboarding-language-${lang.code}'), icon: AppIcons.language, selected: app.locale.languageCode == lang.code, onTap: () => app.language = lang.code),
          ],
        ),
      ],
    );
  }
}

class NameStep extends StatefulWidget {
  const NameStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late final _name = TextEditingController(text: AppScope.read(context).userName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    AppScope.read(context).userName = _name.text;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) => StepLayout(
    icon: AppIcons.wave,
    title: context.l10n.onbNameTitle,
    body: context.l10n.onbNameBody,
    action: context.l10n.continue_,
    onAction: _save,
    children: [
      TextField(
        key: const Key('onboarding-name'),
        controller: _name,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: context.l10n.settingsYourName),
        onSubmitted: (_) => _save(),
      ),
    ],
  );
}

class CurrencyStep extends StatelessWidget {
  const CurrencyStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return StepLayout(
      icon: AppIcons.currency,
      title: context.l10n.onbCurrencyTitle,
      body: context.l10n.onbCurrencyBody,
      action: context.l10n.continue_,
      onAction: onNext,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final cur in currencies)
              Pill('${cur.symbol.trim()}  ${cur.code}', key: Key('onboarding-currency-${cur.code}'), selected: cur.code == app.currency.code, onTap: () => app.currency = cur),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.onbCurrencySample(app.currency.localName, formatInr(12345600)),
          key: const Key('onboarding-currency-sample'),
          style: ts(13, color: context.colors.textMuted),
        ),
      ],
    );
  }
}

class SourceStep extends StatefulWidget {
  const SourceStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<SourceStep> createState() => _SourceStepState();
}

class _SourceStepState extends State<SourceStep> {
  final _name = TextEditingController();
  final _balance = TextEditingController();
  SourceKind _kind = SourceKind.bank;

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  void _save() {
    final app = AppScope.read(context);
    if (_name.text.trim().isNotEmpty) {
      final balance = parseInr(_balance.text) ?? 0;
      app.catalog.addSource(name: _name.text, kind: _kind, openingBalance: _kind == SourceKind.card ? -balance : balance, makeDefault: true);
      app.changed();
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return StepLayout(
      icon: AppIcons.wallet,
      title: context.l10n.onbSourceTitle,
      body: context.l10n.onbSourceBody(app.catalog.defaultSource()?.name ?? context.l10n.sourceKindCash),
      action: context.l10n.continue_,
      onAction: _save,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final k in SourceKind.values) Pill(sourceKindLabel(k), key: Key('onboarding-kind-${k.name}'), selected: k == _kind, onTap: () => setState(() => _kind = k))],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('onboarding-source-name'),
          controller: _name,
          decoration: InputDecoration(labelText: context.l10n.sourceNameField),
        ),
        const SizedBox(height: 10),
        TextField(
          key: const Key('onboarding-source-balance'),
          controller: _balance,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: InputDecoration(labelText: balanceFieldLabel(_kind), helperText: context.l10n.optional),
        ),
      ],
    );
  }
}

class LocationStep extends StatefulWidget {
  const LocationStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  bool _denied = false;

  Future<void> _allow() async {
    final app = AppScope.read(context);
    final granted = await app.location.requestPermission();
    app.locationEnabled = granted;
    if (!mounted) return;
    if (granted) {
      widget.onNext();
    } else {
      setState(() => _denied = true);
    }
  }

  void _skip() {
    AppScope.read(context).locationEnabled = false;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return StepLayout(
      icon: AppIcons.place,
      title: context.l10n.onbLocationTitle,
      body: context.l10n.onbLocationBody,
      action: _denied ? context.l10n.onbLocationContinue : context.l10n.onbLocationAllow,
      onAction: _denied ? widget.onNext : _allow,
      secondary: _denied ? null : TextButton(key: const Key('onboarding-location-skip'), onPressed: _skip, child: Text(context.l10n.notNow)),
      children: [
        if (_denied)
          Text(
            context.l10n.onbLocationDenied,
            key: const Key('onboarding-location-denied'),
            style: ts(13, color: c.spend),
          ),
      ],
    );
  }
}

/// Offers to read bank SMS and ask before adding each transaction (Android).
class SmsStep extends StatefulWidget {
  const SmsStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<SmsStep> createState() => _SmsStepState();
}

class _SmsStepState extends State<SmsStep> {
  bool _denied = false;

  Future<void> _allow() async {
    final result = await AppScope.read(context).enableSms();
    if (!mounted) return;
    if (result == SmsEnableResult.denied) {
      setState(() => _denied = true);
    } else {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return StepLayout(
      icon: AppIcons.sms,
      title: context.l10n.onbSmsTitle,
      body: AppScope.of(context).smsPlatform.viaShortcuts ? context.l10n.onbSmsBodyShortcuts : context.l10n.onbSmsBody,
      action: _denied ? context.l10n.onbSmsContinue : (AppScope.of(context).smsPlatform.viaShortcuts ? context.l10n.turnOn : context.l10n.onbSmsAllow),
      onAction: _denied ? widget.onNext : _allow,
      secondary: _denied ? null : TextButton(key: const Key('onboarding-sms-skip'), onPressed: widget.onNext, child: Text(context.l10n.notNow)),
      children: [
        if (_denied)
          Text(
            context.l10n.onbSmsDenied,
            key: const Key('onboarding-sms-denied'),
            style: ts(13, color: c.spend),
          ),
      ],
    );
  }
}

/// Offers to protect the app with a PIN (and biometrics later in Settings).
class AppLockStep extends StatelessWidget {
  const AppLockStep({super.key, required this.onNext, this.setUp = setUpAppLock});

  final VoidCallback onNext;
  final Future<bool> Function(BuildContext) setUp;

  Future<void> _enable(BuildContext context) async {
    await setUp(context);
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      icon: AppIcons.lock,
      title: context.l10n.onbLockTitle,
      body: context.l10n.onbLockBody,
      action: context.l10n.onbLockAction,
      onAction: () => _enable(context),
      secondary: TextButton(key: const Key('onboarding-lock-skip'), onPressed: onNext, child: Text(context.l10n.notNow)),
    );
  }
}

/// Offers budget alerts and due-date reminders (asks for permission).
class NotificationsStep extends StatefulWidget {
  const NotificationsStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<NotificationsStep> createState() => _NotificationsStepState();
}

class _NotificationsStepState extends State<NotificationsStep> {
  bool _denied = false;

  Future<void> _allow() async {
    final granted = await AppScope.read(context).reminders.enable();
    if (!mounted) return;
    if (granted) {
      widget.onNext();
    } else {
      setState(() => _denied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return StepLayout(
      icon: AppIcons.notifications,
      title: context.l10n.onbRemindersTitle,
      body: context.l10n.onbRemindersBody,
      action: _denied ? context.l10n.onbRemindersContinue : context.l10n.onbRemindersAllow,
      onAction: _denied ? widget.onNext : _allow,
      secondary: _denied ? null : TextButton(key: const Key('onboarding-notif-skip'), onPressed: widget.onNext, child: Text(context.l10n.notNow)),
      children: [
        if (_denied)
          Text(
            context.l10n.onbRemindersDenied,
            key: const Key('onboarding-notif-denied'),
            style: ts(13, color: c.spend),
          ),
      ],
    );
  }
}
