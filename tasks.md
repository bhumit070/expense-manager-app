# Expense Manager — Flutter App Tasks

Offline-first personal finance app. All data lives on the device; there is no server, account or sync.
Design source: Penpot file (page **App screens**). Light screens are `01–18`, dark versions are `· Dark`, and the token reference is on `00 · Design system`.

Legend: **P0** = needed for v1, **P1** = should have, **P2** = later.

## Status (v0.1, 2026-10-28)

**Built and tested (100% line coverage, 134 tests, `tool/verify.sh`):**
- **Foundations:** product rules, design tokens (light/dark/system), SQLite schema with migrations and indexes, FTS5 search, and money stored in paise. State uses `ChangeNotifier` and `InheritedNotifier` instead of Riverpod, and navigation uses `Navigator` instead of go_router, to keep dependencies minimal.
- **Main screens:** Home, Transactions (list, search, filter sheet), Add/Edit/Duplicate/Delete with undo, Insights (week/month/year), Budgets (weekly Mon–Sun, monthly 1st–end, rollover, goals) and Investments (invested amounts only, FD timeline, maturity banner).
- **Other screens:** Debts (EMIs, settle/reopen, repayments), Categories (Spend/Invest/Income, Others default, reorder, archive), Payment sources (default payment mode) and Settings.
- **Data and location:** CSV export, PDF report export, CSV import with duplicate detection and review, and optional location from GPS when permission is already granted.
- **Builds:** Android debug APK builds. iOS is untested here because Xcode is not fully installed.

**Not built yet:**
- **Features:** onboarding, receipts, recurring transactions and SIP auto-entry, local notifications for budget alerts, EMIs and maturity (alert toggles are saved but nothing fires yet), app lock, PDF statement import, encrypted backup/restore, sub-categories and a map location picker.
- **Quality and release:** golden tests, localization and the release/store work.

---

## 0. Product rules (read first)

- Every transaction has a **type**: `spend`, `invest`, `income` or `debt`.
  - **Invest** is money out that is not spending. Show it separately from spend everywhere (home, insights, budgets).
  - **Debt** covers EMIs, card bill payments, and money lent or borrowed. It is not counted in monthly spend.
- **Investments track invested amounts only.** There is no current value, no returns or gain %, and no live prices or market APIs. Totals are the sum of what the user put in.
- New transaction defaults: date and time = **now**. Payment source = the user's **default payment mode**. Category = **Others**. Location = current GPS if permission is granted, otherwise empty and optional, with a manual picker.
- Notes and `#tags` are **searchable**.
- Budget cycles: **weekly = Monday 00:00 → Sunday 23:59**, **monthly = the 1st → the last day of the month**, in local time.
- Currency default is ₹ INR with Indian digit grouping (`1,23,456`). Store amounts as integer minor units (paise), never as doubles.

---

## 1. Project setup — P0

- [ ] Create the Flutter project (latest stable) for Android and iOS. Set the bundle IDs and app name.
- [ ] Folder structure: feature-first (`lib/features/<feature>/{data,domain,presentation}`), plus `lib/core` (theme, db, utils, widgets).
- [ ] State management: **Riverpod** (or Bloc; pick one and stay consistent).
- [ ] Routing: **go_router** with a shell route for the bottom nav (Home, Insights, Add, Invest, Debts).
- [ ] Lints: `flutter_lints` or `very_good_analysis`. Set up formatting and pre-commit hooks.
- [ ] Environment flavors: `dev` and `prod`.
- [ ] CI with GitHub Actions: analyze, test, build APK and IPA (unsigned).
- [ ] Crash and error logging to a local file only (no analytics SDK, to respect the offline/privacy promise).

## 2. Design system & theming — P0

- [ ] Port the colour tokens from `00 · Design system` into `ThemeExtension` classes (`AppColors.light` / `AppColors.dark`):
      bg, surface, surface-muted, track, line, text, text-muted, text-faint, brand, brand-soft, hero, spend(+soft), invest(+soft), income(+soft), debt(+soft), positive.
- [ ] Typography: **Plus Jakarta Sans** (`google_fonts`, or bundled for offline use). Text styles: Amount XL 52/800, Display 34/800, Title 26/800, Section 17/700, Body strong 14/600, Body 14/500, Caption 12/500, Micro 10/800.
- [ ] Spacing tokens (4, 8, 12, 16, 20) and radii (chip 16, input 14, card 20, hero 24).
- [ ] Theme mode: Light / Dark / System, persisted. Switch instantly without restarting.
- [ ] Icon set: Lucide (`lucide_icons`) to match the design's line icons.
- [ ] Shared widgets:
  - [ ] `AppCard`, `HeroCard`, `SectionHeader`
  - [ ] `SegmentedTabs` (Week/Month/Year, type tabs)
  - [ ] `AppChip` (filter, selectable with check, tag, status)
  - [ ] `IconBadge` (soft-tint rounded icon)
  - [ ] `ProgressBar` (single and stacked segments, pace marker)
  - [ ] `TransactionTile` (icon, title, type tag, subtitle, amount)
  - [ ] `AmountText` (₹ formatting, sign, colour by type)
  - [ ] `AppToggle`, `AppCheckbox`, `AppRadioCard`
  - [ ] `BottomNav` with a center FAB
  - [ ] `EmptyState`, `ErrorState`, skeleton loaders
- [ ] Number and date formatting helpers (`intl`): Indian grouping, compact (`₹12.08L`, `₹18.5K`), relative dates ("Today", "Yesterday").

## 3. Local data layer — P0

- [ ] Database: **Drift (SQLite)** with migrations. Isar is an alternative, but Drift gives FTS and SQL aggregates.
- [ ] Tables:
  - [ ] `transactions`: id, type, amount_minor, currency, category_id, source_id, occurred_at, note, merchant, lat, lng, place_name, recurring_rule_id, investment_id, debt_id, receipt_path, created_at, updated_at, deleted_at
  - [ ] `categories`: id, name, kind (`spend` | `invest`), icon, color, sort_order, is_default (Others), archived
  - [ ] `payment_sources`: id, kind (bank | credit_card | cash | wallet), name, last4, credit_limit_minor, bill_day, is_default, archived
  - [ ] `tags` + `transaction_tags`
  - [ ] `budgets`: id, name, period (`weekly` | `monthly`), limit_minor, category_ids / all_spend, rollover, alert_80, alert_100, is_goal (for investment targets)
  - [ ] `investments`: id, kind (fd | mutual_fund | stock | gold | ppf | other), name, institution, interest_rate, start_date, maturity_date, units/shares/grams (optional, user-entered), sip_amount, sip_day, status (active | matured | closed)
  - [ ] `debts`: id, direction (`i_owe` | `owed_to_me`), kind (loan | credit_card | personal), counterparty, principal_minor, interest_rate, emi_minor, total_emis, due_day, status
  - [ ] `recurring_rules`: id, frequency, interval, next_run_at, template (JSON)
  - [ ] `settings` (key-value)
- [ ] **FTS5** virtual table over merchant + note + tags + place_name for search.
- [ ] Seed default categories:
      Spend: Food & dining, Rent, Shopping, Transport, Bills & utilities, Health, Entertainment, Travel, Others (default).
      Investment: Fixed deposit, Mutual funds / SIP, Stocks, Gold, PPF / EPF / NPS.
- [ ] Repositories with streams (`watch*`) so the UI updates live.
- [ ] Soft delete with undo snackbar.
- [ ] Unit tests for repositories and aggregate queries.

## 4. Onboarding — P1 (not designed yet)

- [ ] Welcome screen explaining "your data stays on this phone".
- [ ] Set name (optional), currency and default payment source.
- [ ] Optional: add first bank/card/cash source.
- [ ] Permission primers (location, notifications), each skippable.
- [ ] Optional app lock setup.

## 5. Home (screen 01) — P0

- [ ] Month picker (defaults to the current month).
- [ ] Hero: money out = spend + invest, the income total, left = income − money out, and a stacked bar.
- [ ] Quick stats: total invested, you owe, owed to you.
- [ ] "Coming up": next EMIs, SIPs and card due dates from recurring rules and debts.
- [ ] "Where it went": top 4 spend categories with % and bars.
- [ ] Recent 5 transactions, linking to the list.
- [ ] Avatar opens Settings. The bell opens the reminders list (P1).

## 6. Transactions (02, 03, 17, 18) — P0

- [ ] Paginated list grouped by day, with daily totals.
- [ ] Period switcher (month ◀ ▶) with Out and In totals.
- [ ] Type tabs: All / Spend / Invest / Income / Debt.
- [ ] Horizontal category chips.
- [ ] **Filter sheet**: types, date range (this month, 3 months, this year, custom), categories (multi-select with search), amount min/max, payment source. Show an active filter count badge.
- [ ] **Search** across merchant, note, #tags, amount and place, with scopes (All / Notes / Merchant / Amount / Place), match highlighting, sort, and recent searches.
- [ ] **Transaction detail**: hero, details, note and tags, map preview of the location, Duplicate / Edit / Delete.
- [ ] Swipe actions on rows: edit, delete.

## 7. Add / edit transaction (04) — P0

- [ ] Type segmented control (Spend / Invest / Income / Debt). Colour accent follows the type.
- [ ] Custom amount keypad with a ₹ display. Basic maths (`+ −`) is P2.
- [ ] Paid-from selector with the default pre-selected, plus "Manage".
- [ ] Category grid filtered by type (spend vs investment categories). Falls back to **Others**.
- [ ] Date and time picker (defaults to now).
- [ ] Location:
  - [ ] If permission is granted, auto-fill with `geolocator` and reverse-geocode with `geocoding` (on-device, platform geocoder).
  - [ ] Otherwise leave it empty. The user can tap to pick a place on a map or search, or skip.
  - [ ] Global on/off in Settings.
- [ ] Note field (multi-line) and tag chips (`#work`) with autocomplete.
- [ ] Repeat toggle, which creates a recurring rule (daily, weekly, monthly, yearly).
- [ ] Receipt: camera or gallery photo, or PDF, stored in the app documents directory.
- [ ] Invest type: link to an existing investment or create one inline.
- [ ] Debt type: link to a debt (record EMI or payment, money lent, repayment received).
- [ ] Validation and "Save" with haptic feedback.
- [ ] Templates: quick re-add of frequent transactions (P1).

## 8. Insights (05, 06) — P0

- [ ] Week / Month / Year switcher with period navigation. Weeks are Mon–Sun.
- [ ] Monthly: spend vs invest donut, savings % of income, comparison with the previous period, average per day, week-by-week stacked bars, category breakdown (Spend / Invest toggle).
- [ ] Yearly: year totals (spent, invested, income), savings rate ring, 12-month stacked bar chart (future months greyed out), highlights (highest and lowest month, top category, most invested month), monthly totals list.
- [ ] Charts with `fl_chart`.
- [ ] Tap a category to open the transaction list pre-filtered to it.
- [ ] "Report" button runs the PDF export for the selected period.

## 9. Budgets (07, 08) — P0

- [ ] Weekly / Monthly tabs.
- [ ] Overall budget card: used vs limit, days left, remaining per day, and a pace marker (expected spend so far).
- [ ] Category budget cards with on-track, near-limit and over states.
- [ ] Investment goal budgets (a target, shown in green, with "₹X to reach goal").
- [ ] Over-budget banner.
- [ ] Create/edit: limit with suggestions (based on the 3-month average), period (weekly Mon–Sun / monthly 1st–end), cycle preview, categories or "All spending", rollover toggle, 80% and 100% alerts.
- [ ] Period math utilities with unit tests: week start (Monday), month end, leap years, DST.
- [ ] Rollover calculation at cycle reset.

## 10. Investments (09, 10) — P0

- [ ] Total invested = sum of `invest` transactions linked to holdings. **No current value or returns.**
- [ ] "Added this month" amount and the number of holdings.
- [ ] Allocation bar by kind (FD, mutual funds, stocks, gold, PPF).
- [ ] Maturity alert banner for FDs maturing within 30 days.
- [ ] Holdings grouped by kind, each with its invested amount and number of entries.
- [ ] Holding detail (FD): amount invested, rate, tenure, start → maturity timeline, days left, linked transactions, details, maturity reminder.
- [ ] Actions: break early or mark as matured. Both prompt the user for the received amount and record it as income.
- [ ] SIP support: a recurring rule that auto-creates monthly invest transactions, or a reminder only (user setting).
- [ ] Add investment flow: kind, name, institution, optional rate, dates, units. This screen is not designed yet, so design it first.

## 11. Debts (11) — P0

- [ ] Summary: you owe (with monthly EMI total) and owed to you.
- [ ] Tabs: I owe / Owed to me / Settled.
- [ ] Loan card: remaining vs principal, EMIs paid / total, next due date, "Record EMI".
- [ ] Credit card: statement total and due date, an urgent state, "Pay now", which records a debt payment.
- [ ] Personal debts with counterparty, and "Remind", which opens the share sheet with a message.
- [ ] Mark as settled. Settled history.
- [ ] EMI and card payments are type `debt`, not spend.

## 12. Categories (12) — P1

- [ ] Spend and Investment sections with an explainer.
- [ ] Add, edit and archive a category (name, icon, colour, kind).
- [ ] Reorder by drag.
- [ ] "Others" is the default and cannot be deleted.
- [ ] Sub-categories (P2).

## 13. Payment sources (13) — P0

- [ ] Banks, credit cards, cash and wallets, with this month's spend per source.
- [ ] Credit cards: limit used bar and bill day.
- [ ] Set the **default payment mode**, which pre-selects it on new transactions.
- [ ] Add, edit and archive sources.

## 14. Settings (14) — P0

- [ ] Profile (local name only).
- [ ] Privacy banner: data is stored locally.
- [ ] Appearance: Light / Dark / System.
- [ ] Defaults: payment mode, category (Others), currency, week start (Monday, fixed for budgets).
- [ ] Data: Export, Import, Backup / Restore.
- [ ] Permissions: location on transactions, app lock (biometric with `local_auth`), reminders and alerts.
- [ ] About, licenses, app version.

## 15. Export / Import / Backup (15, 16) — P0

- [ ] **CSV export**: transactions (with type, category, source, note, tags, location), investments, debts, budgets. UTF-8 with BOM for Excel.
- [ ] **PDF export** (`pdf` + `printing`): period summary, charts, category table, transaction table. Save to Files or share (`share_plus`).
- [ ] **CSV import**: pick a file (`file_picker`), map columns once and remember the mapping, parse dates and amounts, auto-categorise by merchant rules, detect duplicates (same date, amount and merchant), preview with checkboxes and a "needs review" state.
- [ ] **PDF import** of bank statements: on-device text extraction (`syncfusion_flutter_pdf` or similar), with per-bank parsers to start (HDFC, SBI, ICICI) and a generic table fallback. Same preview and dedupe flow as CSV.
- [ ] **Full backup**: a single encrypted file (`.ledger` = zipped DB + receipts, with an optional password). Restore replaces or merges the data.
- [ ] Auto-backup reminder (P1).

## 16. Notifications & reminders — P1

- [ ] `flutter_local_notifications` with timezone-aware scheduling.
- [ ] Budget alerts at 80% and 100%.
- [ ] EMI, card due date and SIP reminders.
- [ ] FD maturity reminder N days before.
- [ ] "Remind" for owed-to-me debts.
- [ ] Recurring transaction runner on app open and via a background task (`workmanager`).

## 17. Security & privacy — P0

- [ ] App lock with biometric or PIN fallback, and a lock-on-background timeout.
- [ ] Optional DB encryption (SQLCipher via `sqlcipher_flutter_libs`) — P1.
- [ ] Hide amounts in the app switcher (secure flag on Android, blur on iOS).
- [ ] No network calls except optional map tiles. Document this in the privacy policy.

## 18. Quality — P0

- [ ] Unit tests: money formatting, period math, aggregates, CSV parse/serialize, dedupe.
- [ ] Widget tests: shared components in light and dark themes.
- [ ] Golden tests for key screens in both themes.
- [ ] Integration test: add transaction → appears in list, insights and budget.
- [ ] Accessibility: semantics labels, 48dp touch targets, dynamic text scaling, contrast check in dark mode.
- [ ] Performance: 10k transactions with smooth list scrolling, and aggregates under 50 ms (add indexes on `occurred_at`, `type`, `category_id`).

## 19. Release — P1

- [ ] App icon and splash screen (light and dark).
- [ ] Localization scaffolding (`flutter_localizations`, ARB files), English first.
- [ ] Store listings, screenshots (from the Penpot screens) and privacy policy ("data not collected").
- [ ] Play Store internal testing and TestFlight.

## 20. Design gaps to fill before building

- [ ] Onboarding flow
- [ ] Empty states (no transactions, budgets, investments or debts)
- [ ] Add / edit investment screen
- [ ] Add debt / record payment sheet
- [ ] Location picker (map + search)
- [ ] CSV column-mapping screen
- [ ] Backup / restore screen
- [ ] App lock screen
- [ ] Error and permission-denied states
