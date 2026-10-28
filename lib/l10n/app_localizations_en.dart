// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expense Manager';

  @override
  String get navHome => 'Home';

  @override
  String get navInsights => 'Insights';

  @override
  String get navInvest => 'Invest';

  @override
  String get navDebts => 'Debts';

  @override
  String get addTransaction => 'Add transaction';
}
