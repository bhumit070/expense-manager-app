import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/ui/screens/investments_screen.dart';
import 'package:expense_manager/ui/screens/sip_card.dart';
import 'package:expense_manager/ui/screens/txn_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Future<void> pickDropdown(WidgetTester tester, String key, String item) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item).last);
  await tester.pumpAndSettle();
}

void main() {
  test('nextSipDate is today or later', () {
    expect(nextSipDate(kNow, 28), DateTime(2026, 10, 28, 9));
    expect(nextSipDate(kNow, 5), DateTime(2026, 11, 5, 9));
    expect(nextSipDate(DateTime(2026, 12, 20), 1), DateTime(2027, 1, 1, 9));
  });

  testWidgets('auto-create SIP: set up, shows next date, adds monthly invest transactions', (tester) async {
    final s = makeState()..locationEnabled = false;
    final ids = seed(s);
    await pumpRoute(tester, s, InvestmentDetailScreen(id: ids.sip));
    await tapKey(tester, 'setup-sip');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(s.recurring.forInvestment(ids.sip), isNull);

    await tapKey(tester, 'setup-sip');
    await tester.tap(find.byKey(const Key('sip-save')));
    await tester.pump();
    expect(find.text('Enter an amount greater than zero'), findsWidgets);
    await tester.enterText(find.byKey(const Key('sip-amount')), '5000');
    await pickDropdown(tester, 'sip-day', '28');
    await pickDropdown(tester, 'sip-source', 'ICICI Card ••07');
    await tester.tap(find.byKey(const Key('sip-save')));
    await tester.pumpAndSettle();

    final sip = s.recurring.forInvestment(ids.sip)!;
    expect([sip.template.amount, sip.template.sourceId, sip.autoCreate, sip.template.categoryId, sip.template.merchant], [500000, ids.card, true, catId(s, 'Mutual funds / SIP'), 'Nifty 50 Index']);
    // day 28 is today (9 AM already passed), so the first SIP is added right away
    final added = s.txns.list(TxnFilter(investmentId: ids.sip, types: const {TxnType.invest}));
    expect(added.first.txn.occurredAt, DateTime(2026, 10, 28, 9));
    expect(find.text('SIP · ₹5,000 on day 28'), findsOneWidget);
    expect(find.text('Next Sat, 28 Nov 2026 · ICICI Card ••07'), findsOneWidget);
    expect(find.text('Added automatically'), findsOneWidget);
    expect(find.byKey(const Key('record-sip')), findsNothing);
    expect(find.byKey(const Key('setup-sip')), findsNothing);
    expect(s.recurring.upcoming(kNow, days: 31).single.at, DateTime(2026, 11, 28, 9));
  });

  testWidgets('reminder-only SIP: no transaction, record payment, edit and stop', (tester) async {
    final s = makeState()..locationEnabled = false;
    final fd = s.planning.addInvestment(const Investment(kind: InvestmentKind.stock, name: 'Basket'));
    await pumpRoute(tester, s, InvestmentDetailScreen(id: fd));
    await tapKey(tester, 'setup-sip');
    await tester.enterText(find.byKey(const Key('sip-amount')), '2000');
    await tester.tap(find.byKey(const Key('sip-remind')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sip-save')));
    await tester.pumpAndSettle();
    var sip = s.recurring.forInvestment(fd)!;
    expect([sip.autoCreate, sip.startAt, sip.template.categoryId, sip.template.sourceId], [false, DateTime(2026, 11, 5, 9), s.catalog.firstOf(CategoryKind.invest).id, s.catalog.defaultSource()!.id]);
    expect(s.txns.list(const TxnFilter()), isEmpty);
    expect(find.text('Reminder only · record it when you pay'), findsOneWidget);
    expect(find.text('Next Thu, 5 Nov 2026 · Cash'), findsOneWidget);

    await tapKey(tester, 'record-sip');
    expect(find.byType(TxnFormScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // edit amount only keeps the schedule
    await tapKey(tester, 'edit-sip');
    expect(tester.widget<TextField>(find.byKey(const Key('sip-amount'))).controller!.text, '2000');
    await tester.enterText(find.byKey(const Key('sip-amount')), '2500');
    await pickDropdown(tester, 'sip-source', 'Not set');
    await tester.tap(find.byKey(const Key('sip-save')));
    await tester.pumpAndSettle();
    sip = s.recurring.forInvestment(fd)!;
    expect([sip.template.amount, sip.template.sourceId, sip.startAt, sip.template.note], [250000, null, DateTime(2026, 11, 5, 9), 'SIP']);
    expect(find.text('Next Thu, 5 Nov 2026'), findsOneWidget);

    // changing the day restarts from the next such date; switching to auto
    await tapKey(tester, 'edit-sip');
    await pickDropdown(tester, 'sip-day', '10');
    await tester.tap(find.byKey(const Key('sip-auto')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sip-save')));
    await tester.pumpAndSettle();
    sip = s.recurring.forInvestment(fd)!;
    expect([sip.startAt, sip.count, sip.autoCreate], [DateTime(2026, 11, 10, 9), 0, true]);

    // paused SIPs say so
    s.recurring.setPaused(sip.id!, true, now: kNow);
    s.changed();
    await tester.pumpAndSettle();
    expect(find.text('Paused'), findsOneWidget);

    await tapKey(tester, 'stop-sip');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(s.recurring.forInvestment(fd), isNotNull);
    await tapKey(tester, 'stop-sip');
    await tester.tap(find.byKey(const Key('confirm-stop-sip')));
    await tester.pumpAndSettle();
    expect(s.recurring.forInvestment(fd), isNull);
    expect(find.byKey(const Key('setup-sip')), findsOneWidget);
  });

  testWidgets('closed investments without a SIP offer no setup; archived source still shows', (tester) async {
    final s = makeState();
    final inv = s.planning.addInvestment(const Investment(kind: InvestmentKind.gold, name: 'Gold'));
    s.planning.setInvestmentStatus(inv, InvestmentStatus.closed);
    await pumpRoute(tester, s, InvestmentDetailScreen(id: inv));
    expect(find.byKey(const Key('setup-sip')), findsNothing);
    final src = s.catalog.addSource(name: 'Old', kind: SourceKind.bank);
    final open = s.planning.addInvestment(const Investment(kind: InvestmentKind.gold, name: 'Gold 2'));
    await pumpRoute(tester, s, InvestmentDetailScreen(id: open));
    await tapKey(tester, 'setup-sip');
    await tester.enterText(find.byKey(const Key('sip-amount')), '100');
    await pickDropdown(tester, 'sip-source', 'Old');
    await tester.tap(find.byKey(const Key('sip-save')));
    await tester.pumpAndSettle();
    s.catalog.archiveSource(src);
    s.changed();
    await tester.pumpAndSettle();
    expect(find.text('Next Thu, 5 Nov 2026 · Old'), findsOneWidget);
    await tapKey(tester, 'edit-sip');
    expect(find.text('Not set'), findsOneWidget);
  });
}
