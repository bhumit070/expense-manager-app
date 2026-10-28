import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/database.dart';
import 'services/file_gateway.dart';
import 'services/location.dart';
import 'services/receipts.dart';
import 'state/app_state.dart';

/// Opens the on-device database and builds the app state.
Future<AppState> bootstrap() async {
  final dir = await getApplicationDocumentsDirectory();
  final db = openAppDatabase(p.join(dir.path, 'expense_manager.db'));
  final state = AppState(db: db, files: PlatformFileGateway(), location: PlatformLocationService(), receipts: PlatformReceiptStore());
  await state.startup();
  return state;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ExpenseApp(state: await bootstrap()));
}
