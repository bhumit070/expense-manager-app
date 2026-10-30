import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../../state/reminders.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../theme/icons.dart';

/// Lead times offered for FD maturity reminders.
const maturityLeadChoices = [0, 1, 3, 7, 14];

String leadDaysLabel(int days) => switch (days) {
  0 => currentL10n.onTheDay,
  _ => currentL10n.daysBefore(days),
};

/// Settings › Reminders & alerts.
class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({super.key});

  Future<void> _toggle(BuildContext context, AppState app, bool on) async {
    if (on) {
      final granted = await app.reminders.enable();
      if (!granted && context.mounted) showSnack(context, context.l10n.notificationsBlocked);
    } else {
      await app.reminders.disable();
    }
    app.changed();
  }

  Future<void> _test(BuildContext context, AppState app) async {
    await app.reminders.sendTest();
    if (context.mounted) showSnack(context, context.l10n.testSent);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final r = app.reminders;
    final c = context.colors;
    final on = r.enabled;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.remindersTitle, style: ts(16, weight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SwitchListTile(
              key: const Key('notif-master'),
              secondary: const Icon(AppIcons.notifications),
              title: Text(context.l10n.notifications),
              subtitle: Text(context.l10n.notificationsHelp),
              value: on,
              onChanged: (v) => _toggle(context, app, v),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final t in ReminderType.values)
                  SwitchListTile(
                    key: Key('notif-${t.name}'),
                    title: Text(reminderTypeLabel(t)),
                    value: on && r.isOn(t),
                    onChanged: on
                        ? (v) {
                            r.setOn(t, v);
                            app.changed();
                          }
                        : null,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.fdLeadTitle, style: ts(14, weight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final d in maturityLeadChoices)
                      Pill(
                        key: Key('fd-lead-$d'),
                        leadDaysLabel(d),
                        selected: r.maturityLeadDays == d,
                        onTap: () {
                          r.maturityLeadDays = d;
                          app.changed();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(context.l10n.remindersInfo(DateFormat.j().format(DateTime(2000, 1, 1, reminderHour))), style: ts(12, color: c.textMuted)),
          const SizedBox(height: 16),
          OutlinedButton.icon(key: const Key('notif-test'), onPressed: on ? () => _test(context, app) : null, icon: const Icon(AppIcons.send, size: 18), label: Text(context.l10n.sendTest)),
        ],
      ),
    );
  }
}
