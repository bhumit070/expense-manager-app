import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

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
}

class PlatformLocationService implements LocationService {
  PlatformLocationService({GeolocatorPlatform? geolocator, Future<List<geo.Placemark>> Function(double lat, double lng)? reverseGeocode})
    : _geo = geolocator ?? GeolocatorPlatform.instance,
      _reverse = reverseGeocode ?? ((lat, lng) => geo.Geocoding().placemarkFromCoordinates(lat, lng));

  final GeolocatorPlatform _geo;
  final Future<List<geo.Placemark>> Function(double lat, double lng) _reverse;

  static bool _granted(LocationPermission p) => p == LocationPermission.always || p == LocationPermission.whileInUse;

  @override
  Future<Place?> current() async {
    try {
      if (!_granted(await _geo.checkPermission())) return null;
      final pos = await _geo.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 8)),
      );
      var name = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      try {
        final marks = await _reverse(pos.latitude, pos.longitude);
        if (marks.isNotEmpty) {
          final m = marks.first;
          final parts = [m.subLocality, m.locality].whereType<String>().where((e) => e.isNotEmpty).toList();
          if (parts.isNotEmpty) name = parts.join(', ');
        }
      } catch (_) {
        // Reverse geocoding is best-effort; keep coordinates.
      }
      return Place(name: name, lat: pos.latitude, lng: pos.longitude);
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
}
