import 'package:flutter_map/flutter_map.dart';

/// OpenStreetMap raster tiles; the only network use in the app (optional).
const osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

const mapUserAgent = 'com.bhumit070.expense_manager';

/// Creates the tile provider for map views. Tests swap in an offline one.
TileProvider Function() mapTileProvider = NetworkTileProvider.new;
