import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/transactions_repo.dart';
import '../../services/csv.dart';
import '../../services/pdf_report.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'categories_screen.dart';
import 'diagnostics_screen.dart';
import 'import_screen.dart';
import 'security_screen.dart';
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

  Future<void> _pickDefaultSource(BuildContext context, AppState app) async {
    final sources = app.catalog.sources();
    final picked = await showDialog<int>(
      context: context,
      builder: (_) => ChoiceDialog<int>(
        title: 'Default payment mode',
        values: [for (final s in sources) s.id],
        selected: app.catalog.defaultSource()?.id,
        label: (id) => sources.firstWhere((s) => s.id == id).display,
        keyPrefix: 'pick-source',
      ),
    );
    if (picked == null) return;
    app.catalog.setDefaultSource(picked);
    app.changed();
  }

  Future<void> _pickCurrency(BuildContext context, AppState app) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => ChoiceDialog<String>(
        title: 'Currency',
        subtitle: 'Changes how amounts are shown. Nothing is converted.',
        values: [for (final c in currencies) c.code],
        selected: app.currency.code,
        label: (code) {
          final c = currencyByCode(code);
          return '${c.symbol.trim()}  ${c.name} (${c.code})';
        },
        keyPrefix: 'pick-currency',
      ),
    );
    if (picked != null) app.currency = currencyByCode(picked);
  }

  void _showPrivacy(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Privacy'),
      content: const Text(
        'Expense Manager has no account, server or analytics. Everything you enter is stored in a database on this phone and only leaves it when you export or share a file yourself.\n\n'
        'Location is read only when you allow it, and only to label your own transactions.',
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ),
  );

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
              key: const Key('default-source'),
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Default payment mode'),
              subtitle: const Text('Pre-selected on new transactions'),
              trailing: Text(app.catalog.defaultSource()?.name ?? 'None'),
              onTap: () => _pickDefaultSource(context, app),
            ),
            ListTile(
              key: const Key('open-sources'),
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Payment sources'),
              trailing: Text('${app.catalog.sources().length} active'),
              onTap: () => open(const SourcesScreen()),
            ),
            ListTile(
              key: const Key('open-categories'),
              leading: const Icon(Icons.grid_view),
              title: const Text('Categories'),
              subtitle: const Text('Uncategorised entries go to the default'),
              trailing: Text('Default: ${app.catalog.defaultCategory().name}'),
              onTap: () => open(const CategoriesScreen()),
            ),
            ListTile(
              key: const Key('currency'),
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currency'),
              trailing: Text('${app.currency.code} · $currencySymbol'),
              onTap: () => _pickCurrency(context, app),
            ),
            const ListTile(leading: Icon(Icons.calendar_today_outlined), title: Text('Week starts on'), subtitle: Text('Weekly budgets run Monday → Sunday'), trailing: Text('Monday')),
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
            ListTile(
              key: const Key('open-security'),
              leading: const Icon(Icons.lock_outline),
              title: const Text('App lock & privacy'),
              trailing: Text(app.security.lockEnabled ? 'On' : 'Off'),
              onTap: () => open(const SecurityScreen()),
            ),
          ]),
          group('About', [
            ListTile(
              key: const Key('app-version'),
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              trailing: FutureBuilder<String>(future: app.info.version(), builder: (_, snap) => Text(snap.data ?? (snap.hasError ? 'Unknown' : '…'))),
            ),
            ListTile(
              key: const Key('privacy'),
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy'),
              subtitle: const Text('No data collected · works offline'),
              onTap: () => _showPrivacy(context),
            ),
            ListTile(
              key: const Key('licenses'),
              leading: const Icon(Icons.description_outlined),
              title: const Text('Open-source licenses'),
              onTap: () => showLicensePage(context: context, applicationName: 'Expense Manager'),
            ),
          ]),
          group('Support', [
            ListTile(
              key: const Key('open-diagnostics'),
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Diagnostics'),
              subtitle: const Text('Local error log · view, share or clear'),
              onTap: () => open(const DiagnosticsScreen()),
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

/// Single-choice list dialog; pops the chosen value.
class ChoiceDialog<T> extends StatelessWidget {
  const ChoiceDialog({super.key, required this.title, required this.values, required this.selected, required this.label, required this.keyPrefix, this.subtitle});

  final String title;
  final String? subtitle;
  final List<T> values;
  final T? selected;
  final String Function(T) label;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
    content: SingleChildScrollView(
      child: RadioGroup<T>(
        groupValue: selected,
        onChanged: (v) => Navigator.pop(context, v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(subtitle!, style: ts(12, color: context.colors.textMuted)),
              ),
            for (final v in values) RadioListTile<T>(key: Key('$keyPrefix-$v'), value: v, title: Text(label(v))),
          ],
        ),
      ),
    ),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
  );
}
