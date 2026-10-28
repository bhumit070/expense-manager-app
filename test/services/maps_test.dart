import 'package:expense_manager/services/maps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class FakeLauncher extends UrlLauncherPlatform with MockPlatformInterfaceMixin {
  /// Result per URL scheme; a missing scheme throws like a missing handler.
  final results = <String, bool>{};
  final launched = <(String, PreferredLaunchMode)>[];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add((url, options.mode));
    final r = results[Uri.parse(url).scheme];
    if (r == null) throw Exception('no handler');
    return r;
  }
}

void main() {
  late FakeLauncher launcher;
  setUp(() {
    launcher = FakeLauncher();
    UrlLauncherPlatform.instance = launcher;
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('real tiles come from the network provider', () {
    expect(MapServices().tileProvider(), isA<NetworkTileProvider>());
    expect(MapServices.instance, isA<MapServices>());
  });

  test('Android opens a geo: link in an external app', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    launcher.results['geo'] = true;
    expect(await MapServices().openInMaps(12.97, 77.64, label: 'Indiranagar'), isTrue);
    expect(launcher.launched.single, ('geo:12.97,77.64?q=12.97,77.64(Indiranagar)', PreferredLaunchMode.externalApplication));
  });

  test('iOS opens Apple Maps; falls back to OpenStreetMap; reports failure', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    launcher.results['https'] = false;
    expect(await MapServices().openInMaps(1.5, 2.5), isFalse);
    expect(launcher.launched.map((e) => e.$1), ['https://maps.apple.com/?ll=1.5,2.5&q=1.5%2C2.5', 'https://www.openstreetmap.org/?mlat=1.5&mlon=2.5#map=17/1.5/2.5']);

    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    launcher
      ..launched.clear()
      ..results['https'] = true;
    expect(await MapServices().openInMaps(1.5, 2.5), isTrue); // geo: throws, web works
    expect(launcher.launched.length, 2);
  });
}
