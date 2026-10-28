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
import 'reminders_screen.dart';
import 'data_flows.dart';
import 'settings_screen.dart';
import 'sources_screen.dart';
import 'transactions_screen.dart';
import 'txn_detail_screen.dart';
import '../theme/icons.dart';

String greeting(DateTime now) => now.hour < 12 ? 'Good morning' : (now.hour < 17 ? 'Good afternoon' : 'Good evening');

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenInsights, required this.onOpenInvestments, required this.onOpenDebts});

  final VoidCallback onOpenInsights;
  final VoidCallback onOpenInvestments;
  final VoidCallback onOpenDebts;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Selected month; null means "the current month" so it follows the clock.
  Period? _picked;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final now = app.now();
    final current = Period.of(PeriodKind.month, now);
    final month = _picked ?? current;
    final isCurrent = month == current;
    final totals = app.txns.totalsIn(month);
    final cats = app.txns.byCategory(month, TxnType.spend).take(4).toList();
    final recent = app.txns.list(isCurrent ? const TxnFilter() : TxnFilter(from: month.start, to: month.end), limit: 5);
    final upcoming = app.planning.upcoming(now);
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
              child: Semantics(
                button: true,
                label: 'Settings',
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: c.brandSoft,
                  child: name.isEmpty
                      ? Icon(AppIcons.person, color: c.brand)
                      : Text(
                          initials(name),
                          style: ts(15, weight: FontWeight.w700, color: c.brand),
                        ),
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
            IconButton(
              key: const Key('open-reminders'),
              tooltip: 'Reminders',
              onPressed: () => push(const RemindersScreen()),
              icon: Badge(
                isLabelVisible: upcoming.isNotEmpty,
                smallSize: 8,
                backgroundColor: c.spend,
                child: Icon(AppIcons.notifications, color: c.text),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(key: const Key('home-prev-month'), tooltip: 'Previous month', onPressed: () => setState(() => _picked = month.previous), icon: const Icon(AppIcons.chevronLeft)),
            Expanded(
              child: Text(
                month.label,
                key: const Key('home-month'),
                textAlign: TextAlign.center,
                style: ts(14, weight: FontWeight.w700),
              ),
            ),
            IconButton(
              key: const Key('home-next-month'),
              tooltip: 'Next month',
              onPressed: isCurrent ? null : () => setState(() => _picked = month.next == current ? null : month.next),
              icon: const Icon(AppIcons.chevronRight),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _Hero(totals: totals, base: base, title: isCurrent ? 'Money out this month' : 'Money out in ${monthsShort[month.start.month - 1]}'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: AppIcons.trendingUp,
                label: 'Invested',
                value: formatInrCompact(invested),
                caption: '+${formatInrCompact(totals.invest)} ${isCurrent ? 'this month' : 'in ${monthsShort[month.start.month - 1]}'}',
                color: c.invest,
                soft: c.investSoft,
                onTap: widget.onOpenInvestments,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                icon: AppIcons.creditCard,
                label: 'You owe',
                value: formatInrCompact(debts.owe),
                caption: '${formatInrCompact(debts.monthlyEmi)}/mo EMI',
                color: c.debt,
                soft: c.debtSoft,
                onTap: widget.onOpenDebts,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(icon: AppIcons.people, label: 'Owed to you', value: formatInrCompact(debts.owed), caption: 'to collect', color: c.brand, soft: c.brandSoft, onTap: widget.onOpenDebts),
            ),
          ],
        ),
        if (upcoming.isNotEmpty) ...[
          SectionHeader('Coming up', action: 'See all', onAction: () => push(const RemindersScreen())),
          AppCard(
            key: const Key('coming-up'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [for (final u in upcoming.take(3)) UpcomingTile(u, now: now)]),
          ),
        ],
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Pill('Budgets', icon: AppIcons.insights, onTap: () => push(const BudgetsScreen())),
              const SizedBox(width: 8),
              Pill('Categories', icon: AppIcons.grid, onTap: () => push(const CategoriesScreen())),
              const SizedBox(width: 8),
              Pill('Payment sources', icon: AppIcons.wallet, onTap: () => push(const SourcesScreen())),
            ],
          ),
        ),
        const BackupBanner(padding: EdgeInsets.only(top: 16)),
        SectionHeader('Where it went', action: 'Insights', onAction: widget.onOpenInsights),
        AppCard(
          child: cats.isEmpty
              ? Text(isCurrent ? 'No spending yet this month.' : 'No spending in ${month.label}.', style: ts(13, color: c.textMuted))
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
          AppCard(
            child: isCurrent
                ? const EmptyState(icon: AppIcons.receipt, title: 'No transactions yet', message: 'Tap + to add your first expense, investment or income.')
                : EmptyState(icon: AppIcons.receipt, title: 'Nothing in ${month.label}', message: 'No transactions were recorded that month.'),
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
  const _Hero({required this.totals, required this.base, required this.title});

  final Totals totals;
  final int base;
  final String title;

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
          Text(title, style: ts(13, color: const Color(0xFFC7D2FE))),
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
