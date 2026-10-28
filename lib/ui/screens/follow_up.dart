import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../state/reminders.dart';
import '../widgets/common.dart';

/// "Remind me" on money owed to the user: a local notification on a chosen
/// day, also listed under Coming up. Shows the date once one is set.
class FollowUpButton extends StatelessWidget {
  const FollowUpButton(this.status, {super.key});

  final DebtStatus status;

  Future<void> _pick(BuildContext context, AppState app, DateTime? current) async {
    final id = status.debt.id!;
    if (current != null) {
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Reminder on ${followUpLabel(current)}'),
          actions: [
            TextButton(key: const Key('follow-up-remove'), onPressed: () => Navigator.pop(context, 'remove'), child: const Text('Remove')),
            FilledButton(key: const Key('follow-up-change'), onPressed: () => Navigator.pop(context, 'change'), child: const Text('Change date')),
          ],
        ),
      );
      if (action == 'remove') {
        app.planning.setFollowUp(id, null);
        app.changed();
      }
      if (action != 'change' || !context.mounted) return;
    }
    final today = dayStart(app.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? today.add(const Duration(days: 7)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Remind me on',
    );
    if (picked == null) return;
    app.planning.setFollowUp(id, picked);
    app.changed();
    if (context.mounted) {
      showSnack(context, app.reminders.enabled ? "We'll remind you on ${followUpLabel(picked)}" : 'Saved. Turn on Settings › Reminders & alerts to get a notification.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final current = app.planning.followUpFor(status.debt.id!);
    return OutlinedButton.icon(
      key: Key('follow-up-${status.debt.id}'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
      onPressed: () => _pick(context, app, current),
      icon: Icon(current == null ? Icons.alarm_add_outlined : Icons.alarm_on_outlined, size: 16),
      label: Text(current == null ? 'Remind me' : followUpLabel(current)),
    );
  }
}
