import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'app_localizations_en.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// Localized strings; falls back to English where no delegate is installed
  /// (e.g. a bare widget under test).
  AppLocalizations get l10n => Localizations.of<AppLocalizations>(this, AppLocalizations) ?? AppLocalizationsEn();
}
