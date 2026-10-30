import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/transactions_repo.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'sip_card.dart';
import 'txn_detail_screen.dart';
import 'txn_form_screen.dart';
import '../theme/icons.dart';

const _allocationColors = [Color(0xFF34D399), Color(0xFF5EEAD4), Color(0xFFA3E635), Color(0xFFFDE047), Color(0xFFFFFFFF), Color(0xFF93C5FD)];

/// Tracks only the amounts invested — no current value or returns.
class InvestmentsScreen extends StatelessWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final now = app.now();
    final holdings = app.planning.holdings();
    final total = holdings.fold<int>(0, (a, h) => a + h.invested);
    final month = app.txns.totalsIn(Period.of(PeriodKind.month, now)).invest;
    final byKind = <InvestmentKind, List<Holding>>{};
    for (final h in holdings) {
      byKind.putIfAbsent(h.investment.kind, () => []).add(h);
    }
    int sum(List<Holding> l) => l.fold(0, (a, h) => a + h.invested);
    final maturing = app.planning.maturingSoon(now);
    void open(Widget w) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));
    final kinds = byKind.keys.toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(context.l10n.investmentsTitle, style: ts(26, weight: FontWeight.w800, spacing: -0.5)),
            ),
            FilledButton.icon(
              key: const Key('add-investment'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48), backgroundColor: solidForWhite(c.invest), foregroundColor: Colors.white),
              onPressed: () => open(const InvestmentFormScreen()),
              icon: const Icon(AppIcons.add),
              label: Text(context.l10n.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF064E3B), borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.totalInvested, style: ts(13, color: const Color(0xFFA7F3D0))),
              const SizedBox(height: 4),
              Text(
                formatInr(total),
                key: const Key('total-invested'),
                style: ts(32, weight: FontWeight.w800, color: Colors.white, spacing: -1),
              ),
              const SizedBox(height: 6),
              Text(context.l10n.investThisMonth(formatInr(month), holdings.length), style: ts(12, color: const Color(0xFFA7F3D0))),
              if (total > 0) ...[
                const SizedBox(height: 14),
                SegmentBar(
                  segments: [for (var i = 0; i < kinds.length; i++) (sum(byKind[kinds[i]]!) / total, _allocationColors[i % _allocationColors.length])],
                  height: 10,
                  track: const Color(0xFF065F46),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < kinds.length; i++)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: _allocationColors[i % _allocationColors.length], shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '${investmentKindLabel(kinds[i])} ${(sum(byKind[kinds[i]]!) * 100 / total).round()}%',
                              overflow: TextOverflow.ellipsis,
                              style: ts(11, color: const Color(0xFFD1FAE5)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Text(context.l10n.investNoPrices, style: ts(11, color: const Color(0xFF6EE7B7))),
            ],
          ),
        ),
        for (final m in maturing)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: AppCard(
              color: c.debtSoft,
              border: c.debt.withValues(alpha: 0.4),
              onTap: () => open(InvestmentDetailScreen(id: m.id!)),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(AppIcons.event, color: c.debt),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(context.l10n.investMaturesOn(m.name, shortDate(m.maturityAt!)), style: ts(13, weight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        if (holdings.isEmpty)
          EmptyState(
            icon: AppIcons.trendingUp,
            title: context.l10n.investNone,
            message: context.l10n.investNoneHelp,
            action: context.l10n.investAdd,
            onAction: () => open(const InvestmentFormScreen()),
          ),
        for (final k in kinds) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    investmentKindLabel(k),
                    style: ts(13, weight: FontWeight.w700, color: c.textMuted),
                  ),
                ),
                Text(
                  formatInr(sum(byKind[k]!)),
                  style: ts(13, weight: FontWeight.w700, color: c.textMuted),
                ),
              ],
            ),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < byKind[k]!.length; i++) ...[if (i > 0) const Divider(), _HoldingRow(byKind[k]![i], onTap: () => open(InvestmentDetailScreen(id: byKind[k]![i].investment.id!)))],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

String holdingSubtitle(Investment i) {
  final parts = <String>[
    if (i.institution.isNotEmpty) i.institution,
    if (i.rate != null) '${i.rate!.toStringAsFixed(2)}%',
    if (i.maturityAt != null) currentL10n.investMatures(dayMonthYear(i.maturityAt!)),
  ];
  return parts.isEmpty ? investmentKindLabel(i.kind) : parts.join(' · ');
}

class _HoldingRow extends StatelessWidget {
  const _HoldingRow(this.h, {required this.onTap});

  final Holding h;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            IconBadge(investmentIcon(h.investment.kind), color: c.invest, background: c.investSoft, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.investment.name, style: ts(14, weight: FontWeight.w600)),
                  Text(holdingSubtitle(h.investment), style: ts(11, color: c.textMuted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatInr(h.invested), style: ts(14, weight: FontWeight.w700)),
                Text(context.l10n.nEntries(h.entries), style: ts(11, color: c.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InvestmentDetailScreen extends StatelessWidget {
  const InvestmentDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final inv = app.planning.investment(id);
    final linked = app.txns.list(TxnFilter(investmentId: id, types: const {TxnType.invest}));
    final invested = linked.fold<int>(0, (a, t) => a + t.txn.amount);
    final now = app.now();
    void setStatus(InvestmentStatus s) {
      app.planning.setInvestmentStatus(id, s);
      app.changed();
      Navigator.of(context).pop();
    }

    final hasTimeline = inv.startAt != null && inv.maturityAt != null && inv.maturityAt!.isAfter(inv.startAt!);
    return Scaffold(
      appBar: AppBar(
        title: Text(investmentKindLabel(inv.kind), style: ts(16, weight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: IconBadge(investmentIcon(inv.kind), color: c.invest, background: c.investSoft, size: 64),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(inv.name, style: ts(22, weight: FontWeight.w800)),
          ),
          if (inv.status != InvestmentStatus.active)
            Center(
              child: Text(
                inv.status.name.toUpperCase(),
                style: ts(11, weight: FontWeight.w800, color: c.textMuted),
              ),
            ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.invested, style: ts(11, color: c.textMuted)),
                          Text(
                            formatInr(invested),
                            key: const Key('detail-invested'),
                            style: ts(16, weight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    if (inv.rate != null)
                      Column(
                        children: [
                          Text(context.l10n.interestRate, style: ts(11, color: c.textMuted)),
                          Text('${inv.rate!.toStringAsFixed(2)}%', style: ts(16, weight: FontWeight.w800)),
                        ],
                      ),
                  ],
                ),
                if (hasTimeline) ...[
                  const SizedBox(height: 14),
                  SegmentBar(segments: [(Period(PeriodKind.year, inv.startAt!, inv.maturityAt!).elapsed(now), c.invest)], height: 10, track: c.investSoft),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(context.l10n.investStarted(dayMonthYear(inv.startAt!)), style: ts(11, color: c.textMuted)),
                      ),
                      Text(context.l10n.daysLeft(Period(PeriodKind.year, inv.startAt!, inv.maturityAt!).daysLeft(now)), style: ts(11, weight: FontWeight.w700)),
                      Expanded(
                        child: Text(
                          context.l10n.investMaturesCap(dayMonthYear(inv.maturityAt!)),
                          textAlign: TextAlign.end,
                          style: ts(11, color: c.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (inv.institution.isNotEmpty || inv.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  if (inv.institution.isNotEmpty) DetailRow(label: context.l10n.institution, value: inv.institution),
                  if (inv.note.isNotEmpty) DetailRow(label: context.l10n.note, value: inv.note),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SipCard(investment: inv),
          SectionHeader(context.l10n.contributions(linked.length)),
          if (linked.isEmpty)
            Text(context.l10n.investNoMoney, style: ts(13, color: c.textMuted))
          else
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  for (final t in linked)
                    TxnTile(
                      t,
                      now: now,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TxnDetailScreen(id: t.txn.id!))),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          if (inv.status == InvestmentStatus.active) ...[
            FilledButton.icon(
              key: const Key('add-money'),
              style: FilledButton.styleFrom(backgroundColor: solidForWhite(c.invest), foregroundColor: Colors.white),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TxnFormScreen(initialType: TxnType.invest, investmentId: id),
                ),
              ),
              icon: const Icon(AppIcons.add),
              label: Text(context.l10n.investAddMoney),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(key: const Key('mark-matured'), onPressed: () => setStatus(InvestmentStatus.matured), child: Text(context.l10n.investMarkMatured)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(key: const Key('close-investment'), onPressed: () => setStatus(InvestmentStatus.closed), child: Text(context.l10n.investCloseSold)),
                ),
              ],
            ),
          ] else
            OutlinedButton(key: const Key('reactivate'), onPressed: () => setStatus(InvestmentStatus.active), child: Text(context.l10n.investReactivate)),
        ],
      ),
    );
  }
}

class InvestmentFormScreen extends StatefulWidget {
  const InvestmentFormScreen({super.key});

  @override
  State<InvestmentFormScreen> createState() => _InvestmentFormScreenState();
}

class _InvestmentFormScreenState extends State<InvestmentFormScreen> {
  InvestmentKind _kind = InvestmentKind.fd;
  final _name = TextEditingController();
  final _institution = TextEditingController();
  final _rate = TextEditingController();
  final _amount = TextEditingController();
  DateTime? _start;
  DateTime? _maturity;

  @override
  void dispose() {
    for (final c in [_name, _institution, _rate, _amount]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime? initial) => showDatePicker(context: context, initialDate: initial ?? AppScope.read(context).now(), firstDate: DateTime(1990), lastDate: DateTime(2100));

  void _save() {
    final app = AppScope.read(context);
    if (_name.text.trim().isEmpty) {
      showSnack(context, context.l10n.investNeedName);
      return;
    }
    final id = app.planning.addInvestment(Investment(kind: _kind, name: _name.text, institution: _institution.text, rate: double.tryParse(_rate.text.trim()), startAt: _start, maturityAt: _maturity));
    final amount = parseInr(_amount.text);
    if (amount != null && amount > 0) {
      final cat = app.catalog.firstOf(CategoryKind.invest);
      app.txns.insert(
        Txn(type: TxnType.invest, amount: amount, categoryId: cat.id, sourceId: app.catalog.defaultSource()?.id, occurredAt: _start ?? app.now(), merchant: _name.text.trim(), investmentId: id),
        now: app.now(),
      );
    }
    app.changed();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    String fmt(DateTime? d) => d == null ? context.l10n.notSet : dayMonthYear(d);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.investAdd, style: ts(16, weight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final k in InvestmentKind.values) Pill(investmentKindLabel(k), icon: investmentIcon(k), selected: k == _kind, onTap: () => setState(() => _kind = k))],
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('inv-name'),
            controller: _name,
            decoration: InputDecoration(labelText: context.l10n.investNameField),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('inv-institution'),
            controller: _institution,
            decoration: InputDecoration(labelText: context.l10n.investInstitutionField),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('inv-rate'),
            controller: _rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: context.l10n.debtFieldRate),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('inv-amount'),
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: context.l10n.investAmountField, prefixText: '$currencySymbol '),
          ),
          const SizedBox(height: 8),
          ListTile(
            key: const Key('inv-start'),
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.startDate),
            trailing: Text(fmt(_start), style: ts(13, color: c.textMuted)),
            onTap: () async {
              final d = await _pick(_start);
              if (d != null) setState(() => _start = d);
            },
          ),
          ListTile(
            key: const Key('inv-maturity'),
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.maturityDate),
            trailing: Text(fmt(_maturity), style: ts(13, color: c.textMuted)),
            onTap: () async {
              final d = await _pick(_maturity);
              if (d != null) setState(() => _maturity = d);
            },
          ),
          const SizedBox(height: 16),
          FilledButton(key: const Key('save-investment'), onPressed: _save, child: Text(context.l10n.investSave)),
        ],
      ),
    );
  }
}
