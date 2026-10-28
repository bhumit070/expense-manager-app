# Security & privacy

## App lock
- PIN of 4–6 digits. Only a salted hash is stored (random 16-byte salt, iterated SHA-256), in the `settings` table under `lock_pin`. The PIN itself is never written anywhere.
- Five wrong PINs start a 30-second cooldown. The cooldown is stored, so restarting the app doesn't skip it.
- Biometrics (fingerprint or face) are optional and use `local_auth`. When on, the prompt appears automatically on the lock screen. The PIN always works as a fallback.
- The app locks on every cold start. After it goes to the background, it locks again once the chosen timeout passes: immediately, 30 s, 1 min or 5 min.
- Settings → **App lock & privacy** turns the lock on or off (turning it off asks for the PIN). It also changes the PIN and sets the biometrics option and the timeout.

## App switcher
- Android: `FLAG_SECURE` is set through the `expense_manager/secure_window` channel in `MainActivity`. It blanks the recent-apps preview and blocks screenshots.
- All platforms: a blurred brand cover is drawn over the app while it is inactive or backgrounded. This is what protects the iOS snapshot.
- Both are controlled by **Hide in app switcher**, which is on by default.

## Database encryption (opt-in)
- SQLite comes from the `sqlite3` package's **SQLite3MultipleCiphers** build (`hooks.user_defines.sqlite3.source: sqlite3mc` in `pubspec.yaml`). It is MIT licensed, prebuilt for Android and iOS, and opens unencrypted databases exactly like stock SQLite, FTS5 included.
- Turning on **Encrypt database** generates a random 256-bit key, saves it to `flutter_secure_storage` (iOS Keychain, Android Keystore-wrapped) *before* touching the file, then runs `PRAGMA rekey`. The journal is switched to DELETE for the rekey and back to WAL afterwards.
- On launch, `bootstrap()` reads the key and runs `PRAGMA key` before migrations.
- If the key is lost (app data cleared, Keychain reset on a new phone), the database can't be recovered. The confirmation dialog says so. Export a backup before moving devices.
