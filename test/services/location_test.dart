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
  FakeGeocoding(this.marks, {this.fail = false}) : super.implementation(const pi.GeocodingCreationParams());

  final List<pi.Placemark> marks;
  final bool fail;

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
}
