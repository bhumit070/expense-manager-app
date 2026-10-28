import 'dart:convert';
import 'dart:io';

import 'package:expense_manager/services/error_log.dart';
import 'package:expense_manager/ui/screens/diagnostics_screen.dart';
import 'package:expense_manager/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('without a log the screen shows the empty state', (tester) async {
    await pumpRoute(tester, makeState(), const DiagnosticsScreen());
    expect(find.text('No errors recorded'), findsOneWidget);
    expect(find.byKey(const Key('share-log')), findsNothing);
  });

  testWidgets('opened from Settings: view, share and clear the log', (tester) async {
    final dir = Directory.systemTemp.createTempSync('diag');
    addTearDown(() => dir.deleteSync(recursive: true));
    final log = ErrorLog(File('${dir.path}/errors.log'));
    log.record('Bad thing', null);
    final files = FakeFiles();
    final s = makeState(files: files, errorLog: log);
    await pumpRoute(tester, s, const SettingsScreen());
    await tester.scrollUntilVisible(find.byKey(const Key('open-diagnostics')), 200);
    await tester.tap(find.byKey(const Key('open-diagnostics')));
    await tester.pumpAndSettle();
    expect(find.byType(DiagnosticsScreen), findsOneWidget);
    expect(find.textContaining('Bad thing'), findsOneWidget);
    await tester.tap(find.byKey(const Key('share-log')));
    await tester.pump();
    expect(files.saved.single.$1, 'expense-manager-errors.log');
    expect(utf8.decode(files.saved.single.$2), contains('Bad thing'));
    await tester.tap(find.byKey(const Key('clear-log')));
    await tester.pump();
    expect(find.text('Error log cleared'), findsOneWidget);
    expect(find.text('No errors recorded'), findsOneWidget);
  });
}
