import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';
import 'app_localizations_en.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// Localized strings; falls back to [l10n] where no delegate is installed
  /// (e.g. a bare widget under test).
  AppLocalizations get l10n => Localizations.of<AppLocalizations>(this, AppLocalizations) ?? currentL10n;
}

/// A language offered in Settings, named in its own script.
class AppLanguage {
  const AppLanguage(this.code, this.name);

  final String code;
  final String name;
}

const appLanguages = [AppLanguage('en', 'English'), AppLanguage('fr', 'Français'), AppLanguage('ja', '日本語'), AppLanguage('hi', 'हिन्दी'), AppLanguage('gu', 'ગુજરાતી'), AppLanguage('or', 'ଓଡ଼ିଆ')];

/// Strings for code that has no [BuildContext] (notifications, exports,
/// date labels). Set by `AppState` from the chosen or device language.
AppLocalizations currentL10n = AppLocalizationsEn();

/// The language for a stored choice: [code] when supported, otherwise the
/// device's language when supported, otherwise English.
Locale resolveLocale(String? code, [List<Locale>? device]) {
  bool ok(String? c) => appLanguages.any((l) => l.code == c);
  if (ok(code)) return Locale(code!);
  for (final l in device ?? PlatformDispatcher.instance.locales) {
    if (ok(l.languageCode)) return Locale(l.languageCode);
  }
  return const Locale('en');
}

/// Points [currentL10n] and `intl` date formatting at [locale].
void applyLocale(Locale locale) {
  currentL10n = lookupAppLocalizations(locale);
  Intl.defaultLocale = locale.languageCode;
  initializeDateFormatting(locale.languageCode);
}
