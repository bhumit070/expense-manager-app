import 'package:flutter/material.dart';

import '../../state/app_state.dart';

/// Soft-deletes a transaction and offers Undo on [messenger].
void deleteTxnWithUndo(ScaffoldMessengerState messenger, AppState app, int id) {
  app.txns.delete(id);
  app.changed();
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text('Transaction deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            app.txns.restore(id);
            app.changed();
          },
        ),
      ),
    );
}
