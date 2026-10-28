import 'dart:async';

import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/recurring_repo.dart';
import 'package:expense_manager/data/templates_repo.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/services/location.dart';
import 'package:expense_manager/services/receipts.dart';
import 'package:expense_manager/ui/screens/location_picker_screen.dart';
import 'package:expense_manager/ui/screens/txn_form_screen.dart';
import 'package:expense_manager/ui/widgets/map_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('save-txn')));
  await tester.tap(find.byKey(const Key('save-txn')));
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Future<void> showChip(WidgetTester tester, Finder chip, {double dx = -120}) async {
  final strip = find.descendant(of: find.byKey(const Key('quick-add')), matching: find.byType(Scrollable));
  await tester.dragUntilVisible(chip, strip, Offset(dx, 0));
  await tester.pump();
}

void main() {
  setUp(() => mapTileProvider = FakeTiles.new);

  testWidgets('keypad maths shows the running total and saves it', (tester) async {
    final s = makeState()..locationEnabled = false;
    await pumpRoute(tester, s, const TxnFormScreen());
    expect(find.text('Quick add'), findsNothing);
    await typeAmount(tester, '100+25.5');
    expect(amountShown(tester), '100+25.5');
    expect(find.text('= ₹125.50'), findsOneWidget);
    await typeAmount(tester, '−200');
    expect(find.text('= −₹74.50'), findsOneWidget);
    await save(tester);
    expect(find.text('Enter an amount greater than zero'), findsWidgets);
    await tester.longPress(find.byKey(const Key('key-back')));
    await typeAmount(tester, '40+2');
    await save(tester);
    expect(s.txns.list(const TxnFilter()).single.txn.amount, 4200);
  });

  testWidgets('templates and frequent merchants fill the form; long-press deletes', (tester) async {
    final s = makeState()..locationEnabled = false;
    final ids = seed(s);
    for (final d in [3, 4]) {
      s.txns.insert(Txn(type: TxnType.spend, amount: 9000, categoryId: catId(s, 'Transport'), sourceId: ids.card, occurredAt: DateTime(2026, 10, d), merchant: 'Rapido'));
    }
    final tpl = s.templates.add(
      TxnTemplate(name: 'Gym', type: TxnType.spend, amount: 250000, categoryId: catId(s, 'Health'), sourceId: ids.card, merchant: 'Cult', note: 'monthly fee', tags: const ['#fit']),
    );
    final gone = s.catalog.addSource(name: 'Old wallet', kind: SourceKind.wallet);
    s.templates.add(TxnTemplate(name: 'Archived source', type: TxnType.invest, amount: 100, categoryId: catId(s, 'Stocks'), sourceId: gone));
    s.catalog.archiveSource(gone);
    await pumpRoute(tester, s, const TxnFormScreen());
    expect(find.text('Quick add'), findsOneWidget);

    await showChip(tester, find.byKey(Key('tpl-$tpl')));
    await tester.tap(find.byKey(Key('tpl-$tpl')));
    await tester.pump();
    expect(amountShown(tester), '2,500');
    expect(tester.widget<TextField>(find.byKey(const Key('merchant'))).controller!.text, 'Cult');
    expect(tester.widget<TextField>(find.byKey(const Key('note'))).controller!.text, 'monthly fee');
    expect(tester.widget<TextField>(find.byKey(const Key('tags'))).controller!.text, '#fit');
    await save(tester);
    final gym = s.txns.list(const TxnFilter(search: 'cult')).single;
    expect([gym.category.name, gym.txn.sourceId, gym.txn.amount], ['Health', ids.card, 250000]);

    await pumpRoute(tester, s, const TxnFormScreen());
    await showChip(tester, find.byKey(const Key('freq-rapido')));
    await tester.tap(find.byKey(const Key('freq-rapido')));
    await tester.pump();
    expect(amountShown(tester), '90');
    await showChip(tester, find.text('Archived source · ₹1'), dx: 120);
    await tester.tap(find.text('Archived source · ₹1'));
    await tester.pump();
    expect(find.text('Invest'), findsOneWidget);
    await save(tester);
    expect(s.txns.list(const TxnFilter(types: {TxnType.invest})).first.txn.sourceId, ids.card, reason: 'an archived template source keeps the current pick');

    await pumpRoute(tester, s, const TxnFormScreen());
    await showChip(tester, find.byKey(Key('tpl-$tpl')));
    await tester.longPress(find.byKey(Key('tpl-$tpl')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(s.templates.list().length, 2);
    await showChip(tester, find.byKey(Key('tpl-$tpl')));
    await tester.longPress(find.byKey(Key('tpl-$tpl')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-template')));
    await tester.pumpAndSettle();
    expect(s.templates.list().map((t) => t.name), ['Archived source']);
    expect(find.byKey(Key('tpl-$tpl')), findsNothing);
  });

  testWidgets('save as template validates, suggests a name and can be cancelled', (tester) async {
    final s = makeState()..locationEnabled = false;
    await pumpRoute(tester, s, const TxnFormScreen());
    await tester.tap(find.byKey(const Key('save-template')));
    await tester.pump();
    expect(find.text('Enter an amount greater than zero'), findsWidgets);
    await typeAmount(tester, '60');
    await tester.tap(find.byKey(const Key('save-template')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const Key('template-name'))).controller!.text, 'Others');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('merchant')), 'Chai Point');
    await tester.tap(find.byKey(const Key('save-template')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const Key('template-name'))).controller!.text, 'Chai Point');
    await tester.enterText(find.byKey(const Key('template-name')), ' ');
    await tester.tap(find.byKey(const Key('template-save')));
    await tester.pumpAndSettle();
    expect(s.templates.list(), isEmpty);
    await tester.tap(find.byKey(const Key('save-template')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('template-name')), 'Tea ');
    await tester.tap(find.byKey(const Key('template-save')));
    await tester.pumpAndSettle();
    expect(find.text('Saved “Tea” as a template'), findsOneWidget);
    final t = s.templates.list().single;
    expect([t.name, t.amount, t.merchant, t.categoryId], ['Tea', 6000, 'Chai Point', s.catalog.defaultCategory().id]);
  });

  testWidgets('repeat creates a linked recurring rule with an optional end', (tester) async {
    final s = makeState()..locationEnabled = false;
    await pumpRoute(tester, s, const TxnFormScreen());
    await typeAmount(tester, '1500');
    expect(find.text('Adds it automatically on schedule'), findsOneWidget);
    await tapKey(tester, 'repeat');
    expect(find.text('Monthly · next Sat, 28 Nov 2026'), findsOneWidget);
    await tester.tap(find.text('Weekly'));
    await tester.pump();
    expect(find.text('Weekly · next Wed, 4 Nov 2026'), findsOneWidget);
    expect(find.text('Never ends'), findsOneWidget);
    await tapKey(tester, 'repeat-end');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'repeat-end');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Ends Wed, 20 Jan 2027'), findsOneWidget);
    await tapKey(tester, 'repeat-end-clear');
    expect(find.text('Never ends'), findsOneWidget);
    await tapKey(tester, 'repeat-end');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await save(tester);
    final v = s.txns.list(const TxnFilter()).single;
    final rule = s.recurring.byId(v.txn.recurringId!)!;
    expect([rule.frequency, rule.count, rule.endAt, rule.template.amount], [Frequency.weekly, 1, DateTime(2027, 1, 20, 23, 59), 150000]);

    await pumpRoute(tester, s, TxnFormScreen(existing: v));
    expect(find.textContaining('Part of a recurring series'), findsOneWidget);
    expect(find.byKey(const Key('repeat')), findsNothing);
    await pumpRoute(tester, s, TxnFormScreen(existing: v, duplicate: true));
    expect(find.byKey(const Key('repeat')), findsOneWidget);
  });

  testWidgets('receipts: pick, replace, clear; unsaved picks are deleted', (tester) async {
    final receipts = FakeReceipts();
    final s = makeState(receipts: receipts)..locationEnabled = false;
    await pumpRoute(tester, s, const TxnFormScreen());
    await typeAmount(tester, '99');
    await tapKey(tester, 'receipt-camera');
    expect(find.text('Photo receipt attached'), findsNothing);
    receipts.next = '/r/1.jpg';
    await tapKey(tester, 'receipt-gallery');
    expect(find.text('Photo receipt attached'), findsOneWidget);
    await tapKey(tester, 'receipt-clear');
    receipts.next = '/r/2.pdf';
    await tapKey(tester, 'receipt-pdf');
    expect(find.text('PDF receipt attached'), findsOneWidget);
    expect(receipts.picked, [ReceiptSource.camera, ReceiptSource.gallery, ReceiptSource.pdf]);
    await save(tester);
    final v = s.txns.list(const TxnFilter()).single;
    expect(v.txn.receipt, '/r/2.pdf');
    expect(receipts.deleted, ['/r/1.jpg']);

    // editing: replacing the saved receipt deletes the old file on save
    await pumpRoute(tester, s, TxnFormScreen(existing: v));
    expect(find.text('PDF receipt attached'), findsOneWidget);
    await tapKey(tester, 'receipt-clear');
    receipts.next = '/r/3.jpg';
    await tapKey(tester, 'receipt-camera');
    await save(tester);
    expect(s.txns.byId(v.txn.id!)!.txn.receipt, '/r/3.jpg');
    expect(receipts.deleted, ['/r/1.jpg', '/r/2.pdf']);

    // leaving without saving drops the picked file but keeps the saved one
    await pumpRoute(tester, s, TxnFormScreen(existing: s.txns.byId(v.txn.id!)));
    receipts.next = '/r/4.jpg';
    await tapKey(tester, 'receipt-clear');
    await tapKey(tester, 'receipt-gallery');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(receipts.deleted, ['/r/1.jpg', '/r/2.pdf', '/r/4.jpg']);
    expect(s.txns.byId(v.txn.id!)!.txn.receipt, '/r/3.jpg');
  });

  testWidgets('a receipt picked after leaving is ignored', (tester) async {
    final receipts = _SlowReceipts();
    final s = makeState(receipts: receipts)..locationEnabled = false;
    await pumpRoute(tester, s, const TxnFormScreen());
    await tapKey(tester, 'receipt-camera');
    await tester.pageBack();
    await tester.pumpAndSettle();
    receipts.done.complete('/r/late.jpg');
    await tester.pump();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('map picker fills place and coordinates', (tester) async {
    final loc = FakeLocation()..results['cubbon'] = const [Place(name: 'Cubbon Park', lat: 12.97, lng: 77.59)];
    final s = makeState(location: loc)..locationEnabled = false;
    await pumpRoute(tester, s, const TxnFormScreen());
    await tapKey(tester, 'pick-location');
    expect(find.byType(LocationPickerScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const Key('place'))).controller!.text, '');
    await tapKey(tester, 'pick-location');
    await tester.enterText(find.byKey(const Key('place-search')), 'cubbon');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('result-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-place')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const Key('place'))).controller!.text, 'Cubbon Park');
    // reopening starts from the picked place
    await tapKey(tester, 'pick-location');
    expect(tester.widget<TextField>(find.byKey(const Key('place-name'))).controller!.text, 'Cubbon Park');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await typeAmount(tester, '10');
    await save(tester);
    final t = s.txns.list(const TxnFilter()).single.txn;
    expect([t.place, t.lat, t.lng], ['Cubbon Park', 12.97, 77.59]);
  });
}

class _SlowReceipts extends FakeReceipts {
  final done = Completer<String?>();

  @override
  Future<String?> pick(ReceiptSource source) => done.future;
}
