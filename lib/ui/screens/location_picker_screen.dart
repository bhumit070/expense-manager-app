import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/location.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/map_tiles.dart';
import '../theme/icons.dart';

/// Manual location picker: search an address, tap the map or use the
/// current position. Pops with the chosen [Place].
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initial});

  final Place? initial;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _india = LatLng(20.5937, 78.9629);

  final _map = MapController();
  final _query = TextEditingController();
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late LatLng? _point = widget.initial == null ? null : LatLng(widget.initial!.lat, widget.initial!.lng);
  List<Place> _results = const [];
  bool _busy = false;
  bool _searched = false;

  @override
  void dispose() {
    _query.dispose();
    _name.dispose();
    super.dispose();
  }

  void _select(Place p) {
    setState(() {
      _point = LatLng(p.lat, p.lng);
      _name.text = p.name;
      _results = const [];
    });
    _map.move(_point!, 15);
  }

  Future<void> _search(AppState app) async {
    setState(() => _busy = true);
    final found = await app.location.search(_query.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _searched = true;
      _results = found;
    });
  }

  Future<void> _tapMap(AppState app, LatLng at) async {
    setState(() => _point = at);
    final name = await app.location.describe(at.latitude, at.longitude);
    if (mounted) setState(() => _name.text = name);
  }

  Future<void> _useCurrent(AppState app) async {
    setState(() => _busy = true);
    var place = await app.location.current();
    if (place == null && await app.location.requestPermission()) place = await app.location.current();
    if (!mounted) return;
    setState(() => _busy = false);
    if (place == null) {
      showSnack(context, 'Current location unavailable. Allow location access or search instead.');
    } else {
      _select(place);
    }
  }

  void _confirm() {
    final p = _point!;
    final name = _name.text.trim();
    Navigator.pop(context, Place(name: name.isEmpty ? coordinates(p.latitude, p.longitude) : name, lat: p.latitude, lng: p.longitude));
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick location', style: ts(16, weight: FontWeight.w700)),
        actions: [TextButton(key: const Key('confirm-place'), onPressed: _point == null ? null : _confirm, child: const Text('Done'))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              key: const Key('place-search'),
              controller: _query,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(app),
              decoration: InputDecoration(
                hintText: 'Search a place or address',
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: _busy
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : null,
              ),
            ),
          ),
          if (_results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (i, p) in _results.indexed)
                    ListTile(
                      key: Key('result-$i'),
                      leading: const Icon(AppIcons.place),
                      title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(coordinates(p.lat, p.lng), style: ts(11, color: c.textMuted)),
                      onTap: () => _select(p),
                    ),
                ],
              ),
            )
          else if (_searched)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('No matches. Try another name, or tap the map.', style: ts(12, color: c.textMuted)),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(initialCenter: _point ?? _india, initialZoom: _point == null ? 4 : 15, onTap: (_, at) => _tapMap(app, at)),
              children: [
                TileLayer(urlTemplate: osmTileUrl, userAgentPackageName: mapUserAgent, tileProvider: mapTileProvider()),
                if (_point != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _point!,
                        width: 40,
                        height: 40,
                        alignment: Alignment.topCenter,
                        child: Icon(AppIcons.locationPin, color: c.spend, size: 40),
                      ),
                    ],
                  ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    color: c.surface.withValues(alpha: 0.85),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text('© OpenStreetMap contributors', style: ts(10, color: c.textMuted)),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('place-name'),
                    controller: _name,
                    decoration: InputDecoration(labelText: 'Place name', helperText: _point == null ? 'Tap the map to drop a pin' : coordinates(_point!.latitude, _point!.longitude)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('use-current'),
                    onPressed: _busy ? null : () => _useCurrent(app),
                    icon: const Icon(AppIcons.myLocation),
                    label: const Text('Use current location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
