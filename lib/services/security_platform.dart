import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Fingerprint / face unlock.
abstract class Biometrics {
  Future<bool> available();
  Future<bool> authenticate(String reason);
}

class PlatformBiometrics implements Biometrics {
  PlatformBiometrics([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> available() async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, biometricOnly: true, persistAcrossBackgrounding: true);
    } on LocalAuthException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

/// Used when the platform has no biometrics wired up (and in tests).
class NoBiometrics implements Biometrics {
  const NoBiometrics();

  @override
  Future<bool> available() async => false;

  @override
  Future<bool> authenticate(String reason) async => false;
}

/// Keeps app content out of the recent-apps switcher and screenshots.
abstract class SecureWindow {
  Future<void> setSecure(bool on);
}

/// Android sets FLAG_SECURE (see MainActivity). Other platforms have no
/// handler; there the Flutter privacy overlay does the job.
class ChannelSecureWindow implements SecureWindow {
  const ChannelSecureWindow([this.channel = const MethodChannel('expense_manager/secure_window')]);

  final MethodChannel channel;

  @override
  Future<void> setSecure(bool on) async {
    try {
      await channel.invokeMethod<void>('setSecure', on);
    } on MissingPluginException {
      // Not Android: nothing to do.
    }
  }
}

/// Holds the database encryption key outside the database.
abstract class KeyStore {
  Future<String?> read();
  Future<void> write(String key);
  Future<void> delete();
}

/// Keychain (iOS) / Keystore-backed storage (Android).
class SecureKeyStore implements KeyStore {
  SecureKeyStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  static const _name = 'db_key';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _name);

  @override
  Future<void> write(String key) => _storage.write(key: _name, value: key);

  @override
  Future<void> delete() => _storage.delete(key: _name);
}

/// Keeps the key in memory only (tests and in-memory databases).
class MemoryKeyStore implements KeyStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String key) async => value = key;

  @override
  Future<void> delete() async => value = null;
}

/// The platform pieces security features depend on.
class SecurityPlatform {
  SecurityPlatform({this.biometrics = const NoBiometrics(), this.window = const ChannelSecureWindow(), KeyStore? keys}) : keys = keys ?? MemoryKeyStore();

  final Biometrics biometrics;
  final SecureWindow window;
  final KeyStore keys;
}
