import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../../state/security_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'lock_screen.dart';
import '../theme/icons.dart';

String timeoutLabel(Duration d) => switch (d.inSeconds) {
  0 => currentL10n.immediately,
  < 60 => currentL10n.seconds(d.inSeconds),
  _ => currentL10n.minutes(d.inMinutes),
};

/// Asks for a new PIN twice and pops with it.
class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String? _first;
  String? _error;

  void _submit(String pin) {
    if (_first == null) {
      setState(() {
        _first = pin;
        _error = null;
      });
    } else if (_first == pin) {
      Navigator.pop(context, pin);
    } else {
      setState(() {
        _first = null;
        _error = context.l10n.pinMismatch;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: SingleChildScrollView(
        child: PinPad(
          key: ValueKey(_first == null),
          title: _first == null ? context.l10n.pinChoose : context.l10n.pinConfirm,
          message: _error ?? (_first == null ? context.l10n.pinDigits : context.l10n.pinAgain),
          messageIsError: _error != null,
          onSubmit: _submit,
        ),
      ),
    ),
  );
}

/// Asks for the current PIN; pops true once it's right.
class ConfirmPinScreen extends StatefulWidget {
  const ConfirmPinScreen({super.key});

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen> {
  String? _error;

  void _submit(SecurityState sec, String pin) {
    switch (sec.checkPin(pin)) {
      case PinResult.ok:
        Navigator.pop(context, true);
      case PinResult.wrong:
      case PinResult.coolingDown:
        setState(() => _error = sec.cooldownLeft > Duration.zero ? context.l10n.pinCooldown(sec.cooldownLeft.inSeconds) : context.l10n.pinWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sec = AppScope.of(context).security;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: PinPad(title: context.l10n.pinCurrent, message: _error, messageIsError: _error != null, onSubmit: (pin) => _submit(sec, pin)),
        ),
      ),
    );
  }
}

/// Lets the user choose a PIN and turns the app lock on. Returns whether it
/// was set. Onboarding can call this for its "set up app lock" step.
Future<bool> setUpAppLock(BuildContext context) async {
  final sec = AppScope.read(context).security;
  final pin = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const SetPinScreen()));
  if (pin == null) return false;
  sec.setPin(pin);
  return true;
}

Future<bool> _confirmPin(BuildContext context) async => await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const ConfirmPinScreen())) ?? false;

/// Settings → App lock & privacy.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  late final Future<bool> _bioAvailable = AppScope.read(context).security.biometricsAvailable();

  Future<void> _toggleLock(SecurityState sec, bool on) async {
    if (on) {
      if (await setUpAppLock(context) && mounted) showSnack(context, context.l10n.lockOn);
    } else if (await _confirmPin(context)) {
      sec.disableLock();
    }
  }

  Future<void> _changePin(SecurityState sec) async {
    if (!await _confirmPin(context) || !mounted) return;
    if (await setUpAppLock(context) && mounted) showSnack(context, context.l10n.pinChanged);
  }

  Future<void> _toggleEncryption(SecurityState sec, bool on) async {
    if (on) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.encryptTitle),
          content: Text(context.l10n.encryptBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.cancel)),
            FilledButton(key: const Key('encrypt-confirm'), onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.encrypt)),
          ],
        ),
      );
      if (ok != true) return;
    }
    try {
      on ? await sec.encryptDatabase() : await sec.decryptDatabase();
      if (mounted) showSnack(context, on ? context.l10n.dbEncrypted : context.l10n.dbDecrypted);
    } catch (e) {
      if (mounted) showSnack(context, context.l10n.encryptFailed('$e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sec = AppScope.of(context).security;
    final c = context.colors;
    Widget group(String title, List<Widget> rows) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
          child: Text(
            title.toUpperCase(),
            style: ts(13, weight: FontWeight.w700, color: c.textMuted, spacing: 0.6),
          ),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: rows),
        ),
      ],
    );
    return ListenableBuilder(
      listenable: sec,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settingsAppLock, style: ts(16, weight: FontWeight.w700)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            group(context.l10n.appLock, [
              SwitchListTile(
                key: const Key('lock-switch'),
                secondary: const Icon(AppIcons.lock),
                title: Text(context.l10n.lockWithPin),
                subtitle: Text(context.l10n.lockWithPinHelp),
                value: sec.lockEnabled,
                onChanged: (v) => _toggleLock(sec, v),
              ),
              if (sec.lockEnabled) ...[
                ListTile(key: const Key('change-pin'), leading: const Icon(AppIcons.pin), title: Text(context.l10n.changePin), onTap: () => _changePin(sec)),
                FutureBuilder<bool>(
                  future: _bioAvailable,
                  builder: (context, snap) {
                    final available = snap.data ?? false;
                    return SwitchListTile(
                      key: const Key('bio-switch'),
                      secondary: const Icon(AppIcons.fingerprint),
                      title: Text(context.l10n.unlockBiometric),
                      subtitle: available ? null : Text(context.l10n.notAvailableDevice),
                      value: available && sec.biometricsOn,
                      onChanged: available ? (v) => sec.biometricsOn = v : null,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(context.l10n.lockAgainAfter, style: ts(12, color: c.textMuted)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Segmented<Duration>(key: const Key('lock-timeout'), values: SecurityState.timeouts, selected: sec.timeout, label: timeoutLabel, onChanged: (d) => sec.timeout = d),
                ),
              ],
            ]),
            group(context.l10n.settingsPrivacy, [
              SwitchListTile(
                key: const Key('hide-switch'),
                secondary: const Icon(AppIcons.hidden),
                title: Text(context.l10n.hideSwitcher),
                subtitle: Text(context.l10n.hideSwitcherHelp),
                value: sec.hideInSwitcher,
                onChanged: (v) => sec.hideInSwitcher = v,
              ),
            ]),
            group(context.l10n.encryption, [
              SwitchListTile(
                key: const Key('encrypt-switch'),
                secondary: const Icon(AppIcons.encryption),
                title: Text(context.l10n.encryptDb),
                subtitle: Text(sec.canEncrypt ? context.l10n.encryptKeyStored : context.l10n.encryptUnavailable),
                value: sec.encrypted,
                onChanged: sec.canEncrypt ? (v) => _toggleEncryption(sec, v) : null,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
