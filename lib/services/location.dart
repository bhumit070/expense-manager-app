import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

class Place {
  const Place({required this.name, required this.lat, required this.lng});

  final String name;
  final double lat;
  final double lng;
}

/// Current location for new transactions. Only used when the user has
/// already granted permission; otherwise the place stays optional/manual.
abstract class LocationService {
  Future<Place?> current();

  /// Asks the OS for permission (from Settings). Returns true if granted.
  Future<bool> requestPermission();

  /// Places matching an address or landmark, for the manual picker.
  Future<List<Place>> search(String query);

  /// A readable name for coordinates picked on the map.
  Future<String> describe(double lat, double lng);
}

String coordinates(double lat, double lng) => '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';

class PlatformLocationService implements LocationService {
  PlatformLocationService({
    GeolocatorPlatform? geolocator,
    Future<List<geo.Placemark>> Function(double lat, double lng)? reverseGeocode,
    Future<List<geo.Location>> Function(String query)? forwardGeocode,
  }) : _geo = geolocator ?? (defaultTargetPlatform == TargetPlatform.android ? AndroidLocation() : GeolocatorPlatform.instance),
       _reverse = reverseGeocode ?? ((lat, lng) => geo.Geocoding().placemarkFromCoordinates(lat, lng)),
       _forward = forwardGeocode ?? ((q) => geo.Geocoding().locationFromAddress(q));

  final GeolocatorPlatform _geo;
  final Future<List<geo.Placemark>> Function(double lat, double lng) _reverse;
  final Future<List<geo.Location>> Function(String query) _forward;

  static bool _granted(LocationPermission p) => p == LocationPermission.always || p == LocationPermission.whileInUse;

  @override
  Future<Place?> current() async {
    try {
      if (!_granted(await _geo.checkPermission())) return null;
      final pos = await _geo.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 8)),
      );
      return Place(name: await describe(pos.latitude, pos.longitude), lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      return _granted(await _geo.requestPermission());
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> describe(double lat, double lng) async {
    try {
      final marks = await _reverse(lat, lng);
      if (marks.isNotEmpty) {
        final m = marks.first;
        final parts = [m.subLocality, m.locality].whereType<String>().where((e) => e.isNotEmpty).toList();
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {
      // Reverse geocoding is best-effort; keep coordinates.
    }
    return coordinates(lat, lng);
  }

  @override
  Future<List<Place>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    try {
      final found = await _forward(q);
      return [for (final l in found.take(5)) Place(name: found.length == 1 ? q : '$q · ${await describe(l.latitude, l.longitude)}', lat: l.latitude, lng: l.longitude)];
    } catch (_) {
      return const [];
    }
  }
}

/// Location on Android from the platform LocationManager (MainActivity.kt),
/// so the app has no Google Play services dependency. iOS uses
/// geolocator_apple.
class AndroidLocation extends GeolocatorPlatform {
  AndroidLocation([this.channel = const MethodChannel('expense_manager/location')]);

  final MethodChannel channel;

  static LocationPermission _permission(bool? granted) => granted == true ? LocationPermission.whileInUse : LocationPermission.denied;

  @override
  Future<LocationPermission> checkPermission() async => _permission(await channel.invokeMethod<bool>('hasPermission'));

  @override
  Future<LocationPermission> requestPermission() async => _permission(await channel.invokeMethod<bool>('requestPermission'));

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    var call = channel.invokeMapMethod<String, double>('currentPosition');
    final limit = locationSettings?.timeLimit;
    if (limit != null) call = call.timeout(limit);
    final fix = await call;
    if (fix == null) throw const LocationServiceDisabledException();
    return Position(
      latitude: fix['lat']!,
      longitude: fix['lng']!,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}
