import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:expense_manager/data/database.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/services/backup.dart';
import 'package:expense_manager/services/csv.dart';
import 'package:expense_manager/services/csv_export.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Uint8List zipOf(Map<String, List<int>> files) {
  final a = Archive();
  files.forEach((k, v) => a.add(ArchiveFile.bytes(k, v)));
  return ZipEncoder().encodeBytes(a);
}

Map<String, Object?> manifestJson({int format = 1, int? schema, String app = 'expense_manager'}) => {
  'app': app,
  'format': format,
  'schema_version': schema ?? schemaVersion,
  'app_version': '0.1.0',
  'created_at': '2026-10-28T21:41:00.000',
  'counts': {'transactions': 1},
};

void main() {
  late Directory docs, temp;
  setUp(() {
    docs = Directory.systemTemp.createTempSync('docs');
    temp = Directory.systemTemp.createTempSync('temp');
    backupKdfIterations = 1000;
    runInBackground = <R>(FutureOr<R> Function() f) async => f();
  });
  tearDown(() {
    docs.deleteSync(recursive: true);
    temp.deleteSync(recursive: true);
  });

  group('CSV export', () {
    test('investments, debts and budgets have a BOM and the expected rows', () {
      final s = makeState();
      final ids = seed(s);
      s.planning.setDebtSettled(ids.lent, true);
      s.planning.addBudget(Budget(name: 'Food', period: BudgetPeriod.monthly, limit: 1500000, categoryIds: [catId(s, 'Food & dining'), 999], rollover: true));
      s.planning.addBudget(const Budget(name: 'Save', period: BudgetPeriod.weekly, limit: 500000, isGoal: true, alert80: false, alert100: false));
      final inv = parseCsv(encodeInvestmentsCsv(s));
      expect(encodeInvestmentsCsv(s).startsWith('﻿'), isTrue);
      expect(inv.first.first, 'kind');
      expect(inv.firstWhere((r) => r[1] == 'HDFC FD'), ['fd', 'HDFC FD', 'HDFC Bank', '7.1', '2026-03-12', '2026-11-12', 'active', '50000.00', '1', '']);
      expect(inv.firstWhere((r) => r[1] == 'Nifty 50 Index').sublist(3, 6), ['', '', '']);
      final debts = parseCsv(encodeDebtsCsv(s));
      expect(debts[1], ['iOwe', 'loan', 'Car loan', 'HDFC', '420000.00', '9.2', '12400.00', '36', '5', '12400.00', '407600.00', 'no']);
      expect(debts[2], ['owedToMe', 'personal', 'Rahul', '', '8500.00', '', '', '', '', '2500.00', '6000.00', 'yes']);
      final budgets = parseCsv(encodeBudgetsCsv(s));
      expect(budgets.sublist(1), [
        ['Food', 'monthly', '15000.00', 'Food & dining; #999', 'no', 'yes', 'yes', 'yes'],
        ['Save', 'weekly', '5000.00', 'All spending', 'yes', 'no', 'no', 'no'],
      ]);
    });

    test('one kind is a CSV, several are one zip', () {
      final s = makeState();
      seed(s);
      final one = buildExport(s, {ExportKind.debts});
      expect([one.name, one.mime], ['debts-2026-10-28.csv', 'text/csv']);
      final all = buildExport(s, ExportKind.values.toSet());
      expect([all.name, all.mime], ['expense-manager-export-2026-10-28.zip', 'application/zip']);
      final zip = ZipDecoder().decodeBytes(all.bytes);
      expect(zip.files.map((f) => f.name), ['transactions.csv', 'investments.csv', 'debts.csv', 'budgets.csv']);
      expect(utf8.decode(zip.findFile('transactions.csv')!.readBytes()!), contains('Swiggy'));
      expect(ExportKind.values.map(exportKindLabel), ['Transactions', 'Investments', 'Debts', 'Budgets']);
    });
  });

  group('Backup file', () {
    test('zip holds a snapshot, manifest and receipts; round-trips unencrypted', () async {
      final s = makeState();
      seed(s);
      File('${docs.path}/receipts/2026/r1.jpg')
        ..createSync(recursive: true)
        ..writeAsBytesSync([1, 2, 3]);
      final zip = buildLedgerZip(s, docs: docs, temp: temp);
      expect(isEncryptedLedger(zip), isFalse);
      final l = await openLedger(zip);
      expect(l.manifest.schemaVersion, schemaVersion);
      expect(l.manifest.appVersion, appVersion);
      expect(l.manifest.createdAt, kNow);
      expect(l.manifest.counts['transactions'], 9);
      expect(l.receipts.keys, ['2026/r1.jpg']);
      expect(l.database.take(15), ascii.encode('SQLite format 3'));
      // Without a receipts folder there are no receipts.
      Directory('${docs.path}/receipts').deleteSync(recursive: true);
      expect((await openLedger(buildLedgerZip(s, docs: docs, temp: temp))).receipts, isEmpty);
    });

    test('password protection: needs, wrong and right password', () async {
      final s = makeState();
      seed(s);
      final enc = await encryptLedger(buildLedgerZip(s, docs: docs, temp: temp), 'hunter22');
      expect(isEncryptedLedger(enc), isTrue);
      expect(String.fromCharCodes(enc.take(8)), 'EMLEDGER');
      await expectLater(openLedger(enc), throwsA(isA<BackupNeedsPassword>()));
      await expectLater(openLedger(enc, password: ''), throwsA(isA<BackupNeedsPassword>()));
      await expectLater(openLedger(enc, password: 'nope'), throwsA(isA<BackupWrongPassword>()));
      expect((await openLedger(enc, password: 'hunter22')).manifest.counts['transactions'], 9);
      await expectLater(openLedger(Uint8List.fromList([...ledgerMagic, 1, 2, 3])), throwsA(isA<BackupNeedsPassword>()));
      await expectLater(openLedger(Uint8List.fromList([...ledgerMagic, 1, 2, 3]), password: 'x'), throwsA(isA<BackupInvalid>()));
      expect('${const BackupWrongPassword()}', 'Wrong password');
    });

    test('invalid files are rejected with a reason', () async {
      Future<void> bad(List<int> bytes, String msg) => expectLater(openLedger(Uint8List.fromList(bytes)), throwsA(isA<BackupInvalid>().having((e) => e.message, 'message', contains(msg))));
      await bad(utf8.encode('hello'), 'Not an Expense Manager backup');
      await bad(zipOf({'manifest.json': utf8.encode('{}')}), 'Not an');
      await bad(
        zipOf({
          'manifest.json': utf8.encode('not json'),
          'expense_manager.db': [1],
        }),
        'Not an',
      );
      await bad(
        zipOf({
          'manifest.json': utf8.encode(jsonEncode(manifestJson(app: 'other'))),
          'expense_manager.db': [1],
        }),
        'Not an',
      );
      await bad(
        zipOf({
          'manifest.json': utf8.encode(jsonEncode(manifestJson(schema: schemaVersion + 1))),
          'expense_manager.db': [1],
        }),
        'newer version',
      );
      await bad(
        zipOf({
          'manifest.json': utf8.encode(jsonEncode(manifestJson(format: 99))),
          'expense_manager.db': [1],
        }),
        'newer version',
      );
    });

    test('receipt paths that escape the folder are dropped', () async {
      final l = await openLedger(
        zipOf({
          'manifest.json': utf8.encode(jsonEncode(manifestJson())),
          'expense_manager.db': [1],
          'receipts/ok.png': [1],
          'receipts/../evil.txt': [2],
          'receipts/': [],
          'other/file': [3],
        }),
      );
      expect(l.receipts.keys, ['ok.png']);
    });
  });

  group('Restore', () {
    test('replace swaps all data, keeps backup reminder prefs and receipts', () async {
      final src = makeState();
      seed(src);
      src.userName = 'Asha';
      File('${docs.path}/receipts/a.jpg')
        ..createSync(recursive: true)
        ..writeAsBytesSync([9]);
      final ledger = await openLedger(buildLedgerZip(src, docs: docs, temp: temp));

      final dst = makeState();
      dst.txns.insert(Txn(type: TxnType.spend, amount: 100, categoryId: dst.catalog.defaultCategory().id, sourceId: null, occurredAt: kNow, merchant: 'Old'));
      dst.markBackedUp();
      File('${docs.path}/receipts/old.jpg').writeAsBytesSync([7]);
      var notified = 0;
      dst.addListener(() => notified++);
      final r = restoreLedger(dst, ledger, RestoreMode.replace, docs: docs, temp: temp);
      expect([r.transactions, r.skipped, r.receipts], [9, 0, 1]);
      expect(notified, 1);
      expect(dst.txns.list(const TxnFilter()).any((t) => t.txn.merchant == 'Old'), isFalse);
      expect(dst.txns.list(const TxnFilter(search: 'dinner')).length, 2);
      expect(dst.userName, 'Asha');
      expect(dst.lastBackupAt, kNow);
      expect(File('${docs.path}/receipts/old.jpg').existsSync(), isFalse);
      expect(File('${docs.path}/receipts/a.jpg').readAsBytesSync(), [9]);
      expect(temp.listSync(), isEmpty);
    });

    test('merge maps ids, reuses matches, skips duplicates and keeps existing receipts', () async {
      final src = makeState();
      final ids = seed(src);
      src.catalog.addCategory(name: 'Pets', kind: CategoryKind.spend, icon: 'heart', color: 0xFF000000);
      final pets = catId(src, 'Pets');
      src.planning.addBudget(Budget(name: 'Pets', period: BudgetPeriod.monthly, limit: 100000, categoryIds: [pets]));
      src.planning.addBudget(const Budget(name: 'All', period: BudgetPeriod.monthly, limit: 100000));
      // Two identical coffees in the backup are both kept.
      for (var i = 0; i < 2; i++) {
        src.txns.insert(Txn(type: TxnType.spend, amount: 15000, categoryId: pets, sourceId: ids.card, occurredAt: DateTime(2026, 10, 20, 9), merchant: 'Vet'));
      }
      final deleted = src.txns.insert(Txn(type: TxnType.spend, amount: 5, categoryId: pets, sourceId: null, occurredAt: kNow, merchant: 'Gone'));
      src.txns.delete(deleted);
      File('${docs.path}/receipts/same.jpg')
        ..createSync(recursive: true)
        ..writeAsBytesSync([1]);
      final ledger = await openLedger(buildLedgerZip(src, docs: docs, temp: temp));

      final dst = makeState();
      final dIds = seed(dst); // same 9 transactions already here
      dst.planning.addBudget(const Budget(name: 'all', period: BudgetPeriod.monthly, limit: 1));
      File('${docs.path}/receipts/same.jpg').writeAsBytesSync([2]);
      final before = dst.catalog.categories().length;
      final r = restoreLedger(dst, ledger, RestoreMode.merge, docs: docs, temp: temp);
      expect([r.transactions, r.skipped, r.receipts], [2, 9, 0]);
      expect(dst.catalog.categories().length, before + 1);
      expect(dst.catalog.defaultCategory().name, 'Others');
      expect(dst.catalog.defaultSource()!.id, dIds.hdfc);
      final vets = dst.txns.list(const TxnFilter(search: 'vet'));
      expect(vets.map((t) => (t.category.name, t.source!.id)).toSet(), {('Pets', dIds.card)});
      expect(vets, hasLength(2));
      expect(dst.txns.list(const TxnFilter(search: 'gone')), isEmpty);
      final budgets = dst.planning.budgets();
      expect(budgets.map((b) => b.name), ['all', 'Pets']);
      expect(budgets.last.categoryIds, [catId(dst, 'Pets')]);
      expect(File('${docs.path}/receipts/same.jpg').readAsBytesSync(), [2]);
    });

    test('older backups are migrated before restoring; failures roll back', () async {
      final src = makeState();
      seed(src);
      final zip = buildLedgerZip(src, docs: docs, temp: temp);
      final l = await openLedger(zip);
      // Simulate a v3 snapshot: drop the v4 debt columns and reset the version.
      final f = File('${temp.path}/old.db')..writeAsBytesSync(l.database);
      final old = openAppDatabase(f.path)
        ..execute('ALTER TABLE debts DROP COLUMN statement_amount')
        ..execute('ALTER TABLE debts DROP COLUMN statement_due_at')
        ..userVersion = 3;
      old.close();
      final v1 = Ledger(manifest: l.manifest, database: f.readAsBytesSync(), receipts: const {});
      f.deleteSync();
      final dst = makeState();
      expect(restoreLedger(dst, v1, RestoreMode.replace, docs: docs, temp: temp).transactions, 9);
      expect(dst.db.select('SELECT statement_amount FROM debts').every((r) => r['statement_amount'] == null), isTrue);

      // A snapshot missing a table fails and leaves data untouched.
      final g = File('${temp.path}/broken.db')..writeAsBytesSync(l.database);
      final broken = openAppDatabase(g.path)..execute('DROP TABLE budgets');
      broken.close();
      final bad = Ledger(manifest: l.manifest, database: g.readAsBytesSync(), receipts: const {});
      g.deleteSync();
      expect(() => restoreLedger(dst, bad, RestoreMode.replace, docs: docs, temp: temp), throwsA(isA<Object>()));
      expect(dst.txns.list(const TxnFilter()).length, 9);
      expect(dst.db.select('PRAGMA database_list').length, 1);
    });
  });

  group('Reminder', () {
    test('overdue after the interval, snooze hides it, off disables it', () {
      var now = kNow;
      final s = makeState(now: kNow);
      final clocked = AppState(db: openAppDatabase(null), files: FakeFiles(), location: FakeLocation(), clock: () => now);
      expect(s.backupInterval, BackupInterval.monthly);
      expect(s.backupOverdue, isFalse); // no data yet
      expect(s.lastBackupLabel, 'Never backed up');
      clocked.txns.insert(
        Txn(type: TxnType.spend, amount: 100, categoryId: clocked.catalog.defaultCategory().id, sourceId: null, occurredAt: now),
        now: now,
      );
      expect(clocked.backupOverdue, isFalse);
      now = now.add(const Duration(days: 30));
      expect(clocked.backupOverdue, isTrue);
      clocked.snoozeBackupReminder();
      expect(clocked.backupOverdue, isFalse);
      now = now.add(const Duration(days: 3));
      expect(clocked.backupOverdue, isTrue);
      clocked.markBackedUp();
      expect(clocked.lastBackupAt, now);
      expect(clocked.lastBackupLabel, startsWith('Last backup '));
      clocked.backupInterval = BackupInterval.weekly;
      now = now.add(const Duration(days: 6));
      expect(clocked.backupOverdue, isFalse);
      now = now.add(const Duration(days: 1));
      expect(clocked.backupOverdue, isTrue);
      clocked.backupInterval = BackupInterval.off;
      expect(clocked.backupOverdue, isFalse);
      expect(BackupInterval.values.map(backupIntervalLabel), ['Off', 'Weekly', 'Monthly']);
    });
  });
}
