import 'package:expense_manager/services/notifications.dart';
import 'package:expense_manager/state/sms_inbox.dart';
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

  test('Android: prompts carry a payload and buttons; taps reach the listener', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    FlutterLocalNotificationsPlatform.instance = AndroidFlutterLocalNotificationsPlugin();
    final calls = _mockPlugin();
    final n = PlatformNotificationService(localTimezone: () async => 'UTC');
    final taps = <NotificationTap>[];
    n.listen(taps.add);
    await n.prompt(5, 'New expense', 'Add it?', payload: 'sms:1', actions: const [NotificationActionSpec('add', 'Add'), NotificationActionSpec('edit', 'Edit', opensApp: true)]);
    final shown = calls.last.arguments as Map;
    expect([shown['id'], shown['payload']], [5, 'sms:1']);
    final android = shown['platformSpecifics'] as Map;
    expect(android['channelId'], smsChannelId);
    expect(
      [
        for (final a in android['actions'] as List) [(a as Map)['id'], a['title'], a['showsUserInterface']],
      ],
      [
        ['add', 'Add', false],
        ['edit', 'Edit', true],
      ],
    );
    expect((calls.first.arguments as Map)['dispatcher_handle'], isNotNull, reason: 'background taps have a handler');

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      _channel.name,
      _channel.codec.encodeMethodCall(const MethodCall('didReceiveNotificationResponse', {'notificationId': 5, 'actionId': 'add', 'payload': 'sms:1', 'notificationResponseType': 1})),
      (_) {},
    );
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      _channel.name,
      _channel.codec.encodeMethodCall(const MethodCall('didReceiveNotificationResponse', {'notificationId': 6, 'notificationResponseType': 0})),
      (_) {},
    );
    expect([for (final t in taps) (t.payload, t.action)], [('sms:1', 'add'), ('', null)]);
  });

  test('launchTap: the notification that opened the app, if any', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    FlutterLocalNotificationsPlatform.instance = AndroidFlutterLocalNotificationsPlugin();
    Object? launch;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (call) async => call.method == 'getNotificationAppLaunchDetails' ? launch : true);
    final n = PlatformNotificationService(localTimezone: () async => 'UTC');
    expect(await n.launchTap(), isNull);
    launch = {'notificationLaunchedApp': false};
    expect(await n.launchTap(), isNull);
    launch = {
      'notificationLaunchedApp': true,
      'notificationResponse': {'notificationId': 5, 'actionId': 'edit', 'payload': 'sms:3', 'notificationResponseType': 1},
    };
    final tap = await n.launchTap();
    expect([tap!.payload, tap.action], ['sms:3', 'edit']);
    launch = {
      'notificationLaunchedApp': true,
      'notificationResponse': {'notificationId': 5, 'notificationResponseType': 0},
    };
    expect((await n.launchTap())!.payload, '');
  });

  test('iOS: SMS buttons are registered as categories and prompts use them', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    FlutterLocalNotificationsPlatform.instance = IOSFlutterLocalNotificationsPlugin();
    final calls = _mockPlugin();
    final n = PlatformNotificationService(localTimezone: () async => 'UTC');
    await n.prompt(5, 'New expense', 'Add it?', payload: 'sms:1', actions: smsPromptActions);
    await n.prompt(6, 'Added', 'Food', payload: 'sms:1', actions: smsAddedActions);
    await n.prompt(7, 'Plain', 'No buttons', payload: 'x');
    final categories = (calls.first.arguments as Map)['notificationCategories'] as List;
    expect([for (final c in categories) (c as Map)['identifier']], ['sms_add+sms_edit+sms_ignore', 'sms_undo']);
    final buttons = (categories.first as Map)['actions'] as List;
    expect([for (final a in buttons) '${(a as Map)['identifier']} ${a['options']}'], ['sms_add []', 'sms_edit [4]', 'sms_ignore []'], reason: 'only Add details brings the app forward');
    final shown = [for (final c in calls.where((c) => c.method == 'show')) ((c.arguments as Map)['platformSpecifics'] as Map)['categoryIdentifier']];
    expect(shown, ['sms_add+sms_edit+sms_ignore', 'sms_undo', null]);
  });
}
