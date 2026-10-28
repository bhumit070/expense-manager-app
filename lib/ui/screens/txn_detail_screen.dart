import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/recurring_repo.dart';
import '../../services/receipts.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/map_preview.dart';
import 'txn_actions.dart';
import 'txn_form_screen.dart';
import '../theme/icons.dart';

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
        body: const EmptyState(icon: AppIcons.delete, title: 'Transaction deleted', message: 'This transaction no longer exists.'),
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
                if (t.recurringId == null ? null : app.recurring.byId(t.recurringId!) case final rule?) ...[const Divider(), DetailRow(label: 'Repeats', value: frequencyLabel(rule.frequency))],
              ],
            ),
          ),
          if (t.lat != null && t.lng != null) ...[const SizedBox(height: 12), MapPreview(lat: t.lat!, lng: t.lng!, label: t.place ?? t.titleOr(v.category.name))],
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
          if (t.receipt != null) ...[const SizedBox(height: 12), _ReceiptCard(txn: t)],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('duplicate'),
                  onPressed: () => open(TxnFormScreen(existing: v, duplicate: true)),
                  icon: const Icon(AppIcons.copy),
                  label: const Text('Duplicate'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('edit'),
                  onPressed: () => open(TxnFormScreen(existing: v)),
                  icon: const Icon(AppIcons.edit),
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
                    Navigator.of(context).pop();
                    deleteTxnWithUndo(messenger, app, id);
                  },
                  icon: const Icon(AppIcons.delete),
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

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.txn});

  final Txn txn;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final path = txn.receipt!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECEIPT',
            style: ts(12, weight: FontWeight.w700, color: c.textMuted, spacing: 0.6),
          ),
          const SizedBox(height: 10),
          if (isPdf(path))
            Row(
              children: [
                Icon(AppIcons.pdf, color: c.spend, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('PDF receipt', style: ts(14, weight: FontWeight.w600)),
                ),
              ],
            )
          else
            GestureDetector(
              key: const Key('receipt-image'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ReceiptViewer(path: path))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(File(path), height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, _, _) => _missing(c)),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(key: const Key('receipt-open'), onPressed: () => app.receipts.open(path), icon: const Icon(AppIcons.openExternal, size: 18), label: const Text('Open')),
              const Spacer(),
              TextButton.icon(
                key: const Key('receipt-remove'),
                style: TextButton.styleFrom(foregroundColor: c.spend),
                onPressed: () {
                  app.txns.update(txn.copyWith(receipt: () => null));
                  app.receipts.delete(path);
                  app.changed();
                },
                icon: const Icon(AppIcons.delete, size: 18),
                label: const Text('Remove'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _missing(AppColors c) => Container(
  height: 120,
  color: c.surfaceMuted,
  alignment: Alignment.center,
  child: Text('Receipt file not found', style: ts(12, color: c.textMuted)),
);

/// Full-screen, zoomable receipt photo.
class ReceiptViewer extends StatelessWidget {
  const ReceiptViewer({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: const Text('Receipt')),
    body: InteractiveViewer(
      maxScale: 5,
      child: Center(child: Image.file(File(path), errorBuilder: (_, _, _) => _missing(context.colors))),
    ),
  );
}
