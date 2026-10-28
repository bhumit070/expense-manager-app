import 'package:package_info_plus/package_info_plus.dart';

/// App name/version for the About section.
abstract class AppInfo {
  /// E.g. `0.1.0 (5)`.
  Future<String> version();
}

class PlatformAppInfo implements AppInfo {
  PlatformAppInfo({Future<PackageInfo> Function()? load}) : _load = load ?? PackageInfo.fromPlatform;

  final Future<PackageInfo> Function() _load;

  @override
  Future<String> version() async {
    final p = await _load();
    return p.buildNumber.isEmpty ? p.version : '${p.version} (${p.buildNumber})';
  }
}
