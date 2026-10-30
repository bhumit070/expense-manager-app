import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../l10n/l10n.dart';
import '../../core/dates.dart';
import '../../services/backup.dart';
import '../../services/csv.dart';
import '../../services/csv_export.dart';
import '../../services/pdf_text.dart';
import '../../services/statement_import.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'import_screen.dart';
import '../theme/icons.dart';

// Export, import, backup and restore flows started from Settings.

/// Asks what to export, then shares one CSV or a zip of several.
Future<void> exportCsvFlow(BuildContext context, AppState app) async {
  final kinds = await showModalBottomSheet<Set<ExportKind>>(context: context, showDragHandle: true, builder: (_) => const ExportSheet());
  if (kinds == null || kinds.isEmpty) return;
  final out = buildExport(app, kinds);
  final path = await app.files.saveAndShare(out.name, out.bytes, out.mime);
  if (context.mounted) showSnack(context, kinds.length == 1 ? context.l10n.exportedOne(exportKindLabel(kinds.single).toLowerCase(), path) : context.l10n.exportedMany(kinds.length, path));
}

class ExportSheet extends StatefulWidget {
  const ExportSheet({super.key});

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  final _picked = {...ExportKind.values};

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.settingsExportCsv, style: ts(18, weight: FontWeight.w800)),
            Text(context.l10n.exportHelp, style: ts(12, color: c.textMuted)),
            const SizedBox(height: 8),
            for (final k in ExportKind.values)
              CheckboxListTile(
                key: Key('export-${k.name}'),
                contentPadding: EdgeInsets.zero,
                title: Text(exportKindLabel(k)),
                value: _picked.contains(k),
                onChanged: (v) => setState(() => v! ? _picked.add(k) : _picked.remove(k)),
              ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('export-go'),
              onPressed: _picked.isEmpty ? null : () => Navigator.pop(context, _picked),
              child: Text(_picked.length > 1 ? context.l10n.exportZip(_picked.length) : context.l10n.export),
            ),
          ],
        ),
      ),
    );
  }
}

/// Picks a CSV or PDF statement and opens the import preview.
Future<void> importFlow(BuildContext context, AppState app) async {
  final file = await app.files.pickFile(extensions: const ['csv', 'pdf']);
  if (file == null || !context.mounted) return;
  List<List<String>> rows;
  final l = context.l10n;
  var title = l.importPreview;
  if (file.extension == 'pdf') {
    try {
      final lines = await extractPdfLines(file.bytes);
      final bank = detectBank(lines);
      final found = parseStatement(lines, bank: bank);
      if (found.isEmpty) {
        if (context.mounted) showSnack(context, context.l10n.importPdfEmpty);
        return;
      }
      rows = statementToRows(found);
      title = l.importFound(bankLabel(bank), found.length);
    } on Exception catch (e) {
      if (context.mounted) showSnack(context, '$e');
      return;
    }
  } else {
    rows = parseCsv(file.text);
  }
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ImportScreen(rows: rows, title: title),
    ),
  );
}

/// Shows a non-dismissible spinner while [work] runs.
Future<T> _busy<T>(BuildContext context, String label, Future<T> Function() work) async {
  final nav = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
              const SizedBox(width: 16),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await work();
  } finally {
    nav.pop();
  }
}

/// Creates a `.ledger` backup (optionally password-protected) and shares it.
Future<void> backUpFlow(BuildContext context, AppState app) async {
  final password = await showDialog<String>(context: context, builder: (_) => const BackupPasswordDialog());
  if (password == null || !context.mounted) return;
  final path = await _busy(context, password.isEmpty ? context.l10n.backupCreating : context.l10n.backupEncrypting, () async {
    final zip = buildLedgerZip(app, docs: await getApplicationDocumentsDirectory(), temp: await getTemporaryDirectory());
    final bytes = password.isEmpty ? zip : await encryptLedger(zip, password);
    return app.files.saveAndShare('expense-manager-${isoDateTime(app.now()).substring(0, 10)}.$ledgerExtension', bytes, 'application/octet-stream');
  });
  app.markBackedUp();
  if (context.mounted) showSnack(context, context.l10n.backupSaved(path));
}

/// Restores a `.ledger` backup: password if needed, then Replace or Merge.
Future<void> restoreFlow(BuildContext context, AppState app) async {
  final file = await app.files.pickFile();
  if (file == null || !context.mounted) return;
  String? password;
  Ledger? ledger;
  while (ledger == null) {
    try {
      ledger = await openLedger(file.bytes, password: password);
    } on BackupException catch (e) {
      if (!context.mounted) return;
      if (e is BackupInvalid) {
        showSnack(context, e.message);
        return;
      }
      if (e is BackupWrongPassword) showSnack(context, e.message);
      password = await showDialog<String>(context: context, builder: (_) => const UnlockDialog());
      if (password == null || !context.mounted) return;
    }
  }
  if (!context.mounted) return;
  final found = ledger;
  final mode = await showDialog<RestoreMode>(
    context: context,
    builder: (_) => RestoreDialog(manifest: found.manifest),
  );
  if (mode == null || !context.mounted) return;
  final result = await _busy(context, context.l10n.restoring, () async => restoreLedger(app, found, mode, docs: await getApplicationDocumentsDirectory(), temp: await getTemporaryDirectory()));
  if (!context.mounted) return;
  showSnack(
    context,
    mode == RestoreMode.replace
        ? context.l10n.restoredN(result.transactions)
        : (result.skipped == 0 ? context.l10n.addedN(result.transactions) : context.l10n.addedNSkipped(result.transactions, result.skipped)),
  );
}

/// Optional password for a new backup. Pops '' for none, null on cancel.
class BackupPasswordDialog extends StatefulWidget {
  const BackupPasswordDialog({super.key});

  @override
  State<BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<BackupPasswordDialog> {
  final _pw = TextEditingController();
  final _confirm = TextEditingController();
  bool _protect = false;

  @override
  void dispose() {
    _pw.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _valid => !_protect || (_pw.text.length >= 6 && _pw.text == _confirm.text);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AlertDialog(
      title: Text(context.l10n.settingsBackUp),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.backupHelp, style: ts(13, color: c.textMuted)),
            SwitchListTile(key: const Key('backup-protect'), contentPadding: EdgeInsets.zero, title: Text(context.l10n.backupProtect), value: _protect, onChanged: (v) => setState(() => _protect = v)),
            if (_protect) ...[
              TextField(
                key: const Key('backup-password'),
                controller: _pw,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: context.l10n.backupPasswordField),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('backup-confirm'),
                controller: _confirm,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: context.l10n.confirmPassword),
              ),
              const SizedBox(height: 8),
              Text(context.l10n.backupNoRecovery, style: ts(11, color: c.debt)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
        FilledButton(
          key: const Key('backup-go'),
          style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
          onPressed: _valid ? () => Navigator.pop(context, _protect ? _pw.text : '') : null,
          child: Text(context.l10n.backUp),
        ),
      ],
    );
  }
}

/// Asks for the password of a protected backup.
class UnlockDialog extends StatefulWidget {
  const UnlockDialog({super.key});

  @override
  State<UnlockDialog> createState() => _UnlockDialogState();
}

class _UnlockDialogState extends State<UnlockDialog> {
  final _pw = TextEditingController();

  @override
  void dispose() {
    _pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.backupPassword),
    content: TextField(
      key: const Key('unlock-password'),
      controller: _pw,
      obscureText: true,
      autofocus: true,
      decoration: InputDecoration(labelText: context.l10n.password),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
      FilledButton(
        key: const Key('unlock-go'),
        style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
        onPressed: () => Navigator.pop(context, _pw.text),
        child: Text(context.l10n.unlock),
      ),
    ],
  );
}

/// Shows what is in a backup and asks how to restore it.
class RestoreDialog extends StatefulWidget {
  const RestoreDialog({super.key, required this.manifest});

  final LedgerManifest manifest;

  @override
  State<RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<RestoreDialog> {
  RestoreMode _mode = RestoreMode.merge;
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final m = widget.manifest;
    String n(String k) => '${m.counts[k] ?? 0}';
    return AlertDialog(
      title: Text(context.l10n.restoreBackup),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.backupMade(longDate(m.createdAt), m.appVersion), style: ts(13, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${n('transactions')} transactions · ${n('investments')} investments · ${n('debts')} debts · ${n('budgets')} budgets', style: ts(12, color: c.textMuted)),
            const SizedBox(height: 12),
            Segmented<RestoreMode>(
              values: RestoreMode.values,
              selected: _mode,
              label: (m) => m == RestoreMode.merge ? context.l10n.merge : context.l10n.replace,
              onChanged: (m) => setState(() {
                _mode = m;
                _confirmed = false;
              }),
            ),
            const SizedBox(height: 10),
            Text(_mode == RestoreMode.merge ? context.l10n.restoreMergeHelp : context.l10n.restoreReplaceHelp, style: ts(12, color: _mode == RestoreMode.replace ? c.spend : c.textMuted)),
            if (_mode == RestoreMode.replace)
              CheckboxListTile(
                key: const Key('restore-confirm'),
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.restoreConfirm),
                value: _confirmed,
                onChanged: (v) => setState(() => _confirmed = v!),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
        FilledButton(
          key: const Key('restore-go'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(80, 40),
            backgroundColor: _mode == RestoreMode.replace ? solidForWhite(c.spend) : null,
            foregroundColor: _mode == RestoreMode.replace ? Colors.white : null,
          ),
          onPressed: _mode == RestoreMode.replace && !_confirmed ? null : () => Navigator.pop(context, _mode),
          child: Text(_mode == RestoreMode.merge ? context.l10n.merge : context.l10n.replace),
        ),
      ],
    );
  }
}

/// Settings row for how often to nag about backups.
class BackupIntervalTile extends StatelessWidget {
  const BackupIntervalTile({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ListTile(
      leading: const Icon(AppIcons.alarm),
      title: Text(context.l10n.backupReminder),
      subtitle: Text(app.lastBackupLabel),
      trailing: DropdownButton<BackupInterval>(
        key: const Key('backup-interval'),
        value: app.backupInterval,
        underline: const SizedBox.shrink(),
        items: [for (final i in BackupInterval.values) DropdownMenuItem(value: i, child: Text(backupIntervalLabel(i)))],
        onChanged: (i) => app.backupInterval = i!,
      ),
    );
  }
}

/// "Back up your data" banner, shown only when a backup is overdue.
class BackupBanner extends StatelessWidget {
  const BackupBanner({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (!app.backupOverdue) return const SizedBox.shrink();
    final c = context.colors;
    return Padding(
      padding: padding,
      child: AppCard(
        key: const Key('backup-banner'),
        color: c.debtSoft,
        padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
        child: Row(
          children: [
            Icon(AppIcons.cloudUpload, color: c.debt),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                app.lastBackupAt == null ? context.l10n.backupBannerNever : context.l10n.backupBannerDue(app.lastBackupLabel.toLowerCase()),
                style: ts(12, weight: FontWeight.w600, color: c.text),
              ),
            ),
            TextButton(key: const Key('backup-banner-go'), onPressed: () => backUpFlow(context, app), child: Text(context.l10n.backUp)),
            IconButton(key: const Key('backup-banner-dismiss'), icon: const Icon(AppIcons.close, size: 18), tooltip: context.l10n.remindLater, onPressed: app.snoozeBackupReminder),
          ],
        ),
      ),
    );
  }
}
