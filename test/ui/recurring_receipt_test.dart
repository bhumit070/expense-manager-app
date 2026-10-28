import 'dart:io';

import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/recurring_repo.dart';
import 'package:expense_manager/ui/screens/recurring_screen.dart';
import 'package:expense_manager/ui/screens/settings_screen.dart';
import 'package:expense_manager/ui/screens/txn_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Txn tea(DateTime at, {int amount = 2000}) => Txn(type: TxnType.spend, amount: amount, categoryId: 1, sourceId: 1, occurredAt: at, merchant: 'Chai');

Future<void> settleIo(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
  await tester.pump();
}

void main() {
  testWidgets('detail shows photo receipt: view, open, remove; and the repeat row', (tester) async {
    final dir = Directory.systemTemp.createTempSync('rd');
    addTearDown(() => dir.deleteSync(recursive: true));
    final img = File('${dir.path}/r.png')..writeAsBytesSync(kPng);
    final receipts = FakeReceipts();
    final s = makeState(receipts: receipts);
    final id = s.recurring.createFrom(tea(kNow).copyWith(receipt: () => img.path), Frequency.weekly, now: kNow);
    await pumpRoute(tester, s, TxnDetailScreen(id: id));
    expect(find.text('RECEIPT'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    await tester.tap(find.byKey(const Key('receipt-image')));
    await tester.pumpAndSettle();
    expect(find.byType(ReceiptViewer), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('receipt-open')));
    expect(receipts.opened, [img.path]);
    await tester.tap(find.byKey(const Key('receipt-remove')));
    await tester.pumpAndSettle();
    expect(receipts.deleted, [img.path]);
    expect(s.txns.byId(id)!.txn.receipt, isNull);
    expect(find.text('RECEIPT'), findsNothing);
  });

  testWidgets('pdf receipt, missing image file and a deleted rule', (tester) async {
    final s = makeState();
    final pdf = s.txns.insert(tea(kNow).copyWith(receipt: () => '/nope/bill.pdf'));
    await pumpRoute(tester, s, TxnDetailScreen(id: pdf));
    expect(find.text('PDF receipt'), findsOneWidget);
    final missing = s.txns.insert(tea(kNow).copyWith(receipt: () => '/nope/x.jpg', recurringId: () => 999));
    await pumpRoute(tester, s, TxnDetailScreen(id: missing));
    await settleIo(tester);
    expect(find.text('Receipt file not found'), findsOneWidget);
    expect(find.text('Repeats'), findsNothing);
    await tester.tap(find.byKey(const Key('receipt-image')));
    await tester.pumpAndSettle();
    await settleIo(tester);
    expect(find.descendant(of: find.byType(ReceiptViewer), matching: find.text('Receipt file not found')), findsOneWidget);
  });

  testWidgets('recurring screen: empty, list, pause/resume, edit, delete', (tester) async {
    final s = makeState();
    await pumpRoute(tester, s, const RecurringScreen());
    expect(find.text('Nothing recurring yet'), findsOneWidget);

    final txn = s.recurring.createFrom(tea(DateTime(2026, 10, 1, 8)), Frequency.monthly, now: kNow);
    final id = s.txns.byId(txn)!.txn.recurringId!;
    final ended = s.recurring.add(RecurringRule(template: tea(DateTime(2026, 1, 1), amount: 5), frequency: Frequency.daily, startAt: DateTime(2026, 1, 1), endAt: DateTime(2026, 1, 1), count: 1));
    s.recurring.add(RecurringRule(template: tea(DateTime(2026, 11, 5), amount: 7), frequency: Frequency.monthly, startAt: DateTime(2026, 11, 5), autoCreate: false));
    expect(ruleStatus(s.recurring.byId(ended)!), 'Daily · Ended');
    s.changed();
    await tester.pumpAndSettle();
    expect(find.text('Chai · ₹20'), findsOneWidget);
    expect(find.text('Monthly · Next Sun, 1 Nov 2026'), findsOneWidget);
    expect(find.text('Monthly · Next Thu, 5 Nov 2026 · reminder only'), findsOneWidget);
    expect(find.byKey(Key('pause-$ended')), findsNothing);

    await tester.tap(find.byKey(Key('pause-$id')));
    await tester.pumpAndSettle();
    expect(find.text('Monthly · Paused'), findsOneWidget);
    await tester.tap(find.byKey(Key('pause-$id')));
    await tester.pumpAndSettle();
    expect(s.recurring.byId(id)!.paused, isFalse);

    // edit: cancel, invalid amount, then amount + frequency
    await tester.tap(find.byKey(Key('rule-$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('rule-$id')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('rule-amount')), '0');
    await tester.tap(find.byKey(const Key('rule-save')));
    await tester.pump();
    expect(find.text('Enter an amount greater than zero'), findsWidgets);
    await tester.enterText(find.byKey(const Key('rule-amount')), '25');
    await tester.tap(find.text('Weekly'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rule-save')));
    await tester.pumpAndSettle();
    final edited = s.recurring.byId(id)!;
    expect([edited.template.amount, edited.frequency, edited.nextRun], [2500, Frequency.weekly, DateTime(2026, 11, 1, 8)]);
    // same frequency keeps the schedule
    await tester.tap(find.byKey(Key('rule-$id')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('rule-amount')), '30');
    await tester.tap(find.byKey(const Key('rule-save')));
    await tester.pumpAndSettle();
    expect([s.recurring.byId(id)!.template.amount, s.recurring.byId(id)!.nextRun], [3000, DateTime(2026, 11, 1, 8)]);

    await tester.tap(find.byKey(Key('delete-rule-$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(s.recurring.byId(id), isNotNull);
    await tester.tap(find.byKey(Key('delete-rule-$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-rule')));
    await tester.pumpAndSettle();
    expect(s.recurring.byId(id), isNull);
  });

  testWidgets('settings links to recurring with the active count', (tester) async {
    final s = makeState();
    s.recurring.createFrom(tea(kNow), Frequency.daily, now: kNow);
    await pumpRoute(tester, s, const SettingsScreen());
    expect(find.text('1 active'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('open-recurring')));
    await tester.tap(find.byKey(const Key('open-recurring')));
    await tester.pumpAndSettle();
    expect(find.byType(RecurringScreen), findsOneWidget);
  });

  test('startup runs due rules and purges deleted rows with their receipts', () async {
    final receipts = FakeReceipts();
    final s = makeState(receipts: receipts);
    s.recurring.createFrom(tea(DateTime(2026, 10, 26, 8)), Frequency.daily, now: kNow);
    final gone = s.txns.insert(tea(kNow).copyWith(receipt: () => '/r/old.jpg'));
    s.txns.delete(gone);
    await s.startup();
    expect(s.db.select('SELECT count(*) AS n FROM transactions').single['n'], 3);
    expect(receipts.deleted, ['/r/old.jpg']);
  });
}
