import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'follow_up.dart';
import 'txn_form_screen.dart';
import '../theme/icons.dart';

enum DebtTab { iOwe, owedToMe, settled }

/// "Due today", "Due in 3 days", "Overdue by 2 days".
String statementDueLabel(int days) => switch (days) {
  0 => currentL10n.dueToday,
  1 => currentL10n.dueTomorrow,
  > 1 => currentL10n.dueInDays(days),
  _ => currentL10n.overdueByDays(-days),
};

/// A friendly nudge for money someone owes the user.
String remindMessage(DebtStatus s) {
  final d = s.debt;
  final person = d.counterparty.isNotEmpty ? d.counterparty : d.name;
  final l = currentL10n;
  return d.counterparty.isNotEmpty ? l.debtRemindMessageFor(person, formatInr(s.remaining), d.name) : l.debtRemindMessage(person, formatInr(s.remaining));
}

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  DebtTab _tab = DebtTab.iOwe;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final l = context.l10n;
    final summary = app.planning.debtSummary();
    final list = switch (_tab) {
      DebtTab.iOwe => app.planning.debts(direction: DebtDirection.iOwe),
      DebtTab.owedToMe => app.planning.debts(direction: DebtDirection.owedToMe),
      DebtTab.settled => app.planning.debts(settled: true),
    };
    void open(Widget w) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));
    Widget sumCard(String label, int v, String sub, Color color, Color soft) => Expanded(
      child: AppCard(
        color: soft,
        border: color.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: ts(12, weight: FontWeight.w600, color: color),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(formatInr(v), style: ts(22, weight: FontWeight.w800)),
            ),
            Text(sub, style: ts(11, color: c.textMuted)),
          ],
        ),
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l.navDebts, style: ts(26, weight: FontWeight.w800, spacing: -0.5)),
            ),
            FilledButton.icon(
              key: const Key('add-debt'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 40), backgroundColor: c.text, foregroundColor: c.bg),
              onPressed: () => open(const DebtFormScreen()),
              icon: const Icon(AppIcons.add),
              label: Text(l.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            sumCard(l.debtYouOwe, summary.owe, l.debtMonthlyEmi(formatInr(summary.monthlyEmi)), c.debt, c.debtSoft),
            const SizedBox(width: 10),
            sumCard(l.debtOwedToYou, summary.owed, l.debtToCollect, c.brand, c.brandSoft),
          ],
        ),
        const SizedBox(height: 14),
        Segmented<DebtTab>(
          values: DebtTab.values,
          selected: _tab,
          label: (t) => switch (t) {
            DebtTab.iOwe => l.debtIOwe,
            DebtTab.owedToMe => l.debtOwedToMe,
            DebtTab.settled => l.debtSettled,
          },
          onChanged: (t) => setState(() => _tab = t),
        ),
        const SizedBox(height: 14),
        if (list.isEmpty) EmptyState(icon: AppIcons.people, title: l.nothingHere, message: l.debtEmpty),
        for (final s in list) ...[
          _DebtCard(
            s,
            now: app.now(),
            onPay: () => open(TxnFormScreen(initialType: TxnType.debt, debtId: s.debt.id)),
            onPayNow: () => _payNow(context, s),
            onRemind: () => app.files.shareText(remindMessage(s), subject: l.debtRemindSubject),
            onEdit: () => open(DebtFormScreen(existing: s.debt)),
            onSettle: () {
              app.planning.setDebtSettled(s.debt.id!, !s.debt.settled);
              app.changed();
            },
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        AppCard(
          color: c.brandSoft,
          padding: const EdgeInsets.all(14),
          child: Text(l.debtFooter, style: ts(12, color: c.brand)),
        ),
      ],
    );
  }

  /// Confirms and records the unpaid statement as a debt payment from the
  /// default payment source.
  Future<void> _payNow(BuildContext context, DebtStatus s) async {
    final app = AppScope.read(context);
    final source = app.catalog.defaultSource();
    final amount = s.statementLeft;
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.debtPayTitle(s.debt.name)),
        content: Text(source == null ? l.debtPayBody(formatInr(amount)) : l.debtPayBodyFrom(formatInr(amount), source.display)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(key: const Key('confirm-pay-now'), onPressed: () => Navigator.pop(ctx, true), child: Text(l.debtPayAmount(formatInr(amount)))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    app.txns.insert(
      Txn(type: TxnType.debt, amount: amount, categoryId: app.catalog.defaultCategory().id, sourceId: source?.id, occurredAt: app.now(), merchant: l.debtBillMerchant(s.debt.name), debtId: s.debt.id),
      now: app.now(),
    );
    app.changed();
    showSnack(context, l.debtPaymentRecorded(formatInr(amount)));
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard(this.s, {required this.now, required this.onPay, required this.onPayNow, required this.onRemind, required this.onEdit, required this.onSettle});

  final DebtStatus s;
  final DateTime now;
  final VoidCallback onPay;
  final VoidCallback onPayNow;
  final VoidCallback onRemind;
  final VoidCallback onEdit;
  final VoidCallback onSettle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final d = s.debt;
    final dueIn = d.settled ? null : s.statementDueIn(now);
    final urgent = dueIn != null && dueIn <= 3;
    final color = d.direction == DebtDirection.iOwe ? c.debt : c.brand;
    final icon = switch (d.kind) {
      DebtKind.loan => AppIcons.car,
      DebtKind.card => AppIcons.creditCard,
      DebtKind.personal => AppIcons.people,
    };
    final sub = [
      if (d.counterparty.isNotEmpty) d.counterparty,
      if (d.rate != null) '${d.rate!.toStringAsFixed(1)}%',
      if (d.emi != null) l.debtEmi(formatInr(d.emi!)),
      if (d.dueDay != null) l.debtDueOn(d.dueDay!),
    ].join(' · ');
    return AppCard(
      key: Key('debt-card-${d.id}'),
      border: urgent ? c.spend : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon, color: color, background: color.withValues(alpha: 0.14), size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name, style: ts(15, weight: FontWeight.w700)),
                    if (sub.isNotEmpty) Text(sub, style: ts(11, color: c.textMuted)),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(formatInr(s.remaining), style: ts(15, weight: FontWeight.w800)),
                    ),
                    Text(
                      l.debtLeftOf(formatInr(d.principal)),
                      textAlign: TextAlign.end,
                      style: ts(11, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: Key('edit-debt-${d.id}'),
                tooltip: l.edit,
                icon: Icon(AppIcons.edit, size: 18, color: c.textMuted),
                onPressed: onEdit,
              ),
            ],
          ),
          if (d.kind == DebtKind.card && d.statementAmount != null && !d.settled) ...[
            const SizedBox(height: 12),
            Container(
              key: Key('statement-${d.id}'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: urgent ? c.spendSoft : c.surfaceMuted, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(urgent ? AppIcons.warning : AppIcons.receipt, size: 18, color: urgent ? c.spend : c.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.statementDueAt == null ? l.debtStatement(formatInr(d.statementAmount!)) : l.debtStatementDue(formatInr(d.statementAmount!), shortDate(d.statementDueAt!)),
                      style: ts(12, weight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    dueIn != null ? statementDueLabel(dueIn) : (s.statementLeft == 0 ? l.debtPaid : l.debtUnpaid(formatInr(s.statementLeft))),
                    style: ts(12, weight: FontWeight.w700, color: urgent ? c.spend : (s.statementLeft == 0 ? c.positive : c.textMuted)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SegmentBar(segments: [(s.fraction, color)], height: 8),
          const SizedBox(height: 10),
          Text(
            d.totalEmis != null ? l.debtEmisPaid(s.payments, d.totalEmis!) : l.debtPaymentsRecorded(s.payments),
            style: ts(12, weight: FontWeight.w600, color: c.textMuted),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton(key: Key('settle-${d.id}'), onPressed: onSettle, child: Text(d.settled ? l.debtReopen : l.debtSettle)),
              if (!d.settled && d.direction == DebtDirection.owedToMe && s.remaining > 0)
                OutlinedButton.icon(
                  key: Key('remind-${d.id}'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
                  onPressed: onRemind,
                  icon: const Icon(AppIcons.send, size: 16),
                  label: Text(l.debtRemind),
                ),
              if (!d.settled && d.direction == DebtDirection.owedToMe && s.remaining > 0) FollowUpButton(s),
              if (!d.settled)
                FilledButton(
                  key: Key('pay-${d.id}'),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 34), backgroundColor: c.surfaceMuted, foregroundColor: c.text),
                  onPressed: onPay,
                  child: Text(d.direction == DebtDirection.iOwe ? l.debtRecordPayment : l.debtRecordRepayment, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              if (!d.settled && s.statementLeft > 0)
                FilledButton(
                  key: Key('pay-now-${d.id}'),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 34), backgroundColor: urgent ? c.spend : c.debt, foregroundColor: Colors.white),
                  onPressed: onPayNow,
                  child: Text(l.debtPayNow(formatInr(s.statementLeft))),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class DebtFormScreen extends StatefulWidget {
  const DebtFormScreen({super.key, this.existing});

  /// When set, the form edits this debt instead of adding one.
  final Debt? existing;

  @override
  State<DebtFormScreen> createState() => _DebtFormScreenState();
}

class _DebtFormScreenState extends State<DebtFormScreen> {
  DebtDirection _direction = DebtDirection.iOwe;
  DebtKind _kind = DebtKind.loan;
  final _name = TextEditingController();
  final _party = TextEditingController();
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _emi = TextEditingController();
  final _emis = TextEditingController();
  final _due = TextEditingController();
  final _statement = TextEditingController();
  DateTime? _statementDue;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e == null) return;
    String money(int? v) => v == null ? '' : (v % 100 == 0 ? '${v ~/ 100}' : (v / 100).toStringAsFixed(2));
    _direction = e.direction;
    _kind = e.kind;
    _name.text = e.name;
    _party.text = e.counterparty;
    _principal.text = money(e.principal);
    _rate.text = e.rate?.toString() ?? '';
    _emi.text = money(e.emi);
    _emis.text = e.totalEmis?.toString() ?? '';
    _due.text = e.dueDay?.toString() ?? '';
    _statement.text = money(e.statementAmount);
    _statementDue = e.statementDueAt;
  }

  Future<void> _pickStatementDue() async {
    final now = AppScope.read(context).now();
    final picked = await showDatePicker(context: context, initialDate: _statementDue ?? now, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 1, 12, 31));
    if (picked != null) setState(() => _statementDue = picked);
  }

  @override
  void dispose() {
    for (final c in [_name, _party, _principal, _rate, _emi, _emis, _due, _statement]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final app = AppScope.read(context);
    final principal = parseInr(_principal.text);
    if (_name.text.trim().isEmpty || principal == null || principal <= 0) {
      showSnack(context, context.l10n.debtNeedNameAmount);
      return;
    }
    final due = int.tryParse(_due.text.trim());
    final card = _kind == DebtKind.card;
    final debt = Debt(
      id: widget.existing?.id,
      settled: widget.existing?.settled ?? false,
      statementAmount: card ? parseInr(_statement.text) : null,
      statementDueAt: card ? _statementDue : null,
      direction: _direction,
      kind: _kind,
      name: _name.text,
      counterparty: _party.text,
      principal: principal,
      rate: double.tryParse(_rate.text.trim()),
      emi: parseInr(_emi.text),
      totalEmis: int.tryParse(_emis.text.trim()),
      dueDay: due != null && due >= 1 && due <= 31 ? due : null,
    );
    widget.existing == null ? app.planning.addDebt(debt) : app.planning.updateDebt(debt);
    app.changed();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget field(String key, TextEditingController c, String label, {bool number = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        key: Key(key),
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? l.debtAddTitle : l.debtEditTitle, style: ts(16, weight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Segmented<DebtDirection>(
            values: DebtDirection.values,
            selected: _direction,
            label: (d) => d == DebtDirection.iOwe ? l.debtIOwe : l.debtOwedToMe,
            onChanged: (d) => setState(() => _direction = d),
          ),
          const SizedBox(height: 12),
          Segmented<DebtKind>(
            values: DebtKind.values,
            selected: _kind,
            label: (k) => switch (k) {
              DebtKind.loan => l.debtKindLoan,
              DebtKind.card => l.debtKindCard,
              DebtKind.personal => l.debtKindPersonal,
            },
            onChanged: (k) => setState(() => _kind = k),
          ),
          const SizedBox(height: 16),
          field('debt-name', _name, l.debtFieldName),
          field('debt-party', _party, l.debtFieldParty),
          field('debt-principal', _principal, l.debtFieldPrincipal(currencySymbol), number: true),
          field('debt-rate', _rate, l.debtFieldRate, number: true),
          field('debt-emi', _emi, l.debtFieldEmi, number: true),
          field('debt-emis', _emis, l.debtFieldEmis, number: true),
          field('debt-due', _due, l.debtFieldDueDay, number: true),
          if (_kind == DebtKind.card) ...[
            field('debt-statement', _statement, l.debtFieldStatement(currencySymbol), number: true),
            ListTile(
              key: const Key('debt-statement-due'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(AppIcons.event),
              title: Text(_statementDue == null ? l.debtStatementDueDate : l.debtDueDate(longDate(_statementDue!))),
              trailing: _statementDue == null
                  ? null
                  : IconButton(key: const Key('clear-statement-due'), tooltip: l.clear, icon: const Icon(AppIcons.close), onPressed: () => setState(() => _statementDue = null)),
              onTap: _pickStatementDue,
            ),
          ],
          const SizedBox(height: 8),
          FilledButton(key: const Key('save-debt'), onPressed: _save, child: Text(l.debtSave)),
        ],
      ),
    );
  }
}
