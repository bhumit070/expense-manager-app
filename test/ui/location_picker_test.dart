import 'dart:async';

import 'package:expense_manager/services/location.dart';
import 'package:expense_manager/ui/screens/location_picker_screen.dart';
import 'package:expense_manager/ui/widgets/map_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';
import 'package:expense_manager/ui/theme/icons.dart';

/// Opens the picker from a button and records what it pops with.
Future<List<Place?>> openPicker(WidgetTester tester, FakeLocation loc, {Place? initial}) async {
  final popped = <Place?>[];
  final s = makeState(location: loc);
  await pumpScreen(
    tester,
    s,
    Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async => popped.add(await Navigator.of(context).push<Place>(MaterialPageRoute(builder: (_) => LocationPickerScreen(initial: initial)))),
          child: const Text('open'),
        ),
      ),
    ),
  );
  tester.view.physicalSize = const Size(1170, 2532);
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return popped;
}

void main() {
  test('network tiles by default', () {
    expect(mapTileProvider(), isA<NetworkTileProvider>());
    expect(osmTileUrl, contains('openstreetmap'));
  });

  group('LocationPickerScreen', () {
    setUp(() => mapTileProvider = FakeTiles.new);

    testWidgets('search, pick a result, rename and confirm', (tester) async {
      final loc = FakeLocation()..results['mg road'] = const [Place(name: 'MG Road · Bengaluru', lat: 12.975, lng: 77.606), Place(name: 'MG Road · Pune', lat: 18.5, lng: 73.8)];
      final popped = await openPicker(tester, loc);
      expect(tester.widget<TextButton>(find.byKey(const Key('confirm-place'))).onPressed, isNull);
      expect(find.text('Tap the map to drop a pin'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('place-search')), 'nowhere');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('No matches. Try another name, or tap the map.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('place-search')), 'mg road');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('18.5000, 73.8000'), findsOneWidget);
      await tester.tap(find.byKey(const Key('result-0')));
      await tester.pumpAndSettle();
      expect(find.byIcon(AppIcons.locationPin), findsOneWidget);
      expect(find.text('12.9750, 77.6060'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('place-name')), '  ');
      await tester.tap(find.byKey(const Key('confirm-place')));
      await tester.pumpAndSettle();
      expect([popped.single!.name, popped.single!.lat], ['12.9750, 77.6060', 12.975]);
    });

    testWidgets('tapping the map drops a pin named by reverse geocoding', (tester) async {
      final popped = await openPicker(tester, FakeLocation(), initial: const Place(name: 'Home', lat: 12.9, lng: 77.6));
      expect(tester.widget<TextField>(find.byKey(const Key('place-name'))).controller!.text, 'Home');
      await tester.tapAt(tester.getCenter(find.byType(FlutterMap)) + const Offset(0, 60));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      final name = tester.widget<TextField>(find.byKey(const Key('place-name'))).controller!.text;
      expect(name, startsWith('Pin 12.'));
      await tester.tap(find.byKey(const Key('confirm-place')));
      await tester.pumpAndSettle();
      expect(popped.single!.name, name);
      expect(popped.single!.lat, lessThan(12.9));
    });

    testWidgets('use current location asks for permission when needed', (tester) async {
      final loc = FakeLocation();
      final popped = await openPicker(tester, loc);
      // no fix and permission refused
      loc.grant = false;
      await tester.tap(find.byKey(const Key('use-current')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Current location unavailable'), findsOneWidget);
      expect(loc.requests, 1);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      // fix available straight away
      loc.place = const Place(name: 'Office', lat: 12.93, lng: 77.62);
      await tester.tap(find.byKey(const Key('use-current')));
      await tester.pumpAndSettle();
      expect(loc.requests, 1);
      expect(tester.widget<TextField>(find.byKey(const Key('place-name'))).controller!.text, 'Office');
      await tester.tap(find.byKey(const Key('confirm-place')));
      await tester.pumpAndSettle();
      expect(popped.single!.name, 'Office');
    });

    testWidgets('permission granted on request gives a fix; leaving early is safe', (tester) async {
      final loc = _GrantThenLocate();
      await openPicker(tester, loc);
      await tester.tap(find.byKey(const Key('use-current')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byKey(const Key('place-name'))).controller!.text, 'After grant');

      await tester.enterText(find.byKey(const Key('place-search')), 'slow');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pageBack();
      await tester.pumpAndSettle();
      loc.slow.complete(const []);
      await tester.pump();
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('leaving while locating or naming a pin is safe', (tester) async {
      final loc = _GrantThenLocate()..hold = true;
      await openPicker(tester, loc);
      await tester.tap(find.byKey(const Key('use-current')));
      await tester.pump();
      await tester.pageBack();
      await tester.pumpAndSettle();
      loc.held.complete(null);
      await tester.pump();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      loc.holdDescribe = true;
      await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pageBack();
      await tester.pumpAndSettle();
      loc.describing.complete('late');
      await tester.pump();
      expect(find.text('open'), findsOneWidget);
    });
  });
}

class _GrantThenLocate extends FakeLocation {
  bool granted = false;
  bool hold = false;
  bool holdDescribe = false;
  final held = Completer<Place?>();
  final slow = Completer<List<Place>>();
  final describing = Completer<String>();

  @override
  Future<Place?> current() async {
    if (hold) return held.future;
    return granted ? const Place(name: 'After grant', lat: 1, lng: 2) : null;
  }

  @override
  Future<bool> requestPermission() async => granted = true;

  @override
  Future<List<Place>> search(String query) => slow.future;

  @override
  Future<String> describe(double lat, double lng) => holdDescribe ? describing.future : super.describe(lat, lng);
}
