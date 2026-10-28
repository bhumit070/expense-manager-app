import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../state/security_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'lock_screen.dart';
import '../theme/icons.dart';

String timeoutLabel(Duration d) => switch (d.inSeconds) {
  0 => 'Immediately',
  < 60 => '${d.inSeconds} s',
  _ => '${d.inMinutes} min',
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
        _error = "PINs didn't match. Try again.";
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
          title: _first == null ? 'Choose a PIN' : 'Confirm your PIN',
          message: _error ?? (_first == null ? 'Enter 4–6 digits' : 'Enter the same PIN again'),
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
        setState(() => _error = sec.cooldownLeft > Duration.zero ? 'Too many attempts. Try again in ${sec.cooldownLeft.inSeconds} s' : 'Wrong PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sec = AppScope.of(context).security;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: PinPad(title: 'Enter your current PIN', message: _error, messageIsError: _error != null, onSubmit: (pin) => _submit(sec, pin)),
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
      if (await setUpAppLock(context) && mounted) showSnack(context, 'App lock is on');
    } else if (await _confirmPin(context)) {
      sec.disableLock();
    }
  }

  Future<void> _changePin(SecurityState sec) async {
    if (!await _confirmPin(context) || !mounted) return;
    if (await setUpAppLock(context) && mounted) showSnack(context, 'PIN changed');
  }

  Future<void> _toggleEncryption(SecurityState sec, bool on) async {
    if (on) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Encrypt the database?'),
          content: const Text(
            'Your data will be encrypted with a key kept in this phone\'s secure storage. '
            'If that key is lost (for example, app data is cleared), the data cannot be recovered — export a backup first.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(key: const Key('encrypt-confirm'), onPressed: () => Navigator.pop(context, true), child: const Text('Encrypt')),
          ],
        ),
      );
      if (ok != true) return;
    }
    try {
      on ? await sec.encryptDatabase() : await sec.decryptDatabase();
      if (mounted) showSnack(context, on ? 'Database encrypted' : 'Database decrypted');
    } catch (e) {
      if (mounted) showSnack(context, "Couldn't change encryption: $e");
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
          title: Text('App lock & privacy', style: ts(16, weight: FontWeight.w700)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            group('App lock', [
              SwitchListTile(
                key: const Key('lock-switch'),
                secondary: const Icon(AppIcons.lock),
                title: const Text('Lock with PIN'),
                subtitle: const Text('Asked when the app opens'),
                value: sec.lockEnabled,
                onChanged: (v) => _toggleLock(sec, v),
              ),
              if (sec.lockEnabled) ...[
                ListTile(key: const Key('change-pin'), leading: const Icon(AppIcons.pin), title: const Text('Change PIN'), onTap: () => _changePin(sec)),
                FutureBuilder<bool>(
                  future: _bioAvailable,
                  builder: (context, snap) {
                    final available = snap.data ?? false;
                    return SwitchListTile(
                      key: const Key('bio-switch'),
                      secondary: const Icon(AppIcons.fingerprint),
                      title: const Text('Unlock with fingerprint / face'),
                      subtitle: available ? null : const Text('Not available on this device'),
                      value: available && sec.biometricsOn,
                      onChanged: available ? (v) => sec.biometricsOn = v : null,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Lock again after leaving the app', style: ts(12, color: c.textMuted)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Segmented<Duration>(key: const Key('lock-timeout'), values: SecurityState.timeouts, selected: sec.timeout, label: timeoutLabel, onChanged: (d) => sec.timeout = d),
                ),
              ],
            ]),
            group('Privacy', [
              SwitchListTile(
                key: const Key('hide-switch'),
                secondary: const Icon(AppIcons.hidden),
                title: const Text('Hide in app switcher'),
                subtitle: const Text('Blurs the recent-apps preview and blocks screenshots'),
                value: sec.hideInSwitcher,
                onChanged: (v) => sec.hideInSwitcher = v,
              ),
            ]),
            group('Encryption', [
              SwitchListTile(
                key: const Key('encrypt-switch'),
                secondary: const Icon(AppIcons.encryption),
                title: const Text('Encrypt database'),
                subtitle: Text(sec.canEncrypt ? 'Key stored in the phone\'s secure storage' : 'Not available for this database'),
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
