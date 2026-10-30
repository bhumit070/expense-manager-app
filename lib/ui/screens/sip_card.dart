import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/recurring_repo.dart';
import '../../data/transactions_repo.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/amount_keypad.dart';
import '../widgets/common.dart';
import 'txn_form_screen.dart';
import '../theme/icons.dart';

/// SIPs run on a day 1–28 so every month has it.
const sipDays = 28;

/// The first SIP date on [day] that is today or later, at 9 AM.
DateTime nextSipDate(DateTime now, int day) {
  final thisMonth = DateTime(now.year, now.month, day, 9);
  return day >= now.day ? thisMonth : DateTime(now.year, now.month + 1, day, 9);
}

typedef SipInput = ({int amount, int day, int? sourceId, bool autoCreate});

/// Shows an investment's SIP with its next date, or offers to set one up.
class SipCard extends StatelessWidget {
  const SipCard({super.key, required this.investment});

  final Investment investment;

  Future<void> _edit(BuildContext context, AppState app, RecurringRule? sip) async {
    final input = await showDialog<SipInput>(
      context: context,
      builder: (_) => SipDialog(existing: sip),
    );
    if (input == null) return;
    final now = app.now();
    if (sip == null) {
      final last = app.txns.list(TxnFilter(investmentId: investment.id, types: const {TxnType.invest}), limit: 1);
      final start = nextSipDate(now, input.day);
      app.recurring.add(
        RecurringRule(
          template: Txn(
            type: TxnType.invest,
            amount: input.amount,
            categoryId: last.isEmpty ? app.catalog.firstOf(CategoryKind.invest).id : last.first.txn.categoryId,
            sourceId: input.sourceId,
            occurredAt: start,
            merchant: investment.name,
            note: 'SIP',
            investmentId: investment.id,
          ),
          frequency: Frequency.monthly,
          startAt: start,
          autoCreate: input.autoCreate,
        ),
      );
    } else {
      final t = sip.template;
      var r = sip.copyWith(
        autoCreate: input.autoCreate,
        template: Txn(
          type: t.type,
          amount: input.amount,
          categoryId: t.categoryId,
          sourceId: input.sourceId,
          occurredAt: t.occurredAt,
          merchant: t.merchant,
          note: t.note,
          investmentId: t.investmentId,
        ),
      );
      if (input.day != sip.startAt.day) r = r.copyWith(startAt: nextSipDate(now, input.day), count: 0);
      app.recurring.save(r);
    }
    app.recurring.run(now);
    app.changed();
  }

  Future<void> _stop(BuildContext context, AppState app, RecurringRule sip) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.sipStopTitle),
        content: Text(context.l10n.sipStopBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
          FilledButton(key: const Key('confirm-stop-sip'), onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.sipStop)),
        ],
      ),
    );
    if (ok == true) {
      app.recurring.delete(sip.id!);
      app.changed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final sip = app.recurring.forInvestment(investment.id!);
    if (sip == null) {
      if (investment.status != InvestmentStatus.active) return const SizedBox.shrink();
      return OutlinedButton.icon(key: const Key('setup-sip'), onPressed: () => _edit(context, app, null), icon: const Icon(AppIcons.eventRepeat), label: Text(context.l10n.sipSetup));
    }
    final source = sip.template.sourceId == null ? null : app.catalog.sources(includeArchived: true).where((s) => s.id == sip.template.sourceId).firstOrNull;
    return AppCard(
      key: const Key('sip-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(AppIcons.eventRepeat, color: c.invest, background: c.investSoft, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.sipSummary(formatInr(sip.template.amount), sip.startAt.day), style: ts(15, weight: FontWeight.w700)),
                    Text(
                      sip.paused ? context.l10n.paused : (source == null ? context.l10n.nextOn(longDate(sip.nextRun)) : context.l10n.nextOnFrom(longDate(sip.nextRun), source.display)),
                      key: const Key('sip-next'),
                      style: ts(12, color: c.textMuted),
                    ),
                    Text(sip.autoCreate ? context.l10n.sipAuto : context.l10n.sipReminderOnly, style: ts(11, color: c.textFaint)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              if (!sip.autoCreate)
                TextButton(
                  key: const Key('record-sip'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TxnFormScreen(initialType: TxnType.invest, investmentId: investment.id),
                    ),
                  ),
                  child: Text(context.l10n.debtRecordPayment),
                ),
              TextButton(key: const Key('edit-sip'), onPressed: () => _edit(context, app, sip), child: Text(context.l10n.edit)),
              TextButton(
                key: const Key('stop-sip'),
                style: TextButton.styleFrom(foregroundColor: c.spend),
                onPressed: () => _stop(context, app, sip),
                child: Text(context.l10n.stop),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SipDialog extends StatefulWidget {
  const SipDialog({super.key, this.existing});

  final RecurringRule? existing;

  @override
  State<SipDialog> createState() => _SipDialogState();
}

class _SipDialogState extends State<SipDialog> {
  late final _amount = TextEditingController(text: widget.existing == null ? '' : plainAmount(widget.existing!.template.amount));
  late int _day = widget.existing?.startAt.day ?? 5;
  int? _sourceId;
  late bool _auto = widget.existing?.autoCreate ?? true;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    _sourceId = widget.existing?.template.sourceId ?? AppScope.read(context).catalog.defaultSource()?.id;
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final amount = parseInr(_amount.text);
    if (amount == null || amount <= 0) {
      showSnack(context, context.l10n.txnNeedAmount);
      return;
    }
    Navigator.pop<SipInput>(context, (amount: amount, day: _day, sourceId: _sourceId, autoCreate: _auto));
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final sources = app.catalog.sources();
    return AlertDialog(
      title: Text(widget.existing == null ? context.l10n.sipMonthly : context.l10n.sipEdit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('sip-amount'),
              controller: _amount,
              autofocus: widget.existing == null,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: context.l10n.sipAmountField(currencySymbol)),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              key: const Key('sip-day'),
              initialValue: _day,
              decoration: InputDecoration(labelText: context.l10n.dayOfMonth),
              items: [for (var d = 1; d <= sipDays; d++) DropdownMenuItem(value: d, child: Text('$d'))],
              onChanged: (d) => setState(() => _day = d!),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int?>(
              key: const Key('sip-source'),
              isExpanded: true,
              initialValue: sources.any((s) => s.id == _sourceId) ? _sourceId : null,
              decoration: InputDecoration(labelText: context.l10n.txnPaidFrom),
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(context.l10n.notSet)),
                for (final s in sources)
                  DropdownMenuItem<int?>(
                    value: s.id,
                    child: Text(s.display, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _sourceId = v),
            ),
            const SizedBox(height: 10),
            RadioGroup<bool>(
              groupValue: _auto,
              onChanged: (v) => setState(() => _auto = v!),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    key: const Key('sip-auto'),
                    contentPadding: EdgeInsets.zero,
                    value: true,
                    title: Text(context.l10n.sipAutoOption),
                    subtitle: Text(context.l10n.sipAutoOptionHelp),
                  ),
                  RadioListTile<bool>(
                    key: const Key('sip-remind'),
                    contentPadding: EdgeInsets.zero,
                    value: false,
                    title: Text(context.l10n.sipRemindOption),
                    subtitle: Text(context.l10n.sipRemindOptionHelp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
        FilledButton(key: const Key('sip-save'), onPressed: _save, child: Text(context.l10n.save)),
      ],
    );
  }
}
