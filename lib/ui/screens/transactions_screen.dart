import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/transactions_repo.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'txn_detail_screen.dart';

/// Searchable, filterable list of transactions grouped by day.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, this.initialFilter = const TxnFilter(), this.initialPeriod});

  final TxnFilter initialFilter;
  final Period? initialPeriod;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late TxnFilter _filter = widget.initialFilter;
  Period? _period;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final now = app.now();
    final period = _period ??= widget.initialPeriod ?? Period.of(PeriodKind.month, now);
    final searching = _filter.search.trim().isNotEmpty;
    // Searching spans all time; browsing is per period.
    final f = searching ? _filter : _filter.copyWith(from: period.start, to: period.end);
    final rows = app.txns.list(f, limit: 2000);
    final totals = app.txns.totals(f);
    final cats = app.catalog.categories();

    // Flatten into day headers + rows for a lazy builder.
    final items = <Object>[];
    DateTime? day;
    for (final r in rows) {
      final d = dayStart(r.txn.occurredAt);
      if (d != day) {
        day = d;
        items.add(d);
      }
      items.add(r);
    }
    int dayTotal(DateTime d) => rows.where((r) => dayStart(r.txn.occurredAt) == d).fold(0, (a, r) => a + r.signedAmount);

    final type = _filter.types.length == 1 ? _filter.types.first : null;
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions', style: ts(16, weight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('search'),
                    controller: _search,
                    onChanged: (v) => setState(() => _filter = _filter.copyWith(search: v)),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(Icons.search, color: c.textFaint),
                      hintText: 'Search merchant, note, #tag, amount…',
                      suffixIcon: searching
                          ? IconButton(
                              key: const Key('clear-search'),
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => setState(() {
                                _search.clear();
                                _filter = _filter.copyWith(search: '');
                              }),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Badge(
                  isLabelVisible: _filter.activeCount > 0,
                  label: Text('${_filter.activeCount}'),
                  backgroundColor: c.spend,
                  child: IconButton.filled(
                    key: const Key('open-filters'),
                    style: IconButton.styleFrom(backgroundColor: c.text, foregroundColor: c.bg, fixedSize: const Size(48, 48)),
                    icon: const Icon(Icons.filter_alt_outlined),
                    onPressed: () async {
                      final next = await showModalBottomSheet<TxnFilter>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: c.surface,
                        builder: (_) => FilterSheet(initial: _filter, app: app),
                      );
                      if (next != null) setState(() => _filter = next.copyWith(search: _filter.search));
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Segmented<TxnType?>(
              values: const [null, ...TxnType.values],
              selected: type,
              label: (t) => t == null ? 'All' : typeLabel(t),
              onChanged: (t) => setState(() => _filter = _filter.copyWith(types: t == null ? {} : {t})),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView(
              key: const Key('category-chips'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Pill(
                  'All categories',
                  selected: _filter.categoryIds.isEmpty,
                  onTap: () => setState(() => _filter = _filter.copyWith(categoryIds: {})),
                ),
                for (final cat in cats) ...[
                  const SizedBox(width: 8),
                  Pill(
                    cat.name,
                    dot: Color(cat.color),
                    selected: _filter.categoryIds.contains(cat.id),
                    onTap: () {
                      final ids = {..._filter.categoryIds};
                      ids.contains(cat.id) ? ids.remove(cat.id) : ids.add(cat.id);
                      setState(() => _filter = _filter.copyWith(categoryIds: ids));
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  if (!searching) IconButton(key: const Key('prev-period'), icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _period = _period!.previous)),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: searching ? 8 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(searching ? 'All time' : period.label, style: ts(14, weight: FontWeight.w700)),
                          Text('${totals.count} transactions', style: ts(12, color: c.textMuted)),
                        ],
                      ),
                    ),
                  ),
                  if (!searching) IconButton(key: const Key('next-period'), icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _period = _period!.next)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Out ${formatInr(totals.allOut)}',
                        style: ts(12, weight: FontWeight.w700, color: c.spend),
                      ),
                      Text(
                        'In ${formatInr(totals.allIn)}',
                        style: ts(12, weight: FontWeight.w700, color: c.positive),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(icon: Icons.search_off, title: 'Nothing here', message: searching ? 'No transactions match "${_filter.search.trim()}".' : 'No transactions in this period.')
                : ListView.builder(
                    key: const Key('txn-list'),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      if (item is DateTime) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4, 14, 4, 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  relativeDay(item, now),
                                  style: ts(13, weight: FontWeight.w700, color: c.textMuted),
                                ),
                              ),
                              Text(
                                formatInr(dayTotal(item), signed: true),
                                style: ts(13, weight: FontWeight.w600, color: c.textMuted),
                              ),
                            ],
                          ),
                        );
                      }
                      final v = item as TxnView;
                      return TxnTile(
                        v,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TxnDetailScreen(id: v.txn.id!))),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for types, categories, sources and amount range.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial, required this.app});

  final TxnFilter initial;
  final AppState app;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Set<TxnType> _types = {...widget.initial.types};
  late Set<int> _cats = {...widget.initial.categoryIds};
  late Set<int> _sources = {...widget.initial.sourceIds};
  late final _min = TextEditingController(text: widget.initial.minAmount == null ? '' : '${widget.initial.minAmount! ~/ 100}');
  late final _max = TextEditingController(text: widget.initial.maxAmount == null ? '' : '${widget.initial.maxAmount! ~/ 100}');
  String _catQuery = '';

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _toggle<T>(Set<T> set, T v) => setState(() => set.contains(v) ? set.remove(v) : set.add(v));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final q = _catQuery.toLowerCase();
    final cats = widget.app.catalog.categories().where((x) => x.name.toLowerCase().contains(q)).toList();
    Widget label(String t) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        t.toUpperCase(),
        style: ts(12, weight: FontWeight.w700, color: c.textMuted, spacing: 0.6),
      ),
    );
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Filters', style: ts(20, weight: FontWeight.w800)),
              ),
              TextButton(
                key: const Key('reset-filters'),
                onPressed: () => setState(() {
                  _types = {};
                  _cats = {};
                  _sources = {};
                  _min.clear();
                  _max.clear();
                }),
                child: const Text('Reset all'),
              ),
            ],
          ),
          label('Type'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final t in TxnType.values) Pill(typeLabel(t), dot: c.typeColor(t), selected: _types.contains(t), onTap: () => _toggle(_types, t))],
          ),
          label('Categories'),
          TextField(
            key: const Key('category-search'),
            onChanged: (v) => setState(() => _catQuery = v),
            decoration: const InputDecoration(isDense: true, prefixIcon: Icon(Icons.search), hintText: 'Search categories'),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final cat in cats) Pill(cat.name, dot: Color(cat.color), selected: _cats.contains(cat.id), onTap: () => _toggle(_cats, cat.id))],
          ),
          label('Amount ($currencySymbol)'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('min-amount'),
                  controller: _min,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(isDense: true, labelText: 'Min'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const Key('max-amount'),
                  controller: _max,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(isDense: true, labelText: 'Max'),
                ),
              ),
            ],
          ),
          label('Paid via'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final s in widget.app.catalog.sources()) Pill(s.name, selected: _sources.contains(s.id), onTap: () => _toggle(_sources, s.id))],
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('apply-filters'),
            onPressed: () {
              final min = parseInr(_min.text);
              final max = parseInr(_max.text);
              Navigator.of(context).pop(TxnFilter(types: _types, categoryIds: _cats, sourceIds: _sources, minAmount: min, maxAmount: max));
            },
            child: const Text('Apply filters'),
          ),
        ],
      ),
    );
  }
}
