import 'package:expense_manager/data/database.dart';
import 'package:expense_manager/services/security_platform.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:sqlite3/sqlite3.dart';

import 'helpers.dart';

class FakeBiometrics implements Biometrics {
  FakeBiometrics({this.isAvailable = true, this.result = true});

  bool isAvailable;
  bool result;
  int prompts = 0;

  @override
  Future<bool> available() async => isAvailable;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return result;
  }
}

class FakeWindow implements SecureWindow {
  final calls = <bool>[];

  @override
  Future<void> setSecure(bool on) async => calls.add(on);
}

class FailingKeys extends MemoryKeyStore {
  @override
  Future<void> write(String key) async => throw StateError('keystore unavailable');
}

/// App state with fake security platform pieces. [db] lets a test reuse a
/// database to simulate a cold start.
({AppState state, FakeBiometrics bio, FakeWindow window, MemoryKeyStore keys}) makeSecureState({
  bool onboarded = true,
  Database? db,
  FakeBiometrics? bio,
  MemoryKeyStore? keys,
  DateTime Function()? clock,
}) {
  final b = bio ?? FakeBiometrics();
  final w = FakeWindow();
  final k = keys ?? MemoryKeyStore();
  final state = AppState(
    db: db ?? openAppDatabase(null),
    files: FakeFiles(),
    location: FakeLocation(),
    clock: clock ?? () => kNow,
    security: SecurityPlatform(biometrics: b, window: w, keys: k),
  );
  if (onboarded) state.completeOnboarding();
  return (state: state, bio: b, window: w, keys: k);
}
