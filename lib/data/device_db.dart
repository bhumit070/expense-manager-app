import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../core/flavor.dart';
import '../services/security_platform.dart';
import 'database.dart';

/// Opens this flavor's on-device database, decrypting it with the stored key
/// when encryption is on. Used by the app and by the background task.
Future<Database> openDeviceDatabase({Flavor? flavor, KeyStore? keys}) async {
  final dir = await getApplicationDocumentsDirectory();
  return openAppDatabase(p.join(dir.path, databaseFileName(flavor ?? currentFlavor)), key: await (keys ?? SecureKeyStore()).read());
}
