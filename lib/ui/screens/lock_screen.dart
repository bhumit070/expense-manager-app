import 'dart:ui';

import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../state/security_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../theme/icons.dart';

/// PIN dots plus a number pad. [onSubmit] gets 4–6 digits.
class PinPad extends StatefulWidget {
  const PinPad({super.key, required this.title, required this.onSubmit, this.message, this.messageIsError = false, this.onBiometrics, this.submitLabel = 'Continue'});

  final String title;
  final String? message;
  final bool messageIsError;
  final String submitLabel;
  final void Function(String pin) onSubmit;
  final VoidCallback? onBiometrics;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  var _pin = '';

  void _tap(String d) {
    if (_pin.length < 6) setState(() => _pin += d);
  }

  void _back() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _submit() {
    final pin = _pin;
    setState(() => _pin = '');
    widget.onSubmit(pin);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget key(String label, {Key? key, VoidCallback? onTap, Widget? child}) => SizedBox(
      width: 76,
      height: 64,
      child: TextButton(
        key: key,
        onPressed: onTap,
        style: TextButton.styleFrom(shape: const CircleBorder(), foregroundColor: c.text),
        child: child ?? Text(label, style: ts(26, weight: FontWeight.w600)),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: ts(20, weight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34,
          child: Text(
            key: const Key('pin-message'),
            widget.message ?? 'Enter 4–6 digits',
            textAlign: TextAlign.center,
            style: ts(12, color: widget.messageIsError ? c.spend : c.textMuted),
          ),
        ),
        Row(
          key: const Key('pin-dots'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 6; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length ? c.brand : Colors.transparent,
                  border: Border.all(color: i < _pin.length ? c.brand : (i < 4 ? c.textMuted : c.line), width: 1.5),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final d in row) key(d, key: Key('pin-$d'), onTap: () => _tap(d))],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.onBiometrics == null
                ? const SizedBox(width: 76, height: 64)
                : key(
                    '',
                    key: const Key('pin-bio'),
                    onTap: widget.onBiometrics,
                    child: Icon(AppIcons.fingerprint, size: 30, color: c.brand),
                  ),
            key('0', key: const Key('pin-0'), onTap: () => _tap('0')),
            key('', key: const Key('pin-back'), onTap: _back, child: const Icon(AppIcons.backspace)),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('pin-ok'),
          style: FilledButton.styleFrom(minimumSize: const Size(220, 48)),
          onPressed: SecurityState.validPin(_pin) ? _submit : null,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}

/// Covers the app until the PIN or biometrics unlock it.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    // Offer biometrics straight away; the PIN pad stays as the fallback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppScope.read(context).security.unlockWithBiometrics();
    });
  }

  void _submit(SecurityState sec, String pin) {
    final result = sec.checkPin(pin);
    setState(
      () => _error = switch (result) {
        PinResult.ok => null,
        PinResult.wrong when sec.cooldownLeft > Duration.zero => 'Too many attempts. Try again in ${sec.cooldownLeft.inSeconds} s',
        PinResult.wrong => 'Wrong PIN · ${SecurityState.maxAttempts - sec.failedAttempts} attempts left',
        PinResult.coolingDown => 'Too many attempts. Try again in ${sec.cooldownLeft.inSeconds} s',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sec = AppScope.of(context).security;
    final c = context.colors;
    return Material(
      key: const Key('lock-screen'),
      color: c.bg,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                IconBadge(AppIcons.lock, color: Colors.white, background: c.hero, size: 64),
                const SizedBox(height: 20),
                PinPad(
                  title: 'Expense Manager is locked',
                  message: _error,
                  messageIsError: _error != null,
                  submitLabel: 'Unlock',
                  onSubmit: (pin) => _submit(sec, pin),
                  onBiometrics: sec.biometricsOn ? sec.unlockWithBiometrics : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown over the app while it is inactive so the app-switcher snapshot
/// doesn't reveal amounts (iOS; Android also uses FLAG_SECURE).
class PrivacyCover extends StatelessWidget {
  const PrivacyCover({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BackdropFilter(
      key: const Key('privacy-cover'),
      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: ColoredBox(
        color: c.hero.withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(AppIcons.wallet, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                'Expense Manager',
                style: ts(18, weight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps the whole app: applies the window privacy flag, tracks background
/// time for the lock timeout and shows the lock screen / privacy cover.
class SecurityGate extends StatefulWidget {
  const SecurityGate({super.key, required this.child});

  final Widget child;

  @override
  State<SecurityGate> createState() => _SecurityGateState();
}

class _SecurityGateState extends State<SecurityGate> with WidgetsBindingObserver {
  var _covered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppScope.read(context).security.applyWindow();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sec = AppScope.read(context).security;
    switch (state) {
      case AppLifecycleState.inactive:
        setState(() => _covered = sec.hideInSwitcher);
      case AppLifecycleState.hidden || AppLifecycleState.paused:
        setState(() => _covered = sec.hideInSwitcher);
        sec.wentToBackground();
      case AppLifecycleState.resumed:
        setState(() => _covered = false);
        sec.cameToForeground();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sec = AppScope.of(context).security;
    return ListenableBuilder(
      listenable: sec,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          // Offstage so nothing behind the lock screen is painted or read out.
          Offstage(offstage: sec.locked, child: widget.child),
          if (sec.locked) const LockScreen(),
          if (_covered) const PrivacyCover(),
        ],
      ),
    );
  }
}
