import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/transactions_repo.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'budgets_screen.dart';
import 'categories_screen.dart';
import 'settings_screen.dart';
import 'sources_screen.dart';
import 'transactions_screen.dart';
import 'txn_detail_screen.dart';

String greeting(DateTime now) => now.hour < 12 ? 'Good morning' : (now.hour < 17 ? 'Good afternoon' : 'Good evening');

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenInsights, required this.onOpenInvestments, required this.onOpenDebts});

  final VoidCallback onOpenInsights;
  final VoidCallback onOpenInvestments;
  final VoidCallback onOpenDebts;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final now = app.now();
    final month = Period.of(PeriodKind.month, now);
    final totals = app.txns.totalsIn(month);
    final cats = app.txns.byCategory(month, TxnType.spend).take(4).toList();
    final recent = app.txns.list(const TxnFilter(), limit: 5);
    final invested = app.planning.holdings().fold<int>(0, (a, h) => a + h.invested);
    final debts = app.planning.debtSummary();
    final name = app.userName;
    void push(Widget w) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));

    final base = totals.income > 0 ? totals.income : (totals.moneyOut == 0 ? 1 : totals.moneyOut);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Row(
          children: [
            GestureDetector(
              key: const Key('open-settings'),
              onTap: () => push(const SettingsScreen()),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: c.brandSoft,
                child: name.isEmpty
                    ? Icon(Icons.person_outline, color: c.brand)
                    : Text(
                        initials(name),
                        style: ts(15, weight: FontWeight.w700, color: c.brand),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting(now), style: ts(12, color: c.textMuted)),
                  Text(name.isEmpty ? 'Welcome' : name, style: ts(18, weight: FontWeight.w700)),
                ],
              ),
            ),
            Text(
              month.label,
              style: ts(13, weight: FontWeight.w600, color: c.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _Hero(totals: totals, base: base),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.trending_up,
                label: 'Invested',
                value: formatInrCompact(invested),
                caption: '+${formatInrCompact(totals.invest)} this month',
                color: c.invest,
                soft: c.investSoft,
                onTap: onOpenInvestments,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                icon: Icons.credit_card,
                label: 'You owe',
                value: formatInrCompact(debts.owe),
                caption: '${formatInrCompact(debts.monthlyEmi)}/mo EMI',
                color: c.debt,
                soft: c.debtSoft,
                onTap: onOpenDebts,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(icon: Icons.people_outline, label: 'Owed to you', value: formatInrCompact(debts.owed), caption: 'to collect', color: c.brand, soft: c.brandSoft, onTap: onOpenDebts),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Pill('Budgets', icon: Icons.donut_large, onTap: () => push(const BudgetsScreen())),
              const SizedBox(width: 8),
              Pill('Categories', icon: Icons.grid_view, onTap: () => push(const CategoriesScreen())),
              const SizedBox(width: 8),
              Pill('Payment sources', icon: Icons.account_balance_wallet_outlined, onTap: () => push(const SourcesScreen())),
            ],
          ),
        ),
        SectionHeader('Where it went', action: 'Insights', onAction: onOpenInsights),
        AppCard(
          child: cats.isEmpty
              ? Text('No spending yet this month.', style: ts(13, color: c.textMuted))
              : Column(
                  children: [
                    for (final ct in cats)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            CategoryBadge(ct.category, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(ct.category.name, style: ts(13, weight: FontWeight.w600)),
                                      ),
                                      Text('${(ct.total * 100 / totals.spend).round()}%  ', style: ts(11, color: c.textMuted)),
                                      Text(formatInr(ct.total), style: ts(13, weight: FontWeight.w700)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  SegmentBar(segments: [(ct.total / cats.first.total, Color(ct.category.color))], height: 6),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        SectionHeader('Recent', action: 'View all', onAction: () => push(const TransactionsScreen())),
        if (recent.isEmpty)
          const AppCard(
            child: EmptyState(icon: Icons.receipt_long_outlined, title: 'No transactions yet', message: 'Tap + to add your first expense, investment or income.'),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < recent.length; i++) ...[
                  if (i > 0) const Divider(),
                  TxnTile(
                    recent[i],
                    now: now,
                    onTap: () => push(TxnDetailScreen(id: recent[i].txn.id!)),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.totals, required this.base});

  final Totals totals;
  final int base;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget legend(String label, int v, Color color) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts(12, color: const Color(0xFFC7D2FE)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatInr(v),
              style: ts(15, weight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Money out this month', style: ts(13, color: const Color(0xFFC7D2FE))),
          const SizedBox(height: 4),
          Text(
            formatInr(totals.moneyOut),
            key: const Key('hero-out'),
            style: ts(34, weight: FontWeight.w800, color: Colors.white, spacing: -1),
          ),
          Text('of ${formatInr(totals.income)} income', style: ts(13, color: const Color(0xFFA5B4FC))),
          const SizedBox(height: 16),
          SegmentBar(segments: [(totals.spend / base, c.spend), (totals.invest / base, c.invest)], height: 10, track: const Color(0xFF312E81)),
          const SizedBox(height: 16),
          Row(
            children: [
              legend('Spent', totals.spend, c.spend),
              const SizedBox(width: 8),
              legend('Invested', totals.invest, c.invest),
              const SizedBox(width: 8),
              legend('Left', totals.left, const Color(0xFF6366F1)),
            ],
          ),
        ],
      ),
    );
  }
}
