import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/services/backup.dart';
import 'package:expense_manager/services/file_gateway.dart';
import 'package:expense_manager/ui/screens/home_screen.dart';
import 'package:expense_manager/ui/screens/import_screen.dart';
import 'package:expense_manager/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../helpers.dart';
import '../services/pdf_fixtures.dart';

class Paths extends PathProviderPlatform with MockPlatformInterfaceMixin {
  Paths(this.docs, this.temp);

  final String docs, temp;

  @override
  Future<String?> getApplicationDocumentsPath() async => docs;

  @override
  Future<String?> getTemporaryPath() async => temp;
}

/// Runs real async work (file IO, PDF parsing) and lets the UI settle.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
  }
}

void main() {
  late Directory docs, temp;
  setUp(() {
    docs = Directory.systemTemp.createTempSync('d');
    temp = Directory.systemTemp.createTempSync('t');
    PathProviderPlatform.instance = Paths(docs.path, temp.path);
    backupKdfIterations = 1000;
    runInBackground = <R>(FutureOr<R> Function() f) async => f();
  });
  tearDown(() {
    docs.deleteSync(recursive: true);
    temp.deleteSync(recursive: true);
  });

  testWidgets('export sheet: dismiss, nothing picked, several kinds as a zip', (tester) async {
    final files = FakeFiles();
    final s = makeState(files: files);
    seed(s);
    await pumpRoute(tester, s, const SettingsScreen());
    await tester.tap(find.byKey(const Key('export-csv')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(files.saved, isEmpty);
    await tester.tap(find.byKey(const Key('export-csv')));
    await tester.pumpAndSettle();
    expect(find.text('Export 4 files (zip)'), findsOneWidget);
    for (final k in ['transactions', 'investments', 'debts', 'budgets']) {
      await tester.tap(find.byKey(Key('export-$k')));
      await tester.pump();
    }
    expect(tester.widget<FilledButton>(find.byKey(const Key('export-go'))).onPressed, isNull);
    await tester.tap(find.byKey(const Key('export-debts')));
    await tester.tap(find.byKey(const Key('export-budgets')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('export-go')));
    await tester.pumpAndSettle();
    expect(find.text('Exported 2 files to /tmp/expense-manager-export-2026-10-28.zip'), findsWidgets);
    expect(ZipDecoder().decodeBytes(files.saved.single.$2).files.map((f) => f.name), ['debts.csv', 'budgets.csv']);
  });

  group('import', () {
    testWidgets('PDF statement opens the preview with the bank name', (tester) async {
      final files = FakeFiles();
      final s = makeState(files: files);
      await pumpRoute(tester, s, const SettingsScreen());
      final pdf = (await tester.runAsync(
        () => statementPdf([
          ['State Bank of India', 'Txn Date|Value Date|Description|Debit|Balance', 'Balance as on 1 Oct 2026|50,000.00', '1 Oct 2026|1 Oct 2026|UPI ZOMATO|350.00|49,650.00'],
        ]),
      ))!;
      files.picked = PickedFile('Statement.PDF', pdf);
      await tester.tap(find.byKey(const Key('import-csv')));
      await settle(tester);
      expect(files.lastExtensions, ['csv', 'pdf']);
      expect(find.text('SBI · 1 found'), findsOneWidget);
      expect(find.text('Import 1 transaction'), findsOneWidget);
      expect(tester.widget<ImportScreen>(find.byType(ImportScreen)).rows, isNotNull);
    });

    testWidgets('PDF with no rows, locked PDFs and CSVs', (tester) async {
      final files = FakeFiles();
      final s = makeState(files: files);
      await pumpRoute(tester, s, const SettingsScreen());
      final empty = (await tester.runAsync(
        () => statementPdf([
          ['Just a letter'],
        ]),
      ))!;
      files.picked = PickedFile('x.pdf', empty);
      await tester.tap(find.byKey(const Key('import-csv')));
      await settle(tester);
      expect(find.textContaining('No transactions found in this PDF'), findsOneWidget);
      files.picked = PickedFile('x.pdf', Uint8List.fromList(utf8.encode('garbage')));
      await tester.tap(find.byKey(const Key('import-csv')));
      await settle(tester);
      expect(find.textContaining('Could not read this PDF'), findsOneWidget);
      expect(find.byType(ImportScreen), findsNothing);
      files.picked = PickedFile('x.csv', Uint8List.fromList(utf8.encode('date,amount,merchant\n2026-10-01,100,Tea\n')));
      await tester.tap(find.byKey(const Key('import-csv')));
      await settle(tester);
      expect(find.text('Import preview'), findsOneWidget);
    });
  });

  group('backup', () {
    testWidgets('cancel, plain backup, then a password-protected one', (tester) async {
      final files = FakeFiles();
      final s = makeState(files: files);
      seed(s);
      await tester.runAsync(
        () async => s.txns.insert(
          Txn(type: TxnType.spend, amount: 1, categoryId: s.catalog.defaultCategory().id, sourceId: null, occurredAt: kNow),
          now: kNow.subtract(const Duration(days: 31)),
        ),
      );
      await pumpRoute(tester, s, const SettingsScreen());
      expect(find.byKey(const Key('backup-banner')), findsOneWidget);
      expect(find.text('Your data lives only on this phone. Make a backup.'), findsOneWidget);
      expect(find.text('Never backed up'), findsOneWidget);
      await tester.tap(find.byKey(const Key('backup-now')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(files.saved, isEmpty);

      await tester.tap(find.byKey(const Key('backup-now')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('backup-go')));
      await settle(tester);
      expect(files.saved.single.$1, 'expense-manager-2026-10-28.ledger');
      expect(isEncryptedLedger(Uint8List.fromList(files.saved.single.$2)), isFalse);
      expect(find.text('Backup saved to /tmp/expense-manager-2026-10-28.ledger'), findsWidgets);
      expect(s.lastBackupAt, kNow);
      expect(find.byKey(const Key('backup-banner')), findsNothing);

      await tester.tap(find.byKey(const Key('backup-now')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('backup-protect')));
      await tester.pump();
      expect(find.text('There is no way to recover a forgotten password.'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('backup-password')), 'secret1');
      await tester.pump();
      expect(tester.widget<FilledButton>(find.byKey(const Key('backup-go'))).onPressed, isNull);
      await tester.enterText(find.byKey(const Key('backup-confirm')), 'secret1');
      await tester.pump();
      final gate = Completer<void>();
      runInBackground = <R>(FutureOr<R> Function() f) async {
        await gate.future;
        return f();
      };
      await tester.tap(find.byKey(const Key('backup-go')));
      await tester.pump();
      await tester.pump();
      expect(find.text('Encrypting backup…'), findsOneWidget);
      gate.complete();
      await settle(tester);
      expect(find.text('Encrypting backup…'), findsNothing);
      expect(isEncryptedLedger(Uint8List.fromList(files.saved.last.$2)), isTrue);
    });

    testWidgets('restore: cancel, invalid, password retry, replace and merge', (tester) async {
      final files = FakeFiles();
      final src = makeState();
      seed(src);
      final zip = buildLedgerZip(src, docs: docs, temp: temp);
      final enc = (await tester.runAsync(() => encryptLedger(zip, 'pw1234')))!;

      final s = makeState(files: files);
      await pumpRoute(tester, s, const SettingsScreen());
      await tester.tap(find.byKey(const Key('restore-backup')));
      await settle(tester);
      expect(files.lastExtensions, isNull);

      files.picked = PickedFile('x.ledger', Uint8List.fromList(utf8.encode('nope')));
      await tester.tap(find.byKey(const Key('restore-backup')));
      await settle(tester);
      expect(find.text('Not an Expense Manager backup'), findsOneWidget);

      // Encrypted: cancel the password prompt.
      files.picked = PickedFile('x.ledger', enc);
      await tester.tap(find.byKey(const Key('restore-backup')));
      await settle(tester);
      expect(find.text('Backup password'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await settle(tester);

      // Wrong, then right password; cancel at the mode dialog.
      await tester.tap(find.byKey(const Key('restore-backup')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('unlock-password')), 'wrong');
      await tester.tap(find.byKey(const Key('unlock-go')));
      await settle(tester);
      expect(find.text('Wrong password'), findsWidgets);
      await tester.enterText(find.byKey(const Key('unlock-password')), 'pw1234');
      await tester.tap(find.byKey(const Key('unlock-go')));
      await settle(tester);
      expect(find.text('Restore backup'), findsOneWidget);
      expect(find.textContaining('9 transactions · 2 investments · 2 debts · 0 budgets'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect(s.txns.list(const TxnFilter()), isEmpty);

      // Replace needs the confirmation checkbox.
      files.picked = PickedFile('x.ledger', zip);
      await tester.tap(find.byKey(const Key('restore-backup')));
      await settle(tester);
      await tester.tap(find.text('Replace').first);
      await tester.pump();
      expect(tester.widget<FilledButton>(find.byKey(const Key('restore-go'))).onPressed, isNull);
      await tester.tap(find.byKey(const Key('restore-confirm')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('restore-go')));
      await settle(tester);
      expect(find.text('Restored 9 transactions'), findsWidgets);
      expect(s.txns.list(const TxnFilter()), hasLength(9));

      // Merge the same backup again: everything is already here.
      await tester.tap(find.byKey(const Key('restore-backup')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('restore-go')));
      await settle(tester);
      expect(find.text('Added 0 transactions · 9 already here'), findsWidgets);

      src.txns.insert(Txn(type: TxnType.spend, amount: 99, categoryId: src.catalog.defaultCategory().id, sourceId: null, occurredAt: kNow, merchant: 'New'));
      files.picked = PickedFile('x.ledger', buildLedgerZip(src, docs: docs, temp: temp));
      await tester.tap(find.byKey(const Key('restore-backup')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('restore-go')));
      await settle(tester);
      expect(find.text('Added 1 transaction · 9 already here'), findsWidgets);
    });

    testWidgets('reminder interval and banner on Home: snooze and back up', (tester) async {
      final files = FakeFiles();
      final s = makeState(files: files);
      seed(s);
      s.settings.set('backup.last', '${kNow.subtract(const Duration(days: 40)).millisecondsSinceEpoch}');
      await pumpScreen(tester, s, inScaffold(HomeScreen(onOpenInsights: () {}, onOpenInvestments: () {}, onOpenDebts: () {})));
      expect(find.textContaining('Time for a backup · last backup'), findsOneWidget);
      await tester.tap(find.byKey(const Key('backup-banner-dismiss')));
      await tester.pump();
      expect(find.byKey(const Key('backup-banner')), findsNothing);
      s.settings.set('backup.snooze', '0');
      s.changed();
      await tester.pump();
      await tester.tap(find.byKey(const Key('backup-banner-go')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('backup-go')));
      await settle(tester);
      expect(files.saved, hasLength(1));
      expect(find.byKey(const Key('backup-banner')), findsNothing);

      await pumpRoute(tester, s, const SettingsScreen());
      await tester.tap(find.byKey(const Key('backup-interval')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weekly').last);
      await tester.pumpAndSettle();
      expect(s.backupInterval, BackupInterval.weekly);
    });
  });
}
