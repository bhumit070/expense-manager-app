import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

import '../core/money.dart';
import '../data/catalog_repo.dart';
import '../data/planning_repo.dart';
import '../data/settings_repo.dart';
import '../data/transactions_repo.dart';
import '../services/app_info.dart';
import '../services/file_gateway.dart';
import '../services/location.dart';

/// App-wide state. Repositories are synchronous (SQLite via FFI) and fast;
/// screens re-query when [notifyListeners] fires after a write.
class AppState extends ChangeNotifier {
  AppState({required this.db, required this.files, required this.location, AppInfo? info, DateTime Function()? clock})
    : clock = clock ?? DateTime.now,
      info = info ?? PlatformAppInfo(),
      txns = TransactionsRepo(db),
      catalog = CatalogRepo(db),
      planning = PlanningRepo(db),
      settings = SettingsRepo(db) {
    currentCurrency = currencyByCode(settings.get('currency'));
  }

  final Database db;
  final FileGateway files;
  final LocationService location;
  final AppInfo info;
  final DateTime Function() clock;
  final TransactionsRepo txns;
  final CatalogRepo catalog;
  final PlanningRepo planning;
  final SettingsRepo settings;

  DateTime now() => clock();

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
