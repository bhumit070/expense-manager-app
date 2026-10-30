import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../l10n/l10n.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/category_picker.dart';
import '../widgets/common.dart';
import '../theme/icons.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  BudgetPeriod _period = BudgetPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final now = app.now();
    final items = app.planning.budgets(period: _period).map((b) => app.planning.progress(b, now)).toList();
    final over = items.where((p) => p.isOver).toList();
    void open([Budget? b]) => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BudgetFormScreen(existing: b, period: _period),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.budgetsTitle, style: ts(16, weight: FontWeight.w700)),
        actions: [IconButton(key: const Key('new-budget'), tooltip: context.l10n.budgetNew, icon: const Icon(AppIcons.add), onPressed: open)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Segmented<BudgetPeriod>(
            values: BudgetPeriod.values,
            selected: _period,
            label: (p) => p == BudgetPeriod.weekly ? context.l10n.budgetTabWeekly(weekSpanLabel) : context.l10n.budgetTabMonthly,
            onChanged: (p) => setState(() => _period = p),
          ),
          const SizedBox(height: 14),
          for (final o in over)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                color: c.spendSoft,
                border: c.spend.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(AppIcons.info, color: c.spend),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.budgetOverBanner(o.budget.name, formatInr(o.used - o.limit)),
                        style: ts(13, weight: FontWeight.w700, color: c.spend),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (items.isEmpty)
            EmptyState(
              icon: AppIcons.insights,
              title: _period == BudgetPeriod.weekly ? context.l10n.budgetNoneWeekly : context.l10n.budgetNoneMonthly,
              message: context.l10n.budgetEmptyHelp,
              action: context.l10n.budgetCreate,
              onAction: open,
            ),
          for (final p in items) ...[_BudgetCard(p, onTap: () => open(p.budget)), const SizedBox(height: 10)],
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard(this.p, {required this.onTap});

  final BudgetProgress p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = p.budget.isGoal ? c.invest : (p.isOver ? c.spend : (p.isNear ? c.debt : c.brand));
    final status = p.budget.isGoal
        ? (p.remaining <= 0 ? context.l10n.budgetGoalReached : context.l10n.budgetToGoal(formatInr(p.remaining)))
        : p.isOver
        ? context.l10n.budgetOverBy(formatInr(-p.remaining))
        : context.l10n.budgetLeft(formatInr(p.remaining), formatInr(p.perDayLeft), context.l10n.daysLeft(p.daysLeft));
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(p.budget.isGoal ? AppIcons.trendingUp : AppIcons.insights, color: color, background: color.withValues(alpha: 0.14)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.budget.name, style: ts(14, weight: FontWeight.w700)),
                    Text(
                      p.budget.categoryIds.isEmpty ? (p.budget.isGoal ? context.l10n.budgetAllInvestments : context.l10n.budgetAllSpending) : context.l10n.nCategories(p.budget.categoryIds.length),
                      style: ts(11, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatInr(p.used),
                    style: ts(14, weight: FontWeight.w700, color: p.isOver ? c.spend : c.text),
                  ),
                  Text(context.l10n.ofAmount(formatInr(p.limit)), style: ts(11, color: c.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              SegmentBar(segments: [(p.fraction, color)], height: 8),
              if (!p.budget.isGoal)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment((p.elapsed * 2) - 1, 0),
                    child: Container(key: const Key('pace-marker'), width: 2, height: 8, color: c.text),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: ts(12, weight: FontWeight.w600, color: p.isOver ? c.spend : (p.budget.isGoal ? c.positive : c.textMuted)),
          ),
        ],
      ),
    );
  }
}

class BudgetFormScreen extends StatefulWidget {
  const BudgetFormScreen({super.key, this.existing, this.period = BudgetPeriod.monthly});

  final Budget? existing;
  final BudgetPeriod period;

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _limit = TextEditingController(text: widget.existing == null ? '' : '${widget.existing!.limit ~/ 100}');
  late BudgetPeriod _period = widget.existing?.period ?? widget.period;
  late Set<int> _cats = {...?widget.existing?.categoryIds};
  late bool _goal = widget.existing?.isGoal ?? false;
  late bool _rollover = widget.existing?.rollover ?? false;
  late bool _alert80 = widget.existing?.alert80 ?? true;
  late bool _alert100 = widget.existing?.alert100 ?? true;

  @override
  void dispose() {
    _name.dispose();
    _limit.dispose();
    super.dispose();
  }

  void _save() {
    final app = AppScope.read(context);
    final limit = parseInr(_limit.text);
    if (_name.text.trim().isEmpty || limit == null || limit <= 0) {
      showSnack(context, context.l10n.budgetNeedNameLimit);
      return;
    }
    final b = Budget(
      id: widget.existing?.id,
      name: _name.text,
      period: _period,
      limit: limit,
      categoryIds: _cats.toList()..sort(),
      rollover: _rollover,
      alert80: _alert80,
      alert100: _alert100,
      isGoal: _goal,
    );
    widget.existing == null ? app.planning.addBudget(b) : app.planning.updateBudget(b);
    app.changed();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final cats = app.catalog.categories(kind: _goal ? CategoryKind.invest : CategoryKind.spend);
    final suggestion = app.planning.suggestedLimit(_cats.toList(), app.now());
    Widget label(String t) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(t, style: ts(14, weight: FontWeight.w700)),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? context.l10n.budgetNew : context.l10n.budgetEdit, style: ts(16, weight: FontWeight.w700)),
        actions: [
          if (widget.existing != null)
            IconButton(
              key: const Key('delete-budget'),
              tooltip: context.l10n.budgetDelete,
              icon: const Icon(AppIcons.delete),
              onPressed: () {
                app.planning.deleteBudget(widget.existing!.id!);
                app.changed();
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          TextField(
            key: const Key('budget-name'),
            controller: _name,
            decoration: InputDecoration(labelText: context.l10n.budgetNameField),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('budget-limit'),
            controller: _limit,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: context.l10n.budgetLimitField(currencySymbol), prefixText: '$currencySymbol '),
          ),
          if (suggestion > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                key: const Key('use-suggestion'),
                onTap: () => setState(() => _limit.text = '${suggestion ~/ 100}'),
                child: Text(context.l10n.budgetSuggestion(formatInr(suggestion)), style: ts(12, color: c.brand)),
              ),
            ),
          label(context.l10n.budgetRepeats),
          Segmented<BudgetPeriod>(
            values: BudgetPeriod.values,
            selected: _period,
            label: (p) => p == BudgetPeriod.weekly ? context.l10n.budgetWeek(weekSpanLabel) : context.l10n.budgetMonth,
            onChanged: (p) => setState(() => _period = p),
          ),
          SwitchListTile(
            key: const Key('goal-switch'),
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.budgetGoal),
            subtitle: Text(context.l10n.budgetGoalHelp),
            value: _goal,
            onChanged: (v) => setState(() {
              _goal = v;
              _cats = {};
            }),
          ),
          label(_goal ? context.l10n.budgetCounts : context.l10n.budgetAppliesTo),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cat in cats)
                Pill(categoryLabel(cat, cats), dot: Color(cat.color), selected: _cats.contains(cat.id), onTap: () => setState(() => _cats.contains(cat.id) ? _cats.remove(cat.id) : _cats.add(cat.id))),
            ],
          ),
          const SizedBox(height: 8),
          if (!_goal)
            SwitchListTile(
              key: const Key('rollover-switch'),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.budgetRollover),
              value: _rollover,
              onChanged: (v) => setState(() => _rollover = v),
            ),
          SwitchListTile(
            key: const Key('alert80-switch'),
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.budgetAlert80Switch),
            value: _alert80,
            onChanged: (v) => setState(() => _alert80 = v),
          ),
          SwitchListTile(
            key: const Key('alert100-switch'),
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.budgetAlertOver),
            value: _alert100,
            onChanged: (v) => setState(() => _alert100 = v),
          ),
          const SizedBox(height: 16),
          FilledButton(key: const Key('save-budget'), onPressed: _save, child: Text(widget.existing == null ? context.l10n.budgetCreate : context.l10n.budgetSave)),
        ],
      ),
    );
  }
}
