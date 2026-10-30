---
title: Privacy policy
permalink: /privacy-policy/
---

# Privacy policy — Expense Manager

_Last updated: 30 October 2026 (SMS)_

**Expense Manager does not collect any data.** The developer never receives anything you enter in the app.

- **Everything stays on your device.** Transactions, categories, payment sources, budgets, investments, debts, receipts and settings are stored in a local database inside the app's private storage. There is no account, no server, no cloud sync and no analytics or advertising SDK.
- **Database encryption (optional).** You can encrypt the database with a key kept in your phone's secure storage (Android Keystore / iOS Keychain). The key never leaves the device.
- **Location (optional).** If you turn on "Location on transactions" and grant permission, the app reads your current position when you add a transaction and stores the place name and coordinates with that transaction, on your device. The device's built-in geocoder may be used to turn coordinates into a place name. You can turn this off at any time in Settings or in your phone's settings.
- **Maps.** When you open a map (for example, to pick a place), map tiles are downloaded from OpenStreetMap. Like any website, their servers see your IP address and which map area is requested; nothing about your transactions is sent. "Open in maps" hands the location to your maps app.
- **Camera, photos and files (optional).** Receipt photos or PDFs you take or pick are copied into the app's private storage and attached to the transaction. They are deleted with the transaction.
- **Biometrics and PIN (optional).** App lock uses your phone's fingerprint/face unlock through the operating system; the app never sees biometric data. Your PIN is never stored; only a salted hash of it is kept in the app database on the device.
- **Bank SMS (optional).** On Android the app reads incoming SMS itself; on iPhone, where apps cannot read SMS, a Shortcuts automation you set up passes each matching message to the app ([setup guide](../ios-sms/)). Either way, if you turn on "Expenses from SMS" (and on Android grant the SMS permission), messages are read on your device to spot bank, card and UPI transactions. A message that looks like a completed debit or credit is stored in the app's local database (sender, text, amount, payee and the last digits of the account) so it can ask whether to add it; OTPs, offers, reminders and personal messages are discarded without being stored. Handled messages are deleted after 30 days. Nothing is sent anywhere, and the app never sends SMS or reads your existing inbox. Turn it off in Settings → Expenses from SMS or revoke the permission at any time.
- **Notifications (optional).** Reminders, budget alerts and "add this expense?" prompts are shown locally on the device. No push service is used.
- **Files you choose.** Import reads only the CSV or PDF statement you pick, or the backup you choose to restore. Export and backup create a file (CSV, PDF or an optionally password-encrypted `.ledger` backup) and hand it to the share sheet; where it goes next is up to you.
- **Error log.** Crashes and errors are written to a log file on your device only. It is never sent anywhere; you can view, share or clear it in Settings → Diagnostics.
- **Deleting your data.** Uninstalling the app removes all of its data. Clearing the app's storage does the same.
- **Children.** The app is not directed at children and collects no data from anyone.

Data safety (Play Console): _No data collected · No data shared · Users can delete data by uninstalling._
App privacy (App Store Connect): _Data Not Collected._

Questions: open an issue at <https://github.com/bhumit070/expense-manager-app/issues>.
