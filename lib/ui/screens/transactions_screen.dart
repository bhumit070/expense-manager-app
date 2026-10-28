import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/recent_searches.dart';
import '../../data/transactions_repo.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/category_picker.dart';
import '../widgets/common.dart';
import '../widgets/highlight.dart';
import 'txn_actions.dart';
import 'txn_detail_screen.dart';
import 'txn_form_screen.dart';
import '../theme/icons.dart';

String scopeLabel(SearchScope s) => switch (s) {
  SearchScope.all => 'All',
  SearchScope.notes => 'Notes',
  SearchScope.merchant => 'Merchant',
  SearchScope.amount => 'Amount',
  SearchScope.place => 'Place',
};

String sortLabel(TxnSort s) => switch (s) {
  TxnSort.newest => 'Newest first',
  TxnSort.oldest => 'Oldest first',
  TxnSort.amountDesc => 'Amount: high to low',
  TxnSort.amountAsc => 'Amount: low to high',
};

/// The note, tags or place line that matched [query] within [scope], if any.
String? searchSnippet(TxnView v, String query, SearchScope scope) {
  final t = v.txn;
  final candidates = switch (scope) {
    SearchScope.all => [t.note, t.tags.join(' '), t.place ?? ''],
    SearchScope.notes => [t.note, t.tags.join(' ')],
    SearchScope.place => [t.place ?? ''],
    SearchScope.merchant || SearchScope.amount => const <String>[],
  };
  for (final text in candidates) {
    if (matchRanges(text, query).isNotEmpty) return text;
  }
  return null;
}

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
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _setSearch(String q) => setState(() => _filter = _filter.copyWith(search: q));

  void _useRecent(RecentSearches recent, String q) {
    _search.text = q;
    recent.add(q);
    _focus.unfocus();
    _setSearch(q);
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
    final recent = RecentSearches(app.settings);
    final recents = recent.items;
    final showRecents = _focus.hasFocus && !searching && recents.isNotEmpty;
    final byDay = _filter.sort == TxnSort.newest || _filter.sort == TxnSort.oldest;
    final query = _filter.search.trim();
    final amountQuery = parseInr(query);

    // Flatten into day headers + rows for a lazy builder.
    final items = <Object>[];
    DateTime? day;
    for (final r in rows) {
      final d = dayStart(r.txn.occurredAt);
      if (byDay && d != day) {
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
        actions: [
          PopupMenuButton<TxnSort>(
            key: const Key('sort'),
            tooltip: 'Sort',
            icon: const Icon(AppIcons.sort),
            initialValue: _filter.sort,
            onSelected: (v) => setState(() => _filter = _filter.copyWith(sort: v)),
            itemBuilder: (_) => [for (final v in TxnSort.values) PopupMenuItem(key: Key('sort-${v.name}'), value: v, child: Text(sortLabel(v)))],
          ),
        ],
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
                    focusNode: _focus,
                    textInputAction: TextInputAction.search,
                    onChanged: _setSearch,
                    onSubmitted: (v) {
                      recent.add(v);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(AppIcons.search, color: c.textFaint),
                      hintText: switch (_filter.scope) {
                        SearchScope.all => 'Search merchant, note, #tag, amount…',
                        SearchScope.notes => 'Search notes and #tags',
                        SearchScope.merchant => 'Search merchants',
                        SearchScope.amount => 'Exact amount, e.g. 450 or ₹1,200',
                        SearchScope.place => 'Search places',
                      },
                      suffixIcon: searching
                          ? IconButton(
                              key: const Key('clear-search'),
                              icon: const Icon(AppIcons.close, size: 18),
                              onPressed: () {
                                _search.clear();
                                _setSearch('');
                              },
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
                    icon: const Icon(AppIcons.filter),
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
          if (searching || _focus.hasFocus) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              key: const Key('search-scopes'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (final sc in SearchScope.values) ...[
                    if (sc != SearchScope.all) const SizedBox(width: 8),
                    Pill(
                      key: Key('scope-${sc.name}'),
                      scopeLabel(sc),
                      selected: _filter.scope == sc,
                      onTap: () => setState(() => _filter = _filter.copyWith(scope: sc)),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
                for (final cat in cats.where((x) => !x.isChild)) ...[
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
                  if (!searching) IconButton(key: const Key('prev-period'), icon: const Icon(AppIcons.chevronLeft), onPressed: () => setState(() => _period = _period!.previous)),
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
                  if (!searching) IconButton(key: const Key('next-period'), icon: const Icon(AppIcons.chevronRight), onPressed: () => setState(() => _period = _period!.next)),
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
            child: showRecents
                ? _RecentList(items: recents, recent: recent, onPick: (q) => _useRecent(recent, q), onChanged: () => setState(() {}))
                : items.isEmpty
                ? EmptyState(icon: AppIcons.searchOff, title: 'Nothing here', message: searching ? 'No transactions match "${_filter.search.trim()}".' : 'No transactions in this period.')
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
                      final id = v.txn.id!;
                      return Dismissible(
                        key: ValueKey('swipe-$id'),
                        background: _SwipeBackground(color: c.brand, icon: AppIcons.edit, label: 'Edit', alignment: Alignment.centerLeft),
                        secondaryBackground: _SwipeBackground(color: c.spend, icon: AppIcons.delete, label: 'Delete', alignment: Alignment.centerRight),
                        confirmDismiss: (dir) async {
                          if (dir == DismissDirection.endToStart) return true;
                          await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TxnFormScreen(existing: v)));
                          return false;
                        },
                        onDismissed: (_) => deleteTxnWithUndo(ScaffoldMessenger.of(context), app, id),
                        child: TxnTile(
                          v,
                          now: byDay ? null : now,
                          highlight: searching ? query : null,
                          snippet: searching ? searchSnippet(v, query, _filter.scope) : null,
                          highlightAmount: searching && (_filter.scope == SearchScope.all || _filter.scope == SearchScope.amount) && amountQuery == v.txn.amount,
                          onTap: () {
                            if (searching) recent.add(query);
                            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TxnDetailScreen(id: id)));
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.color, required this.icon, required this.label, required this.alignment});

  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Container(
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          label,
          style: ts(13, weight: FontWeight.w700, color: Colors.white),
        ),
      ],
    ),
  );
}

/// Recent searches, shown while the empty search box has focus.
class _RecentList extends StatelessWidget {
  const _RecentList({required this.items, required this.recent, required this.onPick, required this.onChanged});

  final List<String> items;
  final RecentSearches recent;
  final ValueChanged<String> onPick;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      key: const Key('recent-searches'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'RECENT SEARCHES',
                style: ts(12, weight: FontWeight.w700, color: c.textMuted, spacing: 0.6),
              ),
            ),
            TextButton(
              key: const Key('clear-recent'),
              onPressed: () {
                recent.clear();
                onChanged();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        for (final (i, q) in items.indexed)
          ListTile(
            key: Key('recent-$i'),
            contentPadding: EdgeInsets.zero,
            leading: Icon(AppIcons.history, color: c.textFaint),
            title: Text(q, style: ts(14, weight: FontWeight.w600)),
            onTap: () => onPick(q),
            trailing: IconButton(
              key: Key('remove-recent-$i'),
              icon: const Icon(AppIcons.close, size: 18),
              onPressed: () {
                recent.remove(q);
                onChanged();
              },
            ),
          ),
      ],
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
    final all = widget.app.catalog.categories();
    final cats = all.where((x) => categoryLabel(x, all).toLowerCase().contains(q)).toList();
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
            decoration: const InputDecoration(isDense: true, prefixIcon: Icon(AppIcons.search), hintText: 'Search categories'),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final cat in cats) Pill(categoryLabel(cat, all), dot: Color(cat.color), selected: _cats.contains(cat.id), onTap: () => _toggle(_cats, cat.id))],
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
