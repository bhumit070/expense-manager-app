import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'txn_form_screen.dart';

class TxnDetailScreen extends StatelessWidget {
  const TxnDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final v = app.txns.byId(id);
    if (v == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.delete_outline, title: 'Transaction deleted', message: 'This transaction no longer exists.'),
      );
    }
    final t = v.txn;
    void open(Widget w) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction', style: ts(16, weight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(child: CategoryBadge(v.category, size: 64)),
          const SizedBox(height: 10),
          Center(
            child: Text(t.titleOr(v.category.name), style: ts(18, weight: FontWeight.w700)),
          ),
          Center(
            child: Text(
              formatInr(v.signedAmount, signed: true),
              style: ts(38, weight: FontWeight.w800, spacing: -1, color: v.inflow ? c.positive : c.text),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TypeTag(t.type),
              const SizedBox(width: 8),
              Text(v.category.name, style: ts(12, color: c.textMuted)),
            ],
          ),
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                DetailRow(label: 'Date & time', value: '${longDate(t.occurredAt)} · ${timeOfDay(t.occurredAt)}'),
                const Divider(),
                DetailRow(label: v.inflow ? 'Received in' : 'Paid from', value: v.source?.display ?? '—'),
                if (t.place != null) ...[const Divider(), DetailRow(label: 'Location', value: t.place!)],
                if (t.lat != null) ...[const Divider(), DetailRow(label: 'Coordinates', value: '${t.lat!.toStringAsFixed(4)}, ${t.lng!.toStringAsFixed(4)}')],
              ],
            ),
          ),
          if (t.note.isNotEmpty || t.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOTE',
                    style: ts(12, weight: FontWeight.w700, color: c.textMuted, spacing: 0.6),
                  ),
                  if (t.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(t.note, style: ts(15, height: 1.45)),
                    ),
                  if (t.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [for (final tag in t.tags) Chip(label: Text(tag), visualDensity: VisualDensity.compact)],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('duplicate'),
                  onPressed: () => open(TxnFormScreen(existing: v, duplicate: true)),
                  icon: const Icon(Icons.copy),
                  label: const Text('Duplicate'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('edit'),
                  onPressed: () => open(TxnFormScreen(existing: v)),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('delete'),
                  style: OutlinedButton.styleFrom(foregroundColor: c.spend),
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    app.txns.delete(id);
                    app.changed();
                    Navigator.of(context).pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('Transaction deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            app.txns.restore(id);
                            app.changed();
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
