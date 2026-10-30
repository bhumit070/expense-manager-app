import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:workmanager/workmanager.dart';

import '../data/device_db.dart';
import '../core/dates.dart';
import '../data/recurring_repo.dart';
import '../data/settings_repo.dart';
import '../state/reminders.dart';
import 'notifications.dart';

/// Unique name of the daily background task.
const dailyTask = 'expense-manager-daily';

/// What the daily task does: create due recurring transactions, post budget
/// alerts and re-plan reminders. Pure function of the database, [now] and
/// the notification [service].
Future<void> runDaily(Database db, DateTime now, NotificationService service) async {
  weekStartDay = parseWeekStart(SettingsRepo(db).get('week_start'));
  RecurringRepo(db).run(now);
  await Reminders(db: db, service: service, clock: () => now).refresh();
}

/// Background entry point: opens the device database, runs [runDaily] and
/// closes it again. Returns false (retry later) if anything fails.
Future<bool> backgroundTask({Future<Database> Function()? open, NotificationService? service, DateTime Function()? clock}) async {
  try {
    DartPluginRegistrant.ensureInitialized();
    final db = await (open ?? openDeviceDatabase)();
    try {
      await runDaily(db, (clock ?? DateTime.now)(), service ?? PlatformNotificationService());
    } finally {
      db.close();
    }
    return true;
  } catch (e) {
    debugPrint('Background task failed: $e');
    return false;
  }
}

/// Registered with WorkManager; runs in a background isolate.
@pragma('vm:entry-point')
void callbackDispatcher() => Workmanager().executeTask((task, input) => backgroundTask());

/// Schedules the daily task. Android only: iOS gives apps no reliable daily
/// background slot, so there the work runs on app open and the reminders
/// themselves are already scheduled with the OS.
class BackgroundScheduler {
  BackgroundScheduler({Workmanager? workmanager}) : _wm = workmanager ?? Workmanager();

  final Workmanager _wm;

  Future<bool> ensureScheduled() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    await _wm.initialize(callbackDispatcher);
    await _wm.registerPeriodicTask(dailyTask, dailyTask, frequency: const Duration(hours: 24), existingWorkPolicy: ExistingPeriodicWorkPolicy.keep);
    return true;
  }
}
