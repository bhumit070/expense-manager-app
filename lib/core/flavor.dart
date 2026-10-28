import 'package:flutter/services.dart' as services;

/// Build environment. Android picks it with `--flavor dev|prod`; iOS (no
/// Xcode schemes) and desktop use `--dart-define=FLAVOR=dev`. Defaults to prod.
enum Flavor { dev, prod }

/// Resolves the flavor from Flutter's `--flavor` value, then the dart-define.
Flavor resolveFlavor({String? buildFlavor, String define = const String.fromEnvironment('FLAVOR')}) {
  final raw = (buildFlavor == null || buildFlavor.isEmpty) ? define : buildFlavor;
  return raw.toLowerCase() == 'dev' ? Flavor.dev : Flavor.prod;
}

/// The flavor this build was compiled with.
final Flavor currentFlavor = resolveFlavor(buildFlavor: services.appFlavor);

/// Separate databases so dev and prod data never mix on one device.
String databaseFileName(Flavor f) => f == Flavor.dev ? 'expense_manager_dev.db' : 'expense_manager.db';
