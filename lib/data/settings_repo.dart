import 'package:sqlite3/sqlite3.dart';

/// Key-value app settings.
class SettingsRepo {
  SettingsRepo(this.db);

  final Database db;

  String? get(String key) {
    final r = db.select('SELECT value FROM settings WHERE key = ?', [key]);
    return r.isEmpty ? null : r.first['value'] as String;
  }

  void set(String key, String value) => db.execute('INSERT INTO settings(key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value', [key, value]);
}
