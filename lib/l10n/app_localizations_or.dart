// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get appTitle => 'Expense Manager';

  @override
  String get navHome => 'ହୋମ';

  @override
  String get navInsights => 'ବିଶ୍ଳେଷଣ';

  @override
  String get navInvest => 'ନିବେଶ';

  @override
  String get navDebts => 'ଋଣ';

  @override
  String get addTransaction => 'କାରବାର ଯୋଡନ୍ତୁ';

  @override
  String get ok => 'ଠିକ ଅଛି';

  @override
  String get save => 'ସେଭ କରନ୍ତୁ';

  @override
  String get cancel => 'ବାତିଲ';

  @override
  String get none => 'କିଛି ନାହିଁ';

  @override
  String get notSet => 'ସେଟ ହୋଇନାହିଁ';

  @override
  String get on => 'ଚାଲୁ';

  @override
  String get off => 'ବନ୍ଦ';

  @override
  String get unknown => 'ଅଜଣା';

  @override
  String get today => 'ଆଜି';

  @override
  String get yesterday => 'ଗତକାଲି';

  @override
  String nActive(int count) {
    return '$count ସକ୍ରିୟ';
  }

  @override
  String get locationDenied => 'ଲୋକେସନ ଅନୁମତି ମିଳିଲା ନାହିଁ — ଆପଣ ସ୍ଥାନ ନିଜେ ଲେଖିପାରିବେ।';

  @override
  String get themeLight => 'ଲାଇଟ';

  @override
  String get themeDark => 'ଡାର୍କ';

  @override
  String get themeSystem => 'ସିଷ୍ଟମ';

  @override
  String get settingsTitle => 'ସେଟିଂସ';

  @override
  String get settingsLocalOnly => 'ଆପଣଙ୍କ ଡାଟା ଏହି ଫୋନରୁ ବାହାରକୁ ଯାଏ ନାହିଁ। ଫୋନରେ ହିଁ ସେଭ ହୁଏ, କୌଣସି ସର୍ଭର ନାହିଁ। ଡିଭାଇସ ବଦଳାଇବାକୁ ବ୍ୟାକଅପ ଏକ୍ସପୋର୍ଟ କରନ୍ତୁ।';

  @override
  String get settingsProfile => 'ପ୍ରୋଫାଇଲ';

  @override
  String get settingsName => 'ନାମ';

  @override
  String get settingsYourName => 'ଆପଣଙ୍କ ନାମ';

  @override
  String get settingsAppearance => 'ରୂପ';

  @override
  String get settingsLanguage => 'ଭାଷା';

  @override
  String get settingsLanguageDevice => 'ଡିଭାଇସର ଭାଷା';

  @override
  String get settingsDefaults => 'ଡିଫଲ୍ଟ';

  @override
  String get settingsDefaultSource => 'ଡିଫଲ୍ଟ ଦେୟ ପଦ୍ଧତି';

  @override
  String get settingsDefaultSourceHelp => 'ନୂଆ କାରବାରରେ ପୂର୍ବରୁ ବଛା ହୋଇଥାଏ';

  @override
  String get settingsSources => 'ଦେୟ ପଦ୍ଧତି';

  @override
  String get settingsCategories => 'ବର୍ଗ';

  @override
  String get settingsCategoriesHelp => 'ବର୍ଗ ବିନା ଏଣ୍ଟ୍ରି ଡିଫଲ୍ଟ ବର୍ଗକୁ ଯାଏ';

  @override
  String settingsDefaultCategory(String name) {
    return 'ଡିଫଲ୍ଟ: $name';
  }

  @override
  String get settingsCurrency => 'ମୁଦ୍ରା';

  @override
  String get settingsCurrencyHelp => 'କେବଳ ରାଶି ଦେଖାଇବା ଢଙ୍ଗ ବଦଳେ। କିଛି କନଭର୍ଟ ହୁଏ ନାହିଁ।';

  @override
  String get settingsRecurring => 'ପୁନରାବୃତ୍ତ କାରବାର';

  @override
  String get settingsWeekStart => 'ସପ୍ତାହ ଆରମ୍ଭ ହୁଏ';

  @override
  String get settingsWeekStartHelp => 'ସାପ୍ତାହିକ ବଜେଟ ଓ ବିଶ୍ଳେଷଣର ସପ୍ତାହ ଦୃଶ୍ୟ ଏହାକୁ ମାନେ।';

  @override
  String settingsWeekSpan(String span) {
    return 'ସାପ୍ତାହିକ ବଜେଟ ଓ ବିଶ୍ଳେଷଣ $span ଚାଲେ';
  }

  @override
  String get settingsData => 'ଡାଟା';

  @override
  String get settingsExportCsv => 'CSV ଏକ୍ସପୋର୍ଟ କରନ୍ତୁ';

  @override
  String get settingsExportCsvHelp => 'କାରବାର, ନିବେଶ, ଋଣ, ବଜେଟ';

  @override
  String get settingsExportPdf => 'ଏହି ମାସର PDF ଏକ୍ସପୋର୍ଟ କରନ୍ତୁ';

  @override
  String get settingsImport => 'CSV କିମ୍ବା PDF ଷ୍ଟେଟମେଣ୍ଟ ଇମ୍ପୋର୍ଟ କରନ୍ତୁ';

  @override
  String get settingsImportHelp => 'HDFC, SBI, ICICI ଓ ଅଧିକାଂଶ ବ୍ୟାଙ୍କର PDF, କିମ୍ବା CSV ଏକ୍ସପୋର୍ଟ';

  @override
  String get settingsBackUp => 'ଏବେ ବ୍ୟାକଅପ ନିଅନ୍ତୁ';

  @override
  String get settingsBackUpHelp => 'ଗୋଟିଏ .ledger ଫାଇଲ, ପାସୱାର୍ଡ ଇଚ୍ଛାଧୀନ';

  @override
  String get settingsRestore => 'ବ୍ୟାକଅପରୁ ରିଷ୍ଟୋର କରନ୍ତୁ';

  @override
  String get settingsPrivacyGroup => 'ଗୋପନୀୟତା ଓ ଅନୁମତି';

  @override
  String get settingsLocation => 'କାରବାରରେ ଲୋକେସନ';

  @override
  String get settingsAppLock => 'ଆପ ଲକ ଓ ଗୋପନୀୟତା';

  @override
  String get smsTitle => 'SMS ରୁ ଖର୍ଚ୍ଚ';

  @override
  String get remindersTitle => 'ରିମାଇଣ୍ଡର ଓ ଆଲର୍ଟ';

  @override
  String get settingsAbout => 'ବିଷୟରେ';

  @override
  String get settingsVersion => 'ସଂସ୍କରଣ';

  @override
  String get settingsPrivacy => 'ଗୋପନୀୟତା';

  @override
  String get settingsPrivacyHelp => 'କୌଣସି ଡାଟା ସଂଗ୍ରହ ନାହିଁ · ଅଫଲାଇନରେ ଚାଲେ';

  @override
  String get settingsPrivacyBody =>
      'Expense Manager ରେ କୌଣସି ଆକାଉଣ୍ଟ, ସର୍ଭର କିମ୍ବା ଆନାଲିଟିକ୍ସ ନାହିଁ। ଆପଣ ଯାହା ଲେଖନ୍ତି ତାହା ଏହି ଫୋନର ଡାଟାବେସରେ ସେଭ ହୁଏ ଏବଂ ଆପଣ ନିଜେ ଫାଇଲ ଏକ୍ସପୋର୍ଟ କିମ୍ବା ସେୟାର କଲେ ହିଁ ବାହାରକୁ ଯାଏ।\n\nଲୋକେସନ କେବଳ ଆପଣଙ୍କ ଅନୁମତିରେ ଓ କେବଳ ଆପଣଙ୍କ କାରବାରରେ ସ୍ଥାନ ଲେଖିବା ପାଇଁ ପଢ଼ାଯାଏ। ମାନଚିତ୍ର ଖୋଲିଲେ ମାନଚିତ୍ର ଟାଇଲ OpenStreetMap ରୁ ଲୋଡ ହୁଏ। SMS ରୁ ଖର୍ଚ୍ଚ ଚାଲୁ କଲେ ବ୍ୟାଙ୍କ SMS କେବଳ ଏହି ଫୋନରେ ପଢ଼ାଯାଏ।';

  @override
  String get settingsReadPolicy => 'ପୂରା ନୀତି ପଢ଼ନ୍ତୁ';

  @override
  String get settingsSourceCode => 'GitHub ରେ ସୋର୍ସ କୋଡ';

  @override
  String get settingsLicenses => 'ଓପନ-ସୋର୍ସ ଲାଇସେନ୍ସ';

  @override
  String get settingsSupport => 'ସହାୟତା';

  @override
  String get diagnosticsTitle => 'ଡାଇଗ୍ନୋଷ୍ଟିକ୍ସ';

  @override
  String get settingsDiagnosticsHelp => 'ଫୋନରେ ଏରର ଲଗ · ଦେଖନ୍ତୁ, ସେୟାର କରନ୍ତୁ କିମ୍ବା ସଫା କରନ୍ତୁ';

  @override
  String get settingsReportIssue => 'ସମସ୍ୟା ଜଣାନ୍ତୁ';

  @override
  String get settingsReportIssueHelp => 'GitHub ଇସ୍ୟୁ ଖୋଲେ · GitHub ଆକାଉଣ୍ଟ ଦରକାର';

  @override
  String settingsNoBrowser(String url) {
    return '$url ଖୋଲିବାକୁ କୌଣସି ବ୍ରାଉଜର ମିଳିଲା ନାହିଁ';
  }

  @override
  String get add => 'ଯୋଡନ୍ତୁ';

  @override
  String get edit => 'ବଦଳାନ୍ତୁ';

  @override
  String get clear => 'ସଫା କରନ୍ତୁ';

  @override
  String get nothingHere => 'ଏଠାରେ କିଛି ନାହିଁ';

  @override
  String get dueToday => 'ଆଜି ଦେୟ';

  @override
  String get dueTomorrow => 'କାଲି ଦେୟ';

  @override
  String dueInDays(int n) {
    return '$n ଦିନରେ ଦେୟ';
  }

  @override
  String overdueByDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ଦିନ ବକେୟା', one: '1 ଦିନ ବକେୟା');
    return '$_temp0';
  }

  @override
  String debtRemindMessage(String person, String amount) {
    return 'ନମସ୍କାର $person, $amount ବିଷୟରେ ଏକ ଛୋଟ ରିମାଇଣ୍ଡର। ଆପଣଙ୍କ ସୁବିଧା ଅନୁସାରେ ଦେବେ। ଧନ୍ୟବାଦ!';
  }

  @override
  String debtRemindMessageFor(String person, String amount, String reason) {
    return 'ନମସ୍କାର $person, $reason ର $amount ବିଷୟରେ ଏକ ଛୋଟ ରିମାଇଣ୍ଡର। ଆପଣଙ୍କ ସୁବିଧା ଅନୁସାରେ ଦେବେ। ଧନ୍ୟବାଦ!';
  }

  @override
  String get debtRemindSubject => 'ବନ୍ଧୁତ୍ୱପୂର୍ଣ୍ଣ ରିମାଇଣ୍ଡର';

  @override
  String get debtYouOwe => 'ଆପଣ ଦେବାର ଅଛି';

  @override
  String get debtOwedToYou => 'ଆପଣ ପାଇବାର ଅଛି';

  @override
  String debtMonthlyEmi(String amount) {
    return '$amount/ମାସ EMI ରେ';
  }

  @override
  String get debtToCollect => 'ଆଦାୟ ବାକି';

  @override
  String get debtIOwe => 'ମୁଁ ଦେବାର ଅଛି';

  @override
  String get debtOwedToMe => 'ମୁଁ ପାଇବାର ଅଛି';

  @override
  String get debtSettled => 'ପରିଶୋଧ';

  @override
  String get debtEmpty => 'ଲୋନ, କ୍ରେଡିଟ କାର୍ଡ ଓ ଧାର ଦିଆ କିମ୍ବା ନିଆ ଟଙ୍କା ଏଠାରେ ଦେଖାଯାଏ।';

  @override
  String get debtFooter => 'ଏଠାରେ ରେକର୍ଡ ହୋଇଥିବା EMI ଓ କାର୍ଡ ଦେୟ ଖର୍ଚ୍ଚ ନୁହେଁ, ଋଣ ଭାବେ ଗଣାଯାଏ — ଯାହାଦ୍ୱାରା ଆପଣଙ୍କ ମାସିକ ଖର୍ଚ୍ଚ ଠିକ ରହେ।';

  @override
  String debtPayTitle(String name) {
    return '$name ଦେବେ?';
  }

  @override
  String debtPayBody(String amount) {
    return '$amount ର କାର୍ଡ ଦେୟ ରେକର୍ଡ ହେବ। ଏହା ଖର୍ଚ୍ଚ ନୁହେଁ, ଋଣ ଭାବେ ଗଣାଯିବ।';
  }

  @override
  String debtPayBodyFrom(String amount, String source) {
    return '$source ରୁ $amount ର କାର୍ଡ ଦେୟ ରେକର୍ଡ ହେବ। ଏହା ଖର୍ଚ୍ଚ ନୁହେଁ, ଋଣ ଭାବେ ଗଣାଯିବ।';
  }

  @override
  String debtPayAmount(String amount) {
    return '$amount ଦିଅନ୍ତୁ';
  }

  @override
  String debtBillMerchant(String name) {
    return '$name ବିଲ';
  }

  @override
  String debtPaymentRecorded(String amount) {
    return '$amount ର କାର୍ଡ ଦେୟ ରେକର୍ଡ ହେଲା';
  }

  @override
  String debtEmi(String amount) {
    return 'EMI $amount';
  }

  @override
  String debtDueOn(int day) {
    return '$day ତାରିଖରେ ଦେୟ';
  }

  @override
  String debtLeftOf(String amount) {
    return '$amount ରୁ ବାକି';
  }

  @override
  String debtStatement(String amount) {
    return 'ଷ୍ଟେଟମେଣ୍ଟ $amount';
  }

  @override
  String debtStatementDue(String amount, String date) {
    return 'ଷ୍ଟେଟମେଣ୍ଟ $amount · ଦେୟ $date';
  }

  @override
  String get debtPaid => 'ଦିଆଯାଇଛି';

  @override
  String debtUnpaid(String amount) {
    return 'ବକେୟା $amount';
  }

  @override
  String debtEmisPaid(int paid, int total) {
    return '$total ରୁ $paid EMI ଦିଆଯାଇଛି';
  }

  @override
  String debtPaymentsRecorded(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ଦେୟ ରେକର୍ଡ ହେଲା', one: '1 ଦେୟ ରେକର୍ଡ ହେଲା');
    return '$_temp0';
  }

  @override
  String get debtReopen => 'ପୁଣି ଖୋଲନ୍ତୁ';

  @override
  String get debtSettle => 'ପରିଶୋଧ କରନ୍ତୁ';

  @override
  String get debtRemind => 'ମନେ ପକାନ୍ତୁ';

  @override
  String get debtRecordPayment => 'ଦେୟ ରେକର୍ଡ କରନ୍ତୁ';

  @override
  String get debtRecordRepayment => 'ଫେରସ୍ତ ରେକର୍ଡ କରନ୍ତୁ';

  @override
  String debtPayNow(String amount) {
    return 'ଏବେ ଦିଅନ୍ତୁ · $amount';
  }

  @override
  String get debtNeedNameAmount => 'ନାମ ଓ ରାଶି ଲେଖନ୍ତୁ';

  @override
  String get debtAddTitle => 'ଋଣ ଯୋଡନ୍ତୁ';

  @override
  String get debtEditTitle => 'ଋଣ ବଦଳାନ୍ତୁ';

  @override
  String get debtKindLoan => 'ଲୋନ';

  @override
  String get debtKindCard => 'କ୍ରେଡିଟ କାର୍ଡ';

  @override
  String get debtKindPersonal => 'ବ୍ୟକ୍ତିଗତ';

  @override
  String get debtFieldName => 'ନାମ, ଯେପରି କାର ଲୋନ';

  @override
  String get debtFieldParty => 'ଦାତା / ବ୍ୟକ୍ତି (ଇଚ୍ଛାଧୀନ)';

  @override
  String debtFieldPrincipal(String symbol) {
    return 'ମୋଟ ରାଶି ($symbol)';
  }

  @override
  String get debtFieldRate => 'ସୁଧ ହାର % (ଇଚ୍ଛାଧୀନ)';

  @override
  String get debtFieldEmi => 'EMI / ମାସିକ ଦେୟ (ଇଚ୍ଛାଧୀନ)';

  @override
  String get debtFieldEmis => 'EMI ସଂଖ୍ୟା (ଇଚ୍ଛାଧୀନ)';

  @override
  String get debtFieldDueDay => 'ମାସର ଦେୟ ତାରିଖ (ଇଚ୍ଛାଧୀନ)';

  @override
  String debtFieldStatement(String symbol) {
    return 'ଶେଷ ଷ୍ଟେଟମେଣ୍ଟର ମୋଟ ($symbol, ଇଚ୍ଛାଧୀନ)';
  }

  @override
  String get debtStatementDueDate => 'ଷ୍ଟେଟମେଣ୍ଟ ଦେୟ ତାରିଖ';

  @override
  String debtDueDate(String date) {
    return 'ଦେୟ $date';
  }

  @override
  String get debtSave => 'ଋଣ ସେଭ କରନ୍ତୁ';

  @override
  String get all => 'ସବୁ';

  @override
  String get amount => 'ରାଶି';

  @override
  String get delete => 'ଡିଲିଟ କରନ୍ତୁ';

  @override
  String get type => 'ପ୍ରକାର';

  @override
  String get min => 'ସର୍ବନିମ୍ନ';

  @override
  String get max => 'ସର୍ବାଧିକ';

  @override
  String get searchScopeNotes => 'ନୋଟ';

  @override
  String get searchScopeMerchant => 'ଦୋକାନ';

  @override
  String get searchScopePlace => 'ସ୍ଥାନ';

  @override
  String get sortNewest => 'ନୂଆ ପ୍ରଥମେ';

  @override
  String get sortOldest => 'ପୁରୁଣା ପ୍ରଥମେ';

  @override
  String get sortAmountDesc => 'ରାଶି: ଅଧିକରୁ କମ';

  @override
  String get sortAmountAsc => 'ରାଶି: କମରୁ ଅଧିକ';

  @override
  String get transactionsTitle => 'କାରବାର';

  @override
  String get sort => 'କ୍ରମ';

  @override
  String get searchHintAll => 'ଦୋକାନ, ନୋଟ, #ଟ୍ୟାଗ, ରାଶି ଖୋଜନ୍ତୁ…';

  @override
  String get searchHintNotes => 'ନୋଟ ଓ #ଟ୍ୟାଗ ଖୋଜନ୍ତୁ';

  @override
  String get searchHintMerchant => 'ଦୋକାନ ଖୋଜନ୍ତୁ';

  @override
  String searchHintAmount(String symbol) {
    return 'ସଠିକ ରାଶି, ଯେପରି 450 କିମ୍ବା ${symbol}1,200';
  }

  @override
  String get searchHintPlace => 'ସ୍ଥାନ ଖୋଜନ୍ତୁ';

  @override
  String get clearSearch => 'ସନ୍ଧାନ ସଫା କରନ୍ତୁ';

  @override
  String get filters => 'ଫିଲ୍ଟର';

  @override
  String get allCategories => 'ସବୁ ବର୍ଗ';

  @override
  String get previousMonth => 'ଗତ ମାସ';

  @override
  String get nextMonth => 'ଆସନ୍ତା ମାସ';

  @override
  String get allTime => 'ଏଯାବତ';

  @override
  String nTransactions(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n କାରବାର', one: '1 କାରବାର');
    return '$_temp0';
  }

  @override
  String moneyOut(String amount) {
    return 'ବାହାର $amount';
  }

  @override
  String moneyIn(String amount) {
    return 'ଭିତର $amount';
  }

  @override
  String noTxnMatch(String query) {
    return '\"$query\" ସହ ମେଳ ଖାଉଥିବା କୌଣସି କାରବାର ନାହିଁ।';
  }

  @override
  String get noTxnInPeriod => 'ଏହି ଅବଧିରେ କୌଣସି କାରବାର ନାହିଁ।';

  @override
  String get recentSearches => 'ସାମ୍ପ୍ରତିକ ସନ୍ଧାନ';

  @override
  String get removeRecentSearch => 'ସାମ୍ପ୍ରତିକ ସନ୍ଧାନରୁ ହଟାନ୍ତୁ';

  @override
  String get resetAll => 'ସବୁ ରିସେଟ କରନ୍ତୁ';

  @override
  String get searchCategories => 'ବର୍ଗ ଖୋଜନ୍ତୁ';

  @override
  String amountIn(String symbol) {
    return 'ରାଶି ($symbol)';
  }

  @override
  String get paidVia => 'ଦେୟ ପଦ୍ଧତି';

  @override
  String get applyFilters => 'ଫିଲ୍ଟର ଲାଗୁ କରନ୍ତୁ';

  @override
  String get txnNeedAmount => 'ଶୂନରୁ ଅଧିକ ରାଶି ଲେଖନ୍ତୁ';

  @override
  String txnTemplateSaved(String name) {
    return '“$name” ଟେମ୍ପଲେଟ ଭାବେ ସେଭ ହେଲା';
  }

  @override
  String deleteNamed(String name) {
    return '“$name” ଡିଲିଟ କରିବେ?';
  }

  @override
  String get txnTemplateDeleteBody => 'ଟେମ୍ପଲେଟ ହଟିଯିବ। ଏଥିରୁ ତିଆରି କାରବାର ରହିବ।';

  @override
  String get txnNeedDebt => 'ଏହି ଦେୟ କେଉଁ ଋଣର ତାହା ବାଛନ୍ତୁ';

  @override
  String get txnEditTitle => 'କାରବାର ବଦଳାନ୍ତୁ';

  @override
  String get txnNewTitle => 'ନୂଆ କାରବାର';

  @override
  String get txnSaveTemplate => 'ଟେମ୍ପଲେଟ ଭାବେ ସେଭ କରନ୍ତୁ';

  @override
  String get txnReceivedIn => 'କେଉଁଥିରେ ମିଳିଲା';

  @override
  String get txnPaidFrom => 'କେଉଁଥିରୁ ଦିଆଗଲା';

  @override
  String get category => 'ବର୍ଗ';

  @override
  String txnCategoryHint(String name) {
    return 'ନିଶ୍ଚିତ ନୁହଁନ୍ତି? ଡିଫଲ୍ଟ ଭାବେ ଏହା “$name” କୁ ଯିବ।';
  }

  @override
  String get txnHolding => 'ହୋଲ୍ଡିଂ (ଇଚ୍ଛାଧୀନ)';

  @override
  String get txnNotLinked => 'ଯୋଡା ହୋଇନାହିଁ';

  @override
  String get txnDebt => 'ଋଣ';

  @override
  String get txnChooseDebt => 'ଋଣ ବାଛନ୍ତୁ';

  @override
  String txnDebtYouPay(String name) {
    return '$name · ଆପଣ ଦେବେ';
  }

  @override
  String txnDebtYouReceive(String name) {
    return '$name · ଆପଣ ପାଇବେ';
  }

  @override
  String get details => 'ବିବରଣୀ';

  @override
  String get date => 'ତାରିଖ';

  @override
  String get time => 'ସମୟ';

  @override
  String get txnMerchant => 'ଦୋକାନ / ପାଉଥିବା ବ୍ୟକ୍ତି';

  @override
  String get txnLocation => 'ସ୍ଥାନ · ଇଚ୍ଛାଧୀନ';

  @override
  String get pickOnMap => 'ମାନଚିତ୍ରରେ ବାଛନ୍ତୁ';

  @override
  String get useCurrentLocation => 'ବର୍ତ୍ତମାନର ଲୋକେସନ ବ୍ୟବହାର କରନ୍ତୁ';

  @override
  String get txnNote => 'କାହିଁକି? ନୋଟ ଯୋଡନ୍ତୁ (ଖୋଜିହେବ)';

  @override
  String get txnTags => 'ଟ୍ୟାଗ, ଯେପରି #କାମ #ଭାଗ';

  @override
  String get receipt => 'ରସିଦ';

  @override
  String get receiptCamera => 'କ୍ୟାମେରା';

  @override
  String get receiptGallery => 'ଗ୍ୟାଲେରୀ';

  @override
  String get receiptPdf => 'PDF';

  @override
  String get receiptPdfAttached => 'PDF ରସିଦ ଯୋଡା ହୋଇଛି';

  @override
  String get receiptPhotoAttached => 'ରସିଦର ଫଟୋ ଯୋଡା ହୋଇଛି';

  @override
  String get receiptRemove => 'ରସିଦ ହଟାନ୍ତୁ';

  @override
  String get txnRecurringNote => 'ଏହା ଏକ ପୁନରାବୃତ୍ତ ସିରିଜର ଅଂଶ। ପରିବର୍ତ୍ତନ କେବଳ ଏଥିରେ ଲାଗୁ ହେବ; ସିରିଜ ସେଟିଂସ › ପୁନରାବୃତ୍ତ ରେ ପରିଚାଳନା କରନ୍ତୁ।';

  @override
  String get repeat => 'ପୁନରାବୃତ୍ତି';

  @override
  String get txnRepeat => 'ଏହି କାରବାର ପୁନରାବୃତ୍ତି କରନ୍ତୁ';

  @override
  String txnRepeatNext(String frequency, String date) {
    return '$frequency · ପରବର୍ତ୍ତୀ $date';
  }

  @override
  String get txnRepeatHelp => 'ସମୟସୂଚୀ ଅନୁସାରେ ସ୍ୱତଃ ଯୋଡେ';

  @override
  String get neverEnds => 'କେବେ ଶେଷ ନୁହେଁ';

  @override
  String endsOn(String date) {
    return '$date ରେ ଶେଷ';
  }

  @override
  String get clearEndDate => 'ଶେଷ ତାରିଖ ସଫା କରନ୍ତୁ';

  @override
  String get saveChanges => 'ପରିବର୍ତ୍ତନ ସେଭ କରନ୍ତୁ';

  @override
  String get txnSave => 'କାରବାର ସେଭ କରନ୍ତୁ';

  @override
  String get quickAdd => 'ଶୀଘ୍ର ଯୋଡନ୍ତୁ';

  @override
  String get continue_ => 'ଜାରି ରଖନ୍ତୁ';

  @override
  String get done => 'ହେଲା';

  @override
  String get notNow => 'ଏବେ ନୁହେଁ';

  @override
  String get remove => 'ହଟାନ୍ତୁ';

  @override
  String get typeSpend => 'ଖର୍ଚ୍ଚ';

  @override
  String get typeInvest => 'ନିବେଶ';

  @override
  String get typeIncome => 'ଆୟ';

  @override
  String get typeDebt => 'ଋଣ';

  @override
  String get investKindFd => 'ଫିକ୍ସଡ ଡିପୋଜିଟ';

  @override
  String get investKindMf => 'ମ୍ୟୁଚୁଆଲ ଫଣ୍ଡ';

  @override
  String get investKindStock => 'ସେୟାର';

  @override
  String get investKindGold => 'ସୁନା';

  @override
  String get investKindRetirement => 'ଅବସର (PPF/EPF/NPS)';

  @override
  String get investKindOther => 'ଅନ୍ୟ';

  @override
  String get reminderTypeBudget => 'ବଜେଟ ଆଲର୍ଟ (80% ଓ 100%)';

  @override
  String get reminderTypeDues => 'EMI ଓ କାର୍ଡ ଦେୟ ତାରିଖ';

  @override
  String get reminderTypeSip => 'SIP ରିମାଇଣ୍ଡର';

  @override
  String get reminderTypeMaturity => 'FD ମ୍ୟାଚ୍ୟୁରିଟି';

  @override
  String get reminderTypeFollowUp => 'ମୁଁ ପାଇବାକୁ ଥିବା ଟଙ୍କାର ଫଲୋ-ଅପ';

  @override
  String get reminderEmiTomorrow => 'EMI କାଲି ଦେୟ';

  @override
  String get reminderCardTomorrow => 'କାର୍ଡ ବିଲ କାଲି ଦେୟ';

  @override
  String get reminderEmiToday => 'EMI ଆଜି ଦେୟ';

  @override
  String get reminderCardToday => 'କାର୍ଡ ବିଲ ଆଜି ଦେୟ';

  @override
  String get reminderSipToday => 'SIP ଆଜି';

  @override
  String reminderSipBody(String title, String amount) {
    return '$title: ଆଜି $amount ନିବେଶ କରନ୍ତୁ।';
  }

  @override
  String reminderFdMatures(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'FD $n ଦିନରେ ମ୍ୟାଚ୍ୟୁର ହେବ', one: 'FD କାଲି ମ୍ୟାଚ୍ୟୁର ହେବ', zero: 'FD ଆଜି ମ୍ୟାଚ୍ୟୁର ହେବ');
    return '$_temp0';
  }

  @override
  String reminderFdBody(String title, String amount, String date) {
    return '$title ($amount ନିବେଶ) $date ରେ ମ୍ୟାଚ୍ୟୁର ହେବ।';
  }

  @override
  String reminderFollowUp(String name) {
    return '$name ସହ ଫଲୋ-ଅପ କରନ୍ତୁ';
  }

  @override
  String reminderFollowUpBody(String name, String amount) {
    return '$name ଙ୍କଠାରୁ ଏବେ ବି $amount ପାଇବାକୁ ବାକି।';
  }

  @override
  String budgetAlertFull(String name) {
    return '$name ବଜେଟ ସମ୍ପୂର୍ଣ୍ଣ ଖର୍ଚ୍ଚ ହୋଇଗଲା';
  }

  @override
  String budgetAlert80(String name) {
    return '$name ବଜେଟର 80% ଖର୍ଚ୍ଚ ହୋଇଗଲା';
  }

  @override
  String budgetAlertBody(String used, String limit, String left) {
    return '$limit ରୁ $used ଖର୍ଚ୍ଚ · $left';
  }

  @override
  String daysLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ଦିନ ବାକି', one: '1 ଦିନ ବାକି');
    return '$_temp0';
  }

  @override
  String get reminderTestTitle => 'ରିମାଇଣ୍ଡର ଚାଲୁ ଅଛି';

  @override
  String get reminderTestBody => 'ବଜେଟ, ଦେୟ ତାରିଖ, SIP ଓ ମ୍ୟାଚ୍ୟୁରିଟି ବିଷୟରେ ଏଠାରେ ଜଣାଯିବ। କିଛି ବି ଆପଣଙ୍କ ଫୋନରୁ ବାହାରକୁ ଯାଏ ନାହିଁ।';

  @override
  String get smsAddDetails => 'ବିବରଣୀ ଯୋଡନ୍ତୁ';

  @override
  String get smsIgnore => 'ଉପେକ୍ଷା କରନ୍ତୁ';

  @override
  String get undo => 'ପୂର୍ବାବସ୍ଥା';

  @override
  String smsAmountFrom(String amount, String name) {
    return '$name ଠାରୁ $amount';
  }

  @override
  String smsAmountAt(String amount, String name) {
    return '$name ରେ $amount';
  }

  @override
  String smsAmountInto(String amount, String name) {
    return '$name କୁ $amount';
  }

  @override
  String smsMoneyReceived(String what) {
    return 'ଟଙ୍କା ମିଳିଲା: $what';
  }

  @override
  String smsNewExpense(String what) {
    return 'ନୂଆ ଖର୍ଚ୍ଚ: $what';
  }

  @override
  String smsAddTo(String where) {
    return '$where ରେ ଯୋଡିବେ?';
  }

  @override
  String smsIncomeAdded(String what) {
    return 'ଆୟ ଯୋଡାଗଲା: $what';
  }

  @override
  String smsExpenseAdded(String what) {
    return 'ଖର୍ଚ୍ଚ ଯୋଡାଗଲା: $what';
  }

  @override
  String get reminderChannelHelp => 'ବଜେଟ ଆଲର୍ଟ, ଦେୟ ତାରିଖ, SIP ଓ ମ୍ୟାଚ୍ୟୁରିଟି ରିମାଇଣ୍ଡର';

  @override
  String get smsChannelHelp => 'SMS ରୁ ପଢ଼ାଯାଇଥିବା ବ୍ୟାଙ୍କ କିମ୍ବା UPI କାରବାର ଯୋଡିବା ପୂର୍ବରୁ ପଚାରେ';

  @override
  String get unlockPrompt => 'Expense Manager ଅନଲକ କରନ୍ତୁ';

  @override
  String get daily => 'ପ୍ରତିଦିନ';

  @override
  String get weekly => 'ସାପ୍ତାହିକ';

  @override
  String get monthly => 'ମାସିକ';

  @override
  String get yearly => 'ବାର୍ଷିକ';

  @override
  String get backupNeedsPassword => 'ଏହି ବ୍ୟାକଅପ ପାସୱାର୍ଡ ଦ୍ୱାରା ସୁରକ୍ଷିତ';

  @override
  String get backupWrongPassword => 'ଭୁଲ ପାସୱାର୍ଡ';

  @override
  String get backupInvalid => 'ଏହା Expense Manager ବ୍ୟାକଅପ ନୁହେଁ';

  @override
  String get backupDamaged => 'ବ୍ୟାକଅପ ଫାଇଲ ଖରାପ ହୋଇଛି';

  @override
  String get backupTooNew => 'ଏହି ବ୍ୟାକଅପ ଆପର ନୂଆ ସଂସ୍କରଣରେ ତିଆରି। ପ୍ରଥମେ ଆପ ଅପଡେଟ କରନ୍ତୁ।';

  @override
  String get backupNever => 'କେବେ ବ୍ୟାକଅପ ନିଆଯାଇନାହିଁ';

  @override
  String backupLast(String date) {
    return 'ଶେଷ ବ୍ୟାକଅପ $date';
  }

  @override
  String get importNeedColumns => 'ତାରିଖ ସ୍ତମ୍ଭ ଓ ରାଶି (କିମ୍ବା ଡେବିଟ/କ୍ରେଡିଟ) ସ୍ତମ୍ଭ ଦରକାର';

  @override
  String importInvalidDate(String value) {
    return 'ଭୁଲ ତାରିଖ \"$value\"';
  }

  @override
  String get importInvalidAmount => 'ଭୁଲ ରାଶି';

  @override
  String get investmentsTitle => 'ନିବେଶ';

  @override
  String get budgetsTitle => 'ବଜେଟ';

  @override
  String get pdfLocked => 'ଏହି PDF ପାସୱାର୍ଡ ଦ୍ୱାରା ସୁରକ୍ଷିତ। ଲକ ବିନା ଏକ କପି ସେଭ କରନ୍ତୁ (ପ୍ରିଣ୍ଟ → PDF ଭାବେ ସେଭ) ଏବଂ ତାହା ଇମ୍ପୋର୍ଟ କରନ୍ତୁ।';

  @override
  String pdfUnreadable(String cause) {
    return 'ଏହି PDF ପଢ଼ିହେଲା ନାହିଁ ($cause)';
  }

  @override
  String get bankStatement => 'ବ୍ୟାଙ୍କ ଷ୍ଟେଟମେଣ୍ଟ';

  @override
  String get emi => 'EMI';

  @override
  String get cardBill => 'କାର୍ଡ ବିଲ';

  @override
  String reminderDueTomorrowBody(String title, String what) {
    return '$title: $what କାଲି ଦେୟ।';
  }

  @override
  String reminderDueTomorrowAmountBody(String title, String what, String amount) {
    return '$title: $amount ର $what କାଲି ଦେୟ।';
  }

  @override
  String reminderDueTodayBody(String title, String what) {
    return '$title: $what ଆଜି ଦେୟ।';
  }

  @override
  String reminderDueTodayAmountBody(String title, String what, String amount) {
    return '$title: $amount ର $what ଆଜି ଦେୟ।';
  }

  @override
  String exportedOne(String what, String path) {
    return '$what କୁ $path ରେ ଏକ୍ସପୋର୍ଟ କଲା';
  }

  @override
  String exportedMany(int n, String path) {
    return '$n ଫାଇଲ $path ରେ ଏକ୍ସପୋର୍ଟ କଲା';
  }

  @override
  String get exportHelp => 'Excel କିମ୍ବା Sheets ରେ ଖୋଲୁଥିବା UTF-8 ଫାଇଲ। ଅନେକ ଫାଇଲ ଗୋଟିଏ zip ରେ ସେୟାର ହୁଏ।';

  @override
  String exportZip(int n) {
    return '$n ଫାଇଲ ଏକ୍ସପୋର୍ଟ କରନ୍ତୁ (zip)';
  }

  @override
  String get export => 'ଏକ୍ସପୋର୍ଟ କରନ୍ତୁ';

  @override
  String get importPreview => 'ଇମ୍ପୋର୍ଟ ପ୍ରିଭ୍ୟୁ';

  @override
  String get importPdfEmpty => 'ଏହି PDF ରେ କୌଣସି କାରବାର ମିଳିଲା ନାହିଁ। ନେଟ ବ୍ୟାଙ୍କିଂରୁ CSV/Excel ଏକ୍ସପୋର୍ଟ ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String importFound(String bank, int n) {
    return '$bank · $n ମିଳିଲା';
  }

  @override
  String get backupCreating => 'ବ୍ୟାକଅପ ତିଆରି ହେଉଛି…';

  @override
  String get backupEncrypting => 'ବ୍ୟାକଅପ ଏନକ୍ରିପ୍ଟ ହେଉଛି…';

  @override
  String backupSaved(String path) {
    return 'ବ୍ୟାକଅପ $path ରେ ସେଭ ହେଲା';
  }

  @override
  String get restoring => 'ରିଷ୍ଟୋର ହେଉଛି…';

  @override
  String restoredN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n କାରବାର ରିଷ୍ଟୋର ହେଲା', one: '1 କାରବାର ରିଷ୍ଟୋର ହେଲା');
    return '$_temp0';
  }

  @override
  String addedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n କାରବାର ଯୋଡାଗଲା', one: '1 କାରବାର ଯୋଡାଗଲା');
    return '$_temp0';
  }

  @override
  String addedNSkipped(int n, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n କାରବାର ଯୋଡାଗଲା', one: '1 କାରବାର ଯୋଡାଗଲା');
    return '$_temp0 · $skipped ପୂର୍ବରୁ ଅଛି';
  }

  @override
  String get backupHelp => 'ଆପଣଙ୍କ ସମସ୍ତ ଡାଟା ଓ ରସିଦ ଥିବା ଗୋଟିଏ .ledger ଫାଇଲ। ଏହାକୁ Drive, Files କିମ୍ବା କମ୍ପ୍ୟୁଟରରେ ସେଭ କରନ୍ତୁ।';

  @override
  String get backupProtect => 'ପାସୱାର୍ଡ ଦ୍ୱାରା ସୁରକ୍ଷିତ କରନ୍ତୁ';

  @override
  String get backupPasswordField => 'ପାସୱାର୍ଡ (6+ ଅକ୍ଷର)';

  @override
  String get confirmPassword => 'ପାସୱାର୍ଡ ନିଶ୍ଚିତ କରନ୍ତୁ';

  @override
  String get backupNoRecovery => 'ଭୁଲିଯାଇଥିବା ପାସୱାର୍ଡ ଫେରିପାଇବାର କୌଣସି ଉପାୟ ନାହିଁ।';

  @override
  String get backUp => 'ବ୍ୟାକଅପ ନିଅନ୍ତୁ';

  @override
  String get backupPassword => 'ବ୍ୟାକଅପ ପାସୱାର୍ଡ';

  @override
  String get password => 'ପାସୱାର୍ଡ';

  @override
  String get unlock => 'ଅନଲକ କରନ୍ତୁ';

  @override
  String get restoreBackup => 'ବ୍ୟାକଅପ ରିଷ୍ଟୋର କରନ୍ତୁ';

  @override
  String backupMade(String date, String version) {
    return '$date ରେ ତିଆରି · ଆପ $version';
  }

  @override
  String get merge => 'ମିଶାନ୍ତୁ';

  @override
  String get replace => 'ବଦଳାନ୍ତୁ';

  @override
  String get restoreMergeHelp => 'ଏହି ଫୋନରେ ଯାହା ନାହିଁ ତାହା ଯୋଡେ। ମେଳ ଖାଉଥିବା ବର୍ଗ, ଦେୟ ପଦ୍ଧତି ଓ ଆକାଉଣ୍ଟ ପୁଣି ବ୍ୟବହାର ହୁଏ; ପୂର୍ବରୁ ଥିବା କାରବାର ଛାଡି ଦିଆଯାଏ।';

  @override
  String get restoreReplaceHelp => 'ଏହି ଫୋନର ସବୁକିଛି ଡିଲିଟ କରି ବ୍ୟାକଅପ ବ୍ୟବହାର କରେ।';

  @override
  String get restoreConfirm => 'ମୁଁ ବୁଝୁଛି ଯେ ମୋର ବର୍ତ୍ତମାନର ଡାଟା ଲିଭିଯିବ';

  @override
  String get backupReminder => 'ବ୍ୟାକଅପ ରିମାଇଣ୍ଡର';

  @override
  String get backupBannerNever => 'ଆପଣଙ୍କ ଡାଟା କେବଳ ଏହି ଫୋନରେ ଅଛି। ବ୍ୟାକଅପ ନିଅନ୍ତୁ।';

  @override
  String backupBannerDue(String last) {
    return 'ବ୍ୟାକଅପ ସମୟ · $last';
  }

  @override
  String get remindLater => 'ପରେ ମନେ ପକାନ୍ତୁ';

  @override
  String importedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n କାରବାର ଇମ୍ପୋର୍ଟ ହେଲା', one: '1 କାରବାର ଇମ୍ପୋର୍ଟ ହେଲା');
    return '$_temp0';
  }

  @override
  String importLine(int n) {
    return 'ଧାଡି $n';
  }

  @override
  String get importDuplicate => 'ନକଲ';

  @override
  String importToDefault(String name) {
    return 'ବର୍ଗ → $name';
  }

  @override
  String importNewSub(String name) {
    return 'ନୂଆ ଉପ-ବର୍ଗ: $name';
  }

  @override
  String importN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n କାରବାର ଇମ୍ପୋର୍ଟ କରନ୍ତୁ', one: '1 କାରବାର ଇମ୍ପୋର୍ଟ କରନ୍ତୁ');
    return '$_temp0';
  }

  @override
  String get finish => 'ଶେଷ କରନ୍ତୁ';

  @override
  String get skip => 'ଛାଡନ୍ତୁ';

  @override
  String get onbWelcomeTitle => 'ଆପଣଙ୍କ ଟଙ୍କା, ଆପଣଙ୍କ ଫୋନରେ';

  @override
  String get onbWelcomeBody => 'ଖର୍ଚ୍ଚ, ନିବେଶ ଓ ଋଣ ଗୋଟିଏ ସ୍ଥାନରେ ଟ୍ରାକ କରନ୍ତୁ। ଆପଣଙ୍କ ଡାଟା ଏହି ଫୋନରେ ରହେ। କୌଣସି ଆକାଉଣ୍ଟ ନାହିଁ, ସର୍ଭର ନାହିଁ, ଟ୍ରାକିଂ ନାହିଁ।';

  @override
  String get onbGetStarted => 'ଆରମ୍ଭ କରନ୍ତୁ';

  @override
  String get onbPointLocal => 'କେବଳ ଏହି ଡିଭାଇସରେ ସେଭ';

  @override
  String get onbPointOffline => 'ସମ୍ପୂର୍ଣ୍ଣ ଅଫଲାଇନରେ ଚାଲେ';

  @override
  String get onbPointExport => 'ଯେକୌଣସି ସମୟରେ CSV କିମ୍ବା PDF ରେ ଏକ୍ସପୋର୍ଟ';

  @override
  String get onbNameTitle => 'ଆମେ ଆପଣଙ୍କୁ କ\'ଣ ଡାକିବୁ?';

  @override
  String get onbNameBody => 'କେବଳ ହୋମ ସ୍କ୍ରିନରେ ଅଭିବାଦନ ପାଇଁ। ଇଚ୍ଛାଧୀନ।';

  @override
  String get onbCurrencyTitle => 'ଆପଣଙ୍କ ମୁଦ୍ରା ବାଛନ୍ତୁ';

  @override
  String get onbCurrencyBody => 'ରାଶି ଏହି ମୁଦ୍ରାରେ ଦେଖାଯିବ। ଆପଣ ପରେ ସେଟିଂସରେ ବଦଳାଇପାରିବେ।';

  @override
  String onbCurrencySample(String currency, String amount) {
    return '$currency · ଯେପରି $amount';
  }

  @override
  String get onbSourceTitle => 'ଆପଣ କେଉଁଥିରୁ ଦେୟ କରନ୍ତି?';

  @override
  String onbSourceBody(String name) {
    return 'ଆପଣଙ୍କ ମୁଖ୍ୟ ଆକାଉଣ୍ଟ ଯୋଡନ୍ତୁ। ଏହା ନୂଆ କାରବାରର ଡିଫଲ୍ଟ ଦେୟ ପଦ୍ଧତି ହେବ। ଖାଲି ରଖିଲେ $name ରୁ ଆରମ୍ଭ ହେବ।';
  }

  @override
  String get sourceKindCash => 'ନଗଦ';

  @override
  String get sourceNameField => 'ନାମ, ଯେପରି HDFC ସଞ୍ଚୟ';

  @override
  String get optional => 'ଇଚ୍ଛାଧୀନ';

  @override
  String get onbLocationTitle => 'ସ୍ଥାନ ସ୍ୱତଃ ଲେଖିବେ?';

  @override
  String get onbLocationBody => 'ଲୋକେସନ ଚାଲୁ ଥିଲେ ନୂଆ କାରବାରରେ ଆପଣ ଥିବା ସ୍ଥାନ ଯୋଡାଯାଏ। ଏହା କେବଳ ଏହି ଫୋନରେ ଆପଣଙ୍କ ଏଣ୍ଟ୍ରି ସହ ସେଭ ହୁଏ। ଆପଣ ସ୍ଥାନ ନିଜେ ବି ଲେଖିପାରିବେ।';

  @override
  String get onbLocationContinue => 'ଲୋକେସନ ବିନା ଜାରି ରଖନ୍ତୁ';

  @override
  String get onbLocationAllow => 'ଲୋକେସନ ଅନୁମତି ଦିଅନ୍ତୁ';

  @override
  String get onbLocationDenied => 'ଅନୁମତି ମିଳିଲା ନାହିଁ। ଆପଣ ପରେ ସେଟିଂସରେ ଚାଲୁ କରିପାରିବେ।';

  @override
  String get onbSmsTitle => 'ବ୍ୟାଙ୍କ SMS ରୁ ଖର୍ଚ୍ଚ ଯୋଡିବେ?';

  @override
  String get onbSmsBodyShortcuts =>
      'Shortcuts ଅଟୋମେସନ ପ୍ରତ୍ୟେକ ବ୍ୟାଙ୍କ, କାର୍ଡ କିମ୍ବା UPI SMS ଆମକୁ ଦେଇପାରେ; ଆମେ ଏହାକୁ ଏହି ଫୋନରେ ପଢ଼ୁ ଏବଂ ନୋଟିଫିକେସନରୁ ଗୋଟିଏ ଟ୍ୟାପରେ ପଚାରୁ ଯୋଡିବେ କି ନାହିଁ। ସେଟଅପ ପଦ୍ଧତି ସେଟିଂସ › SMS ରୁ ଖର୍ଚ୍ଚ ରେ ଅଛି।';

  @override
  String get onbSmsBody => 'ବ୍ୟାଙ୍କ, କାର୍ଡ କିମ୍ବା UPI SMS ଆସିଲେ ଆମେ ଏହାକୁ ଏହି ଫୋନରେ ପଢ଼ୁ ଏବଂ ନୋଟିଫିକେସନରୁ ଗୋଟିଏ ଟ୍ୟାପରେ ପଚାରୁ ଯୋଡିବେ କି ନାହିଁ। OTP ଓ ଅଫର ଛାଡି ଦିଆଯାଏ, ଏବଂ କିଛି ଅପଲୋଡ ହୁଏ ନାହିଁ।';

  @override
  String get onbSmsContinue => 'SMS ବିନା ଜାରି ରଖନ୍ତୁ';

  @override
  String get turnOn => 'ଚାଲୁ କରନ୍ତୁ';

  @override
  String get onbSmsAllow => 'SMS ଅନୁମତି ଦିଅନ୍ତୁ';

  @override
  String get onbSmsDenied => 'SMS ଅନୁମତି ମିଳିଲା ନାହିଁ। ଆପଣ ପରେ ସେଟିଂସ › SMS ରୁ ଖର୍ଚ୍ଚ ରେ ଚାଲୁ କରିପାରିବେ।';

  @override
  String get onbLockTitle => 'ଆପ ଲକ କରିବେ?';

  @override
  String get onbLockBody => 'ଆପ ଖୋଲିଲେ PIN (କିମ୍ବା ଫିଙ୍ଗରପ୍ରିଣ୍ଟ / ମୁହଁ) ମାଗନ୍ତୁ, ଏବଂ ଆପ ସୁଇଚରରେ ରାଶି ଲୁଚାନ୍ତୁ। ଆପଣ ଯେକୌଣସି ସମୟରେ ସେଟିଂସରେ ବଦଳାଇପାରିବେ।';

  @override
  String get onbLockAction => 'PIN ସେଟ କରନ୍ତୁ';

  @override
  String get onbRemindersTitle => 'ରିମାଇଣ୍ଡର ଚାହାଁନ୍ତି?';

  @override
  String get onbRemindersBody => 'ବଜେଟ 80% କିମ୍ବା 100% ପହଞ୍ଚିଲେ, EMI କିମ୍ବା କାର୍ଡ ବିଲ ଦେୟର ଆଗଦିନ, SIP ତାରିଖରେ ଏବଂ FD ମ୍ୟାଚ୍ୟୁର ହେବା ପୂର୍ବରୁ ସୂଚନା। ଏହି ଫୋନରେ ହିଁ ସ୍ଥିର ହୁଏ; କିଛି କୁଆଡେ ପଠାଯାଏ ନାହିଁ।';

  @override
  String get onbRemindersContinue => 'ରିମାଇଣ୍ଡର ବିନା ଜାରି ରଖନ୍ତୁ';

  @override
  String get onbRemindersAllow => 'ରିମାଇଣ୍ଡର ଚାଲୁ କରନ୍ତୁ';

  @override
  String get onbRemindersDenied => 'ନୋଟିଫିକେସନ ବ୍ଲକ ଅଛି। ଆପଣ ପରେ ସେଟିଂସ › ରିମାଇଣ୍ଡର ଓ ଆଲର୍ଟ ରେ ଚାଲୁ କରିପାରିବେ।';

  @override
  String get currencyInr => 'ଭାରତୀୟ ଟଙ୍କା';

  @override
  String get currencyUsd => 'ଆମେରିକୀୟ ଡଲାର';

  @override
  String get currencyEur => 'ୟୁରୋ';

  @override
  String get currencyGbp => 'ବ୍ରିଟିଶ ପାଉଣ୍ଡ';

  @override
  String get currencyAed => 'UAE ଦିରହାମ';

  @override
  String get currencySgd => 'ସିଙ୍ଗାପୁର ଡଲାର';

  @override
  String get currencyAud => 'ଅଷ୍ଟ୍ରେଲୀୟ ଡଲାର';

  @override
  String get currencyCad => 'କାନାଡୀୟ ଡଲାର';

  @override
  String get goodMorning => 'ସୁପ୍ରଭାତ';

  @override
  String get goodAfternoon => 'ନମସ୍କାର';

  @override
  String get goodEvening => 'ଶୁଭ ସନ୍ଧ୍ୟା';

  @override
  String get welcome => 'ସ୍ୱାଗତ';

  @override
  String get reminders => 'ରିମାଇଣ୍ଡର';

  @override
  String homeSmsReview(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'SMS ରୁ $n କାରବାର ଯାଞ୍ଚ କରିବାକୁ ଅଛି', one: 'SMS ରୁ 1 କାରବାର ଯାଞ୍ଚ କରିବାକୁ ଅଛି');
    return '$_temp0';
  }

  @override
  String get homeOutThisMonth => 'ଏହି ମାସ ବାହାରକୁ ଗଲା';

  @override
  String homeOutIn(String month) {
    return '$month ରେ ବାହାରକୁ ଗଲା';
  }

  @override
  String get invested => 'ନିବେଶ କଲେ';

  @override
  String homeInvestedThisMonth(String amount) {
    return 'ଏହି ମାସ +$amount';
  }

  @override
  String homeInvestedIn(String amount, String month) {
    return '$month ରେ +$amount';
  }

  @override
  String homeMonthlyEmi(String amount) {
    return '$amount/ମାସ EMI';
  }

  @override
  String get comingUp => 'ଆସନ୍ତା';

  @override
  String get seeAll => 'ସବୁ ଦେଖନ୍ତୁ';

  @override
  String get whereItWent => 'ଟଙ୍କା କୁଆଡେ ଗଲା';

  @override
  String get homeNoSpendYet => 'ଏହି ମାସ ଏଯାଏଁ କୌଣସି ଖର୍ଚ୍ଚ ନାହିଁ।';

  @override
  String homeNoSpendIn(String period) {
    return '$period ରେ କୌଣସି ଖର୍ଚ୍ଚ ନାହିଁ।';
  }

  @override
  String get recent => 'ସାମ୍ପ୍ରତିକ';

  @override
  String get viewAll => 'ସବୁ ଦେଖନ୍ତୁ';

  @override
  String get homeNoTxns => 'ଏଯାଏଁ କୌଣସି କାରବାର ନାହିଁ';

  @override
  String get homeNoTxnsHelp => 'ଆପଣଙ୍କ ପ୍ରଥମ ଖର୍ଚ୍ଚ, ନିବେଶ କିମ୍ବା ଆୟ ଯୋଡିବାକୁ + ଦବାନ୍ତୁ।';

  @override
  String homeNothingIn(String period) {
    return '$period ରେ କିଛି ନାହିଁ';
  }

  @override
  String get homeNothingInHelp => 'ସେହି ମାସରେ କୌଣସି କାରବାର ରେକର୍ଡ ହୋଇନାହିଁ।';

  @override
  String homeOfIncome(String amount) {
    return '$amount ଆୟରୁ';
  }

  @override
  String get spent => 'ଖର୍ଚ୍ଚ';

  @override
  String get left => 'ବାକି';

  @override
  String get catKindInvestment => 'ନିବେଶ';

  @override
  String catMove(String name) {
    return '$name ସ୍ଥାନାନ୍ତର କରନ୍ତୁ';
  }

  @override
  String get catTopLevel => 'ସର୍ବୋଚ୍ଚ ସ୍ତର';

  @override
  String catUnder(String name) {
    return '$name ତଳେ';
  }

  @override
  String get catMoveOnlyLeaf => 'କେବଳ ଉପ-ବର୍ଗ ନଥିବା ବର୍ଗକୁ ଅନ୍ୟ ବର୍ଗ ତଳକୁ ନିଆଯାଇପାରିବ';

  @override
  String get catDefaultHelp => 'ଡିଫଲ୍ଟ — କିଛି ନ ବାଛିଲେ ବ୍ୟବହାର ହୁଏ';

  @override
  String get catAddSub => 'ଉପ-ବର୍ଗ ଯୋଡନ୍ତୁ';

  @override
  String get catMoveMenu => 'ସ୍ଥାନାନ୍ତର…';

  @override
  String get catMoveUnderMenu => 'ତଳକୁ ନିଅନ୍ତୁ…';

  @override
  String catArchive(String name) {
    return '$name ଆର୍କାଇଭ କରନ୍ତୁ';
  }

  @override
  String catArchived(String name) {
    return '$name ଆର୍କାଇଭ ହେଲା';
  }

  @override
  String get catAdd => 'ବର୍ଗ ଯୋଡନ୍ତୁ';

  @override
  String get catSpendHelp => 'ଚାଲିଯାଇଥିବା ଟଙ୍କା — ଖାଦ୍ୟ, ଭଡା, ବିଲ। ଉପ-ବର୍ଗ ଯୋଡିବାକୁ ⋮ ଦବାନ୍ତୁ।';

  @override
  String get catInvestHelp => 'ବାହାରକୁ ଯାଇଥିବା ଟଙ୍କା ଯାହା ଆପଣଙ୍କ ସମ୍ପତ୍ତି ବଢ଼ାଏ।';

  @override
  String get catIncomeHelp => 'ଆସୁଥିବା ଟଙ୍କା।';

  @override
  String catArchivedCount(int n) {
    return 'ଆର୍କାଇଭ ($n)';
  }

  @override
  String get catArchivedHelp => 'ଇତିହାସ ପାଇଁ ରଖାଯାଇଛି; ନୂଆ କାରବାରରେ ଦେଖାଯାଏ ନାହିଁ';

  @override
  String catKindUnder(String kind, String parent) {
    return '$kind · $parent ତଳେ';
  }

  @override
  String get restore => 'ରିଷ୍ଟୋର କରନ୍ତୁ';

  @override
  String catRestored(String name) {
    return '$name ରିଷ୍ଟୋର ହେଲା';
  }

  @override
  String get catNew => 'ନୂଆ ବର୍ଗ';

  @override
  String catNewSub(String name) {
    return '$name ରେ ନୂଆ ଉପ-ବର୍ଗ';
  }

  @override
  String get immediately => 'ତୁରନ୍ତ';

  @override
  String seconds(int n) {
    return '$n ସେକେଣ୍ଡ';
  }

  @override
  String minutes(int n) {
    return '$n ମିନିଟ';
  }

  @override
  String get pinChoose => 'PIN ବାଛନ୍ତୁ';

  @override
  String get pinConfirm => 'ଆପଣଙ୍କ PIN ପୁଣି ଦିଅନ୍ତୁ';

  @override
  String get pinDigits => '4–6 ଅଙ୍କ ଦିଅନ୍ତୁ';

  @override
  String get pinAgain => 'ସେହି PIN ପୁଣି ଦିଅନ୍ତୁ';

  @override
  String pinCooldown(int n) {
    return 'ବହୁତ ଅଧିକ ଚେଷ୍ଟା। $n ସେକେଣ୍ଡ ପରେ ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';
  }

  @override
  String get pinWrong => 'ଭୁଲ PIN';

  @override
  String get pinCurrent => 'ଆପଣଙ୍କ ବର୍ତ୍ତମାନର PIN ଦିଅନ୍ତୁ';

  @override
  String get lockOn => 'ଆପ ଲକ ଚାଲୁ ଅଛି';

  @override
  String get pinChanged => 'PIN ବଦଳିଗଲା';

  @override
  String get encryptTitle => 'ଡାଟାବେସ ଏନକ୍ରିପ୍ଟ କରିବେ?';

  @override
  String get encryptBody =>
      'ଆପଣଙ୍କ ଡାଟା ଏହି ଫୋନର ସୁରକ୍ଷିତ ଷ୍ଟୋରେଜରେ ଥିବା ଏକ କି ଦ୍ୱାରା ଏନକ୍ରିପ୍ଟ ହେବ। ସେହି କି ହଜିଗଲେ (ଯେପରି ଆପ ଡାଟା ସଫା ହେଲେ), ଡାଟା ଫେରିପାଇହେବ ନାହିଁ — ପ୍ରଥମେ ବ୍ୟାକଅପ ଏକ୍ସପୋର୍ଟ କରନ୍ତୁ।';

  @override
  String get encrypt => 'ଏନକ୍ରିପ୍ଟ କରନ୍ତୁ';

  @override
  String get dbEncrypted => 'ଡାଟାବେସ ଏନକ୍ରିପ୍ଟ ହେଲା';

  @override
  String get dbDecrypted => 'ଡାଟାବେସ ଡିକ୍ରିପ୍ଟ ହେଲା';

  @override
  String get appLock => 'ଆପ ଲକ';

  @override
  String get lockWithPin => 'PIN ଦ୍ୱାରା ଲକ କରନ୍ତୁ';

  @override
  String get lockWithPinHelp => 'ଆପ ଖୋଲିଲେ ପଚରାଯାଏ';

  @override
  String get changePin => 'PIN ବଦଳାନ୍ତୁ';

  @override
  String get unlockBiometric => 'ଫିଙ୍ଗରପ୍ରିଣ୍ଟ / ମୁହଁ ଦ୍ୱାରା ଅନଲକ କରନ୍ତୁ';

  @override
  String get notAvailableDevice => 'ଏହି ଡିଭାଇସରେ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get lockAgainAfter => 'ଆପ ଛାଡିବା ପରେ ପୁଣି ଲକ';

  @override
  String get hideSwitcher => 'ଆପ ସୁଇଚରରେ ଲୁଚାନ୍ତୁ';

  @override
  String get hideSwitcherHelp => 'ସାମ୍ପ୍ରତିକ ଆପର ପ୍ରିଭ୍ୟୁ ଅସ୍ପଷ୍ଟ କରେ ଏବଂ ସ୍କ୍ରିନସଟ ରୋକେ';

  @override
  String get encryption => 'ଏନକ୍ରିପସନ';

  @override
  String get encryptDb => 'ଡାଟାବେସ ଏନକ୍ରିପ୍ଟ କରନ୍ତୁ';

  @override
  String get encryptKeyStored => 'କି ଫୋନର ସୁରକ୍ଷିତ ଷ୍ଟୋରେଜରେ ଅଛି';

  @override
  String get encryptUnavailable => 'ଏହି ଡାଟାବେସ ପାଇଁ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get budgetNew => 'ନୂଆ ବଜେଟ';

  @override
  String budgetTabWeekly(String span) {
    return 'ସାପ୍ତାହିକ · $span';
  }

  @override
  String get budgetTabMonthly => 'ମାସିକ · 1 ତାରିଖରୁ ମାସ ଶେଷ ଯାଏଁ';

  @override
  String budgetOverBanner(String name, String amount) {
    return '$name $amount ଅଧିକ ହୋଇଗଲା';
  }

  @override
  String get budgetNoneWeekly => 'କୌଣସି ସାପ୍ତାହିକ ବଜେଟ ନାହିଁ';

  @override
  String get budgetNoneMonthly => 'କୌଣସି ମାସିକ ବଜେଟ ନାହିଁ';

  @override
  String get budgetEmptyHelp => 'ଯେକୌଣସି ବର୍ଗ ପାଇଁ ସୀମା ସ୍ଥିର କରନ୍ତୁ ଏବଂ ପ୍ରତି ଅବଧିରେ ଟ୍ରାକ କରନ୍ତୁ।';

  @override
  String get budgetCreate => 'ବଜେଟ ତିଆରି କରନ୍ତୁ';

  @override
  String get budgetGoalReached => 'ଲକ୍ଷ୍ୟ ପୂରଣ';

  @override
  String budgetToGoal(String amount) {
    return 'ଲକ୍ଷ୍ୟ ପାଇଁ $amount ବାକି';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount ଅଧିକ';
  }

  @override
  String budgetLeft(String amount, String perDay, String days) {
    return '$amount ବାକି · $perDay/ଦିନ · $days';
  }

  @override
  String get budgetAllInvestments => 'ସବୁ ନିବେଶ';

  @override
  String get budgetAllSpending => 'ସବୁ ଖର୍ଚ୍ଚ';

  @override
  String nCategories(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ବର୍ଗ', one: '1 ବର୍ଗ');
    return '$_temp0';
  }

  @override
  String ofAmount(String amount) {
    return '$amount ରୁ';
  }

  @override
  String get budgetNeedNameLimit => 'ନାମ ଓ ସୀମା ଲେଖନ୍ତୁ';

  @override
  String get budgetEdit => 'ବଜେଟ ବଦଳାନ୍ତୁ';

  @override
  String get budgetDelete => 'ବଜେଟ ଡିଲିଟ କରନ୍ତୁ';

  @override
  String get budgetNameField => 'ନାମ, ଯେପରି ଖାଦ୍ୟ';

  @override
  String budgetLimitField(String symbol) {
    return 'ସୀମା ($symbol)';
  }

  @override
  String budgetSuggestion(String amount) {
    return 'ଗତ 3 ମାସରେ ଆପଣଙ୍କ ହାରାହାରି $amount/ମାସ · ବ୍ୟବହାର ପାଇଁ ଟ୍ୟାପ କରନ୍ତୁ';
  }

  @override
  String get budgetRepeats => 'ପୁନରାବୃତ୍ତି';

  @override
  String budgetWeek(String span) {
    return 'ସପ୍ତାହ ($span)';
  }

  @override
  String get budgetMonth => 'ମାସ (1 ତାରିଖ → ଶେଷ)';

  @override
  String get budgetGoal => 'ନିବେଶ ଲକ୍ଷ୍ୟ';

  @override
  String get budgetGoalHelp => 'ଖର୍ଚ୍ଚ ସୀମା ବଦଳରେ ନିବେଶ ରାଶିର ଲକ୍ଷ୍ୟ ଟ୍ରାକ କରନ୍ତୁ';

  @override
  String get budgetCounts => 'ଏହି ନିବେଶଗୁଡିକ ଗଣାଯିବ';

  @override
  String get budgetAppliesTo => 'କେଉଁଥିରେ ଲାଗୁ (ଖାଲି = ସବୁ ଖର୍ଚ୍ଚ)';

  @override
  String get budgetRollover => 'ବଳକା ରାଶି ଆଗକୁ ନିଅନ୍ତୁ';

  @override
  String get budgetAlert80Switch => '80% ରେ ଆଲର୍ଟ';

  @override
  String get budgetAlertOver => 'ସୀମା ପାର ହେଲେ ଆଲର୍ଟ';

  @override
  String get budgetSave => 'ବଜେଟ ସେଭ କରନ୍ତୁ';

  @override
  String get totalInvested => 'ମୋଟ ନିବେଶ';

  @override
  String investThisMonth(String amount, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ହୋଲ୍ଡିଂ', one: '1 ହୋଲ୍ଡିଂ');
    return 'ଏହି ମାସ +$amount · $_temp0';
  }

  @override
  String get investNoPrices => 'ଆପଣ ଲଗାଇଥିବା ରାଶି · ଲାଇଭ ଦର କିମ୍ବା ରିଟର୍ନ ନାହିଁ';

  @override
  String investMaturesOn(String name, String date) {
    return '$name $date ରେ ମ୍ୟାଚ୍ୟୁର ହେବ';
  }

  @override
  String get investNone => 'ଏଯାଏଁ କୌଣସି ନିବେଶ ନାହିଁ';

  @override
  String get investNoneHelp => 'ଆପଣ କ\'ଣ ନିବେଶ କରନ୍ତି ତାହା ଟ୍ରାକ କରିବାକୁ FD, SIP, ସେୟାର କିମ୍ବା ସୁନା ଯୋଡନ୍ତୁ।';

  @override
  String get investAdd => 'ନିବେଶ ଯୋଡନ୍ତୁ';

  @override
  String investMatures(String date) {
    return '$date ରେ ମ୍ୟାଚ୍ୟୁର';
  }

  @override
  String nEntries(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ଏଣ୍ଟ୍ରି', one: '1 ଏଣ୍ଟ୍ରି');
    return '$_temp0';
  }

  @override
  String get interestRate => 'ସୁଧ ହାର';

  @override
  String investStarted(String date) {
    return '$date ରେ ଆରମ୍ଭ';
  }

  @override
  String investMaturesCap(String date) {
    return '$date ରେ ମ୍ୟାଚ୍ୟୁର';
  }

  @override
  String get institution => 'ସଂସ୍ଥା';

  @override
  String get note => 'ନୋଟ';

  @override
  String contributions(int n) {
    return 'ଯୋଗଦାନ ($n)';
  }

  @override
  String get investNoMoney => 'ଏଯାଏଁ କୌଣସି ଟଙ୍କା ଯୋଡାଯାଇନାହିଁ।';

  @override
  String get investAddMoney => 'ଟଙ୍କା ଯୋଡନ୍ତୁ';

  @override
  String get investMarkMatured => 'ମ୍ୟାଚ୍ୟୁର ଭାବେ ଚିହ୍ନିତ କରନ୍ତୁ';

  @override
  String get investCloseSold => 'ବନ୍ଦ / ବିକ୍ରି';

  @override
  String get investReactivate => 'ପୁଣି ସକ୍ରିୟ କରନ୍ତୁ';

  @override
  String get investNeedName => 'ନିବେଶକୁ ଏକ ନାମ ଦିଅନ୍ତୁ';

  @override
  String get investNameField => 'ନାମ, ଯେପରି HDFC ବ୍ୟାଙ୍କ FD';

  @override
  String get investInstitutionField => 'ବ୍ୟାଙ୍କ / ପ୍ଲାଟଫର୍ମ (ଇଚ୍ଛାଧୀନ)';

  @override
  String get investAmountField => 'ଏବେ ନିବେଶ ରାଶି (ଇଚ୍ଛାଧୀନ)';

  @override
  String get startDate => 'ଆରମ୍ଭ ତାରିଖ';

  @override
  String get maturityDate => 'ମ୍ୟାଚ୍ୟୁରିଟି ତାରିଖ (ଇଚ୍ଛାଧୀନ)';

  @override
  String get investSave => 'ନିବେଶ ସେଭ କରନ୍ତୁ';

  @override
  String get sourceKindBank => 'ବ୍ୟାଙ୍କ ଆକାଉଣ୍ଟ';

  @override
  String get sourceKindWallet => 'UPI / ୱାଲେଟ';

  @override
  String get sourceAdd => 'ଦେୟ ପଦ୍ଧତି ଯୋଡନ୍ତୁ';

  @override
  String get sourceDefaultHelp => 'ପ୍ରତ୍ୟେକ ନୂଆ କାରବାରରେ ପୂର୍ବରୁ ବଛା ହୋଇଥାଏ';

  @override
  String sourceOutIn(String kind, String amount, String month) {
    return '$kind · $month ରେ $amount ବାହାର';
  }

  @override
  String sourceLimit(String amount) {
    return 'ସୀମା $amount';
  }

  @override
  String sourceBalance(String amount) {
    return 'ବାଲାନ୍ସ $amount';
  }

  @override
  String sourceOutstanding(String amount) {
    return '$amount ବକେୟା';
  }

  @override
  String sourceCredit(String amount) {
    return '$amount କ୍ରେଡିଟ';
  }

  @override
  String get sourceNew => 'ନୂଆ ଦେୟ ପଦ୍ଧତି';

  @override
  String get sourceLast4 => 'ଶେଷ 4 ଅଙ୍କ (ଇଚ୍ଛାଧୀନ)';

  @override
  String sourceCreditLimit(String symbol) {
    return 'କ୍ରେଡିଟ ସୀମା ($symbol)';
  }

  @override
  String sourceBalanceHelp(String amount) {
    return 'ଇଚ୍ଛାଧୀନ · ଡିଫଲ୍ଟ $amount';
  }

  @override
  String get makeDefault => 'ଡିଫଲ୍ଟ କରନ୍ତୁ';

  @override
  String sourceOutstandingField(String symbol) {
    return 'ବର୍ତ୍ତମାନର ବକେୟା ($symbol)';
  }

  @override
  String sourceBalanceField(String symbol) {
    return 'ବର୍ତ୍ତମାନର ବାଲାନ୍ସ ($symbol)';
  }

  @override
  String get sourceAdjustHelp => 'ଏଠାରୁ ଆଗକୁ ଆପଣ ଯୋଡୁଥିବା କାରବାର ଏହାକୁ ବଦଳାଇବ';

  @override
  String get pdfReport => 'PDF ରିପୋର୍ଟ';

  @override
  String get week => 'ସପ୍ତାହ';

  @override
  String get month => 'ମାସ';

  @override
  String get year => 'ବର୍ଷ';

  @override
  String get previousPeriod => 'ଗତ ଅବଧି';

  @override
  String get nextPeriod => 'ପରବର୍ତ୍ତୀ ଅବଧି';

  @override
  String insightsDonutLabel(String spent, String invested) {
    return 'ଖର୍ଚ୍ଚ $spent, ନିବେଶ $invested';
  }

  @override
  String get moneyOutLabel => 'ବାହାରକୁ ଗଲା';

  @override
  String insightsSaved(int n) {
    return 'ଆୟର $n% ସଞ୍ଚୟ';
  }

  @override
  String get insightsNoEarlier => 'ପୂର୍ବର ଡାଟା ନାହିଁ';

  @override
  String insightsLessSpent(int n) {
    return '$n% କମ ଖର୍ଚ୍ଚ';
  }

  @override
  String insightsMoreSpent(int n) {
    return '$n% ଅଧିକ ଖର୍ଚ୍ଚ';
  }

  @override
  String get insightsThanPrevious => 'ଗତ ଅବଧି ତୁଳନାରେ';

  @override
  String perDay(String amount) {
    return '$amount / ଦିନ';
  }

  @override
  String get averageSpend => 'ହାରାହାରି ଖର୍ଚ୍ଚ';

  @override
  String get monthByMonth => 'ମାସ ମାସ';

  @override
  String get weekByWeek => 'ସପ୍ତାହ ସପ୍ତାହ';

  @override
  String get dayByDay => 'ଦିନ ଦିନ';

  @override
  String get byCategory => 'ବର୍ଗ ଅନୁସାରେ';

  @override
  String get insightsNothing => 'ଏହି ଅବଧିରେ କିଛି ରେକର୍ଡ ହୋଇନାହିଁ।';

  @override
  String insightsDirect(String name) {
    return '$name (ସିଧାସଳଖ)';
  }

  @override
  String insightsCatRow(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n କାରବାର', one: '1 କାରବାର');
    return '$name  ·  $_temp0';
  }

  @override
  String get hideSubs => 'ଉପ-ବର୍ଗ ଲୁଚାନ୍ତୁ';

  @override
  String get showSubs => 'ଉପ-ବର୍ଗ ଦେଖାନ୍ତୁ';

  @override
  String get smsReadTitle => 'ବ୍ୟାଙ୍କ SMS ପଢ଼ିବେ?';

  @override
  String get smsReadBodyShortcuts =>
      'iPhone ଆପ SMS ପଢ଼ିପାରେ ନାହିଁ, ତେଣୁ Shortcuts ଅଟୋମେସନ ପ୍ରତ୍ୟେକ ବ୍ୟାଙ୍କ ମେସେଜ Expense Manager କୁ ଦିଏ। ଏହା ଏହି ଫୋନରେ ପଢ଼ାଯାଏ ଏବଂ ଆପଣଙ୍କୁ ପଚରାଯାଏ କାରବାର ଯୋଡିବେ କି ନାହିଁ।\n\nକିଛି କୁଆଡେ ପଠାଯାଏ ନାହିଁ। OTP, ଅଫର ଓ ରିମାଇଣ୍ଡର ଛାଡି ଦିଆଯାଏ। ଏହାପରେ, ଏହି ସ୍କ୍ରିନର ପଦକ୍ଷେପ ଅନୁସାରେ ଅଟୋମେସନ ସେଟ କରନ୍ତୁ।';

  @override
  String get smsReadBody =>
      'ବ୍ୟାଙ୍କ, କାର୍ଡ କିମ୍ବା UPI SMS ଆସିଲେ Expense Manager ଏହାକୁ ଏହି ଫୋନରେ ପଢ଼େ ଏବଂ ପଚାରେ କାରବାର ଯୋଡିବେ କି ନାହିଁ।\n\nକେବଳ ଡେବିଟ କିମ୍ବା କ୍ରେଡିଟ ହୋଇଥିବା ରାଶି ଥିବା ମେସେଜ ରଖାଯାଏ, ଏବଂ କିଛି କୁଆଡେ ପଠାଯାଏ ନାହିଁ। OTP, ଅଫର ଓ ରିମାଇଣ୍ଡର ଛାଡି ଦିଆଯାଏ।';

  @override
  String get smsDenied => 'SMS ଅନୁମତି ମନା କରାଗଲା। ସିଷ୍ଟମ ସେଟିଂସରେ Expense Manager କୁ ଅନୁମତି ଦିଅନ୍ତୁ।';

  @override
  String get smsNoNotifications => 'ନୋଟିଫିକେସନ ବ୍ଲକ ଅଛି, ତେଣୁ ନୂଆ ଖର୍ଚ୍ଚ କେବଳ ଏଠାରେ ଦେଖାଯିବ।';

  @override
  String addedThing(String what) {
    return '$what ଯୋଡାଗଲା';
  }

  @override
  String get smsAskToAdd => 'ବ୍ୟାଙ୍କ SMS ଯୋଡିବାକୁ ପଚାରନ୍ତୁ';

  @override
  String get smsAskToAddHelp => 'ଏହି ଫୋନରେ ପଢ଼ାଯାଏ · କିଛି ଅପଲୋଡ ହୁଏ ନାହିଁ';

  @override
  String get smsPermissionOff => 'SMS ଅନୁମତି ବନ୍ଦ ଅଛି, ତେଣୁ ନୂଆ ମେସେଜ ପଢ଼ାଯାଏ ନାହିଁ।';

  @override
  String get allow => 'ଅନୁମତି ଦିଅନ୍ତୁ';

  @override
  String get smsNothingToReview => 'ଯାଞ୍ଚ କରିବାକୁ କିଛି ନାହିଁ';

  @override
  String smsToReview(int n) {
    return 'ଯାଞ୍ଚ କରିବାକୁ ($n)';
  }

  @override
  String get smsOnHelp => 'ନୂଆ ବ୍ୟାଙ୍କ ଓ UPI କାରବାର ଏଠାରେ ଏବଂ ନୋଟିଫିକେସନରେ ଦେଖାଯାଏ।';

  @override
  String get smsOffHelp => 'ପ୍ରତ୍ୟେକ ବ୍ୟାଙ୍କ କିମ୍ବା UPI କାରବାରର SMS ଆସିଲେ ପଚରାଯିବା ପାଇଁ ଏହା ଚାଲୁ କରନ୍ତୁ।';

  @override
  String get smsStep1 => 'Shortcuts ଖୋଲନ୍ତୁ → Automation → + (New Automation) → Message।';

  @override
  String smsStep2(String keyword) {
    return 'Message Contains: $keyword। Run Immediately ବାଛନ୍ତୁ, ତାପରେ Next।';
  }

  @override
  String smsStep3(String action) {
    return 'New Blank Automation → Add Action → \"$action\" (Expense Manager) ଖୋଜନ୍ତୁ।';
  }

  @override
  String get smsStep4 => 'ଆକ୍ସନରେ Message ଟ୍ୟାପ କରନ୍ତୁ ଏବଂ Shortcut Input ବାଛନ୍ତୁ। Done।';

  @override
  String smsStep5(String first, String second) {
    return 'ଅଧିକ ବ୍ୟାଙ୍କ ପାଇଁ \"$first\" ଓ \"$second\" ସହ ଏହା ପୁନରାବୃତ୍ତି କରନ୍ତୁ।';
  }

  @override
  String couldNotOpen(String url) {
    return '$url ଖୋଲିହେଲା ନାହିଁ';
  }

  @override
  String get smsSetupIphone => 'iPhone ରେ ସେଟଅପ';

  @override
  String get smsSetupIphoneHelp => 'iOS ଆପକୁ SMS ପଢ଼ିବାକୁ ଦିଏ ନାହିଁ। ଏହା ବଦଳରେ ଏକ Shortcuts ଅଟୋମେସନ ପ୍ରତ୍ୟେକ ବ୍ୟାଙ୍କ ମେସେଜ Expense Manager କୁ ଦିଏ (iOS 17 କିମ୍ବା ପରବର୍ତ୍ତୀ ନ ପଚାରି ଚଲାଏ)।';

  @override
  String get smsOpenShortcuts => 'Shortcuts ଖୋଲନ୍ତୁ';

  @override
  String get smsGuide => 'ଛବି ସହ ଗାଇଡ';

  @override
  String get sipStopTitle => 'ଏହି SIP ବନ୍ଦ କରିବେ?';

  @override
  String get sipStopBody => 'ପୂର୍ବରୁ ରେକର୍ଡ ହୋଇଥିବା ଯୋଗଦାନ ଏହି ନିବେଶରେ ରହିବ।';

  @override
  String get sipStop => 'SIP ବନ୍ଦ କରନ୍ତୁ';

  @override
  String get sipSetup => 'ମାସିକ SIP ସେଟ କରନ୍ତୁ';

  @override
  String sipSummary(String amount, int day) {
    return 'SIP · ପ୍ରତି ମାସ $day ତାରିଖରେ $amount';
  }

  @override
  String get paused => 'ବିରତ';

  @override
  String nextOn(String date) {
    return 'ପରବର୍ତ୍ତୀ $date';
  }

  @override
  String nextOnFrom(String date, String source) {
    return 'ପରବର୍ତ୍ତୀ $date · $source';
  }

  @override
  String get sipAuto => 'ସ୍ୱତଃ ଯୋଡାଯାଏ';

  @override
  String get sipReminderOnly => 'କେବଳ ରିମାଇଣ୍ଡର · ଦେୟ କଲେ ରେକର୍ଡ କରନ୍ତୁ';

  @override
  String get stop => 'ବନ୍ଦ କରନ୍ତୁ';

  @override
  String get sipMonthly => 'ମାସିକ SIP';

  @override
  String get sipEdit => 'SIP ବଦଳାନ୍ତୁ';

  @override
  String sipAmountField(String symbol) {
    return 'ପ୍ରତି ମାସର ରାଶି ($symbol)';
  }

  @override
  String get dayOfMonth => 'ମାସର ତାରିଖ';

  @override
  String get sipAutoOption => 'ସ୍ୱତଃ ଯୋଡନ୍ତୁ';

  @override
  String get sipAutoOptionHelp => 'ପ୍ରତି ମାସ ନିବେଶ କାରବାର ରେକର୍ଡ କରେ';

  @override
  String get sipRemindOption => 'କେବଳ ମନେ ପକାନ୍ତୁ';

  @override
  String get sipRemindOptionHelp => 'ଆସନ୍ତାରେ ଦେଖାଯାଏ; ରେକର୍ଡ ଆପଣ କରନ୍ତି';

  @override
  String get shareLog => 'ଲଗ ସେୟାର କରନ୍ତୁ';

  @override
  String get clearLog => 'ଲଗ ସଫା କରନ୍ତୁ';

  @override
  String get logCleared => 'ଏରର ଲଗ ସଫା ହେଲା';

  @override
  String get noErrors => 'କୌଣସି ଏରର ରେକର୍ଡ ହୋଇନାହିଁ';

  @override
  String get noErrorsHelp => 'କ୍ରାସ ଓ ଏରର କେବଳ ଏହି ଫୋନରେ ରେକର୍ଡ ହୁଏ। ବଗ ଜଣାଇବା ବେଳେ ଲଗ ସେୟାର କରନ୍ତୁ।';

  @override
  String reminderOn(String date) {
    return '$date ରେ ରିମାଇଣ୍ଡର';
  }

  @override
  String get changeDate => 'ତାରିଖ ବଦଳାନ୍ତୁ';

  @override
  String get remindMeOn => 'ଏହି ଦିନ ମନେ ପକାନ୍ତୁ';

  @override
  String willRemind(String date) {
    return 'ଆମେ ଆପଣଙ୍କୁ $date ରେ ମନେ ପକାଇବୁ';
  }

  @override
  String get savedTurnOnReminders => 'ସେଭ ହେଲା। ନୋଟିଫିକେସନ ପାଇବାକୁ ସେଟିଂସ › ରିମାଇଣ୍ଡର ଓ ଆଲର୍ଟ ଚାଲୁ କରନ୍ତୁ।';

  @override
  String get remindMe => 'ମନେ ପକାନ୍ତୁ';

  @override
  String get locationUnavailable => 'ବର୍ତ୍ତମାନର ଲୋକେସନ ମିଳୁନାହିଁ। ଲୋକେସନ ଅନୁମତି ଦିଅନ୍ତୁ କିମ୍ବା ଖୋଜନ୍ତୁ।';

  @override
  String get pickLocation => 'ସ୍ଥାନ ବାଛନ୍ତୁ';

  @override
  String get searchPlace => 'ସ୍ଥାନ କିମ୍ବା ଠିକଣା ଖୋଜନ୍ତୁ';

  @override
  String get noPlaceMatches => 'କିଛି ମିଳିଲା ନାହିଁ। ଅନ୍ୟ ନାମ ଚେଷ୍ଟା କରନ୍ତୁ କିମ୍ବା ମାନଚିତ୍ରରେ ଟ୍ୟାପ କରନ୍ତୁ।';

  @override
  String get placeName => 'ସ୍ଥାନର ନାମ';

  @override
  String get tapMapForPin => 'ପିନ ରଖିବାକୁ ମାନଚିତ୍ରରେ ଟ୍ୟାପ କରନ୍ତୁ';

  @override
  String pinWrongLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ଚେଷ୍ଟା ବାକି', one: '1 ଚେଷ୍ଟା ବାକି');
    return 'ଭୁଲ PIN · $_temp0';
  }

  @override
  String get appLocked => 'Expense Manager ଲକ ଅଛି';

  @override
  String get ended => 'ଶେଷ';

  @override
  String get reminderOnly => 'କେବଳ ରିମାଇଣ୍ଡର';

  @override
  String get deleteSchedule => 'ଏହି ସମୟସୂଚୀ ଡିଲିଟ କରିବେ?';

  @override
  String get deleteScheduleBody => 'ଆଉ କୌଣସି କାରବାର ଯୋଡାଯିବ ନାହିଁ। ଯାହା ଯୋଡା ହୋଇସାରିଛି ତାହା ରହିବ।';

  @override
  String get recurring => 'ପୁନରାବୃତ୍ତ';

  @override
  String get nothingRecurring => 'ଏଯାଏଁ କିଛି ପୁନରାବୃତ୍ତ ନାହିଁ';

  @override
  String get nothingRecurringHelp => 'କାରବାର ଯୋଡିବା ବେଳେ “ପୁନରାବୃତ୍ତି” ଚାଲୁ କରନ୍ତୁ, କିମ୍ବା କୌଣସି ନିବେଶରେ SIP ସେଟ କରନ୍ତୁ।';

  @override
  String get deleteRule => 'ନିୟମ ଡିଲିଟ କରନ୍ତୁ';

  @override
  String get editSchedule => 'ସମୟସୂଚୀ ବଦଳାନ୍ତୁ';

  @override
  String get onTheDay => 'ସେହି ଦିନ';

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ଦିନ ପୂର୍ବରୁ', one: '1 ଦିନ ପୂର୍ବରୁ');
    return '$_temp0';
  }

  @override
  String get notificationsBlocked => 'ନୋଟିଫିକେସନ ବ୍ଲକ ଅଛି। ସିଷ୍ଟମ ସେଟିଂସରେ Expense Manager କୁ ଅନୁମତି ଦିଅନ୍ତୁ।';

  @override
  String get testSent => 'ଟେଷ୍ଟ ନୋଟିଫିକେସନ ପଠାଗଲା';

  @override
  String get notifications => 'ନୋଟିଫିକେସନ';

  @override
  String get notificationsHelp => 'ଏହି ଫୋନରେ ସ୍ଥିର ହୁଏ · କୌଣସି ସର୍ଭରକୁ କିଛି ପଠାଯାଏ ନାହିଁ';

  @override
  String get fdLeadTitle => 'FD ମ୍ୟାଚ୍ୟୁର ହେବା ପୂର୍ବରୁ ମନେ ପକାନ୍ତୁ';

  @override
  String remindersInfo(String time) {
    return 'ରିମାଇଣ୍ଡର ପ୍ରାୟ $time ରେ ଆସେ: ଦେୟ ତାରିଖ ଆଗଦିନ ଓ ସେହି ଦିନ, SIP ତାହାର ତାରିଖରେ, ଏବଂ ବଜେଟ ଆଲର୍ଟ ପ୍ରତି ବଜେଟ ପାଇଁ ଥରେ ଯେତେବେଳେ ଏହା 80% ଓ 100% ପହଞ୍ଚେ।';
  }

  @override
  String get sendTest => 'ଟେଷ୍ଟ ନୋଟିଫିକେସନ ପଠାନ୍ତୁ';

  @override
  String get tomorrow => 'କାଲି';

  @override
  String inDays(int n) {
    return '$n ଦିନରେ';
  }

  @override
  String get upcomingEmi => 'EMI ଦେୟ';

  @override
  String get upcomingCard => 'କାର୍ଡ ବିଲ ଦେୟ';

  @override
  String get upcomingMaturity => 'ମ୍ୟାଚ୍ୟୁରିଟି';

  @override
  String get upcomingSip => 'SIP ଦେୟ';

  @override
  String get upcomingFollowUp => 'ଫଲୋ-ଅପ';

  @override
  String get nothingComingUp => 'ଆସନ୍ତାରେ କିଛି ନାହିଁ';

  @override
  String get nothingComingUpHelp => 'ଆଗାମୀ 60 ଦିନର EMI, କାର୍ଡ ବିଲ ଓ FD ମ୍ୟାଚ୍ୟୁରିଟି ଏଠାରେ ଦେଖାଯାଏ।';

  @override
  String get txnDeleted => 'କାରବାର ଡିଲିଟ ହେଲା';

  @override
  String get txnGone => 'ଏହି କାରବାର ଆଉ ନାହିଁ।';

  @override
  String get transaction => 'କାରବାର';

  @override
  String get dateTime => 'ତାରିଖ ଓ ସମୟ';

  @override
  String get location => 'ସ୍ଥାନ';

  @override
  String get coordinates => 'ସ୍ଥାନାଙ୍କ';

  @override
  String get repeats => 'ପୁନରାବୃତ୍ତି';

  @override
  String get duplicate => 'ନକଲ କରନ୍ତୁ';

  @override
  String get pdfReceipt => 'PDF ରସିଦ';

  @override
  String get open => 'ଖୋଲନ୍ତୁ';

  @override
  String get receiptMissing => 'ରସିଦ ଫାଇଲ ମିଳିଲା ନାହିଁ';

  @override
  String get keyPlus => 'ପ୍ଲସ';

  @override
  String get keyMinus => 'ମାଇନସ';

  @override
  String get keyEquals => 'ସମାନ';

  @override
  String get keyDecimal => 'ଦଶମିକ';

  @override
  String get keyDoubleZero => 'ଡବଲ ଜିରୋ';

  @override
  String get keyBackspace => 'ବ୍ୟାକସ୍ପେସ';

  @override
  String allOf(String name) {
    return 'ସବୁ $name';
  }

  @override
  String chartBarLabel(String label, String spent, String invested) {
    return '$label: ଖର୍ଚ୍ଚ $spent, ନିବେଶ $invested';
  }

  @override
  String get pinMismatch => 'PIN ମେଳ ଖାଇଲା ନାହିଁ। ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String encryptFailed(String error) {
    return 'ଏନକ୍ରିପସନ ବଦଳାଇହେଲା ନାହିଁ: $error';
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
  String get seedFood => 'ଖାଦ୍ୟ ଓ ଭୋଜନ';

  @override
  String get seedRent => 'ଭଡା';

  @override
  String get seedShopping => 'କିଣାକିଣି';

  @override
  String get seedTransport => 'ପରିବହନ';

  @override
  String get seedBills => 'ବିଲ ଓ ୟୁଟିଲିଟି';

  @override
  String get seedHealth => 'ସ୍ୱାସ୍ଥ୍ୟ';

  @override
  String get seedEntertainment => 'ମନୋରଞ୍ଜନ';

  @override
  String get seedTravel => 'ଯାତ୍ରା';

  @override
  String get seedOthers => 'ଅନ୍ୟ';

  @override
  String get seedFd => 'ଫିକ୍ସଡ ଡିପୋଜିଟ';

  @override
  String get seedMutualFunds => 'ମ୍ୟୁଚୁଆଲ ଫଣ୍ଡ / SIP';

  @override
  String get seedRetirement => 'PPF / EPF / NPS';

  @override
  String get seedSalary => 'ଦରମା';

  @override
  String get seedOtherIncome => 'ଅନ୍ୟ ଆୟ';
}
