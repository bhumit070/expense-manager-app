import 'package:expense_manager/services/app_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

PackageInfo _info(String build) => PackageInfo(appName: 'Expense Manager', packageName: 'x', version: '0.1.0', buildNumber: build);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('version includes the build number when present', () async {
    expect(await PlatformAppInfo(load: () async => _info('5')).version(), '0.1.0 (5)');
    expect(await PlatformAppInfo(load: () async => _info('')).version(), '0.1.0');
  });

  test('defaults to the platform package info', () async {
    PackageInfo.setMockInitialValues(appName: 'a', packageName: 'b', version: '2.0.0', buildNumber: '7', buildSignature: '');
    expect(await PlatformAppInfo().version(), '2.0.0 (7)');
  });
}
