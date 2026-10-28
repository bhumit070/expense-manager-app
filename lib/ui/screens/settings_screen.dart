import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../data/models.dart';
import '../../data/transactions_repo.dart';
import '../../services/csv.dart';
import '../../services/pdf_report.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'categories_screen.dart';
import 'import_screen.dart';
import 'recurring_screen.dart';
import 'sources_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editName(BuildContext context, AppState app) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => NameDialog(initial: app.userName),
    );
    if (name != null) app.userName = name;
  }

  Future<void> _exportCsv(BuildContext context, AppState app) async {
    final rows = app.txns.list(const TxnFilter(), limit: 1 << 30);
    final path = await app.files.saveAndShare('transactions-${isoDateTime(app.now()).substring(0, 10)}.csv', utf8.encode(encodeCsv(rows)), 'text/csv');
    if (context.mounted) showSnack(context, 'Exported ${rows.length} transactions to $path');
  }

  Future<void> _exportPdf(BuildContext context, AppState app) async {
    final p = Period.of(PeriodKind.month, app.now());
    final bytes = await buildPdfReport(
      period: p,
      totals: app.txns.totalsIn(p),
      spendByCategory: app.txns.byCategory(p, TxnType.spend),
      transactions: app.txns.list(TxnFilter(from: p.start, to: p.end), limit: 5000),
    );
    await app.files.saveAndShare('report-${p.start.year}-${p.start.month}.pdf', bytes, 'application/pdf');
  }

  Future<void> _import(BuildContext context, AppState app) async {
    final text = await app.files.pickCsvText();
    if (text == null || !context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ImportScreen(csvText: text)));
  }

  Future<void> _toggleLocation(BuildContext context, AppState app, bool on) async {
    if (on && !await app.location.requestPermission()) {
      if (context.mounted) showSnack(context, 'Location permission denied — you can still type a place.');
      return;
    }
    app.locationEnabled = on;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    void open(Widget w) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));
    Widget group(String title, List<Widget> rows) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
          child: Text(
            title.toUpperCase(),
            style: ts(13, weight: FontWeight.w700, color: c.textMuted, spacing: 0.6),
          ),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: rows),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: ts(16, weight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          AppCard(
            color: c.investSoft,
            border: c.invest.withValues(alpha: 0.4),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: c.positive),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Your data never leaves this phone. Stored locally, no server. Export a backup to move devices.', style: ts(12, color: c.positive)),
                ),
              ],
            ),
          ),
          group('Profile', [
            ListTile(
              key: const Key('edit-name'),
              leading: const Icon(Icons.person_outline),
              title: const Text('Name'),
              trailing: Text(app.userName.isEmpty ? 'Not set' : app.userName),
              onTap: () => _editName(context, app),
            ),
          ]),
          group('Appearance', [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Segmented<ThemeMode>(
                values: const [ThemeMode.light, ThemeMode.dark, ThemeMode.system],
                selected: app.themeMode,
                label: (m) => switch (m) {
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                  ThemeMode.system => 'System',
                },
                onChanged: (m) => app.themeMode = m,
              ),
            ),
          ]),
          group('Defaults', [
            ListTile(
              key: const Key('open-sources'),
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Payment mode'),
              trailing: Text(app.catalog.defaultSource()?.name ?? 'None'),
              onTap: () => open(const SourcesScreen()),
            ),
            ListTile(
              key: const Key('open-categories'),
              leading: const Icon(Icons.grid_view),
              title: const Text('Categories'),
              trailing: Text('Default: ${app.catalog.defaultCategory().name}'),
              onTap: () => open(const CategoriesScreen()),
            ),
            ListTile(
              key: const Key('open-recurring'),
              leading: const Icon(Icons.repeat),
              title: const Text('Recurring transactions'),
              trailing: Text('${app.recurring.rules().where((r) => !r.paused && !r.ended).length} active'),
              onTap: () => open(const RecurringScreen()),
            ),
            const ListTile(leading: Icon(Icons.calendar_today_outlined), title: Text('Week starts on'), trailing: Text('Monday')),
          ]),
          group('Data', [
            ListTile(key: const Key('export-csv'), leading: const Icon(Icons.table_chart_outlined), title: const Text('Export CSV'), onTap: () => _exportCsv(context, app)),
            ListTile(key: const Key('export-pdf-month'), leading: const Icon(Icons.picture_as_pdf_outlined), title: const Text('Export this month as PDF'), onTap: () => _exportPdf(context, app)),
            ListTile(
              key: const Key('import-csv'),
              leading: const Icon(Icons.file_upload_outlined),
              title: const Text('Import CSV'),
              subtitle: const Text('Bank statement or a previous export'),
              onTap: () => _import(context, app),
            ),
          ]),
          group('Privacy & permissions', [
            SwitchListTile(
              key: const Key('location-switch'),
              secondary: const Icon(Icons.place_outlined),
              title: const Text('Location on transactions'),
              value: app.locationEnabled,
              onChanged: (v) => _toggleLocation(context, app, v),
            ),
          ]),
        ],
      ),
    );
  }
}

class NameDialog extends StatefulWidget {
  const NameDialog({super.key, required this.initial});

  final String initial;

  @override
  State<NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<NameDialog> {
  late final _ctrl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Your name'),
    content: TextField(key: const Key('name-field'), controller: _ctrl, autofocus: true),
    actions: [
      FilledButton(
        key: const Key('name-save'),
        style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
        onPressed: () => Navigator.pop(context, _ctrl.text),
        child: const Text('Save'),
      ),
    ],
  );
}
