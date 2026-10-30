import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../l10n/l10n.dart';
import '../../data/models.dart';
import '../../data/transactions_repo.dart';
import '../../services/pdf_report.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import 'budgets_screen.dart';
import 'transactions_screen.dart';
import '../theme/icons.dart';

/// Percent change from [before] to [now], or null when there is no baseline.
int? percentChange(int before, int now) => before == 0 ? null : ((now - before) * 100 / before).round();

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  PeriodKind _kind = PeriodKind.month;
  Period? _period;
  TxnType _breakdown = TxnType.spend;

  /// Parent categories whose sub-category split is shown.
  final _expanded = <int>{};
  bool _exporting = false;

  Future<void> _export(AppState app, Period p) async {
    setState(() => _exporting = true);
    final bytes = await buildPdfReport(
      period: p,
      totals: app.txns.totalsIn(p),
      spendByCategory: app.txns.byCategory(p, TxnType.spend),
      transactions: app.txns.list(TxnFilter(from: p.start, to: p.end), limit: 5000),
    );
    await app.files.saveAndShare('report-${p.start.year}-${p.start.month}.pdf', bytes, 'application/pdf');
    if (mounted) setState(() => _exporting = false);
  }

  List<String> _labels(Period p, List<Bucket> b) => switch (p.kind) {
    PeriodKind.year => [for (final x in b) monthsShort[x.start.month - 1][0]],
    PeriodKind.month => [for (final x in b) shortDate(x.start)],
    PeriodKind.week => [for (final x in b) weekdaysShort[x.start.weekday - 1][0]],
  };

  int? _highlight(Period p, List<Bucket> b, DateTime now) {
    if (!p.contains(now)) return null;
    for (var i = b.length - 1; i >= 0; i--) {
      if (!b[i].start.isAfter(now)) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final now = app.now();
    final p = _period ??= Period.of(_kind, now);
    final t = app.txns.totalsIn(p);
    final prev = app.txns.totalsIn(p.previous);
    final change = percentChange(prev.spend, t.spend);
    final buckets = app.txns.buckets(p);
    final cats = app.txns.byCategory(p, _breakdown);
    final catTotal = cats.fold<int>(0, (a, x) => a + x.total);
    final daysElapsed = p.contains(now) ? (now.difference(p.start).inDays + 1) : p.days;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(context.l10n.navInsights, style: ts(26, weight: FontWeight.w800, spacing: -0.5)),
            ),
            IconButton(
              key: const Key('open-budgets'),
              tooltip: context.l10n.budgetsTitle,
              icon: const Icon(AppIcons.insights),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BudgetsScreen())),
            ),
            _exporting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(key: const Key('export-pdf'), tooltip: context.l10n.pdfReport, icon: const Icon(AppIcons.pdf), onPressed: () => _export(app, p)),
          ],
        ),
        const SizedBox(height: 12),
        Segmented<PeriodKind>(
          values: PeriodKind.values,
          selected: _kind,
          label: (k) => switch (k) {
            PeriodKind.week => context.l10n.week,
            PeriodKind.month => context.l10n.month,
            PeriodKind.year => context.l10n.year,
          },
          onChanged: (k) => setState(() {
            _kind = k;
            _period = Period.of(k, now);
          }),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(key: const Key('insights-prev'), tooltip: context.l10n.previousPeriod, icon: const Icon(AppIcons.chevronLeft), onPressed: () => setState(() => _period = _period!.previous)),
            Expanded(
              child: Column(
                children: [
                  Text(p.label, style: ts(16, weight: FontWeight.w700)),
                  Text(p.rangeLabel, style: ts(12, color: c.textMuted)),
                ],
              ),
            ),
            IconButton(key: const Key('insights-next'), tooltip: context.l10n.nextPeriod, icon: const Icon(AppIcons.chevronRight), onPressed: () => setState(() => _period = _period!.next)),
          ],
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              DonutChart(
                semanticLabel: context.l10n.insightsDonutLabel(formatInr(t.spend), formatInr(t.invest)),
                segments: [(t.spend.toDouble(), c.spend), (t.invest.toDouble(), c.invest)],
                center: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.moneyOutLabel, style: ts(11, color: c.textMuted)),
                        Text(formatInrCompact(t.moneyOut), style: ts(18, weight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LegendDot(context.l10n.spent, c.spend),
                    Text(formatInr(t.spend), style: ts(17, weight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    LegendDot(context.l10n.invested, c.invest),
                    Text(formatInr(t.invest), style: ts(17, weight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: c.investSoft, borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        context.l10n.insightsSaved((t.savingsRate * 100).round()),
                        style: ts(11, weight: FontWeight.w600, color: c.positive),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      change == null ? context.l10n.insightsNoEarlier : (change <= 0 ? context.l10n.insightsLessSpent(-change) : context.l10n.insightsMoreSpent(change)),
                      style: ts(13, weight: FontWeight.w700),
                    ),
                    Text(context.l10n.insightsThanPrevious, style: ts(11, color: c.textMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.perDay(formatInr(t.spend ~/ daysElapsed)), style: ts(13, weight: FontWeight.w700)),
                    Text(context.l10n.averageSpend, style: ts(11, color: c.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),
        SectionHeader(switch (p.kind) {
          PeriodKind.year => context.l10n.monthByMonth,
          PeriodKind.month => context.l10n.weekByWeek,
          PeriodKind.week => context.l10n.dayByDay,
        }),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BucketBars(buckets: buckets, labels: _labels(p, buckets), highlight: _highlight(p, buckets, now)),
              const SizedBox(height: 10),
              Row(children: [LegendDot(context.l10n.typeSpend, c.spend), const SizedBox(width: 16), LegendDot(context.l10n.typeInvest, c.invest)]),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(context.l10n.byCategory, style: ts(17, weight: FontWeight.w700)),
              ),
              SizedBox(
                width: 160,
                child: Segmented<TxnType>(values: const [TxnType.spend, TxnType.invest], selected: _breakdown, label: typeLabel, onChanged: (v) => setState(() => _breakdown = v)),
              ),
            ],
          ),
        ),
        AppCard(
          child: cats.isEmpty
              ? Text(context.l10n.insightsNothing, style: ts(13, color: c.textMuted))
              : Column(
                  children: [
                    for (final ct in cats) ...[
                      _catRow(context, ct, p, share: ct.total / catTotal, bar: ct.total / cats.first.total, expanded: _expanded.contains(ct.category.id)),
                      if (_expanded.contains(ct.category.id))
                        for (final sub in app.txns.byCategory(p, _breakdown, parentId: ct.category.id))
                          Padding(
                            padding: const EdgeInsets.only(left: 28),
                            child: _catRow(
                              context,
                              sub,
                              p,
                              share: sub.total / ct.total,
                              bar: sub.total / ct.total,
                              label: sub.category.id == ct.category.id ? context.l10n.insightsDirect(sub.category.name) : null,
                            ),
                          ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  /// One breakdown row; tapping opens the matching transactions. Parents with
  /// sub-categories get a chevron that shows their split.
  Widget _catRow(BuildContext context, CategoryTotal ct, Period p, {required double share, required double bar, bool expanded = false, String? label}) {
    final c = context.colors;
    return InkWell(
      key: Key('cat-row-${ct.category.id}${label == null ? '' : '-direct'}'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TransactionsScreen(
            initialFilter: TxnFilter(categoryIds: {ct.category.id}, types: {_breakdown}),
            initialPeriod: p.kind == PeriodKind.month ? p : null,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            CategoryBadge(ct.category, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(context.l10n.insightsCatRow(label ?? ct.category.name, ct.count), style: ts(13, weight: FontWeight.w600)),
                      ),
                      Text('${(share * 100).round()}%  ', style: ts(11, color: c.textMuted)),
                      Text(formatInr(ct.total), style: ts(13, weight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SegmentBar(segments: [(bar, Color(ct.category.color))], height: 6),
                ],
              ),
            ),
            if (ct.subCount > 0)
              IconButton(
                key: Key('expand-cat-${ct.category.id}'),
                tooltip: expanded ? context.l10n.hideSubs : context.l10n.showSubs,
                icon: Icon(expanded ? AppIcons.expandLess : AppIcons.expandMore),
                onPressed: () => setState(() => expanded ? _expanded.remove(ct.category.id) : _expanded.add(ct.category.id)),
              ),
          ],
        ),
      ),
    );
  }
}
