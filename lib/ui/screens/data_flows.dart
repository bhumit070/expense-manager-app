import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
  if (context.mounted) showSnack(context, 'Exported ${kinds.length == 1 ? exportKindLabel(kinds.single).toLowerCase() : '${kinds.length} files'} to $path');
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
            Text('Export CSV', style: ts(18, weight: FontWeight.w800)),
            Text('UTF-8 files that open in Excel or Sheets. Several files are shared as one zip.', style: ts(12, color: c.textMuted)),
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
              child: Text(_picked.length > 1 ? 'Export ${_picked.length} files (zip)' : 'Export'),
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
  var title = 'Import preview';
  if (file.extension == 'pdf') {
    try {
      final lines = await extractPdfLines(file.bytes);
      final bank = detectBank(lines);
      final found = parseStatement(lines, bank: bank);
      if (found.isEmpty) {
        if (context.mounted) showSnack(context, 'No transactions found in this PDF. Try the CSV/Excel export from net banking.');
        return;
      }
      rows = statementToRows(found);
      title = '${bankLabel(bank)} · ${found.length} found';
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
  final path = await _busy(context, password.isEmpty ? 'Creating backup…' : 'Encrypting backup…', () async {
    final zip = buildLedgerZip(app, docs: await getApplicationDocumentsDirectory(), temp: await getTemporaryDirectory());
    final bytes = password.isEmpty ? zip : await encryptLedger(zip, password);
    return app.files.saveAndShare('expense-manager-${isoDateTime(app.now()).substring(0, 10)}.$ledgerExtension', bytes, 'application/octet-stream');
  });
  app.markBackedUp();
  if (context.mounted) showSnack(context, 'Backup saved to $path');
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
  final result = await _busy(context, 'Restoring…', () async => restoreLedger(app, found, mode, docs: await getApplicationDocumentsDirectory(), temp: await getTemporaryDirectory()));
  if (!context.mounted) return;
  showSnack(
    context,
    mode == RestoreMode.replace ? 'Restored ${result.transactions} transactions' : 'Added ${result.transactions} transactions${result.skipped == 0 ? '' : ' · ${result.skipped} already here'}',
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
      title: const Text('Back up now'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('One .ledger file with all your data and receipts. Save it to Drive, Files or a computer.', style: ts(13, color: c.textMuted)),
            SwitchListTile(
              key: const Key('backup-protect'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Protect with a password'),
              value: _protect,
              onChanged: (v) => setState(() => _protect = v),
            ),
            if (_protect) ...[
              TextField(
                key: const Key('backup-password'),
                controller: _pw,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Password (6+ characters)'),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('backup-confirm'),
                controller: _confirm,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Confirm password'),
              ),
              const SizedBox(height: 8),
              Text('There is no way to recover a forgotten password.', style: ts(11, color: c.debt)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          key: const Key('backup-go'),
          style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
          onPressed: _valid ? () => Navigator.pop(context, _protect ? _pw.text : '') : null,
          child: const Text('Back up'),
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
    title: const Text('Backup password'),
    content: TextField(
      key: const Key('unlock-password'),
      controller: _pw,
      obscureText: true,
      autofocus: true,
      decoration: const InputDecoration(labelText: 'Password'),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(
        key: const Key('unlock-go'),
        style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
        onPressed: () => Navigator.pop(context, _pw.text),
        child: const Text('Unlock'),
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
      title: const Text('Restore backup'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Made ${longDate(m.createdAt)} · app ${m.appVersion}', style: ts(13, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${n('transactions')} transactions · ${n('investments')} investments · ${n('debts')} debts · ${n('budgets')} budgets', style: ts(12, color: c.textMuted)),
            const SizedBox(height: 12),
            Segmented<RestoreMode>(
              values: RestoreMode.values,
              selected: _mode,
              label: (m) => m == RestoreMode.merge ? 'Merge' : 'Replace',
              onChanged: (m) => setState(() {
                _mode = m;
                _confirmed = false;
              }),
            ),
            const SizedBox(height: 10),
            Text(
              _mode == RestoreMode.merge
                  ? 'Adds what is missing on this phone. Matching categories, sources and accounts are reused; transactions already here are skipped.'
                  : 'Deletes everything on this phone and uses the backup instead.',
              style: ts(12, color: _mode == RestoreMode.replace ? c.spend : c.textMuted),
            ),
            if (_mode == RestoreMode.replace)
              CheckboxListTile(
                key: const Key('restore-confirm'),
                contentPadding: EdgeInsets.zero,
                title: const Text('I understand my current data will be erased'),
                value: _confirmed,
                onChanged: (v) => setState(() => _confirmed = v!),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          key: const Key('restore-go'),
          style: FilledButton.styleFrom(minimumSize: const Size(80, 40), backgroundColor: _mode == RestoreMode.replace ? c.spend : null),
          onPressed: _mode == RestoreMode.replace && !_confirmed ? null : () => Navigator.pop(context, _mode),
          child: Text(_mode == RestoreMode.merge ? 'Merge' : 'Replace'),
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
      title: const Text('Backup reminder'),
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
                app.lastBackupAt == null ? 'Your data lives only on this phone. Make a backup.' : 'Time for a backup · ${app.lastBackupLabel.toLowerCase()}',
                style: ts(12, weight: FontWeight.w600, color: c.text),
              ),
            ),
            TextButton(key: const Key('backup-banner-go'), onPressed: () => backUpFlow(context, app), child: const Text('Back up')),
            IconButton(key: const Key('backup-banner-dismiss'), icon: const Icon(AppIcons.close, size: 18), tooltip: 'Remind me later', onPressed: app.snoozeBackupReminder),
          ],
        ),
      ),
    );
  }
}
