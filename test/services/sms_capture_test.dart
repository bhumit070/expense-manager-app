import 'dart:io';

import 'package:expense_manager/data/database.dart';
import 'package:expense_manager/services/sms_capture.dart';
import 'package:expense_manager/state/sms_inbox.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../helpers.dart';

const _sms = 'Sent Rs.250.00 From HDFC Bank A/C *1234 To SWIGGY On 28/10/26 Ref 630212345678';

/// An in-memory database that stays open after [withInbox] "closes" it,
/// so the test can look inside.
class _KeptOpen {
  final db = openAppDatabase(null);
  int opens = 0;

  Future<Database> open() async {
    opens++;
    return _NoClose(db);
  }
}

class _NoClose implements Database {
  _NoClose(this._db);
  final Database _db;

  @override
  void close() {}

  @override
  dynamic noSuchMethod(Invocation i) => Function.apply(
    switch (i.memberName) {
      #select => _db.select,
      #execute => _db.execute,
      #lastInsertRowId => () => _db.lastInsertRowId,
      #updatedRows => () => _db.updatedRows,
      _ => throw UnimplementedError('${i.memberName}'),
    },
    i.isGetter ? const [] : i.positionalArguments,
    i.namedArguments,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(smsChannel, null);
  });

  test('decodeMessages keeps well-formed entries only', () {
    expect(decodeMessages(null), isEmpty);
    final m = decodeMessages([
      {'sender': 'AD-HDFCBK', 'body': _sms, 'at': 1000},
      {'sender': 'x'},
      'junk',
    ]);
    expect(m, [(sender: 'AD-HDFCBK', body: _sms, at: DateTime.fromMillisecondsSinceEpoch(1000))]);
  });

  test('receiveAll prompts for each new message when capture is on', () async {
    final store = _KeptOpen();
    final notes = FakeNotifications();
    await receiveAll([(sender: 'AD-HDFCBK', body: _sms, at: kNow)], open: store.open, service: notes);
    expect(notes.prompts, isEmpty, reason: 'off until the user opts in');

    store.db.execute("INSERT INTO settings(key, value) VALUES ('sms_capture', 'on')");
    await receiveAll([(sender: 'AD-HDFCBK', body: _sms, at: kNow), (sender: 'AD-HDFCBK', body: 'hello', at: kNow)], open: store.open, service: notes);
    expect(notes.prompts.keys, [smsNotificationBase + 1]);
    expect(store.opens, 2);
  });

  test('withInbox swallows failures (no UI to report to)', () async {
    var ran = false;
    await withInbox((_) async => ran = true, open: () async => throw StateError('locked'));
    expect(ran, isFalse);
    final store = _KeptOpen();
    await withInbox((_) async => throw StateError('boom'), open: store.open, service: FakeNotifications(), clock: () => kNow);
    expect(store.opens, 1);
  });

  test('smsReceived takes the messages and always reports done', () async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(smsChannel, (call) async {
      calls.add(call.method);
      return call.method == 'take' ? <Object?>[] : null;
    });
    await smsReceived();
    expect(calls, ['take', 'done']);
  });

  test('a background notification tap with no database just logs', () async {
    await smsNotificationBackground(const NotificationResponse(notificationResponseType: NotificationResponseType.selectedNotificationAction, actionId: smsActionAdd, payload: 'sms:1'));
    await smsNotificationBackground(const NotificationResponse(notificationResponseType: NotificationResponseType.selectedNotification));
  });

  test('SmsPlatform: Android asks the activity; elsewhere it is unsupported', () async {
    final asked = <String>[];
    Object? answer = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(smsChannel, (call) async {
      asked.add(call.method);
      return answer;
    });
    const p = SmsPlatform();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(p.supported, isTrue);
    expect(await p.hasPermission(), isTrue);
    expect(await p.requestPermission(), isTrue);
    answer = null;
    expect(await p.hasPermission(), isFalse);
    expect(await p.requestPermission(), isFalse);
    expect(asked, ['hasPermission', 'requestPermission', 'hasPermission', 'requestPermission']);

    expect(p.viaShortcuts, isFalse);

    // iPhone: a Shortcuts automation hands messages over; nothing to grant.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect([p.supported, p.viaShortcuts], [true, true]);
    expect(await p.hasPermission(), isTrue);
    expect(await p.requestPermission(), isTrue);
    expect(asked.length, 4);

    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    expect(p.supported, isFalse);
    expect(await p.hasPermission(), isFalse);
    expect(await p.requestPermission(), isFalse);
    expect(asked.length, 4);
  });

  group('PendingSms', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('pending_sms'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('messages that could not be handled wait for the next start', () async {
      final store = PendingSms(File('${dir.path}/sub/pending.json'));
      final m = (sender: 'AD-HDFCBK', body: _sms, at: kNow);
      await receiveAll([m], open: () async => throw StateError('locked'), pending: () async => store);
      await receiveAll([m], open: () async => throw StateError('locked'), pending: () async => store);
      expect(await store.read(), [m, m]);

      final state = makeState(notifications: FakeNotifications());
      state.sms.enabled = true;
      expect(await store.drainInto(state.sms), 2);
      expect(state.sms.pendingCount, 1, reason: 'the same SMS twice is one capture');
      expect(await store.file.exists(), isFalse);
      expect(await store.drainInto(state.sms), 0);
    });

    test('nothing is queued when it worked or there was nothing to do', () async {
      final store = PendingSms(File('${dir.path}/pending.json'));
      await receiveAll(const [], open: () async => throw StateError('locked'), pending: () async => store);
      await receiveAll([(sender: 'x', body: _sms, at: kNow)], open: _KeptOpen().open, service: FakeNotifications(), pending: () async => store);
      expect(await store.file.exists(), isFalse);
    });

    test('a broken file reads as empty; a failing store is only logged', () async {
      final store = PendingSms(File('${dir.path}/pending.json'))..file.writeAsStringSync('{not json');
      expect(await store.read(), isEmpty);
      await receiveAll([(sender: 'x', body: _sms, at: kNow)], open: () async => throw StateError('locked'), pending: () async => throw StateError('no disk'));
      // Default store: path_provider has no platform in tests, so this is only logged too.
      await receiveAll([(sender: 'x', body: _sms, at: kNow)], open: () async => throw StateError('locked'));
    });
  });
}
