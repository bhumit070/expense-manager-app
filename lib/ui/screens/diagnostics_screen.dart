import 'dart:convert';

import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Shows the local error log, with share and clear. Nothing is uploaded.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final log = app.errorLog;
    final text = log?.read() ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnostics', style: ts(16, weight: FontWeight.w700)),
        actions: [
          if (text.isNotEmpty) ...[
            IconButton(key: const Key('share-log'), icon: const Icon(Icons.ios_share), onPressed: () => app.files.saveAndShare('expense-manager-errors.log', utf8.encode(text), 'text/plain')),
            IconButton(
              key: const Key('clear-log'),
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                log!.clear();
                setState(() {});
                showSnack(context, 'Error log cleared');
              },
            ),
          ],
        ],
      ),
      body: text.isEmpty
          ? const EmptyState(icon: Icons.check_circle_outline, title: 'No errors recorded', message: 'Crashes and errors are logged on this phone only. Share the log if you report a bug.')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                key: const Key('log-text'),
                text,
                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: c.text),
              ),
            ),
    );
  }
}
