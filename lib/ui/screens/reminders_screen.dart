import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../theme/icons.dart';

/// "Today", "Tomorrow", "in 5 days".
String dueIn(DateTime date, DateTime now) {
  final days = dayStart(date).difference(dayStart(now)).inDays;
  return switch (days) {
    0 => 'Today',
    1 => 'Tomorrow',
    _ => 'in $days days',
  };
}

/// Group header for a reminder date: "Today", "Tomorrow" or "Thu, 5 Nov".
String dueDayLabel(DateTime date, DateTime now) {
  final days = dayStart(date).difference(dayStart(now)).inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  final base = '${weekdaysShort[date.weekday - 1]}, ${date.day} ${monthsShort[date.month - 1]}';
  return date.year == now.year ? base : '$base ${date.year}';
}

String upcomingKindLabel(UpcomingKind k) => switch (k) {
  UpcomingKind.emi => 'EMI due',
  UpcomingKind.cardDue => 'Card bill due',
  UpcomingKind.maturity => 'Matures',
  UpcomingKind.sip => 'SIP due',
  UpcomingKind.followUp => 'Follow up',
};

IconData upcomingIcon(UpcomingKind k) => switch (k) {
  UpcomingKind.emi => AppIcons.eventRepeat,
  UpcomingKind.cardDue => AppIcons.creditCard,
  UpcomingKind.maturity => AppIcons.savings,
  UpcomingKind.sip => AppIcons.trendingUp,
  UpcomingKind.followUp => AppIcons.bellRing,
};

class UpcomingTile extends StatelessWidget {
  const UpcomingTile(this.item, {super.key, required this.now});

  final Upcoming item;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final investing = item.kind == UpcomingKind.maturity || item.kind == UpcomingKind.sip;
    final color = investing ? c.invest : c.debt;
    final soft = investing ? c.investSoft : c.debtSoft;
    final soon = dayStart(item.date).difference(dayStart(now)).inDays <= 3;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          IconBadge(upcomingIcon(item.kind), color: color, background: soft, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts(14, weight: FontWeight.w600),
                ),
                Text('${upcomingKindLabel(item.kind)} · ${shortDate(item.date)}', style: ts(11, color: c.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.amount != null) Text(formatInr(item.amount!), style: ts(13, weight: FontWeight.w700)),
              Text(
                dueIn(item.date, now),
                style: ts(11, weight: FontWeight.w600, color: soon ? c.spend : c.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Everything due in the next 60 days, grouped by date.
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final now = app.now();
    final items = app.planning.upcoming(now, days: 60);
    final groups = <DateTime, List<Upcoming>>{};
    for (final u in items) {
      groups.putIfAbsent(dayStart(u.date), () => []).add(u);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders', style: ts(16, weight: FontWeight.w700)),
      ),
      body: items.isEmpty
          ? const EmptyState(icon: AppIcons.notifications, title: 'Nothing coming up', message: 'EMIs, card bills and FD maturities in the next 60 days show up here.')
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                for (final e in groups.entries) ...[
                  SectionHeader(dueDayLabel(e.key, now)),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Column(children: [for (final u in e.value) UpcomingTile(u, now: now)]),
                  ),
                ],
              ],
            ),
    );
  }
}
