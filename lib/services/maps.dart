import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

/// Map tiles and the external maps app, swappable in tests so they never
/// touch the network or the platform.
class MapServices {
  /// Map tiles are the only network use in the app (OpenStreetMap).
  static const tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const userAgent = 'com.bhumit070.expense_manager';

  static MapServices instance = MapServices();

  TileProvider tileProvider() => NetworkTileProvider();

  /// Opens [lat],[lng] in the device's maps app, falling back to the
  /// OpenStreetMap website. Returns whether anything opened.
  Future<bool> openInMaps(double lat, double lng, {String? label}) async {
    final name = Uri.encodeComponent(label ?? '$lat,$lng');
    final native = defaultTargetPlatform == TargetPlatform.iOS ? Uri.parse('https://maps.apple.com/?ll=$lat,$lng&q=$name') : Uri.parse('geo:$lat,$lng?q=$lat,$lng($name)');
    final web = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=17/$lat/$lng');
    for (final uri in [native, web]) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return true;
      } on Exception {
        // No handler for this scheme; try the next one.
      }
    }
    return false;
  }
}
