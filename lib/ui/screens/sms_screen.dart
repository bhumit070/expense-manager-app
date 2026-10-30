import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../app.dart';
import '../../services/maps.dart';
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
        title: Text(context.l10n.smsReadTitle),
        content: Text(app.smsPlatform.viaShortcuts ? context.l10n.smsReadBodyShortcuts : context.l10n.smsReadBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.notNow)),
          FilledButton(key: const Key('sms-allow'), onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.continue_)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final result = await app.enableSms();
    if (!mounted) return;
    switch (result) {
      case SmsEnableResult.denied:
        showSnack(context, context.l10n.smsDenied);
        return;
      case SmsEnableResult.noNotifications:
        showSnack(context, context.l10n.smsNoNotifications);
      case SmsEnableResult.on:
        break;
    }
    setState(() {
      _permission = Future.value(true);
    });
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
    if (mounted) showSnack(context, context.l10n.addedThing(app.sms.headline(c)));
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
        title: Text(context.l10n.smsTitle, style: ts(16, weight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SwitchListTile(
              key: const Key('sms-switch'),
              secondary: const Icon(AppIcons.sms),
              title: Text(context.l10n.smsAskToAdd),
              subtitle: Text(context.l10n.smsAskToAddHelp),
              value: on,
              onChanged: (v) => _toggle(app, v),
            ),
          ),
          if (app.smsPlatform.viaShortcuts) ...[const SizedBox(height: 12), const ShortcutsSetupCard()],
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
                              child: Text(context.l10n.smsPermissionOff, style: ts(13, color: c.textMuted)),
                            ),
                            TextButton(key: const Key('sms-permission'), onPressed: () => _allow(app), child: Text(context.l10n.allow)),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          const SizedBox(height: 20),
          SectionHeader(pending.isEmpty ? context.l10n.smsNothingToReview : context.l10n.smsToReview(pending.length)),
          if (pending.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(on ? context.l10n.smsOnHelp : context.l10n.smsOffHelp, style: ts(13, color: c.textMuted)),
            ),
          for (final p in pending) ...[_CaptureCard(capture: p, onAdd: () => _add(app, p), onIgnore: () => _ignore(app, p)), const SizedBox(height: 12)],
        ],
      ),
    );
  }
}

/// Where the iPhone setup guide lives (GitHub Pages, from docs/ios-sms.md).
const iosSmsGuideUrl = 'https://bhumit070.github.io/expense-manager-app/ios-sms/';

/// The steps to set up the Shortcuts automation that hands bank SMS to the
/// app on iPhone.
class ShortcutsSetupCard extends StatelessWidget {
  const ShortcutsSetupCard({super.key});

  // The keywords and the action name stay in English: bank SMS and the
  // Shortcuts action are in English.
  static List<String> steps(AppLocalizations l) => [l.smsStep1, l.smsStep2('debited'), l.smsStep3('Log bank SMS'), l.smsStep4, l.smsStep5('credited', 'spent')];

  Future<void> _open(BuildContext context, String url) async {
    if (!await MapServices.instance.openExternal(Uri.parse(url)) && context.mounted) showSnack(context, context.l10n.couldNotOpen(url));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      key: const Key('sms-shortcuts-setup'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.smsSetupIphone, style: ts(15, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(context.l10n.smsSetupIphoneHelp, style: ts(12, color: c.textMuted)),
          const SizedBox(height: 10),
          for (final (i, step) in steps(context.l10n).indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${i + 1}.',
                      style: ts(13, weight: FontWeight.w700, color: c.brand),
                    ),
                  ),
                  Expanded(child: Text(step, style: ts(13))),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                key: const Key('sms-open-shortcuts'),
                icon: const Icon(AppIcons.openExternal, size: 18),
                label: Text(context.l10n.smsOpenShortcuts),
                onPressed: () => _open(context, 'shortcuts://'),
              ),
              TextButton.icon(key: const Key('sms-guide'), icon: const Icon(AppIcons.document, size: 18), label: Text(context.l10n.smsGuide), onPressed: () => _open(context, iosSmsGuideUrl)),
            ],
          ),
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
                TextButton(key: Key('sms-ignore-${capture.id}'), onPressed: onIgnore, child: Text(context.l10n.smsIgnore)),
                TextButton(
                  key: Key('sms-edit-${capture.id}'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<bool>(builder: (_) => smsForm(app, capture))),
                  child: Text(context.l10n.smsAddDetails),
                ),
                FilledButton(
                  key: Key('sms-add-${capture.id}'),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: onAdd,
                  child: Text(context.l10n.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
