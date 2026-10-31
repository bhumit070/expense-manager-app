import 'dart:async';

import 'package:expense_manager/services/location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart' as pi;
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeGeo extends GeolocatorPlatform with MockPlatformInterfaceMixin {
  LocationPermission permission = LocationPermission.whileInUse;
  LocationPermission requested = LocationPermission.whileInUse;
  bool fail = false;
  bool failRequest = false;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    if (failRequest) throw Exception('no');
    return requested;
  }

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    if (fail) throw Exception('timeout');
    return Position(latitude: 12.97159, longitude: 77.64125, timestamp: DateTime(2026), accuracy: 5, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
  }
}

class FakeGeocoding extends pi.Geocoding {
  FakeGeocoding(this.marks, {this.fail = false, this.found = const []}) : super.implementation(const pi.GeocodingCreationParams());

  final List<pi.Placemark> marks;
  final bool fail;
  final List<pi.Location> found;

  @override
  Future<List<pi.Location>> locationFromAddress(String address, {dynamic locale}) async => found;

  @override
  Future<List<pi.Placemark>> placemarkFromCoordinates(double latitude, double longitude, {dynamic locale}) async {
    if (fail) throw Exception('offline');
    return marks;
  }
}

class FakeFactory extends pi.GeocodingPlatformFactory {
  FakeFactory(this.g);

  final pi.Geocoding g;

  @override
  pi.Geocoding createGeocoding(pi.GeocodingCreationParams params) => g;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns a named place when permission is granted', () async {
    final svc = PlatformLocationService(
      geolocator: FakeGeo(),
      reverseGeocode: (a, b) async => const [pi.Placemark(subLocality: 'Indiranagar', locality: 'Bengaluru')],
    );
    final p = (await svc.current())!;
    expect(p.name, 'Indiranagar, Bengaluru');
    expect(p.lat, closeTo(12.97, 0.01));
    expect(p.lng, closeTo(77.64, 0.01));
  });

  test('falls back to coordinates when geocoding is empty, blank or fails', () async {
    for (final g in [
      FakeGeocoding(const []),
      FakeGeocoding(const [pi.Placemark(subLocality: '', locality: null)]),
      FakeGeocoding(const [], fail: true),
    ]) {
      final p = await PlatformLocationService(geolocator: FakeGeo(), reverseGeocode: g.placemarkFromCoordinates).current();
      expect(p!.name, '12.9716, 77.6412');
    }
  });

  test('returns null without permission or when the position fails', () async {
    final geo = FakeGeo()..permission = LocationPermission.denied;
    final svc = PlatformLocationService(geolocator: geo, reverseGeocode: (a, b) async => const []);
    expect(await svc.current(), isNull);
    geo
      ..permission = LocationPermission.always
      ..fail = true;
    expect(await svc.current(), isNull);
  });

  test('requestPermission maps results and errors', () async {
    final geo = FakeGeo();
    final svc = PlatformLocationService(geolocator: geo);
    expect(await svc.requestPermission(), isTrue);
    geo.requested = LocationPermission.deniedForever;
    expect(await svc.requestPermission(), isFalse);
    geo.failRequest = true;
    expect(await svc.requestPermission(), isFalse);
  });

  test('default dependencies: geolocator_apple on iOS, the app channel on Android', () async {
    GeolocatorPlatform.instance = FakeGeo();
    pi.GeocodingPlatformFactory.instance = FakeFactory(FakeGeocoding(const [pi.Placemark(locality: 'Pune')]));
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      expect((await PlatformLocationService().current())!.name, 'Pune');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
    // Android: no channel handler in tests, so the error is swallowed.
    expect(await PlatformLocationService().current(), isNull);
  });

  group('AndroidLocation (LocationManager over a method channel)', () {
    const channel = MethodChannel('expense_manager/location');
    final calls = <String>[];
    Object? Function(String method) reply = (_) => null;
    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return reply(call.method);
      });
    });
    tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

    test('permission maps to whileInUse / denied', () async {
      final loc = AndroidLocation();
      reply = (_) => true;
      expect(await loc.checkPermission(), LocationPermission.whileInUse);
      expect(await loc.requestPermission(), LocationPermission.whileInUse);
      reply = (_) => false;
      expect(await loc.checkPermission(), LocationPermission.denied);
      reply = (_) => null;
      expect(await loc.requestPermission(), LocationPermission.denied);
      expect(calls, ['hasPermission', 'requestPermission', 'hasPermission', 'requestPermission']);
    });

    test('a fix becomes a Position; no fix or a slow one is an error', () async {
      final loc = AndroidLocation();
      reply = (_) => {'lat': 12.97, 'lng': 77.64};
      final p = await loc.getCurrentPosition();
      expect([p.latitude, p.longitude], [12.97, 77.64]);
      reply = (_) => null;
      await expectLater(loc.getCurrentPosition(), throwsA(isA<LocationServiceDisabledException>()));
      reply = (_) => Future<Object?>.delayed(const Duration(seconds: 1), () => {'lat': 1.0, 'lng': 2.0});
      await expectLater(loc.getCurrentPosition(locationSettings: const LocationSettings(timeLimit: Duration(milliseconds: 10))), throwsA(isA<TimeoutException>()));
    });

    test('PlatformLocationService on Android reads the channel', () async {
      reply = (m) => m == 'currentPosition' ? {'lat': 18.52, 'lng': 73.85} : true;
      final svc = PlatformLocationService(reverseGeocode: (a, b) async => const [pi.Placemark(locality: 'Pune')]);
      expect(await svc.requestPermission(), isTrue);
      expect((await svc.current())!.name, 'Pune');
    });
  });

  test('search returns named matches, nothing for blank or failures', () async {
    final svc = PlatformLocationService(
      geolocator: FakeGeo(),
      reverseGeocode: (lat, lng) async => [pi.Placemark(locality: lat > 13 ? 'Hebbal' : 'Koramangala')],
      forwardGeocode: (q) async => q == 'one'
          ? const [pi.Location(latitude: 12.9, longitude: 77.6)]
          : q == 'boom'
          ? throw Exception('offline')
          : const [pi.Location(latitude: 12.9, longitude: 77.6), pi.Location(latitude: 13.1, longitude: 77.5)],
    );
    expect(await svc.search('  '), isEmpty);
    expect((await svc.search('one')).single.name, 'one');
    final two = await svc.search('mall');
    expect(two.map((p) => p.name), ['mall · Koramangala', 'mall · Hebbal']);
    expect(two.last.lat, 13.1);
    expect(await svc.search('boom'), isEmpty);
    expect(await svc.describe(1, 2), 'Koramangala');
    expect(coordinates(12.971599, 77.6), '12.9716, 77.6000');
  });

  test('default forward geocoder uses the platform instance', () async {
    pi.GeocodingPlatformFactory.instance = FakeFactory(FakeGeocoding(const [pi.Placemark(locality: 'Pune')], found: const [pi.Location(latitude: 18.5, longitude: 73.8)]));
    expect((await PlatformLocationService(geolocator: FakeGeo()).search('fc road')).single.lat, 18.5);
  });
}
