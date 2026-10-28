import 'dart:io';

import 'package:expense_manager/services/error_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('log'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('records entries with time, source and stack; rotates; clears', () {
    final log = ErrorLog(File('${dir.path}/logs/errors.log'), maxBytes: 60, clock: () => DateTime(2026, 10, 28, 9));
    expect(log.read(), '');
    log.record(StateError('boom'), StackTrace.fromString('#0 main'));
    expect(log.read(), contains('[2026-10-28T09:00:00.000] error: Bad state: boom\n#0 main'));
    log.record('second', null, source: 'flutter');
    expect(log.previous.existsSync(), isFalse);
    log.record('third', null);
    expect(log.previous.existsSync(), isTrue);
    final all = log.read();
    expect(all.indexOf('boom') < all.indexOf('third'), isTrue);
    log.clear();
    expect(log.read(), '');
    log.clear();
  });

  test('install logs framework and uncaught errors and keeps previous handlers', () {
    final log = ErrorLog(File('${dir.path}/errors.log'));
    final savedFlutter = FlutterError.onError;
    final savedPlatform = PlatformDispatcher.instance.onError;
    final seen = <Object>[];
    try {
      FlutterError.onError = (d) => seen.add(d.exception);
      PlatformDispatcher.instance.onError = (e, s) {
        seen.add(e);
        return true;
      };
      log.install();
      FlutterError.onError!(const FlutterErrorDetails(exception: 'layout broke', stack: StackTrace.empty));
      expect(PlatformDispatcher.instance.onError!('async broke', StackTrace.empty), isTrue);
      expect(seen, ['layout broke', 'async broke']);
      expect(log.read(), allOf(contains('flutter: layout broke'), contains('uncaught: async broke')));

      // Without earlier handlers the error is reported as unhandled.
      FlutterError.onError = null;
      PlatformDispatcher.instance.onError = null;
      log.install(dispatcher: PlatformDispatcher.instance);
      FlutterError.onError!(const FlutterErrorDetails(exception: 'again'));
      expect(PlatformDispatcher.instance.onError!('lost', StackTrace.empty), isFalse);
      expect(log.read(), contains('flutter: again'));
    } finally {
      FlutterError.onError = savedFlutter;
      PlatformDispatcher.instance.onError = savedPlatform;
    }
  });
}
