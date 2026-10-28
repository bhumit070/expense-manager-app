import 'dart:io';

import 'package:flutter/foundation.dart';

/// Crash and error log kept in a local file only (no analytics, nothing sent).
/// When the file grows past [maxBytes] it is moved to `<name>.1`, so at most
/// two files are kept.
class ErrorLog {
  ErrorLog(this.file, {this.maxBytes = 256 * 1024, DateTime Function()? clock}) : clock = clock ?? DateTime.now;

  final File file;
  final int maxBytes;
  final DateTime Function() clock;

  File get previous => File('${file.path}.1');

  void record(Object error, StackTrace? stack, {String source = 'error'}) {
    file.parent.createSync(recursive: true);
    if (file.existsSync() && file.lengthSync() > maxBytes) file.renameSync(previous.path);
    final entry = StringBuffer('[${clock().toIso8601String()}] $source: $error\n');
    if (stack != null) entry.writeln(stack.toString().trimRight());
    entry.writeln();
    file.writeAsStringSync(entry.toString(), mode: FileMode.append, flush: true);
  }

  /// Older entries first.
  String read() => [previous, file].where((f) => f.existsSync()).map((f) => f.readAsStringSync()).join();

  void clear() {
    for (final f in [previous, file]) {
      if (f.existsSync()) f.deleteSync();
    }
  }

  /// Routes framework and uncaught async errors here, keeping the previous handlers.
  void install({PlatformDispatcher? dispatcher}) {
    final flutterHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      record(details.exception, details.stack, source: 'flutter');
      flutterHandler?.call(details);
    };
    final platform = dispatcher ?? PlatformDispatcher.instance;
    final platformHandler = platform.onError;
    platform.onError = (error, stack) {
      record(error, stack, source: 'uncaught');
      return platformHandler?.call(error, stack) ?? false;
    };
  }
}
