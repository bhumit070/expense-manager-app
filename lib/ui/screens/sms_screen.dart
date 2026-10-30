import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/dates.dart';
import '../../state/app_state.dart';
import '../../state/sms_inbox.dart';
import '../theme/icons.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Settings › Expenses from SMS (Android): the opt-in switch and the list of
/// detected transactions still waiting for a decision.
class SmsScreen extends StatefulWidget {
  const SmsScreen({super.key});

  @override
  State<SmsScreen> createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> {
  late Future<bool> _permission;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _permission = AppScope.read(context).smsPlatform.hasPermission();
  }

  Future<void> _toggle(AppState app, bool on) async {
    if (!on) {
      app.sms.enabled = false;
      app.changed();
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Read bank SMS?'),
        content: const Text(
          'When a bank, card or UPI SMS arrives, Expense Manager reads it on this phone and asks whether to add the transaction.\n\n'
          'Only messages with an amount that was debited or credited are kept, and nothing is sent anywhere. OTPs, offers and reminders are skipped.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
          FilledButton(key: const Key('sms-allow'), onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (!await app.smsPlatform.requestPermission()) {
      if (mounted) showSnack(context, 'SMS permission was denied. Allow it for Expense Manager in system settings.');
      return;
    }
    if (!await app.reminders.service.requestPermission() && mounted) {
      showSnack(context, 'Notifications are blocked, so new expenses will only show up here.');
    }
    app.sms.enabled = true;
    setState(() {
      _permission = Future.value(true);
    });
    app.changed();
  }

  Future<void> _allow(AppState app) async {
    final granted = await app.smsPlatform.requestPermission();
    setState(() {
      _permission = Future.value(granted);
    });
  }

  Future<void> _add(AppState app, SmsCapture c) async {
    await app.sms.approve(c.id);
    app.changed();
    if (mounted) showSnack(context, 'Added ${app.sms.headline(c)}');
  }

  Future<void> _ignore(AppState app, SmsCapture c) async {
    await app.sms.ignore(c.id);
    app.changed();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final on = app.sms.enabled;
    final pending = app.sms.pending();
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses from SMS', style: ts(16, weight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SwitchListTile(
              key: const Key('sms-switch'),
              secondary: const Icon(AppIcons.sms),
              title: const Text('Ask to add bank SMS'),
              subtitle: const Text('Read on this phone · nothing is uploaded'),
              value: on,
              onChanged: (v) => _toggle(app, v),
            ),
          ),
          if (on)
            FutureBuilder<bool>(
              future: _permission,
              builder: (context, snap) => snap.data == false
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: AppCard(
                        child: Row(
                          children: [
                            Icon(AppIcons.warning, color: c.debt, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('SMS permission is off, so new messages are not read.', style: ts(13, color: c.textMuted)),
                            ),
                            TextButton(key: const Key('sms-permission'), onPressed: () => _allow(app), child: const Text('Allow')),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          const SizedBox(height: 20),
          SectionHeader(pending.isEmpty ? 'Nothing to review' : 'To review (${pending.length})'),
          if (pending.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                on ? 'New bank and UPI transactions show up here and as a notification.' : 'Turn this on to be asked about each bank or UPI transaction as its SMS arrives.',
                style: ts(13, color: c.textMuted),
              ),
            ),
          for (final p in pending) ...[_CaptureCard(capture: p, onAdd: () => _add(app, p), onIgnore: () => _ignore(app, p)), const SizedBox(height: 12)],
        ],
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  const _CaptureCard({required this.capture, required this.onAdd, required this.onIgnore});

  final SmsCapture capture;
  final VoidCallback onAdd;
  final VoidCallback onIgnore;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final draft = app.sms.draft(capture);
    return AppCard(
      key: Key('sms-capture-${capture.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            app.sms.headline(capture),
            style: ts(15, weight: FontWeight.w700, color: capture.sms.credit ? c.income : c.text),
          ),
          const SizedBox(height: 2),
          Text('${app.sms.filing(draft)} · ${shortDate(capture.receivedAt)}, ${timeOfDay(capture.receivedAt)}', style: ts(12, color: c.textMuted)),
          const SizedBox(height: 8),
          Text(
            capture.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: ts(12, color: c.textFaint),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                TextButton(key: Key('sms-ignore-${capture.id}'), onPressed: onIgnore, child: const Text('Ignore')),
                TextButton(
                  key: Key('sms-edit-${capture.id}'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<bool>(builder: (_) => smsForm(app, capture))),
                  child: const Text('Add details'),
                ),
                FilledButton(
                  key: Key('sms-add-${capture.id}'),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: onAdd,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
