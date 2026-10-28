import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

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
import '../services/security_platform.dart';
import 'security_state.dart';
import '../services/receipts.dart';

/// App-wide state. Repositories are synchronous (SQLite via FFI) and fast;
/// screens re-query when [notifyListeners] fires after a write.
class AppState extends ChangeNotifier {
  AppState({required this.db, required this.files, required this.location, ReceiptStore? receipts, this.errorLog, AppInfo? info, DateTime Function()? clock, SecurityPlatform? security})
    : clock = clock ?? DateTime.now,
      info = info ?? PlatformAppInfo(),
      receipts = receipts ?? PlatformReceiptStore(),
      txns = TransactionsRepo(db),
      catalog = CatalogRepo(db),
      planning = PlanningRepo(db),
      settings = SettingsRepo(db),
      recurring = RecurringRepo(db),
      templates = TemplatesRepo(db) {
    currentCurrency = currencyByCode(settings.get('currency'));
    // Installs from before onboarding existed already have data: skip it.
    if (settings.get('onboarded') == null && db.select('SELECT 1 FROM transactions LIMIT 1').isNotEmpty) settings.set('onboarded', '1');
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

  /// App lock, app-switcher privacy and database encryption.
  late final SecurityState security;

  DateTime now() => clock();

  /// Work done once when the app opens: create due recurring transactions
  /// and drop rows deleted in the last session (with their receipt files).
  Future<void> startup() async {
    recurring.run(now());
    await purgeDeleted();
  }

  Future<void> purgeDeleted() async {
    for (final path in txns.purgeDeleted()) {
      await receipts.delete(path);
    }
  }

  /// Call after any write so dependent screens rebuild.
  void changed() => notifyListeners();

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

  /// Whether new transactions should capture the current location.
  bool get locationEnabled => settings.get('location') != 'off';

  set locationEnabled(bool on) {
    settings.set('location', on ? 'on' : 'off');
    changed();
  }

  @override
  void dispose() {
    security.dispose();
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
