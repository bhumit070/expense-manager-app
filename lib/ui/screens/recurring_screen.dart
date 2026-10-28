import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/recurring_repo.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/amount_keypad.dart';
import '../widgets/common.dart';
import '../theme/icons.dart';

String ruleStatus(RecurringRule r) {
  final state = r.ended ? 'Ended' : (r.paused ? 'Paused' : 'Next ${longDate(r.nextRun)}');
  return '${frequencyLabel(r.frequency)} · $state${r.autoCreate ? '' : ' · reminder only'}';
}

/// Lists recurring rules (including SIPs) with pause, edit and delete.
class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  Future<void> _edit(BuildContext context, AppState app, RecurringRule r) async {
    final edited = await showDialog<RecurringRule>(
      context: context,
      builder: (_) => RuleDialog(rule: r),
    );
    if (edited == null) return;
    app.recurring.save(edited);
    app.changed();
  }

  Future<void> _delete(BuildContext context, AppState app, RecurringRule r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this schedule?'),
        content: const Text('No more transactions will be added. Ones already added stay.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(key: const Key('confirm-delete-rule'), onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      app.recurring.delete(r.id!);
      app.changed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final rules = app.recurring.rules();
    return Scaffold(
      appBar: AppBar(
        title: Text('Recurring', style: ts(16, weight: FontWeight.w700)),
      ),
      body: rules.isEmpty
          ? const EmptyState(icon: AppIcons.repeat, title: 'Nothing recurring yet', message: 'Turn on “Repeat” when adding a transaction, or set up a SIP on an investment.')
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      for (final r in rules)
                        ListTile(
                          key: Key('rule-${r.id}'),
                          onTap: () => _edit(context, app, r),
                          leading: CategoryBadge(app.catalog.category(r.template.categoryId), size: 40),
                          title: Text(
                            '${r.template.titleOr(app.catalog.category(r.template.categoryId).name)} · ${formatInr(r.template.amount)}',
                            style: ts(14, weight: FontWeight.w600, color: r.paused || r.ended ? c.textMuted : c.text),
                          ),
                          subtitle: Text(ruleStatus(r), style: ts(11, color: c.textMuted)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!r.ended)
                                Switch(
                                  key: Key('pause-${r.id}'),
                                  value: !r.paused,
                                  onChanged: (on) {
                                    app.recurring.setPaused(r.id!, !on, now: app.now());
                                    app.changed();
                                  },
                                ),
                              IconButton(key: Key('delete-rule-${r.id}'), icon: const Icon(AppIcons.delete), onPressed: () => _delete(context, app, r)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Edits a rule's amount and frequency. A new frequency restarts the
/// schedule from the next occurrence.
class RuleDialog extends StatefulWidget {
  const RuleDialog({super.key, required this.rule});

  final RecurringRule rule;

  @override
  State<RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends State<RuleDialog> {
  late final _amount = TextEditingController(text: plainAmount(widget.rule.template.amount));
  late Frequency _frequency = widget.rule.frequency;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final amount = parseInr(_amount.text);
    if (amount == null || amount <= 0) {
      showSnack(context, 'Enter an amount greater than zero');
      return;
    }
    var r = widget.rule.copyWith(template: widget.rule.template.copyWith(amount: amount));
    if (_frequency != r.frequency) r = r.copyWith(frequency: _frequency, startAt: r.nextRun, count: 0);
    Navigator.pop(context, r);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit schedule'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          key: const Key('rule-amount'),
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (₹)'),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final f in Frequency.values) Pill(frequencyLabel(f), selected: f == _frequency, onTap: () => setState(() => _frequency = f))],
        ),
      ],
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(key: const Key('rule-save'), onPressed: _save, child: const Text('Save')),
    ],
  );
}
