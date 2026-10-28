import 'dart:io';

import 'package:expense_manager/data/database.dart';
import 'package:expense_manager/state/security_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../helpers.dart';
import '../security_fakes.dart';

void main() {
  test('PIN: validation, salted hash, check and cold-start lock', () {
    final f = makeSecureState();
    final sec = f.state.security;
    expect([sec.lockEnabled, sec.locked], [false, false]);
    expect(SecurityState.validPin('123'), isFalse);
    expect(SecurityState.validPin('1234567'), isFalse);
    expect(SecurityState.validPin('12a4'), isFalse);
    expect(() => sec.setPin('12'), throwsArgumentError);
    sec.setPin('2468');
    expect([sec.lockEnabled, sec.locked], [true, false]);
    final stored = f.state.settings.get('lock_pin')!;
    expect(stored, isNot(contains('2468')));
    sec.setPin('2468');
    expect(f.state.settings.get('lock_pin'), isNot(stored), reason: 'new salt each time');
    expect(sec.checkPin('1111'), PinResult.wrong);
    expect(sec.failedAttempts, 1);
    expect(sec.checkPin('2468'), PinResult.ok);
    expect(sec.failedAttempts, 0);

    // A fresh start on the same database begins locked.
    final again = makeSecureState(db: f.state.db).state.security;
    expect(again.locked, isTrue);
    expect(again.checkPin('2468'), PinResult.ok);
    expect(again.locked, isFalse);
  });

  test('five wrong PINs start a 30 s cooldown that survives restarts', () {
    var now = kNow;
    final f = makeSecureState(clock: () => now);
    final sec = f.state.security..setPin('1234');
    for (var i = 0; i < SecurityState.maxAttempts; i++) {
      expect(sec.checkPin('0000'), PinResult.wrong);
    }
    expect(sec.cooldownLeft, SecurityState.cooldown);
    expect(sec.checkPin('1234'), PinResult.coolingDown);
    expect(makeSecureState(db: f.state.db, clock: () => now).state.security.checkPin('1234'), PinResult.coolingDown);
    now = now.add(const Duration(seconds: 31));
    expect(sec.cooldownLeft, Duration.zero);
    expect(sec.checkPin('1234'), PinResult.ok);
  });

  test('locks again after the background timeout', () {
    var now = kNow;
    final sec = makeSecureState(clock: () => now).state.security;
    sec.cameToForeground(); // never left: nothing happens
    sec.wentToBackground(); // lock off: nothing happens
    sec.cameToForeground();
    expect(sec.locked, isFalse);
    sec
      ..setPin('1234')
      ..timeout = const Duration(seconds: 30);
    expect(sec.timeout, const Duration(seconds: 30));
    sec.wentToBackground();
    now = now.add(const Duration(seconds: 10));
    sec.wentToBackground(); // keeps the first time
    sec.cameToForeground();
    expect(sec.locked, isFalse);
    sec.wentToBackground();
    now = now.add(const Duration(seconds: 30));
    sec.cameToForeground();
    expect(sec.locked, isTrue);
    sec.wentToBackground();
    sec.cameToForeground(); // already locked
    expect(sec.locked, isTrue);
    sec.disableLock();
    expect([sec.lockEnabled, sec.locked, sec.biometricsOn], [false, false, false]);
    expect(sec.timeout, const Duration(seconds: 30));
  });

  test('biometric unlock only when enabled and successful', () async {
    final f = makeSecureState(bio: FakeBiometrics(result: false));
    final sec = f.state.security;
    expect(await sec.biometricsAvailable(), isTrue);
    expect(await sec.unlockWithBiometrics(), isFalse);
    sec.setPin('1234');
    expect(await sec.unlockWithBiometrics(), isFalse, reason: 'biometrics off');
    sec.biometricsOn = true;
    final locked = makeSecureState(db: f.state.db, bio: f.bio).state.security;
    expect(await locked.unlockWithBiometrics(), isFalse);
    expect(locked.locked, isTrue);
    f.bio.result = true;
    expect(await locked.unlockWithBiometrics(), isTrue);
    expect(locked.locked, isFalse);
    expect(f.bio.prompts, 2);
  });

  test('app-switcher privacy defaults on and drives the window flag', () async {
    final f = makeSecureState();
    final sec = f.state.security;
    expect(sec.hideInSwitcher, isTrue);
    await sec.applyWindow();
    sec.hideInSwitcher = false;
    expect(sec.hideInSwitcher, isFalse);
    expect(f.window.calls, [true, false]);
  });

  group('database encryption', () {
    late Directory dir;
    late String path;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('enc');
      path = '${dir.path}/app.db';
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('in-memory databases cannot be encrypted', () {
      expect(makeSecureState().state.security.canEncrypt, isFalse);
    });

    test('encrypt with a stored key, reopen, then decrypt', () async {
      final f = makeSecureState(db: openAppDatabase(path));
      final sec = f.state.security;
      expect([sec.canEncrypt, sec.encrypted], [true, false]);
      await sec.encryptDatabase();
      expect(sec.encrypted, isTrue);
      final key = f.keys.value!;
      expect(key, hasLength(64));
      f.state.db.close();

      expect(() => openAppDatabase(path), throwsA(isA<SqliteException>()));
      final db = openAppDatabase(path, key: key);
      expect(db.select("SELECT value FROM settings WHERE key = 'db_encrypted'").single['value'], 'on');
      expect(db.select('PRAGMA journal_mode').single.values.single, 'wal');

      final g = makeSecureState(db: db, keys: f.keys);
      await g.state.security.decryptDatabase();
      expect([g.state.security.encrypted, f.keys.value], [false, null]);
      db.close();
      openAppDatabase(path).close();
    });

    test('a failed key save leaves the database plain', () async {
      final f = makeSecureState(db: openAppDatabase(path), keys: FailingKeys());
      await expectLater(f.state.security.encryptDatabase(), throwsStateError);
      expect(f.state.security.encrypted, isFalse);
      f.state.db.close();
      openAppDatabase(path).close();
    });

    test('a failed rekey forgets the saved key', () async {
      openAppDatabase(path).close();
      final readOnly = sqlite3.open(path, mode: OpenMode.readOnly);
      final f = makeSecureState(db: readOnly, onboarded: false);
      await expectLater(f.state.security.encryptDatabase(), throwsA(isA<SqliteException>()));
      expect(f.keys.value, isNull);
      readOnly.close();
    });
  });
}
