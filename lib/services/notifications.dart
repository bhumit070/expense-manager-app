import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications (no push, no server). Fakeable in tests.
abstract class NotificationService {
  const NotificationService();

  /// A service that does nothing; the default where no platform is wired up.
  static const NotificationService none = _NoNotifications();

  /// False for [none], so callers can skip work that only feeds notifications.
  bool get available => true;

  /// Asks the OS for permission to post notifications (Android 13+, iOS).
  Future<bool> requestPermission();

  /// Shows a notification now.
  Future<void> show(int id, String title, String body);

  /// Schedules a notification for [at] (local wall-clock time).
  Future<void> schedule(int id, DateTime at, String title, String body);

  Future<void> cancel(int id);
}

class _NoNotifications extends NotificationService {
  const _NoNotifications();

  @override
  bool get available => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> show(int id, String title, String body) async {}

  @override
  Future<void> schedule(int id, DateTime at, String title, String body) async {}

  @override
  Future<void> cancel(int id) async {}
}

/// Android channel every reminder and alert is posted to.
const reminderChannelId = 'reminders';

/// flutter_local_notifications with timezone-aware scheduling. Reminders use
/// inexact alarms: they can arrive a few minutes late but need no
/// exact-alarm permission and are battery friendly.
class PlatformNotificationService extends NotificationService {
  PlatformNotificationService({FlutterLocalNotificationsPlugin? plugin, Future<String> Function()? localTimezone})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
      _localTimezone = localTimezone ?? _deviceTimezone;

  final FlutterLocalNotificationsPlugin _plugin;
  final Future<String> Function() _localTimezone;
  Future<void>? _ready;

  static Future<String> _deviceTimezone() async => (await FlutterTimezone.getLocalTimezone()).identifier;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      reminderChannelId,
      'Reminders & alerts',
      channelDescription: 'Budget alerts, due dates, SIPs and maturity reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Loads time zones and initialises the plugin once.
  Future<void> init() => _ready ??= _init();

  Future<void> _init() async {
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(await _localTimezone()));
    } catch (_) {
      // Unknown zone: keep the default (UTC); reminders may shift by the offset.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) return false;
    await init();
    if (platform == TargetPlatform.android) {
      return await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission() ?? false;
    }
    return await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  }

  @override
  Future<void> show(int id, String title, String body) async {
    await init();
    await _plugin.show(id: id, title: title, body: body, notificationDetails: _details);
  }

  @override
  Future<void> schedule(int id, DateTime at, String title, String body) async {
    await init();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime(tz.local, at.year, at.month, at.day, at.hour, at.minute),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id: id);
  }
}
