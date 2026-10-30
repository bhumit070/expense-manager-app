import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../state/app_state.dart';

/// Soft-deletes a transaction and offers Undo on [messenger].
void deleteTxnWithUndo(ScaffoldMessengerState messenger, AppState app, int id) {
  app.txns.delete(id);
  app.changed();
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(currentL10n.txnDeleted),
        action: SnackBarAction(
          label: currentL10n.undo,
          onPressed: () {
            app.txns.restore(id);
            app.changed();
          },
        ),
      ),
    );
}
