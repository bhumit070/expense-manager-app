# Expense Manager

Offline-first Flutter app for tracking spending, investments, income and debts. All data stays on the device in SQLite. There is no server and no account, and nothing is synced.

Design lives in Penpot (page **App screens**). Light screens are `01–18`, dark versions are `· Dark`, and the tokens are on `00 · Design system`. The build plan is in [`tasks.md`](tasks.md).

## Product rules

- Every transaction is **Spend**, **Invest**, **Income** or **Debt**. Investments are money out that isn't spending, and they are reported separately everywhere.
- **Investments track amounts invested only.** There is no current value, no returns and no live prices.
- New transactions default to *now*, the **default payment source**, the **Others** category, and the current location *if permission was already granted*. Location is otherwise optional and can be typed in.
- Notes, `#tags`, merchant, place and amount are all searchable (SQLite FTS5).
- Budgets: weekly runs **Monday → Sunday**, monthly runs **the 1st → the last day**. They support rollover and investment goals.
- Money is stored as integer **paise**, never as floating point.

## Architecture

```
lib/
  core/        money (Indian grouping, parsing), dates (week/month/year periods)
  data/        SQLite schema + migrations, models, repositories (sync FFI, indexed, FTS5)
  services/    CSV export/import (+dedupe), PDF report, file picker/share, location
  state/       AppState (ChangeNotifier) + AppScope (InheritedNotifier)
  ui/          theme tokens (light/dark from Penpot), shared widgets, custom-painted charts, screens
```

Performance choices:

- Synchronous SQLite through FFI (`sqlite3`), with no platform-channel round trips and no isolate hops for queries.
- Indexes on `(deleted, occurred_at)`, `(type, occurred_at)`, category, investment and debt.
- Totals and breakdowns are computed in SQL, not in Dart.
- FTS5 prefix search, kept in sync with triggers.
- Lazy `ListView.builder` for long lists.
- Charts are drawn with `CustomPainter`, with no chart library.
- Few dependencies, and no code generation.

## Commands

```bash
flutter run --flavor dev    # Android: dev flavor (installs as "Expense Manager Dev")
flutter run --flavor prod   # Android: production build
flutter run --dart-define=FLAVOR=dev   # iOS: no Xcode schemes, the flavor is a dart-define
tool/verify.sh              # format + analyze + tests + 100% coverage gate
flutter test --coverage && dart run tool/check_coverage.dart
```

`tool/check_coverage.dart` fails unless **every line in `lib/` is covered**. It also fails if any file under `lib/` was never loaded by a test, so untested files can't hide.

## Flavors

| | Android | iOS | Database | Notes |
|---|---|---|---|---|
| **dev** | `--flavor dev` → `com.bhumit070.expense_manager.dev`, "Expense Manager Dev" | `--dart-define=FLAVOR=dev` | `expense_manager_dev.db` | DEV corner banner |
| **prod** | `--flavor prod` | default | `expense_manager.db` | what CI releases |

Android has product flavors, so `flutter run` / `flutter build apk` on Android needs `--flavor`. The Dart side reads Flutter's `appFlavor` first and falls back to the `FLAVOR` dart-define (default `prod`), so dev and prod data never mix on one device.

## Crash and error log

Framework errors and uncaught async errors are appended to `<app documents>/logs/errors.log` (rotated at 256 KB, one previous file kept). Nothing is sent anywhere. **Settings → Support → Diagnostics** shows the log and lets the user share or clear it.

## Reminders and alerts

Local notifications only, through `flutter_local_notifications`: there's no push and no server. They're off until the user turns them on, either in onboarding or under Settings › Reminders & alerts.

- **What gets notified:**
  - Budget alerts at 80% and 100%, each sent once per budget per cycle.
  - EMI and card due dates, the day before and on the day.
  - Reminder-only SIPs.
  - FD maturity, N days before (default 3).
  - "Remind me" follow-ups on money owed to you.
- **When:** reminders are delivered around 9 AM local time. They're scheduled as inexact alarms, so no exact-alarm permission is needed and they may arrive a few minutes late.
- **How they stay current:** `lib/state/reminders.dart` re-plans them on app open, after every edit and in a daily background task. On Android that task is WorkManager, via `workmanager`: it creates due recurring transactions, checks budgets and reschedules.
- **iOS:** iOS has no reliable daily background slot, so that work happens when the app opens. Reminders that are already scheduled are still delivered by iOS.

## Tests

`test/` mirrors `lib/`:

- **core:** unit tests for money and period maths, including leap years, year rollover and Monday-start weeks.
- **data:** repository tests on a real in-memory SQLite database, covering migrations, FTS search, aggregates, rollover budgets, holdings, debts and duplicate detection.
- **services:** CSV round-trip and bank-statement import, PDF generation, and platform gateways tested with fake plugin implementations.
- **ui:** widget tests for every screen, including the user flows: add, edit, duplicate and delete with undo, filters, search, budgets, investments, debts, categories, sources, settings, import/export, theme and `main()`.

## Import, export and backup

- **CSV export:** transactions, investments, debts and budgets. Each file is UTF-8 with a BOM, so Excel opens it correctly. Picking several shares them as one zip.
- **PDF statement import:** text is extracted on the device, in pure Dart (`lib/services/pdf_text.dart`, built on [`dart_pdf_reader`](https://pub.dev/packages/dart_pdf_reader), Apache-2.0). There are line parsers for HDFC, SBI and ICICI, plus a generic "date … description … amount Dr/Cr" fallback (`lib/services/statement_import.dart`). Rows go through the same preview and duplicate check as CSV. Password-protected PDFs are not supported; save an unlocked copy first.
  - Syncfusion's PDF library was not used. Its community licence has revenue and headcount limits and is not an OSI licence, so it doesn't fit an MIT-licensed public repo.
- **Full backup (`.ledger`):** a zip of a `VACUUM INTO` database snapshot, a `manifest.json` (format, schema version, app version, date and row counts) and `receipts/`.
  - **Password (optional):** the file is encrypted with AES-256-GCM. The key comes from PBKDF2-HMAC-SHA256 with 210k rounds, using [`cryptography`](https://pub.dev/packages/cryptography) (Apache-2.0).
  - **Restore:** checks the manifest, migrates older schemas, then either *replaces* all data or *merges* it. A merge reuses matching categories, sources, investments and debts, and skips transactions already on the phone.
  - **Reminder:** you can be reminded to back up weekly or monthly. The default is monthly.

## Release

See [`docs/release.md`](docs/release.md) (signing secrets, Play internal testing, TestFlight), [`docs/store-listing.md`](docs/store-listing.md) and [`docs/privacy-policy.md`](docs/privacy-policy.md). Strings live in `lib/l10n/app_en.arb`; `flutter pub get` regenerates `app_localizations*.dart`.

## License

[MIT](LICENSE) © 2026 bhumit070.

The bundled font [Plus Jakarta Sans](https://github.com/tokotype/PlusJakartaSans) is licensed under the [SIL Open Font License 1.1](assets/fonts/OFL.txt).
