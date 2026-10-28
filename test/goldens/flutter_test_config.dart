import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real app fonts so goldens show text and icons instead of the
/// Ahem test font's boxes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final jakarta = FontLoader('PlusJakartaSans');
  for (final w in [400, 500, 600, 700, 800]) {
    jakarta.addFont(rootBundle.load('assets/fonts/PlusJakartaSans-$w.ttf'));
  }
  await jakarta.load();
  final lucide = FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'));
  await lucide.load();
  // Roboto stands in for any widget that doesn't set the app font.
  // Roboto (from the Flutter SDK cache) supplies glyphs Jakarta lacks, like ₹.
  final exe = Platform.resolvedExecutable.replaceAll('\\', '/');
  final cache = exe.substring(0, exe.indexOf('/bin/cache/') + '/bin/cache/'.length);
  final roboto = FontLoader('Roboto');
  for (final f in ['Regular', 'Medium', 'Bold']) {
    final file = File('${cache}artifacts/material_fonts/Roboto-$f.ttf');
    roboto.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await roboto.load();
  await testMain();
}
