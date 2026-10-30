import AppIntents
import Flutter
import UIKit
import UserNotifications
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Notification buttons (Add / Ignore / Undo) run Dart in a background
    // engine; it needs the plugins too.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

/// Hands one SMS to Dart (`smsReceived` in sms_capture.dart) on a short-lived
/// headless engine, which parses it on the device and posts the
/// "add this expense?" notification. Mirrors Android's SmsReceiver.
@MainActor
enum SmsBridge {
  static func deliver(sender: String, body: String) async {
    await withCheckedContinuation { (done: CheckedContinuation<Void, Never>) in
      let engine = FlutterEngine(name: "sms", project: nil, allowHeadlessExecution: true)
      var finished = false
      let finish = {
        if finished { return }
        finished = true
        engine.destroyContext()
        done.resume()
      }
      let message: [String: Any] = [
        "sender": sender,
        "body": body,
        "at": Int(Date().timeIntervalSince1970 * 1000),
      ]
      FlutterMethodChannel(name: "expense_manager/sms", binaryMessenger: engine.binaryMessenger).setMethodCallHandler { call, result in
        switch call.method {
        case "take":
          result([message])
        case "done":
          result(nil)
          DispatchQueue.main.async { finish() }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
      engine.run(withEntrypoint: "smsReceived", libraryURI: "package:expense_manager/services/sms_capture.dart")
      GeneratedPluginRegistrant.register(with: engine)
      // Shortcuts gives an action about 30 seconds; never hold on longer.
      DispatchQueue.main.asyncAfter(deadline: .now() + 25) { finish() }
    }
  }
}

/// "Log bank SMS": the action a Shortcuts automation ("When I get a message
/// containing debited…") runs with the message text. iOS doesn't let apps
/// read SMS, so this is how bank messages reach the app on iPhone.
@available(iOS 16.0, *)
struct LogBankSmsIntent: AppIntent {
  static let title: LocalizedStringResource = "Log bank SMS"
  static let description = IntentDescription("Reads a bank, card or UPI SMS on this iPhone and asks whether to add the transaction to Expense Manager.")
  static let openAppWhenRun = false

  @Parameter(title: "Message", description: "The SMS text — pick Shortcut Input in a message automation.")
  var message: String

  @Parameter(title: "Sender", default: "")
  var sender: String

  @MainActor
  func perform() async throws -> some IntentResult {
    await SmsBridge.deliver(sender: sender, body: message)
    return .result()
  }
}
