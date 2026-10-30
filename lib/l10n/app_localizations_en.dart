// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expense Manager';

  @override
  String get navHome => 'Home';

  @override
  String get navInsights => 'Insights';

  @override
  String get navInvest => 'Invest';

  @override
  String get navDebts => 'Debts';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get none => 'None';

  @override
  String get notSet => 'Not set';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get unknown => 'Unknown';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String nActive(int count) {
    return '$count active';
  }

  @override
  String get locationDenied => 'Location permission denied — you can still type a place.';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLocalOnly => 'Your data never leaves this phone. Stored locally, no server. Export a backup to move devices.';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsYourName => 'Your name';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDevice => 'Device language';

  @override
  String get settingsDefaults => 'Defaults';

  @override
  String get settingsDefaultSource => 'Default payment mode';

  @override
  String get settingsDefaultSourceHelp => 'Pre-selected on new transactions';

  @override
  String get settingsSources => 'Payment sources';

  @override
  String get settingsCategories => 'Categories';

  @override
  String get settingsCategoriesHelp => 'Uncategorised entries go to the default';

  @override
  String settingsDefaultCategory(String name) {
    return 'Default: $name';
  }

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsCurrencyHelp => 'Changes how amounts are shown. Nothing is converted.';

  @override
  String get settingsRecurring => 'Recurring transactions';

  @override
  String get settingsWeekStart => 'Week starts on';

  @override
  String get settingsWeekStartHelp => 'Weekly budgets and the week view in Insights follow this.';

  @override
  String settingsWeekSpan(String span) {
    return 'Weekly budgets and insights run $span';
  }

  @override
  String get settingsData => 'Data';

  @override
  String get settingsExportCsv => 'Export CSV';

  @override
  String get settingsExportCsvHelp => 'Transactions, investments, debts, budgets';

  @override
  String get settingsExportPdf => 'Export this month as PDF';

  @override
  String get settingsImport => 'Import CSV or PDF statement';

  @override
  String get settingsImportHelp => 'HDFC, SBI, ICICI and most bank PDFs, or a CSV export';

  @override
  String get settingsBackUp => 'Back up now';

  @override
  String get settingsBackUpHelp => 'One .ledger file, optional password';

  @override
  String get settingsRestore => 'Restore from backup';

  @override
  String get settingsPrivacyGroup => 'Privacy & permissions';

  @override
  String get settingsLocation => 'Location on transactions';

  @override
  String get settingsAppLock => 'App lock & privacy';

  @override
  String get smsTitle => 'Expenses from SMS';

  @override
  String get remindersTitle => 'Reminders & alerts';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyHelp => 'No data collected · works offline';

  @override
  String get settingsPrivacyBody =>
      'Expense Manager has no account, server or analytics. Everything you enter is stored in a database on this phone and only leaves it when you export or share a file yourself.\n\nLocation is read only when you allow it, and only to label your own transactions. Map tiles are loaded from OpenStreetMap when you open a map. Bank SMS are read, on this phone only, if you turn on Expenses from SMS.';

  @override
  String get settingsReadPolicy => 'Read full policy';

  @override
  String get settingsSourceCode => 'Source code on GitHub';

  @override
  String get settingsLicenses => 'Open-source licenses';

  @override
  String get settingsSupport => 'Support';

  @override
  String get diagnosticsTitle => 'Diagnostics';

  @override
  String get settingsDiagnosticsHelp => 'Local error log · view, share or clear';

  @override
  String get settingsReportIssue => 'Report a problem';

  @override
  String get settingsReportIssueHelp => 'Opens a GitHub issue · needs a GitHub account';

  @override
  String settingsNoBrowser(String url) {
    return 'No browser found to open $url';
  }

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get clear => 'Clear';

  @override
  String get nothingHere => 'Nothing here';

  @override
  String get dueToday => 'Due today';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String dueInDays(int n) {
    return 'Due in $n days';
  }

  @override
  String overdueByDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Overdue by $n days', one: 'Overdue by 1 day');
    return '$_temp0';
  }

  @override
  String debtRemindMessage(String person, String amount) {
    return 'Hi $person, just a friendly reminder about the $amount. Whenever it suits you is fine. Thanks!';
  }

  @override
  String debtRemindMessageFor(String person, String amount, String reason) {
    return 'Hi $person, just a friendly reminder about the $amount for $reason. Whenever it suits you is fine. Thanks!';
  }

  @override
  String get debtRemindSubject => 'Friendly reminder';

  @override
  String get debtYouOwe => 'You owe';

  @override
  String get debtOwedToYou => 'Owed to you';

  @override
  String debtMonthlyEmi(String amount) {
    return '$amount/mo in EMIs';
  }

  @override
  String get debtToCollect => 'to collect';

  @override
  String get debtIOwe => 'I owe';

  @override
  String get debtOwedToMe => 'Owed to me';

  @override
  String get debtSettled => 'Settled';

  @override
  String get debtEmpty => 'Loans, credit cards and money lent or borrowed show up here.';

  @override
  String get debtFooter => 'EMIs and card payments recorded here count as Debt, not Spend — so your monthly spend stays honest.';

  @override
  String debtPayTitle(String name) {
    return 'Pay $name?';
  }

  @override
  String debtPayBody(String amount) {
    return 'Records a $amount card payment. It counts as Debt, not Spend.';
  }

  @override
  String debtPayBodyFrom(String amount, String source) {
    return 'Records a $amount card payment from $source. It counts as Debt, not Spend.';
  }

  @override
  String debtPayAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String debtBillMerchant(String name) {
    return '$name bill';
  }

  @override
  String debtPaymentRecorded(String amount) {
    return 'Card payment of $amount recorded';
  }

  @override
  String debtEmi(String amount) {
    return 'EMI $amount';
  }

  @override
  String debtDueOn(int day) {
    return 'due on $day';
  }

  @override
  String debtLeftOf(String amount) {
    return 'left of $amount';
  }

  @override
  String debtStatement(String amount) {
    return 'Statement $amount';
  }

  @override
  String debtStatementDue(String amount, String date) {
    return 'Statement $amount · due $date';
  }

  @override
  String get debtPaid => 'Paid';

  @override
  String debtUnpaid(String amount) {
    return 'Unpaid $amount';
  }

  @override
  String debtEmisPaid(int paid, int total) {
    return '$paid of $total EMIs paid';
  }

  @override
  String debtPaymentsRecorded(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n payments recorded', one: '1 payment recorded');
    return '$_temp0';
  }

  @override
  String get debtReopen => 'Reopen';

  @override
  String get debtSettle => 'Settle';

  @override
  String get debtRemind => 'Remind';

  @override
  String get debtRecordPayment => 'Record payment';

  @override
  String get debtRecordRepayment => 'Record repayment';

  @override
  String debtPayNow(String amount) {
    return 'Pay now · $amount';
  }

  @override
  String get debtNeedNameAmount => 'Add a name and the amount';

  @override
  String get debtAddTitle => 'Add debt';

  @override
  String get debtEditTitle => 'Edit debt';

  @override
  String get debtKindLoan => 'Loan';

  @override
  String get debtKindCard => 'Credit card';

  @override
  String get debtKindPersonal => 'Personal';

  @override
  String get debtFieldName => 'Name, e.g. Car loan';

  @override
  String get debtFieldParty => 'Lender / person (optional)';

  @override
  String debtFieldPrincipal(String symbol) {
    return 'Total amount ($symbol)';
  }

  @override
  String get debtFieldRate => 'Interest rate % (optional)';

  @override
  String get debtFieldEmi => 'EMI / monthly payment (optional)';

  @override
  String get debtFieldEmis => 'Number of EMIs (optional)';

  @override
  String get debtFieldDueDay => 'Due day of month (optional)';

  @override
  String debtFieldStatement(String symbol) {
    return 'Latest statement total ($symbol, optional)';
  }

  @override
  String get debtStatementDueDate => 'Statement due date';

  @override
  String debtDueDate(String date) {
    return 'Due $date';
  }

  @override
  String get debtSave => 'Save debt';

  @override
  String get all => 'All';

  @override
  String get amount => 'Amount';

  @override
  String get delete => 'Delete';

  @override
  String get type => 'Type';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get searchScopeNotes => 'Notes';

  @override
  String get searchScopeMerchant => 'Merchant';

  @override
  String get searchScopePlace => 'Place';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortAmountDesc => 'Amount: high to low';

  @override
  String get sortAmountAsc => 'Amount: low to high';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get sort => 'Sort';

  @override
  String get searchHintAll => 'Search merchant, note, #tag, amount…';

  @override
  String get searchHintNotes => 'Search notes and #tags';

  @override
  String get searchHintMerchant => 'Search merchants';

  @override
  String searchHintAmount(String symbol) {
    return 'Exact amount, e.g. 450 or ${symbol}1,200';
  }

  @override
  String get searchHintPlace => 'Search places';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get filters => 'Filters';

  @override
  String get allCategories => 'All categories';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get allTime => 'All time';

  @override
  String nTransactions(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n transactions', one: '1 transaction');
    return '$_temp0';
  }

  @override
  String moneyOut(String amount) {
    return 'Out $amount';
  }

  @override
  String moneyIn(String amount) {
    return 'In $amount';
  }

  @override
  String noTxnMatch(String query) {
    return 'No transactions match \"$query\".';
  }

  @override
  String get noTxnInPeriod => 'No transactions in this period.';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get removeRecentSearch => 'Remove from recent searches';

  @override
  String get resetAll => 'Reset all';

  @override
  String get searchCategories => 'Search categories';

  @override
  String amountIn(String symbol) {
    return 'Amount ($symbol)';
  }

  @override
  String get paidVia => 'Paid via';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get txnNeedAmount => 'Enter an amount greater than zero';

  @override
  String txnTemplateSaved(String name) {
    return 'Saved “$name” as a template';
  }

  @override
  String deleteNamed(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get txnTemplateDeleteBody => 'The template is removed. Transactions made from it stay.';

  @override
  String get txnNeedDebt => 'Pick which debt this payment belongs to';

  @override
  String get txnEditTitle => 'Edit transaction';

  @override
  String get txnNewTitle => 'New transaction';

  @override
  String get txnSaveTemplate => 'Save as template';

  @override
  String get txnReceivedIn => 'Received in';

  @override
  String get txnPaidFrom => 'Paid from';

  @override
  String get category => 'Category';

  @override
  String txnCategoryHint(String name) {
    return 'Not sure? It goes to “$name” by default.';
  }

  @override
  String get txnHolding => 'Holding (optional)';

  @override
  String get txnNotLinked => 'Not linked';

  @override
  String get txnDebt => 'Debt';

  @override
  String get txnChooseDebt => 'Choose a debt';

  @override
  String txnDebtYouPay(String name) {
    return '$name · you pay';
  }

  @override
  String txnDebtYouReceive(String name) {
    return '$name · you receive';
  }

  @override
  String get details => 'Details';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get txnMerchant => 'Merchant / payee';

  @override
  String get txnLocation => 'Location · optional';

  @override
  String get pickOnMap => 'Pick on map';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get txnNote => 'Why? Add a note (searchable)';

  @override
  String get txnTags => 'Tags, e.g. #work #split';

  @override
  String get receipt => 'Receipt';

  @override
  String get receiptCamera => 'Camera';

  @override
  String get receiptGallery => 'Gallery';

  @override
  String get receiptPdf => 'PDF';

  @override
  String get receiptPdfAttached => 'PDF receipt attached';

  @override
  String get receiptPhotoAttached => 'Photo receipt attached';

  @override
  String get receiptRemove => 'Remove receipt';

  @override
  String get txnRecurringNote => 'Part of a recurring series. Changes apply to this one only; manage the series in Settings › Recurring.';

  @override
  String get repeat => 'Repeat';

  @override
  String get txnRepeat => 'Repeat this transaction';

  @override
  String txnRepeatNext(String frequency, String date) {
    return '$frequency · next $date';
  }

  @override
  String get txnRepeatHelp => 'Adds it automatically on schedule';

  @override
  String get neverEnds => 'Never ends';

  @override
  String endsOn(String date) {
    return 'Ends $date';
  }

  @override
  String get clearEndDate => 'Clear end date';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get txnSave => 'Save transaction';

  @override
  String get quickAdd => 'Quick add';

  @override
  String get continue_ => 'Continue';

  @override
  String get done => 'Done';

  @override
  String get notNow => 'Not now';

  @override
  String get remove => 'Remove';

  @override
  String get typeSpend => 'Spend';

  @override
  String get typeInvest => 'Invest';

  @override
  String get typeIncome => 'Income';

  @override
  String get typeDebt => 'Debt';

  @override
  String get investKindFd => 'Fixed deposits';

  @override
  String get investKindMf => 'Mutual funds';

  @override
  String get investKindStock => 'Stocks';

  @override
  String get investKindGold => 'Gold';

  @override
  String get investKindRetirement => 'Retirement (PPF/EPF/NPS)';

  @override
  String get investKindOther => 'Other';

  @override
  String get reminderTypeBudget => 'Budget alerts (80% and 100%)';

  @override
  String get reminderTypeDues => 'EMI and card due dates';

  @override
  String get reminderTypeSip => 'SIP reminders';

  @override
  String get reminderTypeMaturity => 'FD maturity';

  @override
  String get reminderTypeFollowUp => 'Follow-ups on money owed to me';

  @override
  String get reminderEmiTomorrow => 'EMI due tomorrow';

  @override
  String get reminderCardTomorrow => 'Card bill due tomorrow';

  @override
  String get reminderEmiToday => 'EMI due today';

  @override
  String get reminderCardToday => 'Card bill due today';

  @override
  String get reminderSipToday => 'SIP due today';

  @override
  String reminderSipBody(String title, String amount) {
    return '$title: invest $amount today.';
  }

  @override
  String reminderFdMatures(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'FD matures in $n days', one: 'FD matures tomorrow', zero: 'FD matures today');
    return '$_temp0';
  }

  @override
  String reminderFdBody(String title, String amount, String date) {
    return '$title ($amount invested) matures on $date.';
  }

  @override
  String reminderFollowUp(String name) {
    return 'Follow up with $name';
  }

  @override
  String reminderFollowUpBody(String name, String amount) {
    return '$name still owes you $amount.';
  }

  @override
  String budgetAlertFull(String name) {
    return '$name budget used up';
  }

  @override
  String budgetAlert80(String name) {
    return '80% of $name budget used';
  }

  @override
  String budgetAlertBody(String used, String limit, String left) {
    return '$used of $limit spent · $left';
  }

  @override
  String daysLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n days left', one: '1 day left');
    return '$_temp0';
  }

  @override
  String get reminderTestTitle => 'Reminders are on';

  @override
  String get reminderTestBody => 'You will hear about budgets, due dates, SIPs and maturities here. Nothing leaves your phone.';

  @override
  String get smsAddDetails => 'Add details';

  @override
  String get smsIgnore => 'Ignore';

  @override
  String get undo => 'Undo';

  @override
  String smsAmountFrom(String amount, String name) {
    return '$amount from $name';
  }

  @override
  String smsAmountAt(String amount, String name) {
    return '$amount at $name';
  }

  @override
  String smsAmountInto(String amount, String name) {
    return '$amount into $name';
  }

  @override
  String smsMoneyReceived(String what) {
    return 'Money received: $what';
  }

  @override
  String smsNewExpense(String what) {
    return 'New expense: $what';
  }

  @override
  String smsAddTo(String where) {
    return 'Add to $where?';
  }

  @override
  String smsIncomeAdded(String what) {
    return 'Income added: $what';
  }

  @override
  String smsExpenseAdded(String what) {
    return 'Expense added: $what';
  }

  @override
  String get reminderChannelHelp => 'Budget alerts, due dates, SIPs and maturity reminders';

  @override
  String get smsChannelHelp => 'Asks before adding a bank or UPI transaction read from an SMS';

  @override
  String get unlockPrompt => 'Unlock Expense Manager';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get backupNeedsPassword => 'This backup is password-protected';

  @override
  String get backupWrongPassword => 'Wrong password';

  @override
  String get backupInvalid => 'Not an Expense Manager backup';

  @override
  String get backupDamaged => 'Backup file is damaged';

  @override
  String get backupTooNew => 'This backup was made by a newer version of the app. Update the app first.';

  @override
  String get backupNever => 'Never backed up';

  @override
  String backupLast(String date) {
    return 'Last backup $date';
  }

  @override
  String get importNeedColumns => 'Need a date column and an amount (or debit/credit) column';

  @override
  String importInvalidDate(String value) {
    return 'Invalid date \"$value\"';
  }

  @override
  String get importInvalidAmount => 'Invalid amount';

  @override
  String get investmentsTitle => 'Investments';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get pdfLocked => 'This PDF is password-protected. Save an unlocked copy (Print → Save as PDF) and import that.';

  @override
  String pdfUnreadable(String cause) {
    return 'Could not read this PDF ($cause)';
  }

  @override
  String get bankStatement => 'Bank statement';

  @override
  String get emi => 'EMI';

  @override
  String get cardBill => 'Card bill';

  @override
  String reminderDueTomorrowBody(String title, String what) {
    return '$title: $what is due tomorrow.';
  }

  @override
  String reminderDueTomorrowAmountBody(String title, String what, String amount) {
    return '$title: $what of $amount is due tomorrow.';
  }

  @override
  String reminderDueTodayBody(String title, String what) {
    return '$title: $what is due today.';
  }

  @override
  String reminderDueTodayAmountBody(String title, String what, String amount) {
    return '$title: $what of $amount is due today.';
  }

  @override
  String exportedOne(String what, String path) {
    return 'Exported $what to $path';
  }

  @override
  String exportedMany(int n, String path) {
    return 'Exported $n files to $path';
  }

  @override
  String get exportHelp => 'UTF-8 files that open in Excel or Sheets. Several files are shared as one zip.';

  @override
  String exportZip(int n) {
    return 'Export $n files (zip)';
  }

  @override
  String get export => 'Export';

  @override
  String get importPreview => 'Import preview';

  @override
  String get importPdfEmpty => 'No transactions found in this PDF. Try the CSV/Excel export from net banking.';

  @override
  String importFound(String bank, int n) {
    return '$bank · $n found';
  }

  @override
  String get backupCreating => 'Creating backup…';

  @override
  String get backupEncrypting => 'Encrypting backup…';

  @override
  String backupSaved(String path) {
    return 'Backup saved to $path';
  }

  @override
  String get restoring => 'Restoring…';

  @override
  String restoredN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Restored $n transactions', one: 'Restored 1 transaction');
    return '$_temp0';
  }

  @override
  String addedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Added $n transactions', one: 'Added 1 transaction');
    return '$_temp0';
  }

  @override
  String addedNSkipped(int n, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Added $n transactions', one: 'Added 1 transaction');
    return '$_temp0 · $skipped already here';
  }

  @override
  String get backupHelp => 'One .ledger file with all your data and receipts. Save it to Drive, Files or a computer.';

  @override
  String get backupProtect => 'Protect with a password';

  @override
  String get backupPasswordField => 'Password (6+ characters)';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get backupNoRecovery => 'There is no way to recover a forgotten password.';

  @override
  String get backUp => 'Back up';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get password => 'Password';

  @override
  String get unlock => 'Unlock';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String backupMade(String date, String version) {
    return 'Made $date · app $version';
  }

  @override
  String get merge => 'Merge';

  @override
  String get replace => 'Replace';

  @override
  String get restoreMergeHelp => 'Adds what is missing on this phone. Matching categories, sources and accounts are reused; transactions already here are skipped.';

  @override
  String get restoreReplaceHelp => 'Deletes everything on this phone and uses the backup instead.';

  @override
  String get restoreConfirm => 'I understand my current data will be erased';

  @override
  String get backupReminder => 'Backup reminder';

  @override
  String get backupBannerNever => 'Your data lives only on this phone. Make a backup.';

  @override
  String backupBannerDue(String last) {
    return 'Time for a backup · $last';
  }

  @override
  String get remindLater => 'Remind me later';

  @override
  String importedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Imported $n transactions', one: 'Imported 1 transaction');
    return '$_temp0';
  }

  @override
  String importLine(int n) {
    return 'Line $n';
  }

  @override
  String get importDuplicate => 'Duplicate';

  @override
  String importToDefault(String name) {
    return 'Category → $name';
  }

  @override
  String importNewSub(String name) {
    return 'New sub-category: $name';
  }

  @override
  String importN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Import $n transactions', one: 'Import 1 transaction');
    return '$_temp0';
  }

  @override
  String get finish => 'Finish';

  @override
  String get skip => 'Skip';

  @override
  String get onbWelcomeTitle => 'Your money, on your phone';

  @override
  String get onbWelcomeBody => 'Track spending, investments and debts in one place. Your data stays on this phone. There is no account, no server and no tracking.';

  @override
  String get onbGetStarted => 'Get started';

  @override
  String get onbPointLocal => 'Stored only on this device';

  @override
  String get onbPointOffline => 'Works fully offline';

  @override
  String get onbPointExport => 'Export to CSV or PDF any time';

  @override
  String get onbNameTitle => 'What should we call you?';

  @override
  String get onbNameBody => 'Used only for the greeting on the home screen. Optional.';

  @override
  String get onbCurrencyTitle => 'Pick your currency';

  @override
  String get onbCurrencyBody => 'Amounts are shown in this currency. You can change it later in Settings.';

  @override
  String onbCurrencySample(String currency, String amount) {
    return '$currency · e.g. $amount';
  }

  @override
  String get onbSourceTitle => 'Where do you pay from?';

  @override
  String onbSourceBody(String name) {
    return 'Add your main account. It becomes the default payment mode on new transactions. Leave it empty to start with $name.';
  }

  @override
  String get sourceKindCash => 'Cash';

  @override
  String get sourceNameField => 'Name, e.g. HDFC Savings';

  @override
  String get optional => 'Optional';

  @override
  String get onbLocationTitle => 'Tag places automatically?';

  @override
  String get onbLocationBody => 'With location on, new transactions get the place you are at. It is saved only with your entries on this phone. You can always type a place instead.';

  @override
  String get onbLocationContinue => 'Continue without location';

  @override
  String get onbLocationAllow => 'Allow location';

  @override
  String get onbLocationDenied => 'Permission was not granted. You can turn it on later in Settings.';

  @override
  String get onbSmsTitle => 'Add expenses from bank SMS?';

  @override
  String get onbSmsBodyShortcuts =>
      'A Shortcuts automation can hand each bank, card or UPI SMS to us; we read it on this phone and ask whether to add it — one tap from the notification. Settings › Expenses from SMS shows how to set it up.';

  @override
  String get onbSmsBody =>
      'When a bank, card or UPI SMS arrives, we read it on this phone and ask whether to add it — one tap from the notification. OTPs and offers are skipped, and nothing is uploaded.';

  @override
  String get onbSmsContinue => 'Continue without SMS';

  @override
  String get turnOn => 'Turn on';

  @override
  String get onbSmsAllow => 'Allow SMS';

  @override
  String get onbSmsDenied => 'SMS permission was not granted. You can turn this on later in Settings › Expenses from SMS.';

  @override
  String get onbLockTitle => 'Lock the app?';

  @override
  String get onbLockBody => 'Ask for a PIN (or your fingerprint / face) when the app opens, and hide amounts in the app switcher. You can change this anytime in Settings.';

  @override
  String get onbLockAction => 'Set a PIN';

  @override
  String get onbRemindersTitle => 'Get reminders?';

  @override
  String get onbRemindersBody =>
      'A heads-up when a budget reaches 80% or 100%, the day before an EMI or card bill is due, on SIP dates and before an FD matures. Planned on this phone; nothing is sent anywhere.';

  @override
  String get onbRemindersContinue => 'Continue without reminders';

  @override
  String get onbRemindersAllow => 'Turn on reminders';

  @override
  String get onbRemindersDenied => 'Notifications are blocked. You can turn them on later in Settings › Reminders & alerts.';

  @override
  String get currencyInr => 'Indian rupee';

  @override
  String get currencyUsd => 'US dollar';

  @override
  String get currencyEur => 'Euro';

  @override
  String get currencyGbp => 'British pound';

  @override
  String get currencyAed => 'UAE dirham';

  @override
  String get currencySgd => 'Singapore dollar';

  @override
  String get currencyAud => 'Australian dollar';

  @override
  String get currencyCad => 'Canadian dollar';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get welcome => 'Welcome';

  @override
  String get reminders => 'Reminders';

  @override
  String homeSmsReview(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n transactions from SMS to review', one: '1 transaction from SMS to review');
    return '$_temp0';
  }

  @override
  String get homeOutThisMonth => 'Money out this month';

  @override
  String homeOutIn(String month) {
    return 'Money out in $month';
  }

  @override
  String get invested => 'Invested';

  @override
  String homeInvestedThisMonth(String amount) {
    return '+$amount this month';
  }

  @override
  String homeInvestedIn(String amount, String month) {
    return '+$amount in $month';
  }

  @override
  String homeMonthlyEmi(String amount) {
    return '$amount/mo EMI';
  }

  @override
  String get comingUp => 'Coming up';

  @override
  String get seeAll => 'See all';

  @override
  String get whereItWent => 'Where it went';

  @override
  String get homeNoSpendYet => 'No spending yet this month.';

  @override
  String homeNoSpendIn(String period) {
    return 'No spending in $period.';
  }

  @override
  String get recent => 'Recent';

  @override
  String get viewAll => 'View all';

  @override
  String get homeNoTxns => 'No transactions yet';

  @override
  String get homeNoTxnsHelp => 'Tap + to add your first expense, investment or income.';

  @override
  String homeNothingIn(String period) {
    return 'Nothing in $period';
  }

  @override
  String get homeNothingInHelp => 'No transactions were recorded that month.';

  @override
  String homeOfIncome(String amount) {
    return 'of $amount income';
  }

  @override
  String get spent => 'Spent';

  @override
  String get left => 'Left';

  @override
  String get catKindInvestment => 'Investment';

  @override
  String catMove(String name) {
    return 'Move $name';
  }

  @override
  String get catTopLevel => 'Top level';

  @override
  String catUnder(String name) {
    return 'Under $name';
  }

  @override
  String get catMoveOnlyLeaf => 'Only categories without sub-categories can be moved under another';

  @override
  String get catDefaultHelp => 'Default — used when nothing is picked';

  @override
  String get catAddSub => 'Add sub-category';

  @override
  String get catMoveMenu => 'Move…';

  @override
  String get catMoveUnderMenu => 'Move under…';

  @override
  String catArchive(String name) {
    return 'Archive $name';
  }

  @override
  String catArchived(String name) {
    return '$name archived';
  }

  @override
  String get catAdd => 'Add category';

  @override
  String get catSpendHelp => 'Money that’s gone — food, rent, bills. Tap ⋮ to add sub-categories.';

  @override
  String get catInvestHelp => 'Money out that still grows your net worth.';

  @override
  String get catIncomeHelp => 'Money coming in.';

  @override
  String catArchivedCount(int n) {
    return 'Archived ($n)';
  }

  @override
  String get catArchivedHelp => 'Kept for history; not offered on new transactions';

  @override
  String catKindUnder(String kind, String parent) {
    return '$kind · under $parent';
  }

  @override
  String get restore => 'Restore';

  @override
  String catRestored(String name) {
    return '$name restored';
  }

  @override
  String get catNew => 'New category';

  @override
  String catNewSub(String name) {
    return 'New sub-category in $name';
  }

  @override
  String get immediately => 'Immediately';

  @override
  String seconds(int n) {
    return '$n s';
  }

  @override
  String minutes(int n) {
    return '$n min';
  }

  @override
  String get pinChoose => 'Choose a PIN';

  @override
  String get pinConfirm => 'Confirm your PIN';

  @override
  String get pinDigits => 'Enter 4–6 digits';

  @override
  String get pinAgain => 'Enter the same PIN again';

  @override
  String pinCooldown(int n) {
    return 'Too many attempts. Try again in $n s';
  }

  @override
  String get pinWrong => 'Wrong PIN';

  @override
  String get pinCurrent => 'Enter your current PIN';

  @override
  String get lockOn => 'App lock is on';

  @override
  String get pinChanged => 'PIN changed';

  @override
  String get encryptTitle => 'Encrypt the database?';

  @override
  String get encryptBody =>
      'Your data will be encrypted with a key kept in this phone\'s secure storage. If that key is lost (for example, app data is cleared), the data cannot be recovered — export a backup first.';

  @override
  String get encrypt => 'Encrypt';

  @override
  String get dbEncrypted => 'Database encrypted';

  @override
  String get dbDecrypted => 'Database decrypted';

  @override
  String get appLock => 'App lock';

  @override
  String get lockWithPin => 'Lock with PIN';

  @override
  String get lockWithPinHelp => 'Asked when the app opens';

  @override
  String get changePin => 'Change PIN';

  @override
  String get unlockBiometric => 'Unlock with fingerprint / face';

  @override
  String get notAvailableDevice => 'Not available on this device';

  @override
  String get lockAgainAfter => 'Lock again after leaving the app';

  @override
  String get hideSwitcher => 'Hide in app switcher';

  @override
  String get hideSwitcherHelp => 'Blurs the recent-apps preview and blocks screenshots';

  @override
  String get encryption => 'Encryption';

  @override
  String get encryptDb => 'Encrypt database';

  @override
  String get encryptKeyStored => 'Key stored in the phone\'s secure storage';

  @override
  String get encryptUnavailable => 'Not available for this database';

  @override
  String get budgetNew => 'New budget';

  @override
  String budgetTabWeekly(String span) {
    return 'Weekly · $span';
  }

  @override
  String get budgetTabMonthly => 'Monthly · 1st–end';

  @override
  String budgetOverBanner(String name, String amount) {
    return '$name is over by $amount';
  }

  @override
  String get budgetNoneWeekly => 'No weekly budgets';

  @override
  String get budgetNoneMonthly => 'No monthly budgets';

  @override
  String get budgetEmptyHelp => 'Set a limit for any category and track it every cycle.';

  @override
  String get budgetCreate => 'Create budget';

  @override
  String get budgetGoalReached => 'Goal reached';

  @override
  String budgetToGoal(String amount) {
    return '$amount to reach goal';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Over by $amount';
  }

  @override
  String budgetLeft(String amount, String perDay, String days) {
    return '$amount left · $perDay/day · $days';
  }

  @override
  String get budgetAllInvestments => 'All investments';

  @override
  String get budgetAllSpending => 'All spending';

  @override
  String nCategories(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n categories', one: '1 category');
    return '$_temp0';
  }

  @override
  String ofAmount(String amount) {
    return 'of $amount';
  }

  @override
  String get budgetNeedNameLimit => 'Add a name and a limit';

  @override
  String get budgetEdit => 'Edit budget';

  @override
  String get budgetDelete => 'Delete budget';

  @override
  String get budgetNameField => 'Name, e.g. Food';

  @override
  String budgetLimitField(String symbol) {
    return 'Limit ($symbol)';
  }

  @override
  String budgetSuggestion(String amount) {
    return 'You averaged $amount/month over the last 3 months · tap to use';
  }

  @override
  String get budgetRepeats => 'Repeats every';

  @override
  String budgetWeek(String span) {
    return 'Week ($span)';
  }

  @override
  String get budgetMonth => 'Month (1st → end)';

  @override
  String get budgetGoal => 'Investment goal';

  @override
  String get budgetGoalHelp => 'Track a target for money invested instead of a spending cap';

  @override
  String get budgetCounts => 'Counts these investments';

  @override
  String get budgetAppliesTo => 'Applies to (empty = all spending)';

  @override
  String get budgetRollover => 'Roll over unspent amount';

  @override
  String get budgetAlert80Switch => 'Alert at 80%';

  @override
  String get budgetAlertOver => 'Alert when over';

  @override
  String get budgetSave => 'Save budget';

  @override
  String get totalInvested => 'Total invested';

  @override
  String investThisMonth(String amount, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n holdings', one: '1 holding');
    return '+$amount this month · $_temp0';
  }

  @override
  String get investNoPrices => 'Amounts you put in · no live prices or returns';

  @override
  String investMaturesOn(String name, String date) {
    return '$name matures on $date';
  }

  @override
  String get investNone => 'No investments yet';

  @override
  String get investNoneHelp => 'Add an FD, SIP, stock or gold holding to track what you invest.';

  @override
  String get investAdd => 'Add investment';

  @override
  String investMatures(String date) {
    return 'matures $date';
  }

  @override
  String nEntries(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n entries', one: '1 entry');
    return '$_temp0';
  }

  @override
  String get interestRate => 'Interest rate';

  @override
  String investStarted(String date) {
    return 'Started $date';
  }

  @override
  String investMaturesCap(String date) {
    return 'Matures $date';
  }

  @override
  String get institution => 'Institution';

  @override
  String get note => 'Note';

  @override
  String contributions(int n) {
    return 'Contributions ($n)';
  }

  @override
  String get investNoMoney => 'No money added yet.';

  @override
  String get investAddMoney => 'Add money';

  @override
  String get investMarkMatured => 'Mark matured';

  @override
  String get investCloseSold => 'Close / sold';

  @override
  String get investReactivate => 'Mark active again';

  @override
  String get investNeedName => 'Give the investment a name';

  @override
  String get investNameField => 'Name, e.g. HDFC Bank FD';

  @override
  String get investInstitutionField => 'Bank / platform (optional)';

  @override
  String get investAmountField => 'Amount invested now (optional)';

  @override
  String get startDate => 'Start date';

  @override
  String get maturityDate => 'Maturity date (optional)';

  @override
  String get investSave => 'Save investment';

  @override
  String get sourceKindBank => 'Bank account';

  @override
  String get sourceKindWallet => 'UPI / wallet';

  @override
  String get sourceAdd => 'Add payment source';

  @override
  String get sourceDefaultHelp => 'Pre-selected on every new transaction';

  @override
  String sourceOutIn(String kind, String amount, String month) {
    return '$kind · $amount out in $month';
  }

  @override
  String sourceLimit(String amount) {
    return 'limit $amount';
  }

  @override
  String sourceBalance(String amount) {
    return 'Balance $amount';
  }

  @override
  String sourceOutstanding(String amount) {
    return '$amount outstanding';
  }

  @override
  String sourceCredit(String amount) {
    return '$amount credit';
  }

  @override
  String get sourceNew => 'New payment source';

  @override
  String get sourceLast4 => 'Last 4 digits (optional)';

  @override
  String sourceCreditLimit(String symbol) {
    return 'Credit limit ($symbol)';
  }

  @override
  String sourceBalanceHelp(String amount) {
    return 'Optional · defaults to $amount';
  }

  @override
  String get makeDefault => 'Make default';

  @override
  String sourceOutstandingField(String symbol) {
    return 'Outstanding now ($symbol)';
  }

  @override
  String sourceBalanceField(String symbol) {
    return 'Current balance ($symbol)';
  }

  @override
  String get sourceAdjustHelp => 'Transactions you add will adjust it from here';

  @override
  String get pdfReport => 'PDF report';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get previousPeriod => 'Previous period';

  @override
  String get nextPeriod => 'Next period';

  @override
  String insightsDonutLabel(String spent, String invested) {
    return 'Spent $spent, invested $invested';
  }

  @override
  String get moneyOutLabel => 'Money out';

  @override
  String insightsSaved(int n) {
    return 'Saved $n% of income';
  }

  @override
  String get insightsNoEarlier => 'No earlier data';

  @override
  String insightsLessSpent(int n) {
    return '$n% less spent';
  }

  @override
  String insightsMoreSpent(int n) {
    return '$n% more spent';
  }

  @override
  String get insightsThanPrevious => 'than previous period';

  @override
  String perDay(String amount) {
    return '$amount / day';
  }

  @override
  String get averageSpend => 'average spend';

  @override
  String get monthByMonth => 'Month by month';

  @override
  String get weekByWeek => 'Week by week';

  @override
  String get dayByDay => 'Day by day';

  @override
  String get byCategory => 'By category';

  @override
  String get insightsNothing => 'Nothing recorded in this period.';

  @override
  String insightsDirect(String name) {
    return '$name (direct)';
  }

  @override
  String insightsCatRow(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n txns', one: '1 txn');
    return '$name  ·  $_temp0';
  }

  @override
  String get hideSubs => 'Hide sub-categories';

  @override
  String get showSubs => 'Show sub-categories';

  @override
  String get smsReadTitle => 'Read bank SMS?';

  @override
  String get smsReadBodyShortcuts =>
      'iPhone apps can\'t read SMS, so a Shortcuts automation hands each bank message to Expense Manager. It is read on this phone and you are asked whether to add the transaction.\n\nNothing is sent anywhere. OTPs, offers and reminders are skipped. Next, set up the automation using the steps on this screen.';

  @override
  String get smsReadBody =>
      'When a bank, card or UPI SMS arrives, Expense Manager reads it on this phone and asks whether to add the transaction.\n\nOnly messages with an amount that was debited or credited are kept, and nothing is sent anywhere. OTPs, offers and reminders are skipped.';

  @override
  String get smsDenied => 'SMS permission was denied. Allow it for Expense Manager in system settings.';

  @override
  String get smsNoNotifications => 'Notifications are blocked, so new expenses will only show up here.';

  @override
  String addedThing(String what) {
    return 'Added $what';
  }

  @override
  String get smsAskToAdd => 'Ask to add bank SMS';

  @override
  String get smsAskToAddHelp => 'Read on this phone · nothing is uploaded';

  @override
  String get smsPermissionOff => 'SMS permission is off, so new messages are not read.';

  @override
  String get allow => 'Allow';

  @override
  String get smsNothingToReview => 'Nothing to review';

  @override
  String smsToReview(int n) {
    return 'To review ($n)';
  }

  @override
  String get smsOnHelp => 'New bank and UPI transactions show up here and as a notification.';

  @override
  String get smsOffHelp => 'Turn this on to be asked about each bank or UPI transaction as its SMS arrives.';

  @override
  String get smsStep1 => 'Open Shortcuts → Automation → + (New Automation) → Message.';

  @override
  String smsStep2(String keyword) {
    return 'Message Contains: $keyword. Choose Run Immediately, then Next.';
  }

  @override
  String smsStep3(String action) {
    return 'New Blank Automation → Add Action → search \"$action\" (Expense Manager).';
  }

  @override
  String get smsStep4 => 'Tap Message in the action and pick Shortcut Input. Done.';

  @override
  String smsStep5(String first, String second) {
    return 'Repeat with \"$first\" and \"$second\" to catch more banks.';
  }

  @override
  String couldNotOpen(String url) {
    return 'Could not open $url';
  }

  @override
  String get smsSetupIphone => 'Set up on iPhone';

  @override
  String get smsSetupIphoneHelp => 'iOS doesn\'t let apps read SMS. A Shortcuts automation passes each bank message to Expense Manager instead (iOS 17 or later runs it without asking).';

  @override
  String get smsOpenShortcuts => 'Open Shortcuts';

  @override
  String get smsGuide => 'Guide with pictures';

  @override
  String get sipStopTitle => 'Stop this SIP?';

  @override
  String get sipStopBody => 'Contributions already recorded stay on this investment.';

  @override
  String get sipStop => 'Stop SIP';

  @override
  String get sipSetup => 'Set up a monthly SIP';

  @override
  String sipSummary(String amount, int day) {
    return 'SIP · $amount on day $day';
  }

  @override
  String get paused => 'Paused';

  @override
  String nextOn(String date) {
    return 'Next $date';
  }

  @override
  String nextOnFrom(String date, String source) {
    return 'Next $date · $source';
  }

  @override
  String get sipAuto => 'Added automatically';

  @override
  String get sipReminderOnly => 'Reminder only · record it when you pay';

  @override
  String get stop => 'Stop';

  @override
  String get sipMonthly => 'Monthly SIP';

  @override
  String get sipEdit => 'Edit SIP';

  @override
  String sipAmountField(String symbol) {
    return 'Amount each month ($symbol)';
  }

  @override
  String get dayOfMonth => 'Day of month';

  @override
  String get sipAutoOption => 'Add it automatically';

  @override
  String get sipAutoOptionHelp => 'Records the invest transaction each month';

  @override
  String get sipRemindOption => 'Remind me only';

  @override
  String get sipRemindOptionHelp => 'Shows it as coming up; you record it';

  @override
  String get shareLog => 'Share log';

  @override
  String get clearLog => 'Clear log';

  @override
  String get logCleared => 'Error log cleared';

  @override
  String get noErrors => 'No errors recorded';

  @override
  String get noErrorsHelp => 'Crashes and errors are logged on this phone only. Share the log if you report a bug.';

  @override
  String reminderOn(String date) {
    return 'Reminder on $date';
  }

  @override
  String get changeDate => 'Change date';

  @override
  String get remindMeOn => 'Remind me on';

  @override
  String willRemind(String date) {
    return 'We\'ll remind you on $date';
  }

  @override
  String get savedTurnOnReminders => 'Saved. Turn on Settings › Reminders & alerts to get a notification.';

  @override
  String get remindMe => 'Remind me';

  @override
  String get locationUnavailable => 'Current location unavailable. Allow location access or search instead.';

  @override
  String get pickLocation => 'Pick location';

  @override
  String get searchPlace => 'Search a place or address';

  @override
  String get noPlaceMatches => 'No matches. Try another name, or tap the map.';

  @override
  String get placeName => 'Place name';

  @override
  String get tapMapForPin => 'Tap the map to drop a pin';

  @override
  String pinWrongLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n attempts left', one: '1 attempt left');
    return 'Wrong PIN · $_temp0';
  }

  @override
  String get appLocked => 'Expense Manager is locked';

  @override
  String get ended => 'Ended';

  @override
  String get reminderOnly => 'reminder only';

  @override
  String get deleteSchedule => 'Delete this schedule?';

  @override
  String get deleteScheduleBody => 'No more transactions will be added. Ones already added stay.';

  @override
  String get recurring => 'Recurring';

  @override
  String get nothingRecurring => 'Nothing recurring yet';

  @override
  String get nothingRecurringHelp => 'Turn on “Repeat” when adding a transaction, or set up a SIP on an investment.';

  @override
  String get deleteRule => 'Delete rule';

  @override
  String get editSchedule => 'Edit schedule';

  @override
  String get onTheDay => 'On the day';

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n days before', one: '1 day before');
    return '$_temp0';
  }

  @override
  String get notificationsBlocked => 'Notifications are blocked. Allow them for Expense Manager in system settings.';

  @override
  String get testSent => 'Test notification sent';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsHelp => 'Planned on this phone · nothing is sent to a server';

  @override
  String get fdLeadTitle => 'Remind me before an FD matures';

  @override
  String remindersInfo(String time) {
    return 'Reminders arrive around $time: due dates the day before and on the day, SIPs on their date, and budget alerts once per budget when it reaches 80% and 100%.';
  }

  @override
  String get sendTest => 'Send a test notification';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String inDays(int n) {
    return 'in $n days';
  }

  @override
  String get upcomingEmi => 'EMI due';

  @override
  String get upcomingCard => 'Card bill due';

  @override
  String get upcomingMaturity => 'Matures';

  @override
  String get upcomingSip => 'SIP due';

  @override
  String get upcomingFollowUp => 'Follow up';

  @override
  String get nothingComingUp => 'Nothing coming up';

  @override
  String get nothingComingUpHelp => 'EMIs, card bills and FD maturities in the next 60 days show up here.';

  @override
  String get txnDeleted => 'Transaction deleted';

  @override
  String get txnGone => 'This transaction no longer exists.';

  @override
  String get transaction => 'Transaction';

  @override
  String get dateTime => 'Date & time';

  @override
  String get location => 'Location';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get repeats => 'Repeats';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get pdfReceipt => 'PDF receipt';

  @override
  String get open => 'Open';

  @override
  String get receiptMissing => 'Receipt file not found';

  @override
  String get keyPlus => 'Plus';

  @override
  String get keyMinus => 'Minus';

  @override
  String get keyEquals => 'Equals';

  @override
  String get keyDecimal => 'Decimal point';

  @override
  String get keyDoubleZero => 'Double zero';

  @override
  String get keyBackspace => 'Backspace';

  @override
  String allOf(String name) {
    return 'All $name';
  }

  @override
  String chartBarLabel(String label, String spent, String invested) {
    return '$label: spent $spent, invested $invested';
  }

  @override
  String get pinMismatch => 'PINs didn\'t match. Try again.';

  @override
  String encryptFailed(String error) {
    return 'Couldn\'t change encryption: $error';
  }

  @override
  String get pdfTitle => 'Expense report';

  @override
  String pdfTitleFor(String period) {
    return 'Expense report $period';
  }

  @override
  String get pdfDebtPaid => 'Debt paid';

  @override
  String get pdfSpendByCategory => 'Spend by category';

  @override
  String pdfTransactions(int n) {
    return 'Transactions ($n)';
  }

  @override
  String get seedFood => 'Food & dining';

  @override
  String get seedRent => 'Rent';

  @override
  String get seedShopping => 'Shopping';

  @override
  String get seedTransport => 'Transport';

  @override
  String get seedBills => 'Bills & utilities';

  @override
  String get seedHealth => 'Health';

  @override
  String get seedEntertainment => 'Entertainment';

  @override
  String get seedTravel => 'Travel';

  @override
  String get seedOthers => 'Others';

  @override
  String get seedFd => 'Fixed deposit';

  @override
  String get seedMutualFunds => 'Mutual funds / SIP';

  @override
  String get seedRetirement => 'PPF / EPF / NPS';

  @override
  String get seedSalary => 'Salary';

  @override
  String get seedOtherIncome => 'Other income';
}
