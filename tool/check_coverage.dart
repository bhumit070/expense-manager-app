// Fails unless every line in lib/ is covered by tests.
//
// Usage: flutter test --coverage && dart run tool/check_coverage.dart [minPercent]
import 'dart:io';

void main(List<String> args) {
  final min = args.isEmpty ? 100.0 : double.parse(args.first);
  final lcov = File('coverage/lcov.info');
  if (!lcov.existsSync()) {
    stderr.writeln('coverage/lcov.info not found. Run `flutter test --coverage` first.');
    exit(2);
  }
  final hits = <String, Map<int, int>>{};
  String? file;
  for (final line in lcov.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      file = line.substring(3).replaceAll('\\', '/');
      final i = file.indexOf('lib/');
      if (i >= 0) file = file.substring(i);
      hits.putIfAbsent(file, () => {});
    } else if (line.startsWith('DA:') && file != null) {
      final parts = line.substring(3).split(',');
      final n = int.parse(parts[0]);
      hits[file]![n] = (hits[file]![n] ?? 0) + int.parse(parts[1]);
    }
  }
  // Files that no test loaded are reported as 0% instead of silently skipped.
  final all = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).map((f) => f.path.replaceAll('\\', '/'));
  final missing = all.where((f) => !hits.containsKey(f)).toList()..sort();

  var total = 0, covered = 0;
  final report = <String>[];
  for (final e in (hits.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))) {
    final lines = e.value;
    final c = lines.values.where((v) => v > 0).length;
    total += lines.length;
    covered += c;
    if (c < lines.length) {
      final uncovered = (lines.entries.where((l) => l.value == 0).map((l) => l.key).toList()..sort());
      report.add('  ${e.key}: $c/${lines.length}  uncovered lines: ${uncovered.join(', ')}');
    }
  }
  final pct = total == 0 ? 0.0 : covered * 100 / total;
  stdout.writeln('Coverage: $covered/$total lines (${pct.toStringAsFixed(2)}%) across ${hits.length} files');
  if (report.isNotEmpty) stdout.writeln(report.join('\n'));
  if (missing.isNotEmpty) stdout.writeln('Files never loaded by tests:\n  ${missing.join('\n  ')}');
  if (pct + 1e-9 < min || missing.isNotEmpty) {
    stderr.writeln('FAILED: required $min%');
    exit(1);
  }
  stdout.writeln('OK');
}
