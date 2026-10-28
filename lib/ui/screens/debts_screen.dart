import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'txn_form_screen.dart';

enum DebtTab { iOwe, owedToMe, settled }

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
              child: Text('Debts', style: ts(26, weight: FontWeight.w800, spacing: -0.5)),
            ),
            FilledButton.icon(
              key: const Key('add-debt'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 40), backgroundColor: c.text, foregroundColor: c.bg),
              onPressed: () => open(const DebtFormScreen()),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            sumCard('You owe', summary.owe, '${formatInr(summary.monthlyEmi)}/mo in EMIs', c.debt, c.debtSoft),
            const SizedBox(width: 10),
            sumCard('Owed to you', summary.owed, 'to collect', c.brand, c.brandSoft),
          ],
        ),
        const SizedBox(height: 14),
        Segmented<DebtTab>(
          values: DebtTab.values,
          selected: _tab,
          label: (t) => switch (t) {
            DebtTab.iOwe => 'I owe',
            DebtTab.owedToMe => 'Owed to me',
            DebtTab.settled => 'Settled',
          },
          onChanged: (t) => setState(() => _tab = t),
        ),
        const SizedBox(height: 14),
        if (list.isEmpty) const EmptyState(icon: Icons.people_outline, title: 'Nothing here', message: 'Loans, credit cards and money lent or borrowed show up here.'),
        for (final s in list) ...[
          _DebtCard(
            s,
            onPay: () => open(TxnFormScreen(initialType: TxnType.debt, debtId: s.debt.id)),
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
          child: Text('EMIs and card payments recorded here count as Debt, not Spend — so your monthly spend stays honest.', style: ts(12, color: c.brand)),
        ),
      ],
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard(this.s, {required this.onPay, required this.onSettle});

  final DebtStatus s;
  final VoidCallback onPay;
  final VoidCallback onSettle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = s.debt;
    final color = d.direction == DebtDirection.iOwe ? c.debt : c.brand;
    final icon = switch (d.kind) {
      DebtKind.loan => Icons.directions_car_outlined,
      DebtKind.card => Icons.credit_card,
      DebtKind.personal => Icons.people_outline,
    };
    final sub = [
      if (d.counterparty.isNotEmpty) d.counterparty,
      if (d.rate != null) '${d.rate!.toStringAsFixed(1)}%',
      if (d.emi != null) 'EMI ${formatInr(d.emi!)}',
      if (d.dueDay != null) 'due on ${d.dueDay}',
    ].join(' · ');
    return AppCard(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatInr(s.remaining), style: ts(15, weight: FontWeight.w800)),
                  Text('left of ${formatInr(d.principal)}', style: ts(11, color: c.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentBar(segments: [(s.fraction, color)], height: 8),
          const SizedBox(height: 10),
          Text(
            d.totalEmis != null ? '${s.payments} of ${d.totalEmis} EMIs paid' : '${s.payments} payment${s.payments == 1 ? '' : 's'} recorded',
            style: ts(12, weight: FontWeight.w600, color: c.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(key: Key('settle-${d.id}'), onPressed: onSettle, child: Text(d.settled ? 'Reopen' : 'Settle')),
              if (!d.settled)
                Flexible(
                  child: FilledButton(
                    key: Key('pay-${d.id}'),
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 34), backgroundColor: c.surfaceMuted, foregroundColor: c.text),
                    onPressed: onPay,
                    child: Text(d.direction == DebtDirection.iOwe ? 'Record payment' : 'Record repayment', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class DebtFormScreen extends StatefulWidget {
  const DebtFormScreen({super.key});

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

  @override
  void dispose() {
    for (final c in [_name, _party, _principal, _rate, _emi, _emis, _due]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final app = AppScope.read(context);
    final principal = parseInr(_principal.text);
    if (_name.text.trim().isEmpty || principal == null || principal <= 0) {
      showSnack(context, 'Add a name and the amount');
      return;
    }
    final due = int.tryParse(_due.text.trim());
    app.planning.addDebt(
      Debt(
        direction: _direction,
        kind: _kind,
        name: _name.text,
        counterparty: _party.text,
        principal: principal,
        rate: double.tryParse(_rate.text.trim()),
        emi: parseInr(_emi.text),
        totalEmis: int.tryParse(_emis.text.trim()),
        dueDay: due != null && due >= 1 && due <= 31 ? due : null,
      ),
    );
    app.changed();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Add debt', style: ts(16, weight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Segmented<DebtDirection>(
            values: DebtDirection.values,
            selected: _direction,
            label: (d) => d == DebtDirection.iOwe ? 'I owe' : 'Owed to me',
            onChanged: (d) => setState(() => _direction = d),
          ),
          const SizedBox(height: 12),
          Segmented<DebtKind>(
            values: DebtKind.values,
            selected: _kind,
            label: (k) => switch (k) {
              DebtKind.loan => 'Loan',
              DebtKind.card => 'Credit card',
              DebtKind.personal => 'Personal',
            },
            onChanged: (k) => setState(() => _kind = k),
          ),
          const SizedBox(height: 16),
          field('debt-name', _name, 'Name, e.g. Car loan'),
          field('debt-party', _party, 'Lender / person (optional)'),
          field('debt-principal', _principal, 'Total amount ($currencySymbol)', number: true),
          field('debt-rate', _rate, 'Interest rate % (optional)', number: true),
          field('debt-emi', _emi, 'EMI / monthly payment (optional)', number: true),
          field('debt-emis', _emis, 'Number of EMIs (optional)', number: true),
          field('debt-due', _due, 'Due day of month (optional)', number: true),
          const SizedBox(height: 8),
          FilledButton(key: const Key('save-debt'), onPressed: _save, child: const Text('Save debt')),
        ],
      ),
    );
  }
}
