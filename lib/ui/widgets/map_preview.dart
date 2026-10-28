import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/maps.dart';
import '../theme/tokens.dart';
import '../theme/icons.dart';

/// Static (non-interactive) map with a pin. Tap opens the maps app.
class MapPreview extends StatelessWidget {
  const MapPreview({super.key, required this.lat, required this.lng, this.label, this.height = 160, this.zoom = 15});

  final double lat;
  final double lng;
  final String? label;
  final double height;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final maps = MapServices.instance;
    final point = LatLng(lat, lng);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: zoom,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                backgroundColor: c.surfaceMuted,
              ),
              children: [
                TileLayer(urlTemplate: MapServices.tileUrl, userAgentPackageName: MapServices.userAgent, tileProvider: maps.tileProvider()),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 36,
                      height: 36,
                      alignment: Alignment.topCenter,
                      child: Icon(AppIcons.locationPin, size: 36, color: c.spend),
                    ),
                  ],
                ),
              ],
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  key: const Key('map-preview'),
                  onTap: () => maps.openInMaps(lat, lng, label: label),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: c.surface.withValues(alpha: 0.85),
                child: Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 10, color: c.textMuted)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
