import 'package:sqlite3/sqlite3.dart';

import '../core/money.dart';
import '../data/catalog_repo.dart';
import '../data/models.dart';
import '../data/settings_repo.dart';
import '../data/transactions_repo.dart';
import '../services/bank_sms.dart';
import '../services/notifications.dart';

enum CaptureStatus { pending, added, ignored }

/// A transaction detected in a bank SMS.
class SmsCapture {
  const SmsCapture({required this.id, required this.receivedAt, required this.sender, required this.body, required this.sms, required this.status, this.txnId});

  factory SmsCapture.fromRow(Row r) => SmsCapture(
    id: r['id'] as int,
    receivedAt: DateTime.fromMillisecondsSinceEpoch(r['received_at'] as int),
    sender: r['sender'] as String,
    body: r['body'] as String,
    sms: BankSms(amount: r['amount'] as int, credit: r['credit'] == 1, merchant: r['merchant'] as String, last4: r['last4'] as String?),
    status: CaptureStatus.values.byName(r['status'] as String),
    txnId: r['txn_id'] as int?,
  );

  final int id;
  final DateTime receivedAt;
  final String sender;
  final String body;
  final BankSms sms;
  final CaptureStatus status;
  final int? txnId;
}

/// Notification ids for SMS prompts: [smsNotificationBase] + capture id.
const smsNotificationBase = 200000;

/// Notification action ids.
const smsActionAdd = 'sms_add';
const smsActionEdit = 'sms_edit';
const smsActionIgnore = 'sms_ignore';
const smsActionUndo = 'sms_undo';

/// Payload prefix on SMS notifications: `sms:<capture id>`.
const _payloadPrefix = 'sms:';

/// Captures older than this are forgotten once handled.
const _keepHandled = Duration(days: 30);

/// Turns bank SMS into transactions the user approves from a notification
/// (Android). Works on any open database, so the app and the background
/// isolates share it.
class SmsInbox {
  SmsInbox({required this.db, required this.service, required this.clock}) : settings = SettingsRepo(db), catalog = CatalogRepo(db), txns = TransactionsRepo(db);

  final Database db;
  final NotificationService service;
  final DateTime Function() clock;
  final SettingsRepo settings;
  final CatalogRepo catalog;
  final TransactionsRepo txns;

  /// Whether incoming SMS are read at all (off until the user opts in).
  bool get enabled => settings.get('sms_capture') == 'on';

  set enabled(bool on) => settings.set('sms_capture', on ? 'on' : 'off');

  /// Reads one incoming SMS. Returns the new capture's id after prompting,
  /// or null when capture is off, the SMS isn't a transaction, or it was
  /// already seen or already recorded.
  Future<int?> receive(String sender, String body, DateTime at) async {
    if (!enabled) return null;
    final sms = parseBankSms(body);
    if (sms == null) return null;
    final seen = db.select('SELECT 1 FROM sms_captures WHERE sender = ? AND body = ? AND abs(received_at - ?) < 600000 LIMIT 1', [sender, body, at.millisecondsSinceEpoch]);
    if (seen.isNotEmpty) return null;
    final draft = _draft(sms, at);
    if (txns.isDuplicate(draft)) return null;
    db.execute('INSERT INTO sms_captures(received_at, sender, body, amount, credit, merchant, last4) VALUES (?, ?, ?, ?, ?, ?, ?)', [
      at.millisecondsSinceEpoch,
      sender,
      body,
      sms.amount,
      sms.credit ? 1 : 0,
      sms.merchant,
      sms.last4,
    ]);
    final id = db.lastInsertRowId;
    await _prompt(capture(id)!);
    return id;
  }

  SmsCapture? capture(int id) {
    final rows = db.select('SELECT * FROM sms_captures WHERE id = ?', [id]);
    return rows.isEmpty ? null : SmsCapture.fromRow(rows.single);
  }

  /// Captures still waiting for a decision, newest first.
  List<SmsCapture> pending() => db.select("SELECT * FROM sms_captures WHERE status = 'pending' ORDER BY received_at DESC, id DESC").map(SmsCapture.fromRow).toList();

  int get pendingCount => db.select("SELECT count(*) AS n FROM sms_captures WHERE status = 'pending'").single['n'] as int;

  /// The transaction a capture would become: same time, the matched
  /// account or card (else the default source), and the category last used
  /// for this merchant (else the first one).
  Txn draft(SmsCapture c) => _draft(c.sms, c.receivedAt);

  Txn _draft(BankSms sms, DateTime at) {
    final type = sms.credit ? TxnType.income : TxnType.spend;
    final source = sms.last4 == null ? null : catalog.sources().where((s) => s.last4 != null && s.last4!.isNotEmpty && sms.last4!.endsWith(s.last4!)).firstOrNull;
    final last = sms.merchant.isEmpty
        ? null
        : db.select('SELECT category_id FROM transactions WHERE deleted = 0 AND type = ? AND lower(merchant) = lower(?) ORDER BY occurred_at DESC LIMIT 1', [type.name, sms.merchant]).firstOrNull;
    return Txn(
      type: type,
      amount: sms.amount,
      categoryId: last?['category_id'] as int? ?? catalog.firstOf(sms.credit ? CategoryKind.income : CategoryKind.spend).id,
      sourceId: source?.id ?? catalog.defaultSource()?.id,
      occurredAt: at,
      merchant: sms.merchant,
    );
  }

  /// "₹250 at Swiggy" / "₹5,000 from Rahul" / "₹60 from HDFC ••1234".
  String headline(SmsCapture c) {
    final amount = formatInr(c.sms.amount);
    if (c.sms.merchant.isNotEmpty) return '$amount ${c.sms.credit ? 'from' : 'at'} ${c.sms.merchant}';
    return c.sms.last4 == null ? amount : '$amount ${c.sms.credit ? 'into' : 'from'} ••${c.sms.last4}';
  }

  /// "Food · HDFC ••1234": where it will be filed.
  String filing(Txn t) {
    final source = t.sourceId == null ? null : catalog.sources(includeArchived: true).where((s) => s.id == t.sourceId).firstOrNull;
    return [catalog.category(t.categoryId).name, ?source?.display].join(' · ');
  }

  Future<void> _prompt(SmsCapture c) => service.prompt(
    smsNotificationBase + c.id,
    c.sms.credit ? 'Money received: ${headline(c)}' : 'New expense: ${headline(c)}',
    'Add to ${filing(draft(c))}?',
    payload: '$_payloadPrefix${c.id}',
    actions: const [NotificationActionSpec(smsActionAdd, 'Add'), NotificationActionSpec(smsActionEdit, 'Add details', opensApp: true), NotificationActionSpec(smsActionIgnore, 'Ignore')],
  );

  /// Adds a pending capture as a transaction and confirms with an Undo
  /// notification. Returns the transaction id, or null if it was handled.
  Future<int?> approve(int id) async {
    final c = capture(id);
    if (c == null || c.status != CaptureStatus.pending) return null;
    final txn = draft(c);
    final txnId = txns.insert(txn, now: clock());
    markAdded(id, txnId);
    await service.prompt(
      smsNotificationBase + id,
      c.sms.credit ? 'Income added: ${headline(c)}' : 'Expense added: ${headline(c)}',
      filing(txn),
      payload: '$_payloadPrefix$id',
      actions: const [NotificationActionSpec(smsActionUndo, 'Undo')],
    );
    return txnId;
  }

  /// Records that [id] was saved as [txnId] (from the form or [approve]).
  void markAdded(int id, int? txnId) => db.execute("UPDATE sms_captures SET status = 'added', txn_id = ? WHERE id = ?", [txnId, id]);

  Future<void> ignore(int id) async {
    db.execute("UPDATE sms_captures SET status = 'ignored' WHERE id = ? AND status = 'pending'", [id]);
    await service.cancel(smsNotificationBase + id);
  }

  /// Removes the transaction [approve] created and puts the capture back in
  /// the review list.
  Future<void> undo(int id) async {
    final c = capture(id);
    if (c == null || c.status != CaptureStatus.added) return;
    if (c.txnId != null) txns.delete(c.txnId!);
    db.execute("UPDATE sms_captures SET status = 'pending', txn_id = NULL WHERE id = ?", [id]);
    await service.cancel(smsNotificationBase + id);
  }

  /// Handles a tap on an SMS notification. Returns the capture to open in
  /// the add form (body tap or "Add details"), else null.
  Future<SmsCapture?> handleTap(NotificationTap tap) async {
    if (!tap.payload.startsWith(_payloadPrefix)) return null;
    final id = int.tryParse(tap.payload.substring(_payloadPrefix.length));
    if (id == null) return null;
    switch (tap.action) {
      case smsActionAdd:
        await approve(id);
      case smsActionIgnore:
        await ignore(id);
      case smsActionUndo:
        await undo(id);
      default:
        final c = capture(id);
        return c?.status == CaptureStatus.pending ? c : null;
    }
    return null;
  }

  /// Forgets handled captures (and their message text) after 30 days.
  void prune() => db.execute("DELETE FROM sms_captures WHERE status != 'pending' AND received_at < ?", [clock().subtract(_keepHandled).millisecondsSinceEpoch]);
}
