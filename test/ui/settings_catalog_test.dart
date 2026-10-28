import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:expense_manager/app.dart';
import 'package:expense_manager/core/flavor.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/main.dart' as app_main;
import 'package:expense_manager/ui/screens/categories_screen.dart';
import 'package:expense_manager/ui/screens/import_screen.dart';
import 'package:expense_manager/ui/screens/settings_screen.dart';
import 'package:expense_manager/ui/screens/shell.dart';
import 'package:expense_manager/ui/screens/sources_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../helpers.dart';

class FakePaths extends PathProviderPlatform with MockPlatformInterfaceMixin {
  FakePaths(this.dir);

  final String dir;

  @override
  Future<String?> getApplicationDocumentsPath() async => dir;
}

void main() {
  group('Categories', () {
    testWidgets('add with kind, icon and color; cancel and blank are ignored', (tester) async {
      final s = makeState();
      await pumpRoute(tester, s, const CategoriesScreen());
      expect(find.text('Default — used when nothing is picked'), findsOneWidget);
      await tester.tap(find.byKey(const Key('add-category')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add-category')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cat-save')));
      await tester.pumpAndSettle();
      final before = s.catalog.categories().length;
      await tester.tap(find.byKey(const Key('add-category')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('cat-name')), 'Crypto');
      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Invest')));
      await tester.tap(find.byKey(const Key('icon-coins')));
      await tester.tap(find.byKey(const Key('color-${0xFF10B981}')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('cat-save')));
      await tester.pumpAndSettle();
      expect(s.catalog.categories().length, before + 1);
      final c = s.catalog.findCategoryByName('Crypto')!;
      expect([c.kind, c.icon, c.color], [CategoryKind.invest, 'coins', 0xFF10B981]);
      expect(find.text('Crypto'), findsOneWidget);
    });

    testWidgets('archive and drag to reorder', (tester) async {
      final s = makeState();
      await pumpRoute(tester, s, const CategoriesScreen());
      final rent = catId(s, 'Rent');
      await tester.tap(find.byKey(Key('archive-$rent')));
      await tester.pump();
      expect(find.text('Rent'), findsNothing);
      final first = s.catalog.categories(kind: CategoryKind.invest).first.id;
      final handle = find.descendant(of: find.byKey(ValueKey(first)), matching: find.byIcon(Icons.drag_handle));
      await tester.drag(handle, const Offset(0, 140));
      await tester.pumpAndSettle();
      expect(s.catalog.categories(kind: CategoryKind.invest).first.id, isNot(first));
    });
  });

  group('Payment sources', () {
    testWidgets('add a card as default, switch default via radio, archive', (tester) async {
      final s = makeState();
      await pumpRoute(tester, s, const SourcesScreen());
      expect(find.byKey(Key('archive-source-${s.catalog.defaultSource()!.id}')), findsNothing);
      await tester.tap(find.byKey(const Key('add-source')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add-source')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Credit card'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('source-name')), 'ICICI');
      await tester.enterText(find.byKey(const Key('source-last4')), '0707');
      await tester.enterText(find.byKey(const Key('source-limit')), '150000');
      await tester.tap(find.byKey(const Key('source-default')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('source-save')));
      await tester.pumpAndSettle();
      final card = s.catalog.defaultSource()!;
      expect([card.name, card.last4, card.creditLimit, card.kind], ['ICICI', '0707', 15000000, SourceKind.card]);
      expect(find.textContaining('limit ₹1,50,000'), findsOneWidget);

      final cash = s.catalog.sources().firstWhere((x) => x.kind == SourceKind.cash);
      await tester.tap(find.byKey(Key('default-${cash.id}')));
      await tester.pump();
      expect(s.catalog.defaultSource()!.id, cash.id);
      await tester.tap(find.byKey(Key('archive-source-${card.id}')));
      await tester.pump();
      expect(s.catalog.sources().length, 1);

      // bank with no last4 and blank name is ignored
      await tester.tap(find.byKey(const Key('add-source')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('source-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add-source')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('source-name')), 'SBI');
      await tester.tap(find.byKey(const Key('source-save')));
      await tester.pumpAndSettle();
      expect(s.catalog.sources().firstWhere((x) => x.name == 'SBI').last4, isNull);
    });

    testWidgets('opening balance on add, and tap to correct the balance', (tester) async {
      final s = makeState();
      await pumpRoute(tester, s, const SourcesScreen());
      final cash = s.catalog.defaultSource()!;
      expect(find.text('Balance ₹0'), findsOneWidget);

      await tester.tap(find.byKey(const Key('add-source')));
      await tester.pumpAndSettle();
      expect(find.text('Current balance (₹)'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('source-name')), 'SBI');
      await tester.enterText(find.byKey(const Key('source-balance')), '12,500.50');
      await tester.tap(find.byKey(const Key('source-save')));
      await tester.pumpAndSettle();
      final sbi = s.catalog.sources().firstWhere((x) => x.name == 'SBI');
      expect(sbi.openingBalance, 1250050);
      expect(find.text('Balance ₹12,500.50'), findsOneWidget);

      await tester.tap(find.byKey(const Key('add-source')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Credit card'));
      await tester.pump();
      expect(find.text('Outstanding now (₹)'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('source-name')), 'Amex');
      await tester.enterText(find.byKey(const Key('source-balance')), '8000');
      await tester.tap(find.byKey(const Key('source-save')));
      await tester.pumpAndSettle();
      final amex = s.catalog.sources().firstWhere((x) => x.name == 'Amex');
      expect(amex.openingBalance, -800000);
      expect(find.text('₹8,000 outstanding'), findsOneWidget);

      // Correct the cash balance to what's in the wallet today; cancel first.
      await tester.tap(find.byKey(Key('source-${cash.id}')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byKey(const Key('balance-amount'))).controller!.text, '');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      s.txns.insert(Txn(type: TxnType.spend, amount: 20000, categoryId: s.catalog.defaultCategory().id, sourceId: cash.id, occurredAt: kNow));
      s.changed();
      await tester.pump();
      expect(find.text('Balance −₹200'), findsOneWidget);
      await tester.tap(find.byKey(Key('source-${cash.id}')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byKey(const Key('balance-amount'))).controller!.text, '-200');
      await tester.enterText(find.byKey(const Key('balance-amount')), '3000');
      await tester.tap(find.byKey(const Key('balance-save')));
      await tester.pumpAndSettle();
      expect(s.catalog.balances()[cash.id], 300000);
      expect(find.text('Balance ₹3,000'), findsOneWidget);

      // Card: prefilled with outstanding (decimals kept); clearing it means ₹0, overpaying shows credit.
      await tester.tap(find.byKey(Key('source-${amex.id}')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byKey(const Key('balance-amount'))).controller!.text, '8000');
      await tester.enterText(find.byKey(const Key('balance-amount')), '-50.25');
      await tester.tap(find.byKey(const Key('balance-save')));
      await tester.pumpAndSettle();
      expect(find.text('₹50.25 credit'), findsOneWidget);
      await tester.tap(find.byKey(Key('source-${amex.id}')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byKey(const Key('balance-amount'))).controller!.text, '-50.25');
      await tester.enterText(find.byKey(const Key('balance-amount')), '');
      await tester.tap(find.byKey(const Key('balance-save')));
      await tester.pumpAndSettle();
      expect(find.text('₹0 outstanding'), findsOneWidget);
    });

    testWidgets('archived sources are listed with balance and can be restored', (tester) async {
      final s = makeState();
      final sbi = s.catalog.addSource(name: 'SBI', kind: SourceKind.bank, openingBalance: 500000);
      await pumpRoute(tester, s, const SourcesScreen());
      expect(find.byKey(const Key('archived-sources')), findsNothing);
      await tester.tap(find.byKey(Key('archive-source-$sbi')));
      await tester.pump();
      expect(find.text('Archived (1)'), findsOneWidget);
      await tester.tap(find.byKey(const Key('archived-sources')));
      await tester.pumpAndSettle();
      expect(find.text('Bank account · Balance ₹5,000'), findsOneWidget);
      await tester.tap(find.byKey(Key('restore-source-$sbi')));
      await tester.pumpAndSettle();
      expect(find.text('SBI restored'), findsOneWidget);
      expect(find.byKey(const Key('archived-sources')), findsNothing);
      expect(s.catalog.sources().any((x) => x.id == sbi), isTrue);
    });

    testWidgets('no default source shows None', (tester) async {
      final s = makeState();
      s.catalog.archiveSource(s.catalog.defaultSource()!.id);
      await pumpRoute(tester, s, const SourcesScreen());
      expect(find.text('None'), findsOneWidget);
    });
  });

  group('Settings', () {
    testWidgets('name, theme, defaults and navigation', (tester) async {
      final s = makeState();
      await pumpRoute(tester, s, const SettingsScreen());
      expect(find.text('Not set'), findsOneWidget);
      await tester.tap(find.byKey(const Key('edit-name')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('name-field')), 'Bhumit');
      await tester.tap(find.byKey(const Key('name-save')));
      await tester.pumpAndSettle();
      expect(s.userName, 'Bhumit');
      await tester.tap(find.byKey(const Key('edit-name')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(s.userName, 'Bhumit');

      await tester.tap(find.text('Dark'));
      await tester.pump();
      expect(s.themeMode, ThemeMode.dark);
      expect(find.text('Default: Others'), findsOneWidget);
      await tester.tap(find.byKey(const Key('open-sources')));
      await tester.pumpAndSettle();
      expect(find.byType(SourcesScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-categories')));
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesScreen), findsOneWidget);
    });

    testWidgets('no default source shows None in defaults', (tester) async {
      final s = makeState();
      s.catalog.archiveSource(s.catalog.defaultSource()!.id);
      await pumpRoute(tester, s, const SettingsScreen());
      expect(find.text('None'), findsOneWidget);
    });

    testWidgets('export CSV and PDF', (tester) async {
      final files = FakeFiles();
      final s = makeState(files: files);
      seed(s);
      await pumpRoute(tester, s, const SettingsScreen());
      await tester.tap(find.byKey(const Key('export-csv')));
      await tester.pump();
      expect(find.text('Exported 9 transactions to /tmp/transactions-2026-10-28.csv'), findsWidgets);
      expect(files.saved.single.$2.take(3), [0xEF, 0xBB, 0xBF]);
      expect(utf8.decode(files.saved.single.$2), contains('date,type'));
      await tester.tap(find.byKey(const Key('export-pdf-month')));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pump();
      expect(files.saved.last.$1, 'report-2026-10.pdf');
    });

    testWidgets('import: cancelled pick does nothing, picked CSV opens preview', (tester) async {
      final files = FakeFiles();
      final s = makeState(files: files);
      await pumpRoute(tester, s, const SettingsScreen());
      await tester.tap(find.byKey(const Key('import-csv')));
      await tester.pumpAndSettle();
      expect(find.byType(ImportScreen), findsNothing);
      files.csv = 'date,amount,merchant\n2026-10-01,100,Tea\n';
      await tester.tap(find.byKey(const Key('import-csv')));
      await tester.pumpAndSettle();
      expect(find.byType(ImportScreen), findsOneWidget);
    });

    testWidgets('location toggle asks for permission when turning on', (tester) async {
      final loc = FakeLocation()..grant = false;
      final s = makeState(location: loc)..locationEnabled = false;
      await pumpRoute(tester, s, const SettingsScreen());
      await tester.tap(find.byKey(const Key('location-switch')));
      await tester.pump();
      await tester.pump();
      expect(s.locationEnabled, isFalse);
      expect(find.text('Location permission denied — you can still type a place.'), findsWidgets);
      loc.grant = true;
      await tester.tap(find.byKey(const Key('location-switch')));
      await tester.pump();
      await tester.pump();
      expect(s.locationEnabled, isTrue);
      await tester.tap(find.byKey(const Key('location-switch')));
      await tester.pump();
      expect(s.locationEnabled, isFalse);
      expect(loc.requests, 2);
    });
  });

  testWidgets('import preview counts, toggles and imports', (tester) async {
    final s = makeState();
    seed(s);
    const csv =
        'date,type,amount,category,merchant\n'
        '2026-10-28 20:00,spend,486,Food & dining,Swiggy\n'
        '2026-10-20,spend,100,Mystery,Shop\n'
        '2026-10-21,income,500,,\n'
        'bad,spend,1,,\n';
    await pumpRoute(tester, s, const ImportScreen(csvText: csv));
    expect(find.text('Line 5'), findsOneWidget);
    expect(find.text('Import 2 transactions'), findsOneWidget);
    expect(find.textContaining('Duplicate'), findsOneWidget);
    expect(find.textContaining('Category → Others'), findsOneWidget);
    expect(find.text('Income'), findsNothing);
    await tester.tap(find.byKey(const Key('import-1')));
    await tester.pump();
    expect(find.text('Import 1 transactions'), findsOneWidget);
    await tester.tap(find.byKey(const Key('import-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('import-0')));
    await tester.tap(find.byKey(const Key('import-2')));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byKey(const Key('do-import'))).onPressed, isNull);
    await tester.tap(find.byKey(const Key('import-2')));
    await tester.pump();
    final before = s.txns.list(const TxnFilter()).length;
    await tester.tap(find.byKey(const Key('do-import')));
    await tester.pumpAndSettle();
    expect(s.txns.list(const TxnFilter()).length, before + 1);
    expect(find.text('Imported 1 transactions'), findsWidgets);
  });

  testWidgets('ExpenseApp follows the saved theme mode', (tester) async {
    final s = makeState()..themeMode = ThemeMode.dark;
    await tester.pumpWidget(ExpenseApp(state: s));
    await tester.pump();
    expect(find.byType(HomeShell), findsOneWidget);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
    s.themeMode = ThemeMode.light;
    await tester.pump();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.light);
  });

  testWidgets('dev flavor shows a DEV banner; prod does not', (tester) async {
    final s = makeState();
    await tester.pumpWidget(ExpenseApp(state: s, flavor: Flavor.dev));
    await tester.pump();
    expect(find.byType(Banner), findsOneWidget);
    await tester.pumpWidget(ExpenseApp(state: s));
    await tester.pump();
    expect(find.byType(Banner), findsNothing);
  });

  testWidgets('main() boots the app on an on-device database', (tester) async {
    final dir = Directory.systemTemp.createTempSync('main');
    PathProviderPlatform.instance = FakePaths(dir.path);
    final flutterHandler = FlutterError.onError;
    final platformHandler = PlatformDispatcher.instance.onError;
    await tester.runAsync(app_main.main);
    // main() routes errors to the local log; put the test handlers back.
    expect(FlutterError.onError, isNot(same(flutterHandler)));
    FlutterError.onError = flutterHandler;
    PlatformDispatcher.instance.onError = platformHandler;
    await tester.pump();
    expect(find.byType(HomeShell), findsOneWidget);
    expect(File('${dir.path}/expense_manager.db').existsSync(), isTrue);
    final dev = await tester.runAsync(() => app_main.bootstrap(flavor: Flavor.dev));
    expect(File('${dir.path}/expense_manager_dev.db').existsSync(), isTrue);
    expect(dev!.errorLog!.file.path, '${dir.path}/logs/errors.log');
    dev.db.close();
    await tester.pumpWidget(const SizedBox());
    dir.deleteSync(recursive: true);
  });
}
