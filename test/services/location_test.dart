import 'package:expense_manager/services/location.dart';
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

  test('default dependencies use the platform instances', () async {
    GeolocatorPlatform.instance = FakeGeo();
    pi.GeocodingPlatformFactory.instance = FakeFactory(FakeGeocoding(const [pi.Placemark(locality: 'Pune')]));
    expect((await PlatformLocationService().current())!.name, 'Pune');
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
