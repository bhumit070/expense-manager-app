import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqlite3/sqlite3.dart';

import '../data/device_db.dart';
import '../state/sms_inbox.dart';
import 'notifications.dart';

/// Channel shared with the Android SmsReceiver and MainActivity.
const smsChannel = MethodChannel('expense_manager/sms');

/// One SMS handed over by the Android receiver.
typedef IncomingSms = ({String sender, String body, DateTime at});

/// Opens the device database, runs [work] on an [SmsInbox] and closes it.
/// Errors are logged, never thrown: this runs with no UI to report to.
Future<void> withInbox(Future<void> Function(SmsInbox inbox) work, {Future<Database> Function()? open, NotificationService? service, DateTime Function()? clock}) async {
  try {
    final db = await (open ?? openDeviceDatabase)();
    try {
      await work(SmsInbox(db: db, service: service ?? PlatformNotificationService(), clock: clock ?? DateTime.now));
    } finally {
      db.close();
    }
  } catch (e) {
    debugPrint('SMS capture failed: $e');
  }
}

/// Reads the messages the receiver passed over and prompts for each one.
Future<void> receiveAll(List<IncomingSms> messages, {Future<Database> Function()? open, NotificationService? service}) => withInbox(
  (inbox) async {
    for (final m in messages) {
      await inbox.receive(m.sender, m.body, m.at);
    }
  },
  open: open,
  service: service,
);

List<IncomingSms> decodeMessages(List<Object?>? raw) => [
  for (final m in raw ?? const <Object?>[])
    if (m case {'sender': final String sender, 'body': final String body, 'at': final int at}) (sender: sender, body: body, at: DateTime.fromMillisecondsSinceEpoch(at)),
];

/// Started by the Android SmsReceiver in a headless engine: take the
/// messages, prompt, then tell the receiver to shut the engine down.
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

/// SMS access from the app: the permission and whether this platform can
/// read SMS at all (Android only). Fakeable in tests.
class SmsPlatform {
  const SmsPlatform();

  bool get supported => defaultTargetPlatform == TargetPlatform.android;

  Future<bool> hasPermission() async => supported && (await smsChannel.invokeMethod<bool>('hasPermission') ?? false);

  Future<bool> requestPermission() async => supported && (await smsChannel.invokeMethod<bool>('requestPermission') ?? false);
}
