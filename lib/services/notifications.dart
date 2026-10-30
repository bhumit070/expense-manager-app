import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'sms_capture.dart' show smsNotificationBackground;

/// A button on a notification. [opensApp] buttons bring the app forward;
/// the others are handled in the background.
class NotificationActionSpec {
  const NotificationActionSpec(this.id, this.label, {this.opensApp = false});

  final String id;
  final String label;
  final bool opensApp;
}

/// The user tapped a notification ([action] null) or one of its buttons.
class NotificationTap {
  const NotificationTap(this.payload, [this.action]);

  final String payload;
  final String? action;
}

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

  /// Shows a notification with buttons on the SMS channel. Taps arrive in
  /// [listen] while the app runs, else in the background handler.
  Future<void> prompt(int id, String title, String body, {required String payload, List<NotificationActionSpec> actions = const []}) => show(id, title, body);

  /// Registers [handler] for taps while the app is running.
  void listen(void Function(NotificationTap tap) handler) {}

  /// The tap that launched the app, if any.
  Future<NotificationTap?> launchTap() async => null;
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

/// Android channel for "add this expense?" prompts read from SMS.
const smsChannelId = 'sms_expenses';

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
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: smsNotificationBackground,
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

  void Function(NotificationTap tap)? _onTap;

  @override
  void listen(void Function(NotificationTap tap) handler) => _onTap = handler;

  void _onResponse(NotificationResponse r) => _onTap?.call(NotificationTap(r.payload ?? '', r.actionId));

  @override
  Future<NotificationTap?> launchTap() async {
    await init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    final r = details?.notificationResponse;
    return details?.didNotificationLaunchApp == true && r != null ? NotificationTap(r.payload ?? '', r.actionId) : null;
  }

  @override
  Future<void> prompt(int id, String title, String body, {required String payload, List<NotificationActionSpec> actions = const []}) async {
    await init();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      payload: payload,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          smsChannelId,
          'Expenses from SMS',
          channelDescription: 'Asks before adding a bank or UPI transaction read from an SMS',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
          visibility: NotificationVisibility.private,
          actions: [for (final a in actions) AndroidNotificationAction(a.id, a.label, showsUserInterface: a.opensApp, cancelNotification: true)],
        ),
      ),
    );
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
