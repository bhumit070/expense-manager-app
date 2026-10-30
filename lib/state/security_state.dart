import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../l10n/l10n.dart';
import '../data/settings_repo.dart';
import '../services/security_platform.dart';

enum PinResult { ok, wrong, coolingDown }

/// App lock (PIN + optional biometrics), app-switcher privacy and opt-in
/// database encryption. Settings live in the settings table; the database key
/// lives in the platform key store.
class SecurityState extends ChangeNotifier {
  SecurityState({required this.db, required this.settings, required this.platform, required this.clock, Random? random}) : _random = random ?? Random.secure() {
    _locked = lockEnabled;
  }

  final Database db;
  final SettingsRepo settings;
  final SecurityPlatform platform;
  final DateTime Function() clock;
  final Random _random;

  /// Choices offered for "lock after".
  static const timeouts = [Duration.zero, Duration(seconds: 30), Duration(minutes: 1), Duration(minutes: 5)];

  /// Wrong PINs allowed before a cooldown.
  static const maxAttempts = 5;
  static const cooldown = Duration(seconds: 30);
  static const _hashRounds = 20000;

  late bool _locked;
  DateTime? _backgroundAt;

  static bool validPin(String pin) => RegExp(r'^\d{4,6}$').hasMatch(pin);

  bool get lockEnabled => (settings.get('lock_pin') ?? '').isNotEmpty;

  /// True while the lock screen must cover the app.
  bool get locked => _locked && lockEnabled;

  bool get biometricsOn => settings.get('lock_bio') == 'on';

  set biometricsOn(bool on) {
    settings.set('lock_bio', on ? 'on' : 'off');
    notifyListeners();
  }

  Duration get timeout => Duration(seconds: int.tryParse(settings.get('lock_timeout') ?? '') ?? 0);

  set timeout(Duration d) {
    settings.set('lock_timeout', '${d.inSeconds}');
    notifyListeners();
  }

  bool get hideInSwitcher => settings.get('hide_switcher') != 'off';

  set hideInSwitcher(bool on) {
    settings.set('hide_switcher', on ? 'on' : 'off');
    applyWindow();
    notifyListeners();
  }

  Future<void> applyWindow() => platform.window.setSecure(hideInSwitcher);

  Future<bool> biometricsAvailable() => platform.biometrics.available();

  String _hex(int bytes) => [for (var i = 0; i < bytes; i++) _random.nextInt(256).toRadixString(16).padLeft(2, '0')].join();

  static String _hash(String salt, String pin) {
    var digest = sha256.convert(utf8.encode('$salt:$pin')).bytes;
    for (var i = 1; i < _hashRounds; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64.encode(digest);
  }

  /// Turns the lock on (or changes the PIN). Only a salted hash is stored.
  void setPin(String pin) {
    if (!validPin(pin)) throw ArgumentError.value(pin, 'pin', 'must be 4–6 digits');
    final salt = _hex(16);
    settings.set('lock_pin', '$salt:${_hash(salt, pin)}');
    _resetAttempts();
    _locked = false;
    notifyListeners();
  }

  /// Turns the lock off and forgets the PIN.
  void disableLock() {
    settings.set('lock_pin', '');
    settings.set('lock_bio', 'off');
    _resetAttempts();
    _locked = false;
    notifyListeners();
  }

  int get failedAttempts => int.tryParse(settings.get('lock_failures') ?? '') ?? 0;

  /// Time left before another PIN may be tried.
  Duration get cooldownLeft {
    final until = int.tryParse(settings.get('lock_until') ?? '') ?? 0;
    final left = until - clock().millisecondsSinceEpoch;
    return left > 0 ? Duration(milliseconds: left) : Duration.zero;
  }

  void _resetAttempts() {
    settings.set('lock_failures', '0');
    settings.set('lock_until', '0');
  }

  /// Checks [pin]; a correct one unlocks the app.
  PinResult checkPin(String pin) {
    if (cooldownLeft > Duration.zero) return PinResult.coolingDown;
    final parts = (settings.get('lock_pin') ?? '').split(':');
    if (parts.length == 2 && _hash(parts[0], pin) == parts[1]) {
      _resetAttempts();
      _locked = false;
      notifyListeners();
      return PinResult.ok;
    }
    final failures = failedAttempts + 1;
    if (failures >= maxAttempts) {
      settings.set('lock_failures', '0');
      settings.set('lock_until', '${clock().add(cooldown).millisecondsSinceEpoch}');
    } else {
      settings.set('lock_failures', '$failures');
    }
    notifyListeners();
    return PinResult.wrong;
  }

  /// Unlocks with fingerprint / face when the user turned that on.
  Future<bool> unlockWithBiometrics() async {
    if (!lockEnabled || !biometricsOn) return false;
    final ok = await platform.biometrics.authenticate(currentL10n.unlockPrompt);
    if (ok) {
      _resetAttempts();
      _locked = false;
      notifyListeners();
    }
    return ok;
  }

  /// Call when the app goes to the background.
  void wentToBackground() => _backgroundAt ??= clock();

  /// Call when the app is back; locks if it was away for [timeout] or longer.
  void cameToForeground() {
    final since = _backgroundAt;
    _backgroundAt = null;
    if (since == null || !lockEnabled || _locked) return;
    if (clock().difference(since) >= timeout) {
      _locked = true;
      notifyListeners();
    }
  }

  /// Only on-disk databases can be encrypted.
  bool get canEncrypt => db.select('PRAGMA database_list').any((r) => r['name'] == 'main' && (r['file'] as String? ?? '').isNotEmpty);

  bool get encrypted => settings.get('db_encrypted') == 'on';

  void _rekey(String key) {
    // SQLite3 Multiple Ciphers cannot rekey a database in WAL mode.
    db.execute('PRAGMA journal_mode = DELETE');
    try {
      db.select("PRAGMA rekey = '$key'");
    } finally {
      db.execute('PRAGMA journal_mode = WAL');
    }
  }

  /// Encrypts the database with a random key kept in the platform key store.
  /// The key is saved first so a crash mid-way cannot lose it.
  Future<void> encryptDatabase() async {
    final key = _hex(32);
    await platform.keys.write(key);
    try {
      _rekey(key);
    } catch (_) {
      await platform.keys.delete();
      rethrow;
    }
    settings.set('db_encrypted', 'on');
    notifyListeners();
  }

  /// Decrypts the database back to plain SQLite and forgets the key.
  Future<void> decryptDatabase() async {
    _rekey('');
    settings.set('db_encrypted', 'off');
    await platform.keys.delete();
    notifyListeners();
  }
}
