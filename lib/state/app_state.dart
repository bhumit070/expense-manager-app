import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

import '../core/dates.dart';
import '../core/money.dart';
import '../data/catalog_repo.dart';
import '../data/planning_repo.dart';
import '../data/recurring_repo.dart';
import '../data/settings_repo.dart';
import '../data/templates_repo.dart';
import '../data/transactions_repo.dart';
import '../services/app_info.dart';
import '../services/error_log.dart';
import '../services/file_gateway.dart';
import '../services/location.dart';
import '../services/notifications.dart';
import '../services/security_platform.dart';
import '../services/sms_capture.dart';
import 'reminders.dart';
import 'security_state.dart';
import 'sms_inbox.dart';
import '../services/receipts.dart';

/// Result of turning on Expenses from SMS.
enum SmsEnableResult {
  /// SMS permission denied: still off.
  denied,

  /// On, but notifications are blocked so prompts only reach the review list.
  noNotifications,
  on,
}

/// App-wide state. Repositories are synchronous (SQLite via FFI) and fast;
/// screens re-query when [notifyListeners] fires after a write.
class AppState extends ChangeNotifier {
  AppState({
    required this.db,
    required this.files,
    required this.location,
    ReceiptStore? receipts,
    NotificationService? notifications,
    this.errorLog,
    AppInfo? info,
    DateTime Function()? clock,
    SecurityPlatform? security,
    this.smsPlatform = const SmsPlatform(),
  }) : clock = clock ?? DateTime.now,
       info = info ?? PlatformAppInfo(),
       receipts = receipts ?? PlatformReceiptStore(),
       txns = TransactionsRepo(db),
       catalog = CatalogRepo(db),
       planning = PlanningRepo(db),
       settings = SettingsRepo(db),
       recurring = RecurringRepo(db),
       templates = TemplatesRepo(db) {
    currentCurrency = currencyByCode(settings.get('currency'));
    weekStartDay = parseWeekStart(settings.get('week_start'));
    // Installs from before onboarding existed already have data: skip it.
    if (settings.get('onboarded') == null && db.select('SELECT 1 FROM transactions LIMIT 1').isNotEmpty) settings.set('onboarded', '1');
    final service = notifications ?? NotificationService.none;
    reminders = Reminders(db: db, service: service, clock: this.clock);
    sms = SmsInbox(db: db, service: service, clock: this.clock);
    service.listen(handleNotificationTap);
    this.security = SecurityState(db: db, settings: settings, platform: security ?? SecurityPlatform(), clock: this.clock);
  }

  final Database db;
  final FileGateway files;
  final LocationService location;
  final AppInfo info;

  /// Local crash/error log; null in tests that don't need it.
  final ErrorLog? errorLog;
  final ReceiptStore receipts;
  final DateTime Function() clock;
  final TransactionsRepo txns;
  final CatalogRepo catalog;
  final PlanningRepo planning;
  final SettingsRepo settings;
  final RecurringRepo recurring;
  final TemplatesRepo templates;

  /// Notifications: budget alerts and scheduled reminders.
  late final Reminders reminders;

  /// App lock, app-switcher privacy and database encryption.
  late final SecurityState security;

  /// Bank SMS waiting to be added (Android).
  late final SmsInbox sms;
  final SmsPlatform smsPlatform;

  /// An SMS capture to open in the add form, set when its notification is
  /// tapped; the UI opens it and clears this.
  final smsToOpen = ValueNotifier<SmsCapture?>(null);

  /// Asks for the SMS permission (and notifications for the prompts) and
  /// turns Expenses from SMS on when SMS access is granted.
  Future<SmsEnableResult> enableSms() async {
    if (!await smsPlatform.requestPermission()) return SmsEnableResult.denied;
    final notified = await reminders.service.requestPermission();
    sms.enabled = true;
    changed();
    return notified ? SmsEnableResult.on : SmsEnableResult.noNotifications;
  }

  /// Handles a notification tap (or button) while the app runs.
  Future<void> handleNotificationTap(NotificationTap tap) async {
    final open = await sms.handleTap(tap);
    if (open != null) smsToOpen.value = open;
    changed();
  }

  DateTime now() => clock();

  /// Work done once when the app opens: create due recurring transactions
  /// and drop rows deleted in the last session (with their receipt files).
  Future<void> startup() async {
    recurring.run(now());
    sms.prune();
    await purgeDeleted();
    await reminders.refresh();
    NotificationTap? tap;
    try {
      tap = await reminders.service.launchTap();
    } catch (e, st) {
      errorLog?.record('Could not read the notification that opened the app: $e', st);
    }
    if (tap != null) await handleNotificationTap(tap);
  }

  Future<void> purgeDeleted() async {
    for (final path in txns.purgeDeleted()) {
      await receipts.delete(path);
    }
  }

  /// Call after any write so dependent screens rebuild. Also re-checks budget
  /// alerts and reminders (queued, one run at a time).
  void changed() {
    notifyListeners();
    if (reminders.service.available) _reminderRun = _reminderRun.then((_) => reminders.refresh()).catchError((Object _) {});
  }

  Future<void> _reminderRun = Future.value();

  /// Completes when reminder work queued by [changed] has finished.
  Future<void> get reminderWork => _reminderRun;

  ThemeMode get themeMode => ThemeMode.values.firstWhere((m) => m.name == settings.get('theme'), orElse: () => ThemeMode.system);

  set themeMode(ThemeMode mode) {
    settings.set('theme', mode.name);
    changed();
  }

  String get userName => settings.get('name') ?? '';

  set userName(String name) {
    settings.set('name', name.trim());
    changed();
  }

  /// Whether the first-launch flow has been completed (or skipped).
  bool get onboarded => settings.get('onboarded') == '1';

  void completeOnboarding() {
    settings.set('onboarded', '1');
    changed();
  }

  /// Display currency for all amounts (no conversion).
  Currency get currency => currentCurrency;

  set currency(Currency c) {
    settings.set('currency', c.code);
    currentCurrency = c;
    changed();
  }

  /// First day of the week for weekly budgets and insights.
  int get weekStart => weekStartDay;

  set weekStart(int day) {
    settings.set('week_start', '$day');
    weekStartDay = day;
    changed();
  }

  /// Whether new transactions should capture the current location.
  bool get locationEnabled => settings.get('location') != 'off';

  set locationEnabled(bool on) {
    settings.set('location', on ? 'on' : 'off');
    changed();
  }

  @override
  void dispose() {
    security.dispose();
    smsToOpen.dispose();
    db.close();
    super.dispose();
  }
}

/// Exposes [AppState] to the widget tree.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  /// Reads the state and rebuilds the caller when it changes.
  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Reads the state without subscribing (for callbacks).
  static AppState read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
