import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds licenses of bundled assets (not covered by pub packages) to the
/// "Open-source licenses" page.
void registerAssetLicenses({AssetBundle? bundle}) {
  LicenseRegistry.addLicense(() async* {
    final text = await (bundle ?? rootBundle).loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Plus Jakarta Sans (font)'], text);
  });
}
