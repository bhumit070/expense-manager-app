import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

String sourceKindLabel(SourceKind k) => switch (k) {
  SourceKind.bank => 'Bank account',
  SourceKind.card => 'Credit card',
  SourceKind.cash => 'Cash',
  SourceKind.wallet => 'UPI / wallet',
};

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  Future<void> _add(BuildContext context, AppState app) async {
    final r = await showDialog<NewSource>(context: context, builder: (_) => const SourceDialog());
    if (r != null) {
      app.catalog.addSource(name: r.name, kind: r.kind, last4: r.last4, creditLimit: r.creditLimit, makeDefault: r.makeDefault);
      app.changed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final sources = app.catalog.sources();
    final spent = app.catalog.spentBySource(Period.of(PeriodKind.month, app.now()));
    final def = app.catalog.defaultSource();
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment sources', style: ts(16, weight: FontWeight.w700)),
        actions: [IconButton(key: const Key('add-source'), icon: const Icon(Icons.add), onPressed: () => _add(context, app))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Default payment mode', style: ts(11, color: const Color(0xFFA5B4FC))),
                      Text(
                        def?.display ?? 'None',
                        style: ts(16, weight: FontWeight.w700, color: Colors.white),
                      ),
                      Text('Pre-selected on every new transaction', style: ts(11, color: const Color(0xFFC7D2FE))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RadioGroup<int>(
              groupValue: def?.id,
              onChanged: (v) {
                app.catalog.setDefaultSource(v!);
                app.changed();
              },
              child: Column(
                children: [
                  for (final s in sources) ...[
                    ListTile(
                      key: Key('source-${s.id}'),
                      leading: IconBadge(sourceIcon(s.kind), color: c.brand, background: c.brandSoft, size: 40),
                      title: Text(s.display, style: ts(14, weight: FontWeight.w600)),
                      subtitle: Text(
                        '${sourceKindLabel(s.kind)} · ${formatInr(spent[s.id] ?? 0)} out in ${monthsShort[app.now().month - 1]}${s.creditLimit == null ? '' : ' · limit ${formatInr(s.creditLimit!)}'}',
                        style: ts(11, color: c.textMuted),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<int>(key: Key('default-${s.id}'), value: s.id),
                          if (sources.length > 1)
                            IconButton(
                              key: Key('archive-source-${s.id}'),
                              icon: const Icon(Icons.archive_outlined),
                              onPressed: () {
                                app.catalog.archiveSource(s.id);
                                app.changed();
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef NewSource = ({String name, SourceKind kind, String? last4, int? creditLimit, bool makeDefault});

class SourceDialog extends StatefulWidget {
  const SourceDialog({super.key});

  @override
  State<SourceDialog> createState() => _SourceDialogState();
}

class _SourceDialogState extends State<SourceDialog> {
  final _name = TextEditingController();
  final _last4 = TextEditingController();
  final _limit = TextEditingController();
  SourceKind _kind = SourceKind.bank;
  bool _makeDefault = false;

  @override
  void dispose() {
    _name.dispose();
    _last4.dispose();
    _limit.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }
    final last4 = _last4.text.trim();
    Navigator.pop<NewSource>(context, (
      name: _name.text,
      kind: _kind,
      last4: last4.isEmpty ? null : last4,
      creditLimit: _kind == SourceKind.card ? parseInr(_limit.text) : null,
      makeDefault: _makeDefault,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New payment source'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final k in SourceKind.values) Pill(sourceKindLabel(k), selected: k == _kind, onTap: () => setState(() => _kind = k))],
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('source-name'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name, e.g. HDFC Savings'),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('source-last4'),
              controller: _last4,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Last 4 digits (optional)'),
            ),
            if (_kind == SourceKind.card)
              TextField(
                key: const Key('source-limit'),
                controller: _limit,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Credit limit (₹)'),
              ),
            CheckboxListTile(
              key: const Key('source-default'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Make default'),
              value: _makeDefault,
              onChanged: (v) => setState(() => _makeDefault = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          key: const Key('source-save'),
          style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
