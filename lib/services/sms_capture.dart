import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../data/device_db.dart';
import '../state/sms_inbox.dart';
import 'notifications.dart';

/// Channel shared with the Android SmsReceiver / MainActivity and the iOS
/// "Log bank SMS" App Intent.
const smsChannel = MethodChannel('expense_manager/sms');

/// One SMS handed over by the Android receiver or the iOS App Intent.
typedef IncomingSms = ({String sender, String body, DateTime at});

/// Opens the device database, runs [work] on an [SmsInbox] and closes it.
/// Returns false on failure. Errors are logged, never thrown: this runs with
/// no UI to report to.
Future<bool> withInbox(Future<void> Function(SmsInbox inbox) work, {Future<Database> Function()? open, NotificationService? service, DateTime Function()? clock}) async {
  try {
    final db = await (open ?? openDeviceDatabase)();
    try {
      await work(SmsInbox(db: db, service: service ?? PlatformNotificationService(), clock: clock ?? DateTime.now));
    } finally {
      db.close();
    }
    return true;
  } catch (e) {
    debugPrint('SMS capture failed: $e');
    return false;
  }
}

/// Reads the messages handed over and prompts for each one. If the database
/// can't be opened (e.g. it is encrypted and the phone is locked), the
/// messages wait in [PendingSms] for the next app start.
Future<void> receiveAll(List<IncomingSms> messages, {Future<Database> Function()? open, NotificationService? service, Future<PendingSms> Function()? pending}) async {
  final done = await withInbox(
    (inbox) async {
      for (final m in messages) {
        await inbox.receive(m.sender, m.body, m.at);
      }
    },
    open: open,
    service: service,
  );
  if (done || messages.isEmpty) return;
  try {
    await (await (pending ?? PendingSms.device)()).add(messages);
  } catch (e) {
    debugPrint('Could not keep SMS for later: $e');
  }
}

/// Messages that arrived while the database could not be opened. Kept in
/// the app's private support folder and handled on the next app start.
class PendingSms {
  PendingSms(this.file);

  final File file;

  static Future<PendingSms> device() async => PendingSms(File(p.join((await getApplicationSupportDirectory()).path, 'pending_sms.json')));

  Future<List<IncomingSms>> read() async {
    if (!await file.exists()) return const [];
    try {
      return decodeMessages(jsonDecode(await file.readAsString()) as List<Object?>);
    } on FormatException {
      return const [];
    }
  }

  Future<void> add(List<IncomingSms> messages) async {
    final all = [...await read(), ...messages];
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode([for (final m in all) _encode(m)]));
  }

  /// Hands the waiting messages to [inbox] and forgets them. Returns how many there were.
  Future<int> drainInto(SmsInbox inbox) async {
    final waiting = await read();
    for (final m in waiting) {
      await inbox.receive(m.sender, m.body, m.at);
    }
    if (await file.exists()) await file.delete();
    return waiting.length;
  }

  static Map<String, Object> _encode(IncomingSms m) => {'sender': m.sender, 'body': m.body, 'at': m.at.millisecondsSinceEpoch};
}

List<IncomingSms> decodeMessages(List<Object?>? raw) => [
  for (final m in raw ?? const <Object?>[])
    if (m case {'sender': final String sender, 'body': final String body, 'at': final int at}) (sender: sender, body: body, at: DateTime.fromMillisecondsSinceEpoch(at)),
];

/// Started by the Android SmsReceiver or the iOS App Intent in a headless
/// engine: take the messages, prompt, then tell the native side to shut the
/// engine down.
@pragma('vm:entry-point')
Future<void> smsReceived() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  try {
    await receiveAll(decodeMessages(await smsChannel.invokeListMethod<Object?>('take')));
  } finally {
    await smsChannel.invokeMethod<void>('done');
  }
}

/// Taps on "Add", "Ignore" or "Undo" while the app isn't running.
@pragma('vm:entry-point')
Future<void> smsNotificationBackground(NotificationResponse r) async {
  DartPluginRegistrant.ensureInitialized();
  await withInbox((inbox) => inbox.handleTap(NotificationTap(r.payload ?? '', r.actionId)));
}

/// SMS access from the app. Android reads SMS itself and needs the SMS
/// permission; on iOS a Shortcuts automation hands messages over, so there
/// is nothing to grant. Fakeable in tests.
class SmsPlatform {
  const SmsPlatform();

  bool get supported => viaShortcuts || defaultTargetPlatform == TargetPlatform.android;

  /// iPhone: messages arrive through a Shortcuts automation the user sets up.
  bool get viaShortcuts => defaultTargetPlatform == TargetPlatform.iOS;

  Future<bool> hasPermission() => _ask('hasPermission');

  Future<bool> requestPermission() => _ask('requestPermission');

  Future<bool> _ask(String method) async {
    if (viaShortcuts) return true;
    return supported && (await smsChannel.invokeMethod<bool>(method) ?? false);
  }
}
