import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/flavor.dart';
import 'core/licenses.dart';
import 'data/database.dart';
import 'services/error_log.dart';
import 'services/file_gateway.dart';
import 'services/location.dart';
import 'services/security_platform.dart';
import 'services/receipts.dart';
import 'state/app_state.dart';

/// Opens the on-device database and builds the app state.
Future<AppState> bootstrap({Flavor? flavor}) async {
  final dir = await getApplicationDocumentsDirectory();
  final keys = SecureKeyStore();
  final db = openAppDatabase(p.join(dir.path, databaseFileName(flavor ?? currentFlavor)), key: await keys.read());
  final log = ErrorLog(File(p.join(dir.path, 'logs', 'errors.log')));
  final state = AppState(
    db: db,
    files: PlatformFileGateway(),
    location: PlatformLocationService(),
    errorLog: log,
    receipts: PlatformReceiptStore(),
    security: SecurityPlatform(biometrics: PlatformBiometrics(), keys: keys),
  );
  await state.startup();
  return state;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerAssetLicenses();
  final state = await bootstrap();
  state.errorLog!.install();
  runApp(ExpenseApp(state: state));
}
