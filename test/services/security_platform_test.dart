import 'package:expense_manager/services/security_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeLocalAuth extends LocalAuthPlatform with MockPlatformInterfaceMixin {
  bool supported = true;
  bool biometrics = true;
  Object? error;
  bool result = true;
  AuthenticationOptions? lastOptions;

  @override
  Future<bool> isDeviceSupported() async {
    if (error != null) throw error!;
    return supported;
  }

  @override
  Future<bool> deviceSupportsBiometrics() async => biometrics;

  @override
  Future<bool> authenticate({required String localizedReason, required Iterable<AuthMessages> authMessages, AuthenticationOptions options = const AuthenticationOptions()}) async {
    lastOptions = options;
    if (error != null) throw error!;
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PlatformBiometrics maps availability, results and errors', () async {
    final fake = FakeLocalAuth();
    LocalAuthPlatform.instance = fake;
    final bio = PlatformBiometrics();
    expect(await bio.available(), isTrue);
    fake.biometrics = false;
    expect(await bio.available(), isFalse);
    fake
      ..biometrics = true
      ..supported = false;
    expect(await bio.available(), isFalse);
    expect(await bio.authenticate('why'), isTrue);
    expect([fake.lastOptions!.biometricOnly, fake.lastOptions!.stickyAuth], [true, true]);
    fake.result = false;
    expect(await bio.authenticate('why'), isFalse);
    fake.error = const LocalAuthException(code: LocalAuthExceptionCode.userCanceled);
    expect(await bio.authenticate('why'), isFalse);
    fake.error = PlatformException(code: 'x');
    expect(await bio.authenticate('why'), isFalse);
    expect(await PlatformBiometrics(LocalAuthentication()).available(), isFalse);
  });

  test('NoBiometrics is never available', () async {
    expect(await const NoBiometrics().available(), isFalse);
    expect(await const NoBiometrics().authenticate('x'), isFalse);
  });

  test('ChannelSecureWindow calls Android and ignores a missing handler', () async {
    const channel = MethodChannel('expense_manager/secure_window');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    await const ChannelSecureWindow().setSecure(true);
    expect([calls.single.method, calls.single.arguments], ['setSecure', true]);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    await const ChannelSecureWindow().setSecure(false);
    expect(calls, hasLength(1));
  });

  test('SecureKeyStore and MemoryKeyStore read, write and delete', () async {
    final data = <String, String>{};
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(data);
    for (final keys in <KeyStore>[SecureKeyStore(), SecureKeyStore(const FlutterSecureStorage()), MemoryKeyStore()]) {
      expect(await keys.read(), isNull);
      await keys.write('k1');
      expect(await keys.read(), 'k1');
      await keys.delete();
      expect(await keys.read(), isNull);
    }
    final p = SecurityPlatform();
    expect([p.biometrics, p.window, p.keys], [isA<NoBiometrics>(), isA<ChannelSecureWindow>(), isA<MemoryKeyStore>()]);
  });
}
