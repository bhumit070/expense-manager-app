import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../state/reminders.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Lead times offered for FD maturity reminders.
const maturityLeadChoices = [0, 1, 3, 7, 14];

String leadDaysLabel(int days) => switch (days) {
  0 => 'On the day',
  1 => '1 day before',
  _ => '$days days before',
};

/// Settings › Reminders & alerts.
class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({super.key});

  Future<void> _toggle(BuildContext context, AppState app, bool on) async {
    if (on) {
      final granted = await app.reminders.enable();
      if (!granted && context.mounted) showSnack(context, 'Notifications are blocked. Allow them for Expense Manager in system settings.');
    } else {
      await app.reminders.disable();
    }
    app.changed();
  }

  Future<void> _test(BuildContext context, AppState app) async {
    await app.reminders.sendTest();
    if (context.mounted) showSnack(context, 'Test notification sent');
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final r = app.reminders;
    final c = context.colors;
    final on = r.enabled;
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders & alerts', style: ts(16, weight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SwitchListTile(
              key: const Key('notif-master'),
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              subtitle: const Text('Planned on this phone · nothing is sent to a server'),
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
                Text('Remind me before an FD matures', style: ts(14, weight: FontWeight.w600)),
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
          Text(
            'Reminders arrive around $reminderHour AM: due dates the day before and on the day, SIPs on their date, and budget alerts once per budget when it reaches 80% and 100%.',
            style: ts(12, color: c.textMuted),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('notif-test'),
            onPressed: on ? () => _test(context, app) : null,
            icon: const Icon(Icons.send_outlined, size: 18),
            label: const Text('Send a test notification'),
          ),
        ],
      ),
    );
  }
}
