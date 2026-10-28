import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/licenses.dart';
import 'data/database.dart';
import 'services/file_gateway.dart';
import 'services/location.dart';
import 'state/app_state.dart';

/// Opens the on-device database and builds the app state.
Future<AppState> bootstrap() async {
  final dir = await getApplicationDocumentsDirectory();
  final db = openAppDatabase(p.join(dir.path, 'expense_manager.db'));
  return AppState(db: db, files: PlatformFileGateway(), location: PlatformLocationService());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerAssetLicenses();
  runApp(ExpenseApp(state: await bootstrap()));
}
