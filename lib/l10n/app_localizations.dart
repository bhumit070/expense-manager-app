import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_or.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('fr'), Locale('gu'), Locale('hi'), Locale('ja'), Locale('or')];

  /// App name shown in the task switcher and title bar
  ///
  /// In en, this message translates to:
  /// **'Expense Manager'**
  String get appTitle;

  /// Bottom navigation: home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation: insights tab
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// Bottom navigation: investments tab
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get navInvest;

  /// Bottom navigation: debts tab
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get navDebts;

  /// Tooltip of the centre add button
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @nActive.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String nActive(int count);

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied — you can still type a place.'**
  String get locationDenied;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves this phone. Stored locally, no server. Export a backup to move devices.'**
  String get settingsLocalOnly;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsName;

  /// No description provided for @settingsYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get settingsYourName;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDevice.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get settingsLanguageDevice;

  /// No description provided for @settingsDefaults.
  ///
  /// In en, this message translates to:
  /// **'Defaults'**
  String get settingsDefaults;

  /// No description provided for @settingsDefaultSource.
  ///
  /// In en, this message translates to:
  /// **'Default payment mode'**
  String get settingsDefaultSource;

  /// No description provided for @settingsDefaultSourceHelp.
  ///
  /// In en, this message translates to:
  /// **'Pre-selected on new transactions'**
  String get settingsDefaultSourceHelp;

  /// No description provided for @settingsSources.
  ///
  /// In en, this message translates to:
  /// **'Payment sources'**
  String get settingsSources;

  /// No description provided for @settingsCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get settingsCategories;

  /// No description provided for @settingsCategoriesHelp.
  ///
  /// In en, this message translates to:
  /// **'Uncategorised entries go to the default'**
  String get settingsCategoriesHelp;

  /// No description provided for @settingsDefaultCategory.
  ///
  /// In en, this message translates to:
  /// **'Default: {name}'**
  String settingsDefaultCategory(String name);

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsCurrencyHelp.
  ///
  /// In en, this message translates to:
  /// **'Changes how amounts are shown. Nothing is converted.'**
  String get settingsCurrencyHelp;

  /// No description provided for @settingsRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring transactions'**
  String get settingsRecurring;

  /// No description provided for @settingsWeekStart.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get settingsWeekStart;

  /// No description provided for @settingsWeekStartHelp.
  ///
  /// In en, this message translates to:
  /// **'Weekly budgets and the week view in Insights follow this.'**
  String get settingsWeekStartHelp;

  /// No description provided for @settingsWeekSpan.
  ///
  /// In en, this message translates to:
  /// **'Weekly budgets and insights run {span}'**
  String settingsWeekSpan(String span);

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get settingsExportCsv;

  /// No description provided for @settingsExportCsvHelp.
  ///
  /// In en, this message translates to:
  /// **'Transactions, investments, debts, budgets'**
  String get settingsExportCsvHelp;

  /// No description provided for @settingsExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export this month as PDF'**
  String get settingsExportPdf;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import CSV or PDF statement'**
  String get settingsImport;

  /// No description provided for @settingsImportHelp.
  ///
  /// In en, this message translates to:
  /// **'HDFC, SBI, ICICI and most bank PDFs, or a CSV export'**
  String get settingsImportHelp;

  /// No description provided for @settingsBackUp.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get settingsBackUp;

  /// No description provided for @settingsBackUpHelp.
  ///
  /// In en, this message translates to:
  /// **'One .ledger file, optional password'**
  String get settingsBackUpHelp;

  /// No description provided for @settingsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get settingsRestore;

  /// No description provided for @settingsPrivacyGroup.
  ///
  /// In en, this message translates to:
  /// **'Privacy & permissions'**
  String get settingsPrivacyGroup;

  /// No description provided for @settingsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location on transactions'**
  String get settingsLocation;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock & privacy'**
  String get settingsAppLock;

  /// No description provided for @smsTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses from SMS'**
  String get smsTitle;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders & alerts'**
  String get remindersTitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyHelp.
  ///
  /// In en, this message translates to:
  /// **'No data collected · works offline'**
  String get settingsPrivacyHelp;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Expense Manager has no account, server or analytics. Everything you enter is stored in a database on this phone and only leaves it when you export or share a file yourself.\n\nLocation is read only when you allow it, and only to label your own transactions. Map tiles are loaded from OpenStreetMap when you open a map. Bank SMS are read, on this phone only, if you turn on Expenses from SMS.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsReadPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read full policy'**
  String get settingsReadPolicy;

  /// No description provided for @settingsSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code on GitHub'**
  String get settingsSourceCode;

  /// No description provided for @settingsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get settingsLicenses;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @diagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnosticsTitle;

  /// No description provided for @settingsDiagnosticsHelp.
  ///
  /// In en, this message translates to:
  /// **'Local error log · view, share or clear'**
  String get settingsDiagnosticsHelp;

  /// No description provided for @settingsReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get settingsReportIssue;

  /// No description provided for @settingsReportIssueHelp.
  ///
  /// In en, this message translates to:
  /// **'Opens a GitHub issue · needs a GitHub account'**
  String get settingsReportIssueHelp;

  /// No description provided for @settingsNoBrowser.
  ///
  /// In en, this message translates to:
  /// **'No browser found to open {url}'**
  String settingsNoBrowser(String url);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get nothingHere;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get dueTomorrow;

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'Due in {n} days'**
  String dueInDays(int n);

  /// No description provided for @overdueByDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Overdue by 1 day} other{Overdue by {n} days}}'**
  String overdueByDays(int n);

  /// No description provided for @debtRemindMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi {person}, just a friendly reminder about the {amount}. Whenever it suits you is fine. Thanks!'**
  String debtRemindMessage(String person, String amount);

  /// No description provided for @debtRemindMessageFor.
  ///
  /// In en, this message translates to:
  /// **'Hi {person}, just a friendly reminder about the {amount} for {reason}. Whenever it suits you is fine. Thanks!'**
  String debtRemindMessageFor(String person, String amount, String reason);

  /// No description provided for @debtRemindSubject.
  ///
  /// In en, this message translates to:
  /// **'Friendly reminder'**
  String get debtRemindSubject;

  /// No description provided for @debtYouOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get debtYouOwe;

  /// No description provided for @debtOwedToYou.
  ///
  /// In en, this message translates to:
  /// **'Owed to you'**
  String get debtOwedToYou;

  /// No description provided for @debtMonthlyEmi.
  ///
  /// In en, this message translates to:
  /// **'{amount}/mo in EMIs'**
  String debtMonthlyEmi(String amount);

  /// No description provided for @debtToCollect.
  ///
  /// In en, this message translates to:
  /// **'to collect'**
  String get debtToCollect;

  /// No description provided for @debtIOwe.
  ///
  /// In en, this message translates to:
  /// **'I owe'**
  String get debtIOwe;

  /// No description provided for @debtOwedToMe.
  ///
  /// In en, this message translates to:
  /// **'Owed to me'**
  String get debtOwedToMe;

  /// No description provided for @debtSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get debtSettled;

  /// No description provided for @debtEmpty.
  ///
  /// In en, this message translates to:
  /// **'Loans, credit cards and money lent or borrowed show up here.'**
  String get debtEmpty;

  /// No description provided for @debtFooter.
  ///
  /// In en, this message translates to:
  /// **'EMIs and card payments recorded here count as Debt, not Spend — so your monthly spend stays honest.'**
  String get debtFooter;

  /// No description provided for @debtPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay {name}?'**
  String debtPayTitle(String name);

  /// No description provided for @debtPayBody.
  ///
  /// In en, this message translates to:
  /// **'Records a {amount} card payment. It counts as Debt, not Spend.'**
  String debtPayBody(String amount);

  /// No description provided for @debtPayBodyFrom.
  ///
  /// In en, this message translates to:
  /// **'Records a {amount} card payment from {source}. It counts as Debt, not Spend.'**
  String debtPayBodyFrom(String amount, String source);

  /// No description provided for @debtPayAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String debtPayAmount(String amount);

  /// No description provided for @debtBillMerchant.
  ///
  /// In en, this message translates to:
  /// **'{name} bill'**
  String debtBillMerchant(String name);

  /// No description provided for @debtPaymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Card payment of {amount} recorded'**
  String debtPaymentRecorded(String amount);

  /// No description provided for @debtEmi.
  ///
  /// In en, this message translates to:
  /// **'EMI {amount}'**
  String debtEmi(String amount);

  /// No description provided for @debtDueOn.
  ///
  /// In en, this message translates to:
  /// **'due on {day}'**
  String debtDueOn(int day);

  /// No description provided for @debtLeftOf.
  ///
  /// In en, this message translates to:
  /// **'left of {amount}'**
  String debtLeftOf(String amount);

  /// No description provided for @debtStatement.
  ///
  /// In en, this message translates to:
  /// **'Statement {amount}'**
  String debtStatement(String amount);

  /// No description provided for @debtStatementDue.
  ///
  /// In en, this message translates to:
  /// **'Statement {amount} · due {date}'**
  String debtStatementDue(String amount, String date);

  /// No description provided for @debtPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get debtPaid;

  /// No description provided for @debtUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid {amount}'**
  String debtUnpaid(String amount);

  /// No description provided for @debtEmisPaid.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {total} EMIs paid'**
  String debtEmisPaid(int paid, int total);

  /// No description provided for @debtPaymentsRecorded.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 payment recorded} other{{n} payments recorded}}'**
  String debtPaymentsRecorded(int n);

  /// No description provided for @debtReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get debtReopen;

  /// No description provided for @debtSettle.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get debtSettle;

  /// No description provided for @debtRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind'**
  String get debtRemind;

  /// No description provided for @debtRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get debtRecordPayment;

  /// No description provided for @debtRecordRepayment.
  ///
  /// In en, this message translates to:
  /// **'Record repayment'**
  String get debtRecordRepayment;

  /// No description provided for @debtPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now · {amount}'**
  String debtPayNow(String amount);

  /// No description provided for @debtNeedNameAmount.
  ///
  /// In en, this message translates to:
  /// **'Add a name and the amount'**
  String get debtNeedNameAmount;

  /// No description provided for @debtAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add debt'**
  String get debtAddTitle;

  /// No description provided for @debtEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit debt'**
  String get debtEditTitle;

  /// No description provided for @debtKindLoan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get debtKindLoan;

  /// No description provided for @debtKindCard.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get debtKindCard;

  /// No description provided for @debtKindPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get debtKindPersonal;

  /// No description provided for @debtFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name, e.g. Car loan'**
  String get debtFieldName;

  /// No description provided for @debtFieldParty.
  ///
  /// In en, this message translates to:
  /// **'Lender / person (optional)'**
  String get debtFieldParty;

  /// No description provided for @debtFieldPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Total amount ({symbol})'**
  String debtFieldPrincipal(String symbol);

  /// No description provided for @debtFieldRate.
  ///
  /// In en, this message translates to:
  /// **'Interest rate % (optional)'**
  String get debtFieldRate;

  /// No description provided for @debtFieldEmi.
  ///
  /// In en, this message translates to:
  /// **'EMI / monthly payment (optional)'**
  String get debtFieldEmi;

  /// No description provided for @debtFieldEmis.
  ///
  /// In en, this message translates to:
  /// **'Number of EMIs (optional)'**
  String get debtFieldEmis;

  /// No description provided for @debtFieldDueDay.
  ///
  /// In en, this message translates to:
  /// **'Due day of month (optional)'**
  String get debtFieldDueDay;

  /// No description provided for @debtFieldStatement.
  ///
  /// In en, this message translates to:
  /// **'Latest statement total ({symbol}, optional)'**
  String debtFieldStatement(String symbol);

  /// No description provided for @debtStatementDueDate.
  ///
  /// In en, this message translates to:
  /// **'Statement due date'**
  String get debtStatementDueDate;

  /// No description provided for @debtDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String debtDueDate(String date);

  /// No description provided for @debtSave.
  ///
  /// In en, this message translates to:
  /// **'Save debt'**
  String get debtSave;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @searchScopeNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get searchScopeNotes;

  /// No description provided for @searchScopeMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get searchScopeMerchant;

  /// No description provided for @searchScopePlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get searchScopePlace;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldest;

  /// No description provided for @sortAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'Amount: high to low'**
  String get sortAmountDesc;

  /// No description provided for @sortAmountAsc.
  ///
  /// In en, this message translates to:
  /// **'Amount: low to high'**
  String get sortAmountAsc;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @searchHintAll.
  ///
  /// In en, this message translates to:
  /// **'Search merchant, note, #tag, amount…'**
  String get searchHintAll;

  /// No description provided for @searchHintNotes.
  ///
  /// In en, this message translates to:
  /// **'Search notes and #tags'**
  String get searchHintNotes;

  /// No description provided for @searchHintMerchant.
  ///
  /// In en, this message translates to:
  /// **'Search merchants'**
  String get searchHintMerchant;

  /// No description provided for @searchHintAmount.
  ///
  /// In en, this message translates to:
  /// **'Exact amount, e.g. 450 or {symbol}1,200'**
  String searchHintAmount(String symbol);

  /// No description provided for @searchHintPlace.
  ///
  /// In en, this message translates to:
  /// **'Search places'**
  String get searchHintPlace;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @nTransactions.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 transaction} other{{n} transactions}}'**
  String nTransactions(int n);

  /// No description provided for @moneyOut.
  ///
  /// In en, this message translates to:
  /// **'Out {amount}'**
  String moneyOut(String amount);

  /// No description provided for @moneyIn.
  ///
  /// In en, this message translates to:
  /// **'In {amount}'**
  String moneyIn(String amount);

  /// No description provided for @noTxnMatch.
  ///
  /// In en, this message translates to:
  /// **'No transactions match \"{query}\".'**
  String noTxnMatch(String query);

  /// No description provided for @noTxnInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this period.'**
  String get noTxnInPeriod;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @removeRecentSearch.
  ///
  /// In en, this message translates to:
  /// **'Remove from recent searches'**
  String get removeRecentSearch;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get resetAll;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get searchCategories;

  /// No description provided for @amountIn.
  ///
  /// In en, this message translates to:
  /// **'Amount ({symbol})'**
  String amountIn(String symbol);

  /// No description provided for @paidVia.
  ///
  /// In en, this message translates to:
  /// **'Paid via'**
  String get paidVia;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFilters;

  /// No description provided for @txnNeedAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get txnNeedAmount;

  /// No description provided for @txnTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved “{name}” as a template'**
  String txnTemplateSaved(String name);

  /// No description provided for @deleteNamed.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteNamed(String name);

  /// No description provided for @txnTemplateDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The template is removed. Transactions made from it stay.'**
  String get txnTemplateDeleteBody;

  /// No description provided for @txnNeedDebt.
  ///
  /// In en, this message translates to:
  /// **'Pick which debt this payment belongs to'**
  String get txnNeedDebt;

  /// No description provided for @txnEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get txnEditTitle;

  /// No description provided for @txnNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get txnNewTitle;

  /// No description provided for @txnSaveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get txnSaveTemplate;

  /// No description provided for @txnReceivedIn.
  ///
  /// In en, this message translates to:
  /// **'Received in'**
  String get txnReceivedIn;

  /// No description provided for @txnPaidFrom.
  ///
  /// In en, this message translates to:
  /// **'Paid from'**
  String get txnPaidFrom;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @txnCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Not sure? It goes to “{name}” by default.'**
  String txnCategoryHint(String name);

  /// No description provided for @txnHolding.
  ///
  /// In en, this message translates to:
  /// **'Holding (optional)'**
  String get txnHolding;

  /// No description provided for @txnNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get txnNotLinked;

  /// No description provided for @txnDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get txnDebt;

  /// No description provided for @txnChooseDebt.
  ///
  /// In en, this message translates to:
  /// **'Choose a debt'**
  String get txnChooseDebt;

  /// No description provided for @txnDebtYouPay.
  ///
  /// In en, this message translates to:
  /// **'{name} · you pay'**
  String txnDebtYouPay(String name);

  /// No description provided for @txnDebtYouReceive.
  ///
  /// In en, this message translates to:
  /// **'{name} · you receive'**
  String txnDebtYouReceive(String name);

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @txnMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant / payee'**
  String get txnMerchant;

  /// No description provided for @txnLocation.
  ///
  /// In en, this message translates to:
  /// **'Location · optional'**
  String get txnLocation;

  /// No description provided for @pickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on map'**
  String get pickOnMap;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @txnNote.
  ///
  /// In en, this message translates to:
  /// **'Why? Add a note (searchable)'**
  String get txnNote;

  /// No description provided for @txnTags.
  ///
  /// In en, this message translates to:
  /// **'Tags, e.g. #work #split'**
  String get txnTags;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @receiptCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get receiptCamera;

  /// No description provided for @receiptGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get receiptGallery;

  /// No description provided for @receiptPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get receiptPdf;

  /// No description provided for @receiptPdfAttached.
  ///
  /// In en, this message translates to:
  /// **'PDF receipt attached'**
  String get receiptPdfAttached;

  /// No description provided for @receiptPhotoAttached.
  ///
  /// In en, this message translates to:
  /// **'Photo receipt attached'**
  String get receiptPhotoAttached;

  /// No description provided for @receiptRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove receipt'**
  String get receiptRemove;

  /// No description provided for @txnRecurringNote.
  ///
  /// In en, this message translates to:
  /// **'Part of a recurring series. Changes apply to this one only; manage the series in Settings › Recurring.'**
  String get txnRecurringNote;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @txnRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat this transaction'**
  String get txnRepeat;

  /// No description provided for @txnRepeatNext.
  ///
  /// In en, this message translates to:
  /// **'{frequency} · next {date}'**
  String txnRepeatNext(String frequency, String date);

  /// No description provided for @txnRepeatHelp.
  ///
  /// In en, this message translates to:
  /// **'Adds it automatically on schedule'**
  String get txnRepeatHelp;

  /// No description provided for @neverEnds.
  ///
  /// In en, this message translates to:
  /// **'Never ends'**
  String get neverEnds;

  /// No description provided for @endsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends {date}'**
  String endsOn(String date);

  /// No description provided for @clearEndDate.
  ///
  /// In en, this message translates to:
  /// **'Clear end date'**
  String get clearEndDate;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @txnSave.
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get txnSave;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAdd;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @typeSpend.
  ///
  /// In en, this message translates to:
  /// **'Spend'**
  String get typeSpend;

  /// No description provided for @typeInvest.
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get typeInvest;

  /// No description provided for @typeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get typeIncome;

  /// No description provided for @typeDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get typeDebt;

  /// No description provided for @investKindFd.
  ///
  /// In en, this message translates to:
  /// **'Fixed deposits'**
  String get investKindFd;

  /// No description provided for @investKindMf.
  ///
  /// In en, this message translates to:
  /// **'Mutual funds'**
  String get investKindMf;

  /// No description provided for @investKindStock.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get investKindStock;

  /// No description provided for @investKindGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get investKindGold;

  /// No description provided for @investKindRetirement.
  ///
  /// In en, this message translates to:
  /// **'Retirement (PPF/EPF/NPS)'**
  String get investKindRetirement;

  /// No description provided for @investKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get investKindOther;

  /// No description provided for @reminderTypeBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts (80% and 100%)'**
  String get reminderTypeBudget;

  /// No description provided for @reminderTypeDues.
  ///
  /// In en, this message translates to:
  /// **'EMI and card due dates'**
  String get reminderTypeDues;

  /// No description provided for @reminderTypeSip.
  ///
  /// In en, this message translates to:
  /// **'SIP reminders'**
  String get reminderTypeSip;

  /// No description provided for @reminderTypeMaturity.
  ///
  /// In en, this message translates to:
  /// **'FD maturity'**
  String get reminderTypeMaturity;

  /// No description provided for @reminderTypeFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups on money owed to me'**
  String get reminderTypeFollowUp;

  /// No description provided for @reminderEmiTomorrow.
  ///
  /// In en, this message translates to:
  /// **'EMI due tomorrow'**
  String get reminderEmiTomorrow;

  /// No description provided for @reminderCardTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Card bill due tomorrow'**
  String get reminderCardTomorrow;

  /// No description provided for @reminderEmiToday.
  ///
  /// In en, this message translates to:
  /// **'EMI due today'**
  String get reminderEmiToday;

  /// No description provided for @reminderCardToday.
  ///
  /// In en, this message translates to:
  /// **'Card bill due today'**
  String get reminderCardToday;

  /// No description provided for @reminderSipToday.
  ///
  /// In en, this message translates to:
  /// **'SIP due today'**
  String get reminderSipToday;

  /// No description provided for @reminderSipBody.
  ///
  /// In en, this message translates to:
  /// **'{title}: invest {amount} today.'**
  String reminderSipBody(String title, String amount);

  /// No description provided for @reminderFdMatures.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{FD matures today} =1{FD matures tomorrow} other{FD matures in {n} days}}'**
  String reminderFdMatures(int n);

  /// No description provided for @reminderFdBody.
  ///
  /// In en, this message translates to:
  /// **'{title} ({amount} invested) matures on {date}.'**
  String reminderFdBody(String title, String amount, String date);

  /// No description provided for @reminderFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow up with {name}'**
  String reminderFollowUp(String name);

  /// No description provided for @reminderFollowUpBody.
  ///
  /// In en, this message translates to:
  /// **'{name} still owes you {amount}.'**
  String reminderFollowUpBody(String name, String amount);

  /// No description provided for @budgetAlertFull.
  ///
  /// In en, this message translates to:
  /// **'{name} budget used up'**
  String budgetAlertFull(String name);

  /// No description provided for @budgetAlert80.
  ///
  /// In en, this message translates to:
  /// **'80% of {name} budget used'**
  String budgetAlert80(String name);

  /// No description provided for @budgetAlertBody.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit} spent · {left}'**
  String budgetAlertBody(String used, String limit, String left);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day left} other{{n} days left}}'**
  String daysLeft(int n);

  /// No description provided for @reminderTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders are on'**
  String get reminderTestTitle;

  /// No description provided for @reminderTestBody.
  ///
  /// In en, this message translates to:
  /// **'You will hear about budgets, due dates, SIPs and maturities here. Nothing leaves your phone.'**
  String get reminderTestBody;

  /// No description provided for @smsAddDetails.
  ///
  /// In en, this message translates to:
  /// **'Add details'**
  String get smsAddDetails;

  /// No description provided for @smsIgnore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get smsIgnore;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @smsAmountFrom.
  ///
  /// In en, this message translates to:
  /// **'{amount} from {name}'**
  String smsAmountFrom(String amount, String name);

  /// No description provided for @smsAmountAt.
  ///
  /// In en, this message translates to:
  /// **'{amount} at {name}'**
  String smsAmountAt(String amount, String name);

  /// No description provided for @smsAmountInto.
  ///
  /// In en, this message translates to:
  /// **'{amount} into {name}'**
  String smsAmountInto(String amount, String name);

  /// No description provided for @smsMoneyReceived.
  ///
  /// In en, this message translates to:
  /// **'Money received: {what}'**
  String smsMoneyReceived(String what);

  /// No description provided for @smsNewExpense.
  ///
  /// In en, this message translates to:
  /// **'New expense: {what}'**
  String smsNewExpense(String what);

  /// No description provided for @smsAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to {where}?'**
  String smsAddTo(String where);

  /// No description provided for @smsIncomeAdded.
  ///
  /// In en, this message translates to:
  /// **'Income added: {what}'**
  String smsIncomeAdded(String what);

  /// No description provided for @smsExpenseAdded.
  ///
  /// In en, this message translates to:
  /// **'Expense added: {what}'**
  String smsExpenseAdded(String what);

  /// No description provided for @reminderChannelHelp.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts, due dates, SIPs and maturity reminders'**
  String get reminderChannelHelp;

  /// No description provided for @smsChannelHelp.
  ///
  /// In en, this message translates to:
  /// **'Asks before adding a bank or UPI transaction read from an SMS'**
  String get smsChannelHelp;

  /// No description provided for @unlockPrompt.
  ///
  /// In en, this message translates to:
  /// **'Unlock Expense Manager'**
  String get unlockPrompt;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @backupNeedsPassword.
  ///
  /// In en, this message translates to:
  /// **'This backup is password-protected'**
  String get backupNeedsPassword;

  /// No description provided for @backupWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get backupWrongPassword;

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'Not an Expense Manager backup'**
  String get backupInvalid;

  /// No description provided for @backupDamaged.
  ///
  /// In en, this message translates to:
  /// **'Backup file is damaged'**
  String get backupDamaged;

  /// No description provided for @backupTooNew.
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of the app. Update the app first.'**
  String get backupTooNew;

  /// No description provided for @backupNever.
  ///
  /// In en, this message translates to:
  /// **'Never backed up'**
  String get backupNever;

  /// No description provided for @backupLast.
  ///
  /// In en, this message translates to:
  /// **'Last backup {date}'**
  String backupLast(String date);

  /// No description provided for @importNeedColumns.
  ///
  /// In en, this message translates to:
  /// **'Need a date column and an amount (or debit/credit) column'**
  String get importNeedColumns;

  /// No description provided for @importInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid date \"{value}\"'**
  String importInvalidDate(String value);

  /// No description provided for @importInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get importInvalidAmount;

  /// No description provided for @investmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investmentsTitle;

  /// No description provided for @budgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// No description provided for @pdfLocked.
  ///
  /// In en, this message translates to:
  /// **'This PDF is password-protected. Save an unlocked copy (Print → Save as PDF) and import that.'**
  String get pdfLocked;

  /// No description provided for @pdfUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Could not read this PDF ({cause})'**
  String pdfUnreadable(String cause);

  /// No description provided for @bankStatement.
  ///
  /// In en, this message translates to:
  /// **'Bank statement'**
  String get bankStatement;

  /// No description provided for @emi.
  ///
  /// In en, this message translates to:
  /// **'EMI'**
  String get emi;

  /// No description provided for @cardBill.
  ///
  /// In en, this message translates to:
  /// **'Card bill'**
  String get cardBill;

  /// No description provided for @reminderDueTomorrowBody.
  ///
  /// In en, this message translates to:
  /// **'{title}: {what} is due tomorrow.'**
  String reminderDueTomorrowBody(String title, String what);

  /// No description provided for @reminderDueTomorrowAmountBody.
  ///
  /// In en, this message translates to:
  /// **'{title}: {what} of {amount} is due tomorrow.'**
  String reminderDueTomorrowAmountBody(String title, String what, String amount);

  /// No description provided for @reminderDueTodayBody.
  ///
  /// In en, this message translates to:
  /// **'{title}: {what} is due today.'**
  String reminderDueTodayBody(String title, String what);

  /// No description provided for @reminderDueTodayAmountBody.
  ///
  /// In en, this message translates to:
  /// **'{title}: {what} of {amount} is due today.'**
  String reminderDueTodayAmountBody(String title, String what, String amount);

  /// No description provided for @exportedOne.
  ///
  /// In en, this message translates to:
  /// **'Exported {what} to {path}'**
  String exportedOne(String what, String path);

  /// No description provided for @exportedMany.
  ///
  /// In en, this message translates to:
  /// **'Exported {n} files to {path}'**
  String exportedMany(int n, String path);

  /// No description provided for @exportHelp.
  ///
  /// In en, this message translates to:
  /// **'UTF-8 files that open in Excel or Sheets. Several files are shared as one zip.'**
  String get exportHelp;

  /// No description provided for @exportZip.
  ///
  /// In en, this message translates to:
  /// **'Export {n} files (zip)'**
  String exportZip(int n);

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @importPreview.
  ///
  /// In en, this message translates to:
  /// **'Import preview'**
  String get importPreview;

  /// No description provided for @importPdfEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions found in this PDF. Try the CSV/Excel export from net banking.'**
  String get importPdfEmpty;

  /// No description provided for @importFound.
  ///
  /// In en, this message translates to:
  /// **'{bank} · {n} found'**
  String importFound(String bank, int n);

  /// No description provided for @backupCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating backup…'**
  String get backupCreating;

  /// No description provided for @backupEncrypting.
  ///
  /// In en, this message translates to:
  /// **'Encrypting backup…'**
  String get backupEncrypting;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to {path}'**
  String backupSaved(String path);

  /// No description provided for @restoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get restoring;

  /// No description provided for @restoredN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Restored 1 transaction} other{Restored {n} transactions}}'**
  String restoredN(int n);

  /// No description provided for @addedN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Added 1 transaction} other{Added {n} transactions}}'**
  String addedN(int n);

  /// No description provided for @addedNSkipped.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Added 1 transaction} other{Added {n} transactions}} · {skipped} already here'**
  String addedNSkipped(int n, int skipped);

  /// No description provided for @backupHelp.
  ///
  /// In en, this message translates to:
  /// **'One .ledger file with all your data and receipts. Save it to Drive, Files or a computer.'**
  String get backupHelp;

  /// No description provided for @backupProtect.
  ///
  /// In en, this message translates to:
  /// **'Protect with a password'**
  String get backupProtect;

  /// No description provided for @backupPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Password (6+ characters)'**
  String get backupPasswordField;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @backupNoRecovery.
  ///
  /// In en, this message translates to:
  /// **'There is no way to recover a forgotten password.'**
  String get backupNoRecovery;

  /// No description provided for @backUp.
  ///
  /// In en, this message translates to:
  /// **'Back up'**
  String get backUp;

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @backupMade.
  ///
  /// In en, this message translates to:
  /// **'Made {date} · app {version}'**
  String backupMade(String date, String version);

  /// No description provided for @merge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get merge;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @restoreMergeHelp.
  ///
  /// In en, this message translates to:
  /// **'Adds what is missing on this phone. Matching categories, sources and accounts are reused; transactions already here are skipped.'**
  String get restoreMergeHelp;

  /// No description provided for @restoreReplaceHelp.
  ///
  /// In en, this message translates to:
  /// **'Deletes everything on this phone and uses the backup instead.'**
  String get restoreReplaceHelp;

  /// No description provided for @restoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'I understand my current data will be erased'**
  String get restoreConfirm;

  /// No description provided for @backupReminder.
  ///
  /// In en, this message translates to:
  /// **'Backup reminder'**
  String get backupReminder;

  /// No description provided for @backupBannerNever.
  ///
  /// In en, this message translates to:
  /// **'Your data lives only on this phone. Make a backup.'**
  String get backupBannerNever;

  /// No description provided for @backupBannerDue.
  ///
  /// In en, this message translates to:
  /// **'Time for a backup · {last}'**
  String backupBannerDue(String last);

  /// No description provided for @remindLater.
  ///
  /// In en, this message translates to:
  /// **'Remind me later'**
  String get remindLater;

  /// No description provided for @importedN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Imported 1 transaction} other{Imported {n} transactions}}'**
  String importedN(int n);

  /// No description provided for @importLine.
  ///
  /// In en, this message translates to:
  /// **'Line {n}'**
  String importLine(int n);

  /// No description provided for @importDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get importDuplicate;

  /// No description provided for @importToDefault.
  ///
  /// In en, this message translates to:
  /// **'Category → {name}'**
  String importToDefault(String name);

  /// No description provided for @importNewSub.
  ///
  /// In en, this message translates to:
  /// **'New sub-category: {name}'**
  String importNewSub(String name);

  /// No description provided for @importN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Import 1 transaction} other{Import {n} transactions}}'**
  String importN(int n);

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your money, on your phone'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Track spending, investments and debts in one place. Your data stays on this phone. There is no account, no server and no tracking.'**
  String get onbWelcomeBody;

  /// No description provided for @onbGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onbGetStarted;

  /// No description provided for @onbPointLocal.
  ///
  /// In en, this message translates to:
  /// **'Stored only on this device'**
  String get onbPointLocal;

  /// No description provided for @onbPointOffline.
  ///
  /// In en, this message translates to:
  /// **'Works fully offline'**
  String get onbPointOffline;

  /// No description provided for @onbPointExport.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV or PDF any time'**
  String get onbPointExport;

  /// No description provided for @onbNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get onbNameTitle;

  /// No description provided for @onbNameBody.
  ///
  /// In en, this message translates to:
  /// **'Used only for the greeting on the home screen. Optional.'**
  String get onbNameBody;

  /// No description provided for @onbCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your currency'**
  String get onbCurrencyTitle;

  /// No description provided for @onbCurrencyBody.
  ///
  /// In en, this message translates to:
  /// **'Amounts are shown in this currency. You can change it later in Settings.'**
  String get onbCurrencyBody;

  /// No description provided for @onbCurrencySample.
  ///
  /// In en, this message translates to:
  /// **'{currency} · e.g. {amount}'**
  String onbCurrencySample(String currency, String amount);

  /// No description provided for @onbSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you pay from?'**
  String get onbSourceTitle;

  /// No description provided for @onbSourceBody.
  ///
  /// In en, this message translates to:
  /// **'Add your main account. It becomes the default payment mode on new transactions. Leave it empty to start with {name}.'**
  String onbSourceBody(String name);

  /// No description provided for @sourceKindCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get sourceKindCash;

  /// No description provided for @sourceNameField.
  ///
  /// In en, this message translates to:
  /// **'Name, e.g. HDFC Savings'**
  String get sourceNameField;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @onbLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Tag places automatically?'**
  String get onbLocationTitle;

  /// No description provided for @onbLocationBody.
  ///
  /// In en, this message translates to:
  /// **'With location on, new transactions get the place you are at. It is saved only with your entries on this phone. You can always type a place instead.'**
  String get onbLocationBody;

  /// No description provided for @onbLocationContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue without location'**
  String get onbLocationContinue;

  /// No description provided for @onbLocationAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get onbLocationAllow;

  /// No description provided for @onbLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission was not granted. You can turn it on later in Settings.'**
  String get onbLocationDenied;

  /// No description provided for @onbSmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expenses from bank SMS?'**
  String get onbSmsTitle;

  /// No description provided for @onbSmsBodyShortcuts.
  ///
  /// In en, this message translates to:
  /// **'A Shortcuts automation can hand each bank, card or UPI SMS to us; we read it on this phone and ask whether to add it — one tap from the notification. Settings › Expenses from SMS shows how to set it up.'**
  String get onbSmsBodyShortcuts;

  /// No description provided for @onbSmsBody.
  ///
  /// In en, this message translates to:
  /// **'When a bank, card or UPI SMS arrives, we read it on this phone and ask whether to add it — one tap from the notification. OTPs and offers are skipped, and nothing is uploaded.'**
  String get onbSmsBody;

  /// No description provided for @onbSmsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue without SMS'**
  String get onbSmsContinue;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @onbSmsAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow SMS'**
  String get onbSmsAllow;

  /// No description provided for @onbSmsDenied.
  ///
  /// In en, this message translates to:
  /// **'SMS permission was not granted. You can turn this on later in Settings › Expenses from SMS.'**
  String get onbSmsDenied;

  /// No description provided for @onbLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock the app?'**
  String get onbLockTitle;

  /// No description provided for @onbLockBody.
  ///
  /// In en, this message translates to:
  /// **'Ask for a PIN (or your fingerprint / face) when the app opens, and hide amounts in the app switcher. You can change this anytime in Settings.'**
  String get onbLockBody;

  /// No description provided for @onbLockAction.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get onbLockAction;

  /// No description provided for @onbRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminders?'**
  String get onbRemindersTitle;

  /// No description provided for @onbRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'A heads-up when a budget reaches 80% or 100%, the day before an EMI or card bill is due, on SIP dates and before an FD matures. Planned on this phone; nothing is sent anywhere.'**
  String get onbRemindersBody;

  /// No description provided for @onbRemindersContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue without reminders'**
  String get onbRemindersContinue;

  /// No description provided for @onbRemindersAllow.
  ///
  /// In en, this message translates to:
  /// **'Turn on reminders'**
  String get onbRemindersAllow;

  /// No description provided for @onbRemindersDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. You can turn them on later in Settings › Reminders & alerts.'**
  String get onbRemindersDenied;

  /// No description provided for @currencyInr.
  ///
  /// In en, this message translates to:
  /// **'Indian rupee'**
  String get currencyInr;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US dollar'**
  String get currencyUsd;

  /// No description provided for @currencyEur.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyEur;

  /// No description provided for @currencyGbp.
  ///
  /// In en, this message translates to:
  /// **'British pound'**
  String get currencyGbp;

  /// No description provided for @currencyAed.
  ///
  /// In en, this message translates to:
  /// **'UAE dirham'**
  String get currencyAed;

  /// No description provided for @currencySgd.
  ///
  /// In en, this message translates to:
  /// **'Singapore dollar'**
  String get currencySgd;

  /// No description provided for @currencyAud.
  ///
  /// In en, this message translates to:
  /// **'Australian dollar'**
  String get currencyAud;

  /// No description provided for @currencyCad.
  ///
  /// In en, this message translates to:
  /// **'Canadian dollar'**
  String get currencyCad;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @homeSmsReview.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 transaction from SMS to review} other{{n} transactions from SMS to review}}'**
  String homeSmsReview(int n);

  /// No description provided for @homeOutThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Money out this month'**
  String get homeOutThisMonth;

  /// No description provided for @homeOutIn.
  ///
  /// In en, this message translates to:
  /// **'Money out in {month}'**
  String homeOutIn(String month);

  /// No description provided for @invested.
  ///
  /// In en, this message translates to:
  /// **'Invested'**
  String get invested;

  /// No description provided for @homeInvestedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'+{amount} this month'**
  String homeInvestedThisMonth(String amount);

  /// No description provided for @homeInvestedIn.
  ///
  /// In en, this message translates to:
  /// **'+{amount} in {month}'**
  String homeInvestedIn(String amount, String month);

  /// No description provided for @homeMonthlyEmi.
  ///
  /// In en, this message translates to:
  /// **'{amount}/mo EMI'**
  String homeMonthlyEmi(String amount);

  /// No description provided for @comingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get comingUp;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @whereItWent.
  ///
  /// In en, this message translates to:
  /// **'Where it went'**
  String get whereItWent;

  /// No description provided for @homeNoSpendYet.
  ///
  /// In en, this message translates to:
  /// **'No spending yet this month.'**
  String get homeNoSpendYet;

  /// No description provided for @homeNoSpendIn.
  ///
  /// In en, this message translates to:
  /// **'No spending in {period}.'**
  String homeNoSpendIn(String period);

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @homeNoTxns.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get homeNoTxns;

  /// No description provided for @homeNoTxnsHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first expense, investment or income.'**
  String get homeNoTxnsHelp;

  /// No description provided for @homeNothingIn.
  ///
  /// In en, this message translates to:
  /// **'Nothing in {period}'**
  String homeNothingIn(String period);

  /// No description provided for @homeNothingInHelp.
  ///
  /// In en, this message translates to:
  /// **'No transactions were recorded that month.'**
  String get homeNothingInHelp;

  /// No description provided for @homeOfIncome.
  ///
  /// In en, this message translates to:
  /// **'of {amount} income'**
  String homeOfIncome(String amount);

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @catKindInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get catKindInvestment;

  /// No description provided for @catMove.
  ///
  /// In en, this message translates to:
  /// **'Move {name}'**
  String catMove(String name);

  /// No description provided for @catTopLevel.
  ///
  /// In en, this message translates to:
  /// **'Top level'**
  String get catTopLevel;

  /// No description provided for @catUnder.
  ///
  /// In en, this message translates to:
  /// **'Under {name}'**
  String catUnder(String name);

  /// No description provided for @catMoveOnlyLeaf.
  ///
  /// In en, this message translates to:
  /// **'Only categories without sub-categories can be moved under another'**
  String get catMoveOnlyLeaf;

  /// No description provided for @catDefaultHelp.
  ///
  /// In en, this message translates to:
  /// **'Default — used when nothing is picked'**
  String get catDefaultHelp;

  /// No description provided for @catAddSub.
  ///
  /// In en, this message translates to:
  /// **'Add sub-category'**
  String get catAddSub;

  /// No description provided for @catMoveMenu.
  ///
  /// In en, this message translates to:
  /// **'Move…'**
  String get catMoveMenu;

  /// No description provided for @catMoveUnderMenu.
  ///
  /// In en, this message translates to:
  /// **'Move under…'**
  String get catMoveUnderMenu;

  /// No description provided for @catArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive {name}'**
  String catArchive(String name);

  /// No description provided for @catArchived.
  ///
  /// In en, this message translates to:
  /// **'{name} archived'**
  String catArchived(String name);

  /// No description provided for @catAdd.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get catAdd;

  /// No description provided for @catSpendHelp.
  ///
  /// In en, this message translates to:
  /// **'Money that’s gone — food, rent, bills. Tap ⋮ to add sub-categories.'**
  String get catSpendHelp;

  /// No description provided for @catInvestHelp.
  ///
  /// In en, this message translates to:
  /// **'Money out that still grows your net worth.'**
  String get catInvestHelp;

  /// No description provided for @catIncomeHelp.
  ///
  /// In en, this message translates to:
  /// **'Money coming in.'**
  String get catIncomeHelp;

  /// No description provided for @catArchivedCount.
  ///
  /// In en, this message translates to:
  /// **'Archived ({n})'**
  String catArchivedCount(int n);

  /// No description provided for @catArchivedHelp.
  ///
  /// In en, this message translates to:
  /// **'Kept for history; not offered on new transactions'**
  String get catArchivedHelp;

  /// No description provided for @catKindUnder.
  ///
  /// In en, this message translates to:
  /// **'{kind} · under {parent}'**
  String catKindUnder(String kind, String parent);

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @catRestored.
  ///
  /// In en, this message translates to:
  /// **'{name} restored'**
  String catRestored(String name);

  /// No description provided for @catNew.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get catNew;

  /// No description provided for @catNewSub.
  ///
  /// In en, this message translates to:
  /// **'New sub-category in {name}'**
  String catNewSub(String name);

  /// No description provided for @immediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get immediately;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{n} s'**
  String seconds(int n);

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String minutes(int n);

  /// No description provided for @pinChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN'**
  String get pinChoose;

  /// No description provided for @pinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get pinConfirm;

  /// No description provided for @pinDigits.
  ///
  /// In en, this message translates to:
  /// **'Enter 4–6 digits'**
  String get pinDigits;

  /// No description provided for @pinAgain.
  ///
  /// In en, this message translates to:
  /// **'Enter the same PIN again'**
  String get pinAgain;

  /// No description provided for @pinCooldown.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {n} s'**
  String pinCooldown(int n);

  /// No description provided for @pinWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get pinWrong;

  /// No description provided for @pinCurrent.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get pinCurrent;

  /// No description provided for @lockOn.
  ///
  /// In en, this message translates to:
  /// **'App lock is on'**
  String get lockOn;

  /// No description provided for @pinChanged.
  ///
  /// In en, this message translates to:
  /// **'PIN changed'**
  String get pinChanged;

  /// No description provided for @encryptTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypt the database?'**
  String get encryptTitle;

  /// No description provided for @encryptBody.
  ///
  /// In en, this message translates to:
  /// **'Your data will be encrypted with a key kept in this phone\'s secure storage. If that key is lost (for example, app data is cleared), the data cannot be recovered — export a backup first.'**
  String get encryptBody;

  /// No description provided for @encrypt.
  ///
  /// In en, this message translates to:
  /// **'Encrypt'**
  String get encrypt;

  /// No description provided for @dbEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Database encrypted'**
  String get dbEncrypted;

  /// No description provided for @dbDecrypted.
  ///
  /// In en, this message translates to:
  /// **'Database decrypted'**
  String get dbDecrypted;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @lockWithPin.
  ///
  /// In en, this message translates to:
  /// **'Lock with PIN'**
  String get lockWithPin;

  /// No description provided for @lockWithPinHelp.
  ///
  /// In en, this message translates to:
  /// **'Asked when the app opens'**
  String get lockWithPinHelp;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @unlockBiometric.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint / face'**
  String get unlockBiometric;

  /// No description provided for @notAvailableDevice.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get notAvailableDevice;

  /// No description provided for @lockAgainAfter.
  ///
  /// In en, this message translates to:
  /// **'Lock again after leaving the app'**
  String get lockAgainAfter;

  /// No description provided for @hideSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Hide in app switcher'**
  String get hideSwitcher;

  /// No description provided for @hideSwitcherHelp.
  ///
  /// In en, this message translates to:
  /// **'Blurs the recent-apps preview and blocks screenshots'**
  String get hideSwitcherHelp;

  /// No description provided for @encryption.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get encryption;

  /// No description provided for @encryptDb.
  ///
  /// In en, this message translates to:
  /// **'Encrypt database'**
  String get encryptDb;

  /// No description provided for @encryptKeyStored.
  ///
  /// In en, this message translates to:
  /// **'Key stored in the phone\'s secure storage'**
  String get encryptKeyStored;

  /// No description provided for @encryptUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available for this database'**
  String get encryptUnavailable;

  /// No description provided for @budgetNew.
  ///
  /// In en, this message translates to:
  /// **'New budget'**
  String get budgetNew;

  /// No description provided for @budgetTabWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly · {span}'**
  String budgetTabWeekly(String span);

  /// No description provided for @budgetTabMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly · 1st–end'**
  String get budgetTabMonthly;

  /// No description provided for @budgetOverBanner.
  ///
  /// In en, this message translates to:
  /// **'{name} is over by {amount}'**
  String budgetOverBanner(String name, String amount);

  /// No description provided for @budgetNoneWeekly.
  ///
  /// In en, this message translates to:
  /// **'No weekly budgets'**
  String get budgetNoneWeekly;

  /// No description provided for @budgetNoneMonthly.
  ///
  /// In en, this message translates to:
  /// **'No monthly budgets'**
  String get budgetNoneMonthly;

  /// No description provided for @budgetEmptyHelp.
  ///
  /// In en, this message translates to:
  /// **'Set a limit for any category and track it every cycle.'**
  String get budgetEmptyHelp;

  /// No description provided for @budgetCreate.
  ///
  /// In en, this message translates to:
  /// **'Create budget'**
  String get budgetCreate;

  /// No description provided for @budgetGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get budgetGoalReached;

  /// No description provided for @budgetToGoal.
  ///
  /// In en, this message translates to:
  /// **'{amount} to reach goal'**
  String budgetToGoal(String amount);

  /// No description provided for @budgetOverBy.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String budgetOverBy(String amount);

  /// No description provided for @budgetLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left · {perDay}/day · {days}'**
  String budgetLeft(String amount, String perDay, String days);

  /// No description provided for @budgetAllInvestments.
  ///
  /// In en, this message translates to:
  /// **'All investments'**
  String get budgetAllInvestments;

  /// No description provided for @budgetAllSpending.
  ///
  /// In en, this message translates to:
  /// **'All spending'**
  String get budgetAllSpending;

  /// No description provided for @nCategories.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 category} other{{n} categories}}'**
  String nCategories(int n);

  /// No description provided for @ofAmount.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String ofAmount(String amount);

  /// No description provided for @budgetNeedNameLimit.
  ///
  /// In en, this message translates to:
  /// **'Add a name and a limit'**
  String get budgetNeedNameLimit;

  /// No description provided for @budgetEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get budgetEdit;

  /// No description provided for @budgetDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete budget'**
  String get budgetDelete;

  /// No description provided for @budgetNameField.
  ///
  /// In en, this message translates to:
  /// **'Name, e.g. Food'**
  String get budgetNameField;

  /// No description provided for @budgetLimitField.
  ///
  /// In en, this message translates to:
  /// **'Limit ({symbol})'**
  String budgetLimitField(String symbol);

  /// No description provided for @budgetSuggestion.
  ///
  /// In en, this message translates to:
  /// **'You averaged {amount}/month over the last 3 months · tap to use'**
  String budgetSuggestion(String amount);

  /// No description provided for @budgetRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats every'**
  String get budgetRepeats;

  /// No description provided for @budgetWeek.
  ///
  /// In en, this message translates to:
  /// **'Week ({span})'**
  String budgetWeek(String span);

  /// No description provided for @budgetMonth.
  ///
  /// In en, this message translates to:
  /// **'Month (1st → end)'**
  String get budgetMonth;

  /// No description provided for @budgetGoal.
  ///
  /// In en, this message translates to:
  /// **'Investment goal'**
  String get budgetGoal;

  /// No description provided for @budgetGoalHelp.
  ///
  /// In en, this message translates to:
  /// **'Track a target for money invested instead of a spending cap'**
  String get budgetGoalHelp;

  /// No description provided for @budgetCounts.
  ///
  /// In en, this message translates to:
  /// **'Counts these investments'**
  String get budgetCounts;

  /// No description provided for @budgetAppliesTo.
  ///
  /// In en, this message translates to:
  /// **'Applies to (empty = all spending)'**
  String get budgetAppliesTo;

  /// No description provided for @budgetRollover.
  ///
  /// In en, this message translates to:
  /// **'Roll over unspent amount'**
  String get budgetRollover;

  /// No description provided for @budgetAlert80Switch.
  ///
  /// In en, this message translates to:
  /// **'Alert at 80%'**
  String get budgetAlert80Switch;

  /// No description provided for @budgetAlertOver.
  ///
  /// In en, this message translates to:
  /// **'Alert when over'**
  String get budgetAlertOver;

  /// No description provided for @budgetSave.
  ///
  /// In en, this message translates to:
  /// **'Save budget'**
  String get budgetSave;

  /// No description provided for @totalInvested.
  ///
  /// In en, this message translates to:
  /// **'Total invested'**
  String get totalInvested;

  /// No description provided for @investThisMonth.
  ///
  /// In en, this message translates to:
  /// **'+{amount} this month · {n, plural, =1{1 holding} other{{n} holdings}}'**
  String investThisMonth(String amount, int n);

  /// No description provided for @investNoPrices.
  ///
  /// In en, this message translates to:
  /// **'Amounts you put in · no live prices or returns'**
  String get investNoPrices;

  /// No description provided for @investMaturesOn.
  ///
  /// In en, this message translates to:
  /// **'{name} matures on {date}'**
  String investMaturesOn(String name, String date);

  /// No description provided for @investNone.
  ///
  /// In en, this message translates to:
  /// **'No investments yet'**
  String get investNone;

  /// No description provided for @investNoneHelp.
  ///
  /// In en, this message translates to:
  /// **'Add an FD, SIP, stock or gold holding to track what you invest.'**
  String get investNoneHelp;

  /// No description provided for @investAdd.
  ///
  /// In en, this message translates to:
  /// **'Add investment'**
  String get investAdd;

  /// No description provided for @investMatures.
  ///
  /// In en, this message translates to:
  /// **'matures {date}'**
  String investMatures(String date);

  /// No description provided for @nEntries.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 entry} other{{n} entries}}'**
  String nEntries(int n);

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest rate'**
  String get interestRate;

  /// No description provided for @investStarted.
  ///
  /// In en, this message translates to:
  /// **'Started {date}'**
  String investStarted(String date);

  /// No description provided for @investMaturesCap.
  ///
  /// In en, this message translates to:
  /// **'Matures {date}'**
  String investMaturesCap(String date);

  /// No description provided for @institution.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get institution;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @contributions.
  ///
  /// In en, this message translates to:
  /// **'Contributions ({n})'**
  String contributions(int n);

  /// No description provided for @investNoMoney.
  ///
  /// In en, this message translates to:
  /// **'No money added yet.'**
  String get investNoMoney;

  /// No description provided for @investAddMoney.
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get investAddMoney;

  /// No description provided for @investMarkMatured.
  ///
  /// In en, this message translates to:
  /// **'Mark matured'**
  String get investMarkMatured;

  /// No description provided for @investCloseSold.
  ///
  /// In en, this message translates to:
  /// **'Close / sold'**
  String get investCloseSold;

  /// No description provided for @investReactivate.
  ///
  /// In en, this message translates to:
  /// **'Mark active again'**
  String get investReactivate;

  /// No description provided for @investNeedName.
  ///
  /// In en, this message translates to:
  /// **'Give the investment a name'**
  String get investNeedName;

  /// No description provided for @investNameField.
  ///
  /// In en, this message translates to:
  /// **'Name, e.g. HDFC Bank FD'**
  String get investNameField;

  /// No description provided for @investInstitutionField.
  ///
  /// In en, this message translates to:
  /// **'Bank / platform (optional)'**
  String get investInstitutionField;

  /// No description provided for @investAmountField.
  ///
  /// In en, this message translates to:
  /// **'Amount invested now (optional)'**
  String get investAmountField;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @maturityDate.
  ///
  /// In en, this message translates to:
  /// **'Maturity date (optional)'**
  String get maturityDate;

  /// No description provided for @investSave.
  ///
  /// In en, this message translates to:
  /// **'Save investment'**
  String get investSave;

  /// No description provided for @sourceKindBank.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get sourceKindBank;

  /// No description provided for @sourceKindWallet.
  ///
  /// In en, this message translates to:
  /// **'UPI / wallet'**
  String get sourceKindWallet;

  /// No description provided for @sourceAdd.
  ///
  /// In en, this message translates to:
  /// **'Add payment source'**
  String get sourceAdd;

  /// No description provided for @sourceDefaultHelp.
  ///
  /// In en, this message translates to:
  /// **'Pre-selected on every new transaction'**
  String get sourceDefaultHelp;

  /// No description provided for @sourceOutIn.
  ///
  /// In en, this message translates to:
  /// **'{kind} · {amount} out in {month}'**
  String sourceOutIn(String kind, String amount, String month);

  /// No description provided for @sourceLimit.
  ///
  /// In en, this message translates to:
  /// **'limit {amount}'**
  String sourceLimit(String amount);

  /// No description provided for @sourceBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance {amount}'**
  String sourceBalance(String amount);

  /// No description provided for @sourceOutstanding.
  ///
  /// In en, this message translates to:
  /// **'{amount} outstanding'**
  String sourceOutstanding(String amount);

  /// No description provided for @sourceCredit.
  ///
  /// In en, this message translates to:
  /// **'{amount} credit'**
  String sourceCredit(String amount);

  /// No description provided for @sourceNew.
  ///
  /// In en, this message translates to:
  /// **'New payment source'**
  String get sourceNew;

  /// No description provided for @sourceLast4.
  ///
  /// In en, this message translates to:
  /// **'Last 4 digits (optional)'**
  String get sourceLast4;

  /// No description provided for @sourceCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit limit ({symbol})'**
  String sourceCreditLimit(String symbol);

  /// No description provided for @sourceBalanceHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional · defaults to {amount}'**
  String sourceBalanceHelp(String amount);

  /// No description provided for @makeDefault.
  ///
  /// In en, this message translates to:
  /// **'Make default'**
  String get makeDefault;

  /// No description provided for @sourceOutstandingField.
  ///
  /// In en, this message translates to:
  /// **'Outstanding now ({symbol})'**
  String sourceOutstandingField(String symbol);

  /// No description provided for @sourceBalanceField.
  ///
  /// In en, this message translates to:
  /// **'Current balance ({symbol})'**
  String sourceBalanceField(String symbol);

  /// No description provided for @sourceAdjustHelp.
  ///
  /// In en, this message translates to:
  /// **'Transactions you add will adjust it from here'**
  String get sourceAdjustHelp;

  /// No description provided for @pdfReport.
  ///
  /// In en, this message translates to:
  /// **'PDF report'**
  String get pdfReport;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @previousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get previousPeriod;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get nextPeriod;

  /// No description provided for @insightsDonutLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent {spent}, invested {invested}'**
  String insightsDonutLabel(String spent, String invested);

  /// No description provided for @moneyOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Money out'**
  String get moneyOutLabel;

  /// No description provided for @insightsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {n}% of income'**
  String insightsSaved(int n);

  /// No description provided for @insightsNoEarlier.
  ///
  /// In en, this message translates to:
  /// **'No earlier data'**
  String get insightsNoEarlier;

  /// No description provided for @insightsLessSpent.
  ///
  /// In en, this message translates to:
  /// **'{n}% less spent'**
  String insightsLessSpent(int n);

  /// No description provided for @insightsMoreSpent.
  ///
  /// In en, this message translates to:
  /// **'{n}% more spent'**
  String insightsMoreSpent(int n);

  /// No description provided for @insightsThanPrevious.
  ///
  /// In en, this message translates to:
  /// **'than previous period'**
  String get insightsThanPrevious;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'{amount} / day'**
  String perDay(String amount);

  /// No description provided for @averageSpend.
  ///
  /// In en, this message translates to:
  /// **'average spend'**
  String get averageSpend;

  /// No description provided for @monthByMonth.
  ///
  /// In en, this message translates to:
  /// **'Month by month'**
  String get monthByMonth;

  /// No description provided for @weekByWeek.
  ///
  /// In en, this message translates to:
  /// **'Week by week'**
  String get weekByWeek;

  /// No description provided for @dayByDay.
  ///
  /// In en, this message translates to:
  /// **'Day by day'**
  String get dayByDay;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @insightsNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded in this period.'**
  String get insightsNothing;

  /// No description provided for @insightsDirect.
  ///
  /// In en, this message translates to:
  /// **'{name} (direct)'**
  String insightsDirect(String name);

  /// No description provided for @insightsCatRow.
  ///
  /// In en, this message translates to:
  /// **'{name}  ·  {n, plural, =1{1 txn} other{{n} txns}}'**
  String insightsCatRow(String name, int n);

  /// No description provided for @hideSubs.
  ///
  /// In en, this message translates to:
  /// **'Hide sub-categories'**
  String get hideSubs;

  /// No description provided for @showSubs.
  ///
  /// In en, this message translates to:
  /// **'Show sub-categories'**
  String get showSubs;

  /// No description provided for @smsReadTitle.
  ///
  /// In en, this message translates to:
  /// **'Read bank SMS?'**
  String get smsReadTitle;

  /// No description provided for @smsReadBodyShortcuts.
  ///
  /// In en, this message translates to:
  /// **'iPhone apps can\'t read SMS, so a Shortcuts automation hands each bank message to Expense Manager. It is read on this phone and you are asked whether to add the transaction.\n\nNothing is sent anywhere. OTPs, offers and reminders are skipped. Next, set up the automation using the steps on this screen.'**
  String get smsReadBodyShortcuts;

  /// No description provided for @smsReadBody.
  ///
  /// In en, this message translates to:
  /// **'When a bank, card or UPI SMS arrives, Expense Manager reads it on this phone and asks whether to add the transaction.\n\nOnly messages with an amount that was debited or credited are kept, and nothing is sent anywhere. OTPs, offers and reminders are skipped.'**
  String get smsReadBody;

  /// No description provided for @smsDenied.
  ///
  /// In en, this message translates to:
  /// **'SMS permission was denied. Allow it for Expense Manager in system settings.'**
  String get smsDenied;

  /// No description provided for @smsNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked, so new expenses will only show up here.'**
  String get smsNoNotifications;

  /// No description provided for @addedThing.
  ///
  /// In en, this message translates to:
  /// **'Added {what}'**
  String addedThing(String what);

  /// No description provided for @smsAskToAdd.
  ///
  /// In en, this message translates to:
  /// **'Ask to add bank SMS'**
  String get smsAskToAdd;

  /// No description provided for @smsAskToAddHelp.
  ///
  /// In en, this message translates to:
  /// **'Read on this phone · nothing is uploaded'**
  String get smsAskToAddHelp;

  /// No description provided for @smsPermissionOff.
  ///
  /// In en, this message translates to:
  /// **'SMS permission is off, so new messages are not read.'**
  String get smsPermissionOff;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @smsNothingToReview.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review'**
  String get smsNothingToReview;

  /// No description provided for @smsToReview.
  ///
  /// In en, this message translates to:
  /// **'To review ({n})'**
  String smsToReview(int n);

  /// No description provided for @smsOnHelp.
  ///
  /// In en, this message translates to:
  /// **'New bank and UPI transactions show up here and as a notification.'**
  String get smsOnHelp;

  /// No description provided for @smsOffHelp.
  ///
  /// In en, this message translates to:
  /// **'Turn this on to be asked about each bank or UPI transaction as its SMS arrives.'**
  String get smsOffHelp;

  /// No description provided for @smsStep1.
  ///
  /// In en, this message translates to:
  /// **'Open Shortcuts → Automation → + (New Automation) → Message.'**
  String get smsStep1;

  /// No description provided for @smsStep2.
  ///
  /// In en, this message translates to:
  /// **'Message Contains: {keyword}. Choose Run Immediately, then Next.'**
  String smsStep2(String keyword);

  /// No description provided for @smsStep3.
  ///
  /// In en, this message translates to:
  /// **'New Blank Automation → Add Action → search \"{action}\" (Expense Manager).'**
  String smsStep3(String action);

  /// No description provided for @smsStep4.
  ///
  /// In en, this message translates to:
  /// **'Tap Message in the action and pick Shortcut Input. Done.'**
  String get smsStep4;

  /// No description provided for @smsStep5.
  ///
  /// In en, this message translates to:
  /// **'Repeat with \"{first}\" and \"{second}\" to catch more banks.'**
  String smsStep5(String first, String second);

  /// No description provided for @couldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpen(String url);

  /// No description provided for @smsSetupIphone.
  ///
  /// In en, this message translates to:
  /// **'Set up on iPhone'**
  String get smsSetupIphone;

  /// No description provided for @smsSetupIphoneHelp.
  ///
  /// In en, this message translates to:
  /// **'iOS doesn\'t let apps read SMS. A Shortcuts automation passes each bank message to Expense Manager instead (iOS 17 or later runs it without asking).'**
  String get smsSetupIphoneHelp;

  /// No description provided for @smsOpenShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Open Shortcuts'**
  String get smsOpenShortcuts;

  /// No description provided for @smsGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide with pictures'**
  String get smsGuide;

  /// No description provided for @sipStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop this SIP?'**
  String get sipStopTitle;

  /// No description provided for @sipStopBody.
  ///
  /// In en, this message translates to:
  /// **'Contributions already recorded stay on this investment.'**
  String get sipStopBody;

  /// No description provided for @sipStop.
  ///
  /// In en, this message translates to:
  /// **'Stop SIP'**
  String get sipStop;

  /// No description provided for @sipSetup.
  ///
  /// In en, this message translates to:
  /// **'Set up a monthly SIP'**
  String get sipSetup;

  /// No description provided for @sipSummary.
  ///
  /// In en, this message translates to:
  /// **'SIP · {amount} on day {day}'**
  String sipSummary(String amount, int day);

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @nextOn.
  ///
  /// In en, this message translates to:
  /// **'Next {date}'**
  String nextOn(String date);

  /// No description provided for @nextOnFrom.
  ///
  /// In en, this message translates to:
  /// **'Next {date} · {source}'**
  String nextOnFrom(String date, String source);

  /// No description provided for @sipAuto.
  ///
  /// In en, this message translates to:
  /// **'Added automatically'**
  String get sipAuto;

  /// No description provided for @sipReminderOnly.
  ///
  /// In en, this message translates to:
  /// **'Reminder only · record it when you pay'**
  String get sipReminderOnly;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @sipMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly SIP'**
  String get sipMonthly;

  /// No description provided for @sipEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit SIP'**
  String get sipEdit;

  /// No description provided for @sipAmountField.
  ///
  /// In en, this message translates to:
  /// **'Amount each month ({symbol})'**
  String sipAmountField(String symbol);

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get dayOfMonth;

  /// No description provided for @sipAutoOption.
  ///
  /// In en, this message translates to:
  /// **'Add it automatically'**
  String get sipAutoOption;

  /// No description provided for @sipAutoOptionHelp.
  ///
  /// In en, this message translates to:
  /// **'Records the invest transaction each month'**
  String get sipAutoOptionHelp;

  /// No description provided for @sipRemindOption.
  ///
  /// In en, this message translates to:
  /// **'Remind me only'**
  String get sipRemindOption;

  /// No description provided for @sipRemindOptionHelp.
  ///
  /// In en, this message translates to:
  /// **'Shows it as coming up; you record it'**
  String get sipRemindOptionHelp;

  /// No description provided for @shareLog.
  ///
  /// In en, this message translates to:
  /// **'Share log'**
  String get shareLog;

  /// No description provided for @clearLog.
  ///
  /// In en, this message translates to:
  /// **'Clear log'**
  String get clearLog;

  /// No description provided for @logCleared.
  ///
  /// In en, this message translates to:
  /// **'Error log cleared'**
  String get logCleared;

  /// No description provided for @noErrors.
  ///
  /// In en, this message translates to:
  /// **'No errors recorded'**
  String get noErrors;

  /// No description provided for @noErrorsHelp.
  ///
  /// In en, this message translates to:
  /// **'Crashes and errors are logged on this phone only. Share the log if you report a bug.'**
  String get noErrorsHelp;

  /// No description provided for @reminderOn.
  ///
  /// In en, this message translates to:
  /// **'Reminder on {date}'**
  String reminderOn(String date);

  /// No description provided for @changeDate.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get changeDate;

  /// No description provided for @remindMeOn.
  ///
  /// In en, this message translates to:
  /// **'Remind me on'**
  String get remindMeOn;

  /// No description provided for @willRemind.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you on {date}'**
  String willRemind(String date);

  /// No description provided for @savedTurnOnReminders.
  ///
  /// In en, this message translates to:
  /// **'Saved. Turn on Settings › Reminders & alerts to get a notification.'**
  String get savedTurnOnReminders;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Current location unavailable. Allow location access or search instead.'**
  String get locationUnavailable;

  /// No description provided for @pickLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick location'**
  String get pickLocation;

  /// No description provided for @searchPlace.
  ///
  /// In en, this message translates to:
  /// **'Search a place or address'**
  String get searchPlace;

  /// No description provided for @noPlaceMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches. Try another name, or tap the map.'**
  String get noPlaceMatches;

  /// No description provided for @placeName.
  ///
  /// In en, this message translates to:
  /// **'Place name'**
  String get placeName;

  /// No description provided for @tapMapForPin.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to drop a pin'**
  String get tapMapForPin;

  /// No description provided for @pinWrongLeft.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN · {n, plural, =1{1 attempt left} other{{n} attempts left}}'**
  String pinWrongLeft(int n);

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'Expense Manager is locked'**
  String get appLocked;

  /// No description provided for @ended.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get ended;

  /// No description provided for @reminderOnly.
  ///
  /// In en, this message translates to:
  /// **'reminder only'**
  String get reminderOnly;

  /// No description provided for @deleteSchedule.
  ///
  /// In en, this message translates to:
  /// **'Delete this schedule?'**
  String get deleteSchedule;

  /// No description provided for @deleteScheduleBody.
  ///
  /// In en, this message translates to:
  /// **'No more transactions will be added. Ones already added stay.'**
  String get deleteScheduleBody;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// No description provided for @nothingRecurring.
  ///
  /// In en, this message translates to:
  /// **'Nothing recurring yet'**
  String get nothingRecurring;

  /// No description provided for @nothingRecurringHelp.
  ///
  /// In en, this message translates to:
  /// **'Turn on “Repeat” when adding a transaction, or set up a SIP on an investment.'**
  String get nothingRecurringHelp;

  /// No description provided for @deleteRule.
  ///
  /// In en, this message translates to:
  /// **'Delete rule'**
  String get deleteRule;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit schedule'**
  String get editSchedule;

  /// No description provided for @onTheDay.
  ///
  /// In en, this message translates to:
  /// **'On the day'**
  String get onTheDay;

  /// No description provided for @daysBefore.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day before} other{{n} days before}}'**
  String daysBefore(int n);

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Allow them for Expense Manager in system settings.'**
  String get notificationsBlocked;

  /// No description provided for @testSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get testSent;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsHelp.
  ///
  /// In en, this message translates to:
  /// **'Planned on this phone · nothing is sent to a server'**
  String get notificationsHelp;

  /// No description provided for @fdLeadTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind me before an FD matures'**
  String get fdLeadTitle;

  /// No description provided for @remindersInfo.
  ///
  /// In en, this message translates to:
  /// **'Reminders arrive around {time}: due dates the day before and on the day, SIPs on their date, and budget alerts once per budget when it reaches 80% and 100%.'**
  String remindersInfo(String time);

  /// No description provided for @sendTest.
  ///
  /// In en, this message translates to:
  /// **'Send a test notification'**
  String get sendTest;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'in {n} days'**
  String inDays(int n);

  /// No description provided for @upcomingEmi.
  ///
  /// In en, this message translates to:
  /// **'EMI due'**
  String get upcomingEmi;

  /// No description provided for @upcomingCard.
  ///
  /// In en, this message translates to:
  /// **'Card bill due'**
  String get upcomingCard;

  /// No description provided for @upcomingMaturity.
  ///
  /// In en, this message translates to:
  /// **'Matures'**
  String get upcomingMaturity;

  /// No description provided for @upcomingSip.
  ///
  /// In en, this message translates to:
  /// **'SIP due'**
  String get upcomingSip;

  /// No description provided for @upcomingFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow up'**
  String get upcomingFollowUp;

  /// No description provided for @nothingComingUp.
  ///
  /// In en, this message translates to:
  /// **'Nothing coming up'**
  String get nothingComingUp;

  /// No description provided for @nothingComingUpHelp.
  ///
  /// In en, this message translates to:
  /// **'EMIs, card bills and FD maturities in the next 60 days show up here.'**
  String get nothingComingUpHelp;

  /// No description provided for @txnDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get txnDeleted;

  /// No description provided for @txnGone.
  ///
  /// In en, this message translates to:
  /// **'This transaction no longer exists.'**
  String get txnGone;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get dateTime;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @repeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeats;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @pdfReceipt.
  ///
  /// In en, this message translates to:
  /// **'PDF receipt'**
  String get pdfReceipt;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @receiptMissing.
  ///
  /// In en, this message translates to:
  /// **'Receipt file not found'**
  String get receiptMissing;

  /// No description provided for @keyPlus.
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get keyPlus;

  /// No description provided for @keyMinus.
  ///
  /// In en, this message translates to:
  /// **'Minus'**
  String get keyMinus;

  /// No description provided for @keyEquals.
  ///
  /// In en, this message translates to:
  /// **'Equals'**
  String get keyEquals;

  /// No description provided for @keyDecimal.
  ///
  /// In en, this message translates to:
  /// **'Decimal point'**
  String get keyDecimal;

  /// No description provided for @keyDoubleZero.
  ///
  /// In en, this message translates to:
  /// **'Double zero'**
  String get keyDoubleZero;

  /// No description provided for @keyBackspace.
  ///
  /// In en, this message translates to:
  /// **'Backspace'**
  String get keyBackspace;

  /// No description provided for @allOf.
  ///
  /// In en, this message translates to:
  /// **'All {name}'**
  String allOf(String name);

  /// No description provided for @chartBarLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}: spent {spent}, invested {invested}'**
  String chartBarLabel(String label, String spent, String invested);

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs didn\'t match. Try again.'**
  String get pinMismatch;

  /// No description provided for @encryptFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t change encryption: {error}'**
  String encryptFailed(String error);

  /// No description provided for @pdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense report'**
  String get pdfTitle;

  /// No description provided for @pdfTitleFor.
  ///
  /// In en, this message translates to:
  /// **'Expense report {period}'**
  String pdfTitleFor(String period);

  /// No description provided for @pdfDebtPaid.
  ///
  /// In en, this message translates to:
  /// **'Debt paid'**
  String get pdfDebtPaid;

  /// No description provided for @pdfSpendByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spend by category'**
  String get pdfSpendByCategory;

  /// No description provided for @pdfTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions ({n})'**
  String pdfTransactions(int n);

  /// No description provided for @seedFood.
  ///
  /// In en, this message translates to:
  /// **'Food & dining'**
  String get seedFood;

  /// No description provided for @seedRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get seedRent;

  /// No description provided for @seedShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get seedShopping;

  /// No description provided for @seedTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get seedTransport;

  /// No description provided for @seedBills.
  ///
  /// In en, this message translates to:
  /// **'Bills & utilities'**
  String get seedBills;

  /// No description provided for @seedHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get seedHealth;

  /// No description provided for @seedEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get seedEntertainment;

  /// No description provided for @seedTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get seedTravel;

  /// No description provided for @seedOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get seedOthers;

  /// No description provided for @seedFd.
  ///
  /// In en, this message translates to:
  /// **'Fixed deposit'**
  String get seedFd;

  /// No description provided for @seedMutualFunds.
  ///
  /// In en, this message translates to:
  /// **'Mutual funds / SIP'**
  String get seedMutualFunds;

  /// No description provided for @seedRetirement.
  ///
  /// In en, this message translates to:
  /// **'PPF / EPF / NPS'**
  String get seedRetirement;

  /// No description provided for @seedSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get seedSalary;

  /// No description provided for @seedOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other income'**
  String get seedOtherIncome;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr', 'gu', 'hi', 'ja', 'or'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'or':
      return AppLocalizationsOr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
