import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../services/csv.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Preview of a CSV import with duplicate detection and per-row selection.
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key, required this.csvText});

  final String csvText;

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  List<ImportRow>? _rows;
  final _selected = <int>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_rows != null) return;
    final app = AppScope.read(context);
    _rows = buildImport(parseCsv(widget.csvText), app.catalog, app.txns, sourceId: app.catalog.defaultSource()?.id);
    for (var i = 0; i < _rows!.length; i++) {
      if (_rows![i].importable) _selected.add(i);
    }
  }

  void _import() {
    final app = AppScope.read(context);
    final n = app.txns.insertAll(resolveImport([for (final i in _selected) _rows![i]], app.catalog));
    app.changed();
    showSnack(context, 'Imported $n transactions');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rows = _rows!;
    final valid = rows.where((r) => r.txn != null).length;
    final dup = rows.where((r) => r.duplicate).length;
    final review = rows.where((r) => r.needsReview).length;
    final errors = rows.where((r) => r.error != null).length;
    Widget stat(String n, String l, Color color) => Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              n,
              style: ts(18, weight: FontWeight.w800, color: color),
            ),
            Text(
              l,
              style: ts(10, weight: FontWeight.w600, color: c.textMuted),
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Import preview', style: ts(16, weight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                stat('$valid', 'found', c.text),
                const SizedBox(width: 8),
                stat('$dup', 'duplicates', c.textMuted),
                const SizedBox(width: 8),
                stat('$review', 'review', c.debt),
                const SizedBox(width: 8),
                stat('$errors', 'errors', c.spend),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final r = rows[i];
                if (r.txn == null) {
                  return ListTile(
                    leading: Icon(Icons.error_outline, color: c.spend),
                    title: Text('Line ${r.line}'),
                    subtitle: Text(r.error!),
                  );
                }
                final t = r.txn!;
                return CheckboxListTile(
                  key: Key('import-$i'),
                  value: _selected.contains(i),
                  onChanged: (v) => setState(() => v! ? _selected.add(i) : _selected.remove(i)),
                  title: Text(t.titleOr(t.type.name), style: ts(14, weight: FontWeight.w600)),
                  subtitle: Text(
                    [
                      shortDate(t.occurredAt),
                      typeLabel(t.type),
                      if (r.duplicate) 'Duplicate',
                      if (r.needsReview) 'Category → Others',
                      if (r.newSubcategory != null) 'New sub-category: ${r.newSubcategory}',
                    ].join(' · '),
                    style: ts(11, color: r.duplicate ? c.textFaint : (r.needsReview ? c.debt : c.textMuted)),
                  ),
                  secondary: Text(formatInr(t.amount), style: ts(14, weight: FontWeight.w700)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: FilledButton(key: const Key('do-import'), onPressed: _selected.isEmpty ? null : _import, child: Text('Import ${_selected.length} transactions')),
          ),
        ],
      ),
    );
  }
}
