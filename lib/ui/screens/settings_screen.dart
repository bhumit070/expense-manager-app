import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/transactions_repo.dart';
import '../../l10n/l10n.dart';
import '../../services/maps.dart';
import '../../services/pdf_report.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'categories_screen.dart';
import 'data_flows.dart';
import 'diagnostics_screen.dart';
import 'security_screen.dart';
import 'sms_screen.dart';
import 'recurring_screen.dart';
import 'reminder_settings_screen.dart';
import 'sources_screen.dart';
import '../theme/icons.dart';

/// The published privacy policy (GitHub Pages, built from docs/privacy-policy.md).
const privacyPolicyUrl = 'https://bhumit070.github.io/expense-manager-app/privacy-policy/';

/// The app's public source code and issue tracker.
const sourceCodeUrl = 'https://github.com/bhumit070/expense-manager-app';
const reportIssueUrl = '$sourceCodeUrl/issues/new';

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
        title: context.l10n.settingsDefaultSource,
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

  Future<void> _openLink(BuildContext context, String url) async {
    if (!await MapServices.instance.openExternal(Uri.parse(url)) && context.mounted) showSnack(context, context.l10n.settingsNoBrowser(url));
  }

  Future<void> _pickWeekStart(BuildContext context, AppState app) async {
    final picked = await showDialog<int>(
      context: context,
      builder: (_) => ChoiceDialog<int>(
        title: context.l10n.settingsWeekStart,
        subtitle: context.l10n.settingsWeekStartHelp,
        values: weekStartChoices,
        selected: app.weekStart,
        label: (d) => weekdaysLong[d - 1],
        keyPrefix: 'pick-week-start',
      ),
    );
    if (picked != null) app.weekStart = picked;
  }

  Future<void> _pickCurrency(BuildContext context, AppState app) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => ChoiceDialog<String>(
        title: context.l10n.settingsCurrency,
        subtitle: context.l10n.settingsCurrencyHelp,
        values: [for (final c in currencies) c.code],
        selected: app.currency.code,
        label: (code) {
          final c = currencyByCode(code);
          return '${c.symbol.trim()}  ${c.localName} (${c.code})';
        },
        keyPrefix: 'pick-currency',
      ),
    );
    if (picked != null) app.currency = currencyByCode(picked);
  }

  Future<void> _pickLanguage(BuildContext context, AppState app) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => ChoiceDialog<String>(
        title: context.l10n.settingsLanguage,
        values: ['', for (final l in appLanguages) l.code],
        selected: app.language ?? '',
        label: (code) => code.isEmpty ? context.l10n.settingsLanguageDevice : appLanguages.firstWhere((l) => l.code == code).name,
        keyPrefix: 'pick-language',
      ),
    );
    if (picked != null) app.language = picked.isEmpty ? null : picked;
  }

  void _showPrivacy(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(context.l10n.settingsPrivacy),
      content: Text(context.l10n.settingsPrivacyBody),
      actions: [
        TextButton(key: const Key('privacy-policy'), onPressed: () => MapServices.instance.openExternal(Uri.parse(privacyPolicyUrl)), child: Text(context.l10n.settingsReadPolicy)),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.ok)),
      ],
    ),
  );

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

  Future<void> _toggleLocation(BuildContext context, AppState app, bool on) async {
    if (on && !await app.location.requestPermission()) {
      if (context.mounted) showSnack(context, context.l10n.locationDenied);
      return;
    }
    app.locationEnabled = on;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final l = context.l10n;
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
        title: Text(l.settingsTitle, style: ts(16, weight: FontWeight.w700)),
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
                Icon(AppIcons.shield, color: c.positive),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l.settingsLocalOnly, style: ts(12, color: c.positive)),
                ),
              ],
            ),
          ),
          const BackupBanner(padding: EdgeInsets.only(top: 12)),
          group(l.settingsProfile, [
            ListTile(
              key: const Key('edit-name'),
              leading: const Icon(AppIcons.person),
              title: Text(l.settingsName),
              trailing: TrailingText(app.userName.isEmpty ? l.notSet : app.userName),
              onTap: () => _editName(context, app),
            ),
          ]),
          group(l.settingsAppearance, [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Segmented<ThemeMode>(
                values: const [ThemeMode.light, ThemeMode.dark, ThemeMode.system],
                selected: app.themeMode,
                label: (m) => switch (m) {
                  ThemeMode.light => l.themeLight,
                  ThemeMode.dark => l.themeDark,
                  ThemeMode.system => l.themeSystem,
                },
                onChanged: (m) => app.themeMode = m,
              ),
            ),
            ListTile(
              key: const Key('language'),
              leading: const Icon(AppIcons.language),
              title: Text(l.settingsLanguage),
              trailing: TrailingText(app.language == null ? l.settingsLanguageDevice : appLanguages.firstWhere((x) => x.code == app.language).name),
              onTap: () => _pickLanguage(context, app),
            ),
          ]),
          group(l.settingsDefaults, [
            ListTile(
              key: const Key('default-source'),
              leading: const Icon(AppIcons.checkCircle),
              title: Text(l.settingsDefaultSource),
              subtitle: Text(l.settingsDefaultSourceHelp),
              trailing: TrailingText(app.catalog.defaultSource()?.name ?? l.none),
              onTap: () => _pickDefaultSource(context, app),
            ),
            ListTile(
              key: const Key('open-sources'),
              leading: const Icon(AppIcons.wallet),
              title: Text(l.settingsSources),
              trailing: TrailingText(l.nActive(app.catalog.sources().length)),
              onTap: () => open(const SourcesScreen()),
            ),
            ListTile(
              key: const Key('open-categories'),
              leading: const Icon(AppIcons.grid),
              title: Text(l.settingsCategories),
              subtitle: Text(l.settingsCategoriesHelp),
              trailing: TrailingText(l.settingsDefaultCategory(app.catalog.defaultCategory().name)),
              onTap: () => open(const CategoriesScreen()),
            ),
            ListTile(
              key: const Key('currency'),
              leading: const Icon(AppIcons.currency),
              title: Text(l.settingsCurrency),
              trailing: TrailingText('${app.currency.code} · $currencySymbol'),
              onTap: () => _pickCurrency(context, app),
            ),
            ListTile(
              key: const Key('open-recurring'),
              leading: const Icon(AppIcons.repeat),
              title: Text(l.settingsRecurring),
              trailing: TrailingText(l.nActive(app.recurring.rules().where((r) => !r.paused && !r.ended).length)),
              onTap: () => open(const RecurringScreen()),
            ),
            ListTile(
              key: const Key('week-start'),
              leading: const Icon(AppIcons.calendar),
              title: Text(l.settingsWeekStart),
              subtitle: Text(l.settingsWeekSpan(weekSpanLabel)),
              trailing: TrailingText(weekdaysLong[app.weekStart - 1]),
              onTap: () => _pickWeekStart(context, app),
            ),
          ]),
          group(l.settingsData, [
            ListTile(
              key: const Key('export-csv'),
              leading: const Icon(AppIcons.spreadsheet),
              title: Text(l.settingsExportCsv),
              subtitle: Text(l.settingsExportCsvHelp),
              onTap: () => exportCsvFlow(context, app),
            ),
            ListTile(key: const Key('export-pdf-month'), leading: const Icon(AppIcons.pdf), title: Text(l.settingsExportPdf), onTap: () => _exportPdf(context, app)),
            ListTile(key: const Key('import-csv'), leading: const Icon(AppIcons.upload), title: Text(l.settingsImport), subtitle: Text(l.settingsImportHelp), onTap: () => importFlow(context, app)),
            ListTile(key: const Key('backup-now'), leading: const Icon(AppIcons.backup), title: Text(l.settingsBackUp), subtitle: Text(l.settingsBackUpHelp), onTap: () => backUpFlow(context, app)),
            ListTile(key: const Key('restore-backup'), leading: const Icon(AppIcons.restore), title: Text(l.settingsRestore), onTap: () => restoreFlow(context, app)),
            const BackupIntervalTile(),
          ]),
          group(l.settingsPrivacyGroup, [
            SwitchListTile(
              key: const Key('location-switch'),
              secondary: const Icon(AppIcons.place),
              title: Text(l.settingsLocation),
              value: app.locationEnabled,
              onChanged: (v) => _toggleLocation(context, app, v),
            ),
            ListTile(
              key: const Key('open-security'),
              leading: const Icon(AppIcons.lock),
              title: Text(l.settingsAppLock),
              trailing: TrailingText(app.security.lockEnabled ? l.on : l.off),
              onTap: () => open(const SecurityScreen()),
            ),
            if (app.smsPlatform.supported)
              ListTile(
                key: const Key('open-sms'),
                leading: const Icon(AppIcons.sms),
                title: Text(l.smsTitle),
                trailing: TrailingText(app.sms.enabled ? l.on : l.off),
                onTap: () => open(const SmsScreen()),
              ),
            ListTile(
              key: const Key('open-reminders'),
              leading: const Icon(AppIcons.notifications),
              title: Text(l.remindersTitle),
              trailing: TrailingText(app.reminders.enabled ? l.on : l.off),
              onTap: () => open(const ReminderSettingsScreen()),
            ),
          ]),
          group(l.settingsAbout, [
            ListTile(
              key: const Key('app-version'),
              leading: const Icon(AppIcons.info),
              title: Text(l.settingsVersion),
              trailing: FutureBuilder<String>(future: app.info.version(), builder: (_, snap) => TrailingText(snap.data ?? (snap.hasError ? l.unknown : '…'))),
            ),
            ListTile(key: const Key('privacy'), leading: const Icon(AppIcons.privacy), title: Text(l.settingsPrivacy), subtitle: Text(l.settingsPrivacyHelp), onTap: () => _showPrivacy(context)),
            ListTile(
              key: const Key('source-code'),
              leading: const Icon(AppIcons.code),
              title: Text(l.settingsSourceCode),
              subtitle: const Text('github.com/bhumit070/expense-manager-app'),
              trailing: const Icon(AppIcons.openExternal, size: 18),
              onTap: () => _openLink(context, sourceCodeUrl),
            ),
            ListTile(
              key: const Key('licenses'),
              leading: const Icon(AppIcons.document),
              title: Text(l.settingsLicenses),
              onTap: () => showLicensePage(context: context, applicationName: l.appTitle),
            ),
          ]),
          group(l.settingsSupport, [
            ListTile(
              key: const Key('open-diagnostics'),
              leading: const Icon(AppIcons.bug),
              title: Text(l.diagnosticsTitle),
              subtitle: Text(l.settingsDiagnosticsHelp),
              onTap: () => open(const DiagnosticsScreen()),
            ),
            ListTile(
              key: const Key('report-issue'),
              leading: const Icon(AppIcons.bug),
              title: Text(l.settingsReportIssue),
              subtitle: Text(l.settingsReportIssueHelp),
              trailing: const Icon(AppIcons.openExternal, size: 18),
              onTap: () => _openLink(context, reportIssueUrl),
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
    title: Text(context.l10n.settingsYourName),
    content: TextField(key: const Key('name-field'), controller: _ctrl, autofocus: true),
    actions: [
      FilledButton(
        key: const Key('name-save'),
        style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
        onPressed: () => Navigator.pop(context, _ctrl.text),
        child: Text(context.l10n.save),
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
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel))],
  );
}
