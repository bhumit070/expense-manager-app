package com.bhumit070.expense_manager

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Telephony
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Receives incoming SMS (only when the user turned on "Expenses from SMS" and
 * granted RECEIVE_SMS). Messages that look like money movements are handed to
 * Dart in a short-lived headless engine (`smsReceived` in sms_capture.dart),
 * which parses them on the device and posts an "add this expense?" notification.
 */
class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        val parts = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        // A long SMS arrives in parts; join them per sender.
        val bodies = linkedMapOf<String, StringBuilder>()
        var at = System.currentTimeMillis()
        for (p in parts) {
            bodies.getOrPut(p.originatingAddress ?: "") { StringBuilder() }.append(p.messageBody ?: "")
            at = p.timestampMillis
        }
        val messages = bodies.filterValues { MONEY.containsMatchIn(it) }
            .map { (sender, body) -> mapOf("sender" to sender, "body" to body.toString(), "at" to at) }
        if (messages.isEmpty()) return

        val pending = goAsync()
        val app = context.applicationContext
        val main = Handler(Looper.getMainLooper())
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(app)
        loader.ensureInitializationCompleteAsync(app, null, main) {
            val engine = FlutterEngine(app)
            var finished = false
            fun finish() {
                if (finished) return
                finished = true
                engine.destroy()
                pending.finish()
            }
            MethodChannel(engine.dartExecutor.binaryMessenger, "expense_manager/sms").setMethodCallHandler { call, result ->
                when (call.method) {
                    "take" -> result.success(messages)
                    "done" -> {
                        result.success(null)
                        main.post { finish() }
                    }
                    else -> result.notImplemented()
                }
            }
            // Broadcast receivers get about 10 seconds; never hold on longer.
            main.postDelayed({ finish() }, 9000)
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "package:expense_manager/services/sms_capture.dart", "smsReceived")
            )
        }
    }

    companion object {
        /** Cheap pre-filter so unrelated SMS never start an engine. */
        private val MONEY = Regex("(?i)(rs\\.?|inr|₹)\\s*[\\d,]+|debited|credited")
    }
}
