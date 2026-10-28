import 'package:expense_manager/services/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

const _channel = MethodChannel('dexterous.com/flutter/local_notifications');

/// Records every call the plugin makes to the native side.
List<MethodCall> _mockPlugin({Object? permission = true}) {
  final calls = <MethodCall>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (call) async {
    calls.add(call);
    return switch (call.method) {
      'initialize' => true,
      'requestNotificationsPermission' || 'requestPermissions' => permission,
      _ => null,
    };
  });
  return calls;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('flutter_timezone'), null);
  });

  test('none does nothing and is not available', () async {
    const n = NotificationService.none;
    expect(n.available, isFalse);
    expect(await n.requestPermission(), isFalse);
    await n.show(1, 't', 'b');
    await n.schedule(1, DateTime(2030), 't', 'b');
    await n.cancel(1);
  });

  test('Android: initialises once, asks permission, shows, schedules in the local zone and cancels', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    FlutterLocalNotificationsPlatform.instance = AndroidFlutterLocalNotificationsPlugin();
    final calls = _mockPlugin();
    final n = PlatformNotificationService(localTimezone: () async => 'Asia/Kolkata');
    expect(n.available, isTrue);
    expect(await n.requestPermission(), isTrue);
    await n.show(7, 'Hello', 'World');
    final at = DateTime.now().add(const Duration(days: 2));
    await n.schedule(8, DateTime(at.year, at.month, at.day, 9), 'Later', 'Body');
    await n.cancel(8);
    expect(calls.map((c) => c.method), ['initialize', 'requestNotificationsPermission', 'show', 'zonedSchedule', 'cancel']);
    expect((calls.first.arguments as Map)['defaultIcon'], 'ic_notification');
    final shown = calls[2].arguments as Map;
    expect([shown['id'], shown['title'], shown['body']], [7, 'Hello', 'World']);
    expect((shown['platformSpecifics'] as Map)['channelId'], reminderChannelId);
    final sched = calls[3].arguments as Map;
    expect(sched['id'], 8);
    expect(sched['scheduledDateTime'], startsWith('${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')}T09:00'));
    expect(sched['timeZoneName'], 'Asia/Kolkata');
    expect((sched['platformSpecifics'] as Map)['scheduleMode'], 'inexactAllowWhileIdle');
    expect(tz.local.name, 'Asia/Kolkata');
  });

  test('Android: a denied (or unanswered) permission is false', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    FlutterLocalNotificationsPlatform.instance = AndroidFlutterLocalNotificationsPlugin();
    _mockPlugin(permission: null);
    expect(await PlatformNotificationService(localTimezone: () async => 'UTC').requestPermission(), isFalse);
  });

  test('iOS asks for alert, badge and sound', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    FlutterLocalNotificationsPlatform.instance = IOSFlutterLocalNotificationsPlugin();
    final calls = _mockPlugin();
    expect(await PlatformNotificationService(localTimezone: () async => 'Europe/London').requestPermission(), isTrue);
    expect(calls.last.method, 'requestPermissions');
    expect(calls.last.arguments, containsPair('alert', true));
    _mockPlugin(permission: null);
    expect(await PlatformNotificationService(localTimezone: () async => 'UTC').requestPermission(), isFalse);
  });

  test('other platforms never get permission', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    expect(await PlatformNotificationService(localTimezone: () async => 'UTC').requestPermission(), isFalse);
  });

  test('device time zone comes from flutter_timezone; unknown zones fall back to UTC', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    FlutterLocalNotificationsPlatform.instance = AndroidFlutterLocalNotificationsPlugin();
    _mockPlugin();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('flutter_timezone'), (call) async => 'America/New_York');
    await PlatformNotificationService().init();
    expect(tz.local.name, 'America/New_York');
    await PlatformNotificationService(localTimezone: () async => 'Nowhere/Zone').init();
    expect(tz.local.name, 'Etc/UTC');
  });
}
