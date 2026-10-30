import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/services/notifications.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:expense_manager/state/sms_inbox.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const _swiggy = 'Sent Rs.250.00 From HDFC Bank A/C *1242 To SWIGGY On 28/10/26 Ref 630212345678 Not You? Call 18002586161';
const _salary = 'Rs. 5,000.00 credited to a/c XX9999 on 28-10-26 by VPA rahul.k@okaxis';
const _noName = 'Rs 60 debited.';
const _ownCard = 'Rs 75 spent on card XX4407.';
final _at = DateTime(2026, 10, 28, 20, 15);

void main() {
  late FakeNotifications notes;
  late AppState s;
  late SmsInbox inbox;

  setUp(() {
    notes = FakeNotifications();
    s = makeState(notifications: notes);
    inbox = s.sms;
    inbox.enabled = true;
  });

  tearDown(() => s.dispose());

  test('off by default, and nothing is read while off', () async {
    final fresh = makeState();
    expect(fresh.sms.enabled, isFalse);
    expect(await fresh.sms.receive('AD-HDFCBK', _swiggy, _at), isNull);
    fresh.dispose();
  });

  test('a bank SMS becomes a pending capture and an "add?" prompt', () async {
    final ids = seed(s);
    final id = await inbox.receive('AD-HDFCBK', _swiggy, _at);
    expect(id, isNotNull);
    expect(inbox.pendingCount, 1);
    final c = inbox.pending().single;
    expect([c.id, c.sender, c.body, c.receivedAt, c.status, c.txnId], [id, 'AD-HDFCBK', _swiggy, _at, CaptureStatus.pending, null]);
    expect([c.sms.amount, c.sms.credit, c.sms.merchant, c.sms.last4], [25000, false, 'Swiggy', '1242']);

    // Seeded "HDFC Savings ••42" matches the account; Swiggy was last filed under Food & dining.
    final draft = inbox.draft(c);
    expect([draft.type, draft.amount, draft.sourceId, draft.categoryId, draft.occurredAt, draft.merchant], [TxnType.spend, 25000, ids.hdfc, catId(s, 'Food & dining'), _at, 'Swiggy']);
    expect(notes.prompts[smsNotificationBase + id!], ('New expense: ₹250 at Swiggy', 'Add to Food & dining · HDFC Savings ••42?', 'sms:$id', '$smsActionAdd,$smsActionEdit,$smsActionIgnore'));
  });

  test('skips non-transactions, repeats and transactions already recorded', () async {
    expect(await inbox.receive('AD-HDFCBK', 'Your OTP is 1234 for Rs 500', _at), isNull);
    expect(await inbox.receive('AD-HDFCBK', _swiggy, _at), isNotNull);
    expect(await inbox.receive('AD-HDFCBK', _swiggy, _at.add(const Duration(minutes: 2))), isNull, reason: 'same SMS delivered twice');
    s.txns.insert(
      Txn(type: TxnType.spend, amount: 6000, categoryId: catId(s, 'Others'), sourceId: null, occurredAt: _at, merchant: ''),
      now: kNow,
    );
    expect(await inbox.receive('VM-SBIUPI', _noName, _at), isNull, reason: 'same day, amount and merchant already exists');
    expect(inbox.pendingCount, 1);
  });

  test('income, unmatched accounts and messages without a payee', () async {
    final salary = inbox.capture((await inbox.receive('AD-ICICIB', _salary, _at))!)!;
    final d = inbox.draft(salary);
    expect([d.type, d.sourceId, d.categoryId], [TxnType.income, s.catalog.defaultSource()!.id, s.catalog.firstOf(CategoryKind.income).id]);
    expect(inbox.headline(salary), '₹5,000 from Rahul K');
    expect(notes.prompts.values.last.$1, 'Money received: ₹5,000 from Rahul K');

    final bare = inbox.capture((await inbox.receive('AD-ICICIB', _noName, _at))!)!;
    expect(inbox.headline(bare), '₹60');
    expect(inbox.draft(bare).categoryId, s.catalog.firstOf(CategoryKind.spend).id);

    final card = inbox.capture((await inbox.receive('AD-ICICIB', _ownCard, _at))!)!;
    expect(inbox.headline(card), '₹75 from ••4407');
    expect(inbox.capture(999), isNull);
    expect(inbox.pending().map((c) => c.id), [card.id, bare.id, salary.id]);
  });

  test('filing names the category, and the source when there is one', () {
    final t = Txn(type: TxnType.spend, amount: 1, categoryId: catId(s, 'Others'), sourceId: null, occurredAt: _at);
    expect(inbox.filing(t), 'Others');
  });

  test('approve adds the transaction once and confirms with Undo', () async {
    seed(s);
    final id = (await inbox.receive('AD-HDFCBK', _swiggy, _at))!;
    final txnId = await inbox.approve(id);
    expect(txnId, isNotNull);
    final saved = s.txns.byId(txnId!)!.txn;
    expect([saved.amount, saved.merchant, saved.occurredAt], [25000, 'Swiggy', _at]);
    expect(inbox.capture(id)!.status, CaptureStatus.added);
    expect(inbox.capture(id)!.txnId, txnId);
    expect(notes.prompts[smsNotificationBase + id], ('Expense added: ₹250 at Swiggy', 'Food & dining · HDFC Savings ••42', 'sms:$id', smsActionUndo));
    expect(await inbox.approve(id), isNull, reason: 'already added');
    expect(await inbox.approve(999), isNull);

    final income = (await inbox.receive('AD-ICICIB', _salary, _at))!;
    await inbox.approve(income);
    expect(notes.prompts[smsNotificationBase + income]!.$1, 'Income added: ₹5,000 from Rahul K');
  });

  test('undo removes the transaction and puts the capture back for review', () async {
    final id = (await inbox.receive('AD-HDFCBK', _swiggy, _at))!;
    final txnId = (await inbox.approve(id))!;
    await inbox.undo(id);
    expect(s.txns.byId(txnId), isNull);
    expect(inbox.capture(id)!.status, CaptureStatus.pending);
    expect(notes.cancelled, contains(smsNotificationBase + id));
    await inbox.undo(id); // not added any more: nothing to do
    await inbox.undo(999);
    // A capture added from the form without an id (a recurring rule) undoes cleanly too.
    inbox.markAdded(id, null);
    await inbox.undo(id);
    expect(inbox.capture(id)!.status, CaptureStatus.pending);
  });

  test('ignore drops it from the review list', () async {
    final id = (await inbox.receive('AD-HDFCBK', _swiggy, _at))!;
    await inbox.ignore(id);
    expect(inbox.capture(id)!.status, CaptureStatus.ignored);
    expect(inbox.pendingCount, 0);
    expect(notes.cancelled, [smsNotificationBase + id]);
  });

  test('handleTap routes buttons and returns what to open', () async {
    final id = (await inbox.receive('AD-HDFCBK', _swiggy, _at))!;
    expect(await inbox.handleTap(const NotificationTap('budget:1')), isNull);
    expect(await inbox.handleTap(const NotificationTap('sms:x')), isNull);
    expect((await inbox.handleTap(NotificationTap('sms:$id')))!.id, id, reason: 'body tap opens the form');
    expect((await inbox.handleTap(NotificationTap('sms:$id', smsActionEdit)))!.id, id);
    expect(await inbox.handleTap(NotificationTap('sms:$id', smsActionAdd)), isNull);
    expect(inbox.capture(id)!.status, CaptureStatus.added);
    expect(await inbox.handleTap(NotificationTap('sms:$id')), isNull, reason: 'already handled');
    expect(await inbox.handleTap(NotificationTap('sms:$id', smsActionUndo)), isNull);
    expect(inbox.capture(id)!.status, CaptureStatus.pending);
    expect(await inbox.handleTap(NotificationTap('sms:$id', smsActionIgnore)), isNull);
    expect(inbox.capture(id)!.status, CaptureStatus.ignored);
    expect(await inbox.handleTap(const NotificationTap('sms:999')), isNull);
  });

  test('prune forgets handled captures after 30 days but keeps pending ones', () async {
    final old = (await inbox.receive('A', _swiggy, kNow.subtract(const Duration(days: 40))))!;
    final oldPending = (await inbox.receive('B', _salary, kNow.subtract(const Duration(days: 40))))!;
    final recent = (await inbox.receive('C', _noName, kNow.subtract(const Duration(days: 2))))!;
    await inbox.ignore(old);
    await inbox.ignore(recent);
    inbox.prune();
    expect([inbox.capture(old), inbox.capture(oldPending)?.id, inbox.capture(recent)?.id], [null, oldPending, recent]);
  });

  test('the base notification service shows prompts as plain notifications', () async {
    const n = NotificationService.none;
    await n.prompt(1, 't', 'b', payload: 'p');
    n.listen((_) {});
    expect(await n.launchTap(), isNull);
  });
}
