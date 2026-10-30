import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../l10n/l10n.dart';
import '../core/dates.dart';
import '../data/database.dart';
import '../data/models.dart';
import '../state/app_state.dart';

/// App version written into backups (set with --dart-define=APP_VERSION=x).
const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '0.1.0');

/// File extension of a full backup.
const ledgerExtension = 'ledger';

/// Bumped when the container layout changes; restore refuses newer formats.
const ledgerFormat = 1;

/// Prefix of a password-protected backup. Unprotected backups are plain zips.
final ledgerMagic = ascii.encode('EMLEDGER');

/// PBKDF2-HMAC-SHA256 rounds for new backups (stored in the file).
int backupKdfIterations = 210000;

/// Runs CPU-heavy crypto off the UI isolate. Tests swap in a direct call.
Future<R> Function<R>(FutureOr<R> Function() computation) runInBackground = Isolate.run;

sealed class BackupException implements Exception {
  const BackupException();

  /// Why, in the app's language.
  String get message;

  @override
  String toString() => message;
}

class BackupNeedsPassword extends BackupException {
  const BackupNeedsPassword();

  @override
  String get message => currentL10n.backupNeedsPassword;
}

class BackupWrongPassword extends BackupException {
  const BackupWrongPassword();

  @override
  String get message => currentL10n.backupWrongPassword;
}

enum BackupProblem { notABackup, damaged, tooNew }

class BackupInvalid extends BackupException {
  const BackupInvalid([this.problem = BackupProblem.notABackup]);

  final BackupProblem problem;

  @override
  String get message => switch (problem) {
    BackupProblem.notABackup => currentL10n.backupInvalid,
    BackupProblem.damaged => currentL10n.backupDamaged,
    BackupProblem.tooNew => currentL10n.backupTooNew,
  };
}

/// What a backup says about itself.
class LedgerManifest {
  const LedgerManifest({required this.format, required this.schemaVersion, required this.appVersion, required this.createdAt, required this.counts});

  factory LedgerManifest.fromJson(Map<String, Object?> j) => LedgerManifest(
    format: j['format']! as int,
    schemaVersion: j['schema_version']! as int,
    appVersion: j['app_version']! as String,
    createdAt: DateTime.parse(j['created_at']! as String),
    counts: (j['counts']! as Map<String, Object?>).cast<String, int>(),
  );

  final int format;
  final int schemaVersion;
  final String appVersion;
  final DateTime createdAt;

  /// Rows per table (transactions, categories, sources, investments, debts, budgets).
  final Map<String, int> counts;

  Map<String, Object?> toJson() => {
    'app': 'expense_manager',
    'format': format,
    'schema_version': schemaVersion,
    'app_version': appVersion,
    'created_at': createdAt.toIso8601String(),
    'counts': counts,
  };
}

/// An opened backup: manifest, database snapshot and receipt files.
class Ledger {
  const Ledger({required this.manifest, required this.database, required this.receipts});

  final LedgerManifest manifest;
  final Uint8List database;

  /// Receipt files keyed by their path relative to `receipts/`.
  final Map<String, Uint8List> receipts;
}

const _tables = ['categories', 'sources', 'investments', 'debts', 'transactions', 'budgets'];

bool isEncryptedLedger(Uint8List bytes) => bytes.length > ledgerMagic.length && _startsWith(bytes, ledgerMagic);

bool _startsWith(Uint8List b, List<int> prefix) {
  for (var i = 0; i < prefix.length; i++) {
    if (b[i] != prefix[i]) return false;
  }
  return true;
}

/// Builds the backup zip: a consistent `VACUUM INTO` snapshot, a manifest and receipts.
Uint8List buildLedgerZip(AppState app, {required Directory docs, required Directory temp}) {
  final snap = File(p.join(temp.path, 'snapshot-${app.now().microsecondsSinceEpoch}.db'));
  if (snap.existsSync()) snap.deleteSync();
  app.db.execute('VACUUM INTO ?', [snap.path]);
  final counts = {for (final t in _tables) t: app.db.select('SELECT count(*) AS n FROM $t').single['n'] as int};
  final manifest = LedgerManifest(format: ledgerFormat, schemaVersion: app.db.userVersion, appVersion: appVersion, createdAt: app.now(), counts: counts);
  final archive = Archive()
    ..add(ArchiveFile.string('manifest.json', jsonEncode(manifest.toJson())))
    ..add(ArchiveFile.bytes('expense_manager.db', snap.readAsBytesSync()));
  snap.deleteSync();
  final receipts = Directory(p.join(docs.path, 'receipts'));
  if (receipts.existsSync()) {
    for (final f in receipts.listSync(recursive: true).whereType<File>()) {
      archive.add(ArchiveFile.bytes('receipts/${p.relative(f.path, from: receipts.path).replaceAll(r'\', '/')}', f.readAsBytesSync()));
    }
  }
  return ZipEncoder().encodeBytes(archive);
}

/// Encrypts [zip] with AES-256-GCM using a PBKDF2 key from [password].
///
/// Layout: magic(8) · format(1) · iterations(4, BE) · salt(16) · nonce(12) · ciphertext · tag(16).
Future<Uint8List> encryptLedger(Uint8List zip, String password, {int? iterations}) {
  final rounds = iterations ?? backupKdfIterations;
  final rnd = Random.secure();
  final salt = Uint8List.fromList(List.generate(16, (_) => rnd.nextInt(256)));
  final nonce = Uint8List.fromList(List.generate(12, (_) => rnd.nextInt(256)));
  return runInBackground(() async {
    final key = await Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: rounds, bits: 256).deriveKeyFromPassword(password: password, nonce: salt);
    final box = await AesGcm.with256bits().encrypt(zip, secretKey: key, nonce: nonce);
    return (BytesBuilder(copy: false)
          ..add(ledgerMagic)
          ..addByte(ledgerFormat)
          ..add((ByteData(4)..setUint32(0, rounds)).buffer.asUint8List())
          ..add(salt)
          ..add(nonce)
          ..add(box.cipherText)
          ..add(box.mac.bytes))
        .takeBytes();
  });
}

Future<Uint8List> _decrypt(Uint8List bytes, String password) {
  const head = 8 + 1 + 4;
  if (bytes.length < head + 16 + 12 + 16) throw const BackupInvalid(BackupProblem.damaged);
  final rounds = ByteData.sublistView(bytes, 9, 13).getUint32(0);
  final salt = bytes.sublist(head, head + 16);
  final nonce = bytes.sublist(head + 16, head + 28);
  final cipher = bytes.sublist(head + 28, bytes.length - 16);
  final mac = bytes.sublist(bytes.length - 16);
  return runInBackground(() async {
    final key = await Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: rounds, bits: 256).deriveKeyFromPassword(password: password, nonce: salt);
    try {
      return Uint8List.fromList(
        await AesGcm.with256bits().decrypt(
          SecretBox(cipher, nonce: nonce, mac: Mac(mac)),
          secretKey: key,
        ),
      );
    } on SecretBoxAuthenticationError {
      throw const BackupWrongPassword();
    }
  });
}

/// Opens a backup file, decrypting it when protected, and validates it.
Future<Ledger> openLedger(Uint8List bytes, {String? password}) async {
  var zip = bytes;
  if (isEncryptedLedger(bytes)) {
    if (password == null || password.isEmpty) throw const BackupNeedsPassword();
    zip = await _decrypt(bytes, password);
  }
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(zip);
  } catch (_) {
    throw const BackupInvalid();
  }
  final manifestFile = archive.findFile('manifest.json');
  final db = archive.findFile('expense_manager.db');
  if (manifestFile == null || db == null) throw const BackupInvalid();
  final LedgerManifest manifest;
  try {
    final json = jsonDecode(utf8.decode(manifestFile.readBytes()!)) as Map<String, Object?>;
    if (json['app'] != 'expense_manager') throw const FormatException();
    manifest = LedgerManifest.fromJson(json);
  } catch (_) {
    throw const BackupInvalid();
  }
  if (manifest.format > ledgerFormat || manifest.schemaVersion > schemaVersion) {
    throw const BackupInvalid(BackupProblem.tooNew);
  }
  final receipts = <String, Uint8List>{};
  for (final f in archive.files) {
    final rel = f.name.startsWith('receipts/') ? f.name.substring('receipts/'.length) : null;
    // Reject absolute paths and traversal so a crafted zip cannot escape receipts/.
    if (rel == null || !f.isFile || rel.isEmpty || p.isAbsolute(rel) || p.split(rel).contains('..')) continue;
    receipts[rel] = f.readBytes()!;
  }
  return Ledger(manifest: manifest, database: db.readBytes()!, receipts: receipts);
}

enum RestoreMode {
  /// Wipe this phone's data and use the backup's.
  replace,

  /// Add rows from the backup that are not already here.
  merge,
}

class RestoreResult {
  const RestoreResult({required this.transactions, required this.skipped, required this.receipts});

  final int transactions;

  /// Backup transactions that already existed here (merge only).
  final int skipped;
  final int receipts;
}

/// Restores [ledger] into the app's database and receipts folder, then notifies listeners.
RestoreResult restoreLedger(AppState app, Ledger ledger, RestoreMode mode, {required Directory docs, required Directory temp}) {
  final file = File(p.join(temp.path, 'restore-${app.now().microsecondsSinceEpoch}.db'))..writeAsBytesSync(ledger.database, flush: true);
  final bk = sqlite3.open(file.path);
  migrate(bk);
  bk.close();
  final db = app.db;
  db.execute('ATTACH DATABASE ? AS bk', [file.path]);
  final RestoreResult result;
  try {
    db.execute('BEGIN');
    try {
      result = mode == RestoreMode.replace ? _replace(db) : _merge(app);
      db.execute('COMMIT');
    } catch (_) {
      db.execute('ROLLBACK');
      rethrow;
    }
  } finally {
    db.execute('DETACH DATABASE bk');
    file.deleteSync();
  }
  final dir = Directory(p.join(docs.path, 'receipts'));
  if (mode == RestoreMode.replace && dir.existsSync()) dir.deleteSync(recursive: true);
  var written = 0;
  for (final e in ledger.receipts.entries) {
    final f = File(p.joinAll([dir.path, ...p.split(e.key)]));
    if (f.existsSync()) continue;
    f
      ..createSync(recursive: true)
      ..writeAsBytesSync(e.value);
    written++;
  }
  app.changed();
  return RestoreResult(transactions: result.transactions, skipped: result.skipped, receipts: written);
}

List<String> _columns(Database db, String table) => db.select('PRAGMA main.table_info($table)').map((r) => r['name'] as String).toList();

RestoreResult _replace(Database db) {
  for (final t in _tables.reversed) {
    db.execute('DELETE FROM main.$t');
  }
  db.execute("DELETE FROM main.settings WHERE key NOT LIKE 'backup.%'");
  for (final t in _tables) {
    final cols = _columns(db, t).join(', ');
    db.execute('INSERT INTO main.$t ($cols) SELECT $cols FROM bk.$t');
  }
  db.execute("INSERT INTO main.settings(key, value) SELECT key, value FROM bk.settings WHERE key NOT LIKE 'backup.%'");
  return RestoreResult(transactions: db.select('SELECT count(*) AS n FROM main.transactions').single['n'] as int, skipped: 0, receipts: 0);
}

/// Inserts [row] into main.[table] without its id, applying [overrides].
int _insert(Database db, String table, Row row, Map<String, Object?> overrides) {
  final cols = _columns(db, table).where((c) => c != 'id' && row.containsKey(c)).toList();
  db.execute('INSERT INTO main.$table (${cols.join(', ')}) VALUES (${List.filled(cols.length, '?').join(', ')})', [for (final c in cols) overrides.containsKey(c) ? overrides[c] : row[c]]);
  return db.lastInsertRowId;
}

/// Maps each backup row of [table] to an existing row matched by [match], inserting the rest.
Map<int, int> _mapRows(Database db, String table, String match, List<Object?> Function(Row) key, {Map<String, Object?> overrides = const {}}) {
  final ids = <int, int>{};
  for (final row in db.select('SELECT * FROM bk.$table')) {
    final hit = db.select('SELECT id FROM main.$table WHERE $match LIMIT 1', key(row));
    ids[row['id'] as int] = hit.isNotEmpty ? hit.first['id'] as int : _insert(db, table, row, overrides);
  }
  return ids;
}

RestoreResult _merge(AppState app) {
  final db = app.db;
  final cats = _mapRows(db, 'categories', 'lower(name) = lower(?) AND kind = ?', (r) => [r['name'], r['kind']], overrides: {'is_default': 0});
  final sources = _mapRows(db, 'sources', "lower(name) = lower(?) AND kind = ? AND coalesce(last4, '') = coalesce(?, '')", (r) => [r['name'], r['kind'], r['last4']], overrides: {'is_default': 0});
  final invs = _mapRows(db, 'investments', 'kind = ? AND lower(name) = lower(?) AND lower(institution) = lower(?)', (r) => [r['kind'], r['name'], r['institution']]);
  final debts = _mapRows(db, 'debts', 'direction = ? AND kind = ? AND lower(name) = lower(?) AND lower(counterparty) = lower(?)', (r) => [r['direction'], r['kind'], r['name'], r['counterparty']]);
  // Decide duplicates against what was here before the merge, so two identical
  // entries inside the backup (two coffees on one day) are both kept.
  final fresh = <(Row, Map<String, int?>)>[];
  var skipped = 0;
  for (final r in db.select('SELECT * FROM bk.transactions WHERE deleted = 0 ORDER BY occurred_at, id')) {
    final mapped = <String, int?>{'category_id': cats[r['category_id']], 'source_id': sources[r['source_id']], 'investment_id': invs[r['investment_id']], 'debt_id': debts[r['debt_id']]};
    final probe = Txn(
      type: enumByName(TxnType.values, r['type']),
      amount: r['amount'] as int,
      categoryId: mapped['category_id']!,
      sourceId: mapped['source_id'],
      occurredAt: DateTime.fromMillisecondsSinceEpoch(r['occurred_at'] as int),
      merchant: r['merchant'] as String,
    );
    if (app.txns.isDuplicate(probe)) {
      skipped++;
    } else {
      fresh.add((r, mapped));
    }
  }
  for (final (r, mapped) in fresh) {
    _insert(db, 'transactions', r, mapped);
  }
  for (final r in db.select('SELECT * FROM bk.budgets')) {
    if (db.select('SELECT 1 FROM main.budgets WHERE lower(name) = lower(?) AND period = ?', [r['name'], r['period']]).isNotEmpty) continue;
    final ids = (r['category_ids'] as String).split(',').where((s) => s.isNotEmpty).map((s) => cats[int.parse(s)]).whereType<int>();
    _insert(db, 'budgets', r, {'category_ids': ids.join(',')});
  }
  return RestoreResult(transactions: fresh.length, skipped: skipped, receipts: 0);
}

// ---- Reminder --------------------------------------------------------------

enum BackupInterval { off, weekly, monthly }

String backupIntervalLabel(BackupInterval i) => switch (i) {
  BackupInterval.off => currentL10n.off,
  BackupInterval.weekly => currentL10n.weekly,
  BackupInterval.monthly => currentL10n.monthly,
};

/// Backup reminder preferences, stored in settings under `backup.*`.
extension BackupPrefs on AppState {
  BackupInterval get backupInterval => BackupInterval.values.firstWhere((i) => i.name == settings.get('backup.interval'), orElse: () => BackupInterval.monthly);

  set backupInterval(BackupInterval i) {
    settings.set('backup.interval', i.name);
    changed();
  }

  DateTime? get lastBackupAt {
    final v = settings.get('backup.last');
    return v == null ? null : DateTime.fromMillisecondsSinceEpoch(int.parse(v));
  }

  void markBackedUp() {
    settings.set('backup.last', '${now().millisecondsSinceEpoch}');
    changed();
  }

  /// Hides the reminder banner for three days.
  void snoozeBackupReminder() {
    settings.set('backup.snooze', '${now().add(const Duration(days: 3)).millisecondsSinceEpoch}');
    changed();
  }

  /// True when the interval has passed since the last backup (or, if never
  /// backed up, since the first transaction was added).
  bool get backupOverdue {
    final interval = backupInterval;
    if (interval == BackupInterval.off) return false;
    final snooze = int.tryParse(settings.get('backup.snooze') ?? '');
    if (snooze != null && now().millisecondsSinceEpoch < snooze) return false;
    final first = db.select('SELECT min(created_at) AS t FROM transactions WHERE deleted = 0').single['t'] as int?;
    final since = lastBackupAt ?? (first == null ? null : DateTime.fromMillisecondsSinceEpoch(first));
    if (since == null) return false;
    return now().difference(since).inDays >= (interval == BackupInterval.weekly ? 7 : 30);
  }

  /// "Last backup: 12 Oct" / "Never backed up".
  String get lastBackupLabel => lastBackupAt == null ? currentL10n.backupNever : currentL10n.backupLast(shortDate(lastBackupAt!));
}
