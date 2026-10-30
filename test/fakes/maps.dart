import 'dart:typed_data';

import 'package:expense_manager/services/maps.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

/// 1×1 transparent PNG so map tiles never hit the network.
final kTransparentPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, //
  0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, //
  0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class FakeTileProvider extends TileProvider {
  int requests = 0;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    requests++;
    return MemoryImage(kTransparentPng);
  }
}

class FakeMapServices extends MapServices {
  final tiles = FakeTileProvider();
  final opened = <(double, double, String?)>[];
  final links = <Uri>[];

  @override
  TileProvider tileProvider() => tiles;

  @override
  Future<bool> openInMaps(double lat, double lng, {String? label}) async {
    opened.add((lat, lng, label));
    return true;
  }

  @override
  Future<bool> openExternal(Uri uri) async {
    links.add(uri);
    return true;
  }
}

/// Installs [FakeMapServices] for one test and restores the real one after.
FakeMapServices useFakeMaps(void Function(void Function()) addTearDown) {
  final fake = FakeMapServices();
  final real = MapServices.instance;
  MapServices.instance = fake;
  addTearDown(() => MapServices.instance = real);
  return fake;
}
