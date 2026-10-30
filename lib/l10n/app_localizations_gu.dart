// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'Expense Manager';

  @override
  String get navHome => 'હોમ';

  @override
  String get navInsights => 'વિશ્લેષણ';

  @override
  String get navInvest => 'રોકાણ';

  @override
  String get navDebts => 'દેવું';

  @override
  String get addTransaction => 'વ્યવહાર ઉમેરો';

  @override
  String get ok => 'બરાબર';

  @override
  String get save => 'સેવ કરો';

  @override
  String get cancel => 'રદ કરો';

  @override
  String get none => 'કોઈ નહીં';

  @override
  String get notSet => 'સેટ નથી';

  @override
  String get on => 'ચાલુ';

  @override
  String get off => 'બંધ';

  @override
  String get unknown => 'અજાણ્યું';

  @override
  String get today => 'આજે';

  @override
  String get yesterday => 'ગઈકાલે';

  @override
  String nActive(int count) {
    return '$count સક્રિય';
  }

  @override
  String get locationDenied => 'લોકેશનની મંજૂરી ન મળી — તમે જગ્યા જાતે લખી શકો છો.';

  @override
  String get themeLight => 'લાઇટ';

  @override
  String get themeDark => 'ડાર્ક';

  @override
  String get themeSystem => 'સિસ્ટમ';

  @override
  String get settingsTitle => 'સેટિંગ્સ';

  @override
  String get settingsLocalOnly => 'તમારો ડેટા આ ફોનમાંથી બહાર જતો નથી. ફોનમાં જ સેવ થાય છે, કોઈ સર્વર નથી. ડિવાઇસ બદલવા માટે બેકઅપ એક્સપોર્ટ કરો.';

  @override
  String get settingsProfile => 'પ્રોફાઇલ';

  @override
  String get settingsName => 'નામ';

  @override
  String get settingsYourName => 'તમારું નામ';

  @override
  String get settingsAppearance => 'દેખાવ';

  @override
  String get settingsLanguage => 'ભાષા';

  @override
  String get settingsLanguageDevice => 'ડિવાઇસની ભાષા';

  @override
  String get settingsDefaults => 'ડિફૉલ્ટ';

  @override
  String get settingsDefaultSource => 'ડિફૉલ્ટ ચુકવણી રીત';

  @override
  String get settingsDefaultSourceHelp => 'નવા વ્યવહારમાં પહેલેથી પસંદ રહે છે';

  @override
  String get settingsSources => 'ચુકવણીની રીતો';

  @override
  String get settingsCategories => 'કેટેગરી';

  @override
  String get settingsCategoriesHelp => 'કેટેગરી વગરની એન્ટ્રી ડિફૉલ્ટમાં જાય છે';

  @override
  String settingsDefaultCategory(String name) {
    return 'ડિફૉલ્ટ: $name';
  }

  @override
  String get settingsCurrency => 'ચલણ';

  @override
  String get settingsCurrencyHelp => 'ફક્ત રકમ બતાવવાની રીત બદલાય છે. કંઈ કન્વર્ટ થતું નથી.';

  @override
  String get settingsRecurring => 'પુનરાવર્તિત વ્યવહારો';

  @override
  String get settingsWeekStart => 'અઠવાડિયું શરૂ થાય છે';

  @override
  String get settingsWeekStartHelp => 'સાપ્તાહિક બજેટ અને વિશ્લેષણનું અઠવાડિયાનું દૃશ્ય આને અનુસરે છે.';

  @override
  String settingsWeekSpan(String span) {
    return 'સાપ્તાહિક બજેટ અને વિશ્લેષણ $span ચાલે છે';
  }

  @override
  String get settingsData => 'ડેટા';

  @override
  String get settingsExportCsv => 'CSV એક્સપોર્ટ કરો';

  @override
  String get settingsExportCsvHelp => 'વ્યવહારો, રોકાણ, દેવું, બજેટ';

  @override
  String get settingsExportPdf => 'આ મહિનાનું PDF એક્સપોર્ટ કરો';

  @override
  String get settingsImport => 'CSV અથવા PDF સ્ટેટમેન્ટ ઇમ્પોર્ટ કરો';

  @override
  String get settingsImportHelp => 'HDFC, SBI, ICICI અને મોટાભાગની બેંકના PDF, અથવા CSV એક્સપોર્ટ';

  @override
  String get settingsBackUp => 'હમણાં બેકઅપ લો';

  @override
  String get settingsBackUpHelp => 'એક .ledger ફાઇલ, પાસવર્ડ વૈકલ્પિક';

  @override
  String get settingsRestore => 'બેકઅપમાંથી રીસ્ટોર કરો';

  @override
  String get settingsPrivacyGroup => 'પ્રાઇવસી અને પરવાનગીઓ';

  @override
  String get settingsLocation => 'વ્યવહાર પર લોકેશન';

  @override
  String get settingsAppLock => 'ઍપ લૉક અને પ્રાઇવસી';

  @override
  String get smsTitle => 'SMS પરથી ખર્ચ';

  @override
  String get remindersTitle => 'રિમાઇન્ડર અને અલર્ટ';

  @override
  String get settingsAbout => 'માહિતી';

  @override
  String get settingsVersion => 'વર્ઝન';

  @override
  String get settingsPrivacy => 'પ્રાઇવસી';

  @override
  String get settingsPrivacyHelp => 'કોઈ ડેટા એકત્ર થતો નથી · ઑફલાઇન ચાલે છે';

  @override
  String get settingsPrivacyBody =>
      'Expense Manager માં કોઈ અકાઉન્ટ, સર્વર કે એનાલિટિક્સ નથી. તમે જે કંઈ લખો છો તે આ ફોનના ડેટાબેઝમાં સેવ થાય છે અને તમે જાતે ફાઇલ એક્સપોર્ટ કે શેર કરો ત્યારે જ બહાર જાય છે.\n\nલોકેશન ફક્ત તમારી મંજૂરીથી અને ફક્ત તમારા વ્યવહારો પર જગ્યા લખવા માટે વંચાય છે. નકશો ખોલો ત્યારે નકશાની ટાઇલ્સ OpenStreetMap પરથી લોડ થાય છે. SMS પરથી ખર્ચ ચાલુ કરો તો બેંકના SMS ફક્ત આ ફોન પર જ વંચાય છે.';

  @override
  String get settingsReadPolicy => 'આખી પૉલિસી વાંચો';

  @override
  String get settingsSourceCode => 'GitHub પર સોર્સ કોડ';

  @override
  String get settingsLicenses => 'ઓપન-સોર્સ લાઇસન્સ';

  @override
  String get settingsSupport => 'સહાય';

  @override
  String get diagnosticsTitle => 'ડાયગ્નોસ્ટિક્સ';

  @override
  String get settingsDiagnosticsHelp => 'ફોન પર એરર લૉગ · જુઓ, શેર કરો કે સાફ કરો';

  @override
  String get settingsReportIssue => 'સમસ્યા જણાવો';

  @override
  String get settingsReportIssueHelp => 'GitHub ઇશ્યૂ ખોલે છે · GitHub અકાઉન્ટ જરૂરી';

  @override
  String settingsNoBrowser(String url) {
    return '$url ખોલવા માટે કોઈ બ્રાઉઝર મળ્યું નહીં';
  }

  @override
  String get add => 'ઉમેરો';

  @override
  String get edit => 'બદલો';

  @override
  String get clear => 'સાફ કરો';

  @override
  String get nothingHere => 'અહીં કંઈ નથી';

  @override
  String get dueToday => 'આજે ભરવાનું';

  @override
  String get dueTomorrow => 'કાલે ભરવાનું';

  @override
  String dueInDays(int n) {
    return '$n દિવસમાં ભરવાનું';
  }

  @override
  String overdueByDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n દિવસથી બાકી', one: '1 દિવસથી બાકી');
    return '$_temp0';
  }

  @override
  String debtRemindMessage(String person, String amount) {
    return 'નમસ્તે $person, $amount વિશે એક નાનું રિમાઇન્ડર. તમને અનુકૂળ હોય ત્યારે આપજો. આભાર!';
  }

  @override
  String debtRemindMessageFor(String person, String amount, String reason) {
    return 'નમસ્તે $person, $reason ના $amount વિશે એક નાનું રિમાઇન્ડર. તમને અનુકૂળ હોય ત્યારે આપજો. આભાર!';
  }

  @override
  String get debtRemindSubject => 'મૈત્રીપૂર્ણ રિમાઇન્ડર';

  @override
  String get debtYouOwe => 'તમારે આપવાના';

  @override
  String get debtOwedToYou => 'તમારે લેવાના';

  @override
  String debtMonthlyEmi(String amount) {
    return '$amount/મહિને EMI માં';
  }

  @override
  String get debtToCollect => 'લેવાના બાકી';

  @override
  String get debtIOwe => 'મારે આપવાના';

  @override
  String get debtOwedToMe => 'મારે લેવાના';

  @override
  String get debtSettled => 'ચૂકતે';

  @override
  String get debtEmpty => 'લોન, ક્રેડિટ કાર્ડ અને ઉધાર આપેલા કે લીધેલા પૈસા અહીં દેખાય છે.';

  @override
  String get debtFooter => 'અહીં નોંધાયેલા EMI અને કાર્ડ ચુકવણી ખર્ચ નહીં, દેવું ગણાય છે — જેથી તમારો મહિનાનો ખર્ચ સાચો રહે.';

  @override
  String debtPayTitle(String name) {
    return '$name ચૂકવવું છે?';
  }

  @override
  String debtPayBody(String amount) {
    return '$amount ની કાર્ડ ચુકવણી નોંધાશે. તે ખર્ચ નહીં, દેવું ગણાશે.';
  }

  @override
  String debtPayBodyFrom(String amount, String source) {
    return '$source માંથી $amount ની કાર્ડ ચુકવણી નોંધાશે. તે ખર્ચ નહીં, દેવું ગણાશે.';
  }

  @override
  String debtPayAmount(String amount) {
    return '$amount ચૂકવો';
  }

  @override
  String debtBillMerchant(String name) {
    return '$name બિલ';
  }

  @override
  String debtPaymentRecorded(String amount) {
    return '$amount ની કાર્ડ ચુકવણી નોંધાઈ';
  }

  @override
  String debtEmi(String amount) {
    return 'EMI $amount';
  }

  @override
  String debtDueOn(int day) {
    return '$day તારીખે ભરવાનું';
  }

  @override
  String debtLeftOf(String amount) {
    return '$amount માંથી બાકી';
  }

  @override
  String debtStatement(String amount) {
    return 'સ્ટેટમેન્ટ $amount';
  }

  @override
  String debtStatementDue(String amount, String date) {
    return 'સ્ટેટમેન્ટ $amount · ભરવાની તારીખ $date';
  }

  @override
  String get debtPaid => 'ચૂકવેલ';

  @override
  String debtUnpaid(String amount) {
    return 'બાકી $amount';
  }

  @override
  String debtEmisPaid(int paid, int total) {
    return '$total માંથી $paid EMI ભરાઈ';
  }

  @override
  String debtPaymentsRecorded(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ચુકવણી નોંધાઈ', one: '1 ચુકવણી નોંધાઈ');
    return '$_temp0';
  }

  @override
  String get debtReopen => 'ફરી ખોલો';

  @override
  String get debtSettle => 'ચૂકતે કરો';

  @override
  String get debtRemind => 'યાદ અપાવો';

  @override
  String get debtRecordPayment => 'ચુકવણી નોંધો';

  @override
  String get debtRecordRepayment => 'પરત ચુકવણી નોંધો';

  @override
  String debtPayNow(String amount) {
    return 'હમણાં ચૂકવો · $amount';
  }

  @override
  String get debtNeedNameAmount => 'નામ અને રકમ લખો';

  @override
  String get debtAddTitle => 'દેવું ઉમેરો';

  @override
  String get debtEditTitle => 'દેવું બદલો';

  @override
  String get debtKindLoan => 'લોન';

  @override
  String get debtKindCard => 'ક્રેડિટ કાર્ડ';

  @override
  String get debtKindPersonal => 'વ્યક્તિગત';

  @override
  String get debtFieldName => 'નામ, જેમ કે કાર લોન';

  @override
  String get debtFieldParty => 'આપનાર / વ્યક્તિ (વૈકલ્પિક)';

  @override
  String debtFieldPrincipal(String symbol) {
    return 'કુલ રકમ ($symbol)';
  }

  @override
  String get debtFieldRate => 'વ્યાજ દર % (વૈકલ્પિક)';

  @override
  String get debtFieldEmi => 'EMI / માસિક ચુકવણી (વૈકલ્પિક)';

  @override
  String get debtFieldEmis => 'EMI ની સંખ્યા (વૈકલ્પિક)';

  @override
  String get debtFieldDueDay => 'મહિનાની ભરવાની તારીખ (વૈકલ્પિક)';

  @override
  String debtFieldStatement(String symbol) {
    return 'છેલ્લા સ્ટેટમેન્ટની કુલ રકમ ($symbol, વૈકલ્પિક)';
  }

  @override
  String get debtStatementDueDate => 'સ્ટેટમેન્ટ ભરવાની તારીખ';

  @override
  String debtDueDate(String date) {
    return 'ભરવાની તારીખ $date';
  }

  @override
  String get debtSave => 'દેવું સેવ કરો';

  @override
  String get all => 'બધું';

  @override
  String get amount => 'રકમ';

  @override
  String get delete => 'કાઢી નાખો';

  @override
  String get type => 'પ્રકાર';

  @override
  String get min => 'ઓછામાં ઓછું';

  @override
  String get max => 'વધુમાં વધુ';

  @override
  String get searchScopeNotes => 'નોંધ';

  @override
  String get searchScopeMerchant => 'દુકાન';

  @override
  String get searchScopePlace => 'જગ્યા';

  @override
  String get sortNewest => 'નવા પહેલા';

  @override
  String get sortOldest => 'જૂના પહેલા';

  @override
  String get sortAmountDesc => 'રકમ: વધુથી ઓછી';

  @override
  String get sortAmountAsc => 'રકમ: ઓછીથી વધુ';

  @override
  String get transactionsTitle => 'વ્યવહારો';

  @override
  String get sort => 'ક્રમ';

  @override
  String get searchHintAll => 'દુકાન, નોંધ, #ટૅગ, રકમ શોધો…';

  @override
  String get searchHintNotes => 'નોંધ અને #ટૅગ શોધો';

  @override
  String get searchHintMerchant => 'દુકાનો શોધો';

  @override
  String searchHintAmount(String symbol) {
    return 'ચોક્કસ રકમ, જેમ કે 450 અથવા ${symbol}1,200';
  }

  @override
  String get searchHintPlace => 'જગ્યાઓ શોધો';

  @override
  String get clearSearch => 'શોધ સાફ કરો';

  @override
  String get filters => 'ફિલ્ટર';

  @override
  String get allCategories => 'બધી કેટેગરી';

  @override
  String get previousMonth => 'ગયો મહિનો';

  @override
  String get nextMonth => 'આવતો મહિનો';

  @override
  String get allTime => 'અત્યાર સુધી';

  @override
  String nTransactions(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n વ્યવહારો', one: '1 વ્યવહાર');
    return '$_temp0';
  }

  @override
  String moneyOut(String amount) {
    return 'બહાર $amount';
  }

  @override
  String moneyIn(String amount) {
    return 'અંદર $amount';
  }

  @override
  String noTxnMatch(String query) {
    return '\"$query\" સાથે મેળ ખાતો કોઈ વ્યવહાર નથી.';
  }

  @override
  String get noTxnInPeriod => 'આ સમયગાળામાં કોઈ વ્યવહાર નથી.';

  @override
  String get recentSearches => 'તાજેતરની શોધ';

  @override
  String get removeRecentSearch => 'તાજેતરની શોધમાંથી કાઢો';

  @override
  String get resetAll => 'બધું રીસેટ કરો';

  @override
  String get searchCategories => 'કેટેગરી શોધો';

  @override
  String amountIn(String symbol) {
    return 'રકમ ($symbol)';
  }

  @override
  String get paidVia => 'ચુકવણીની રીત';

  @override
  String get applyFilters => 'ફિલ્ટર લાગુ કરો';

  @override
  String get txnNeedAmount => 'શૂન્યથી વધુ રકમ લખો';

  @override
  String txnTemplateSaved(String name) {
    return '“$name” ટેમ્પ્લેટ તરીકે સેવ થયું';
  }

  @override
  String deleteNamed(String name) {
    return '“$name” કાઢી નાખવું છે?';
  }

  @override
  String get txnTemplateDeleteBody => 'ટેમ્પ્લેટ કાઢી નખાશે. તેમાંથી બનેલા વ્યવહારો રહેશે.';

  @override
  String get txnNeedDebt => 'આ ચુકવણી કયા દેવાની છે તે પસંદ કરો';

  @override
  String get txnEditTitle => 'વ્યવહાર બદલો';

  @override
  String get txnNewTitle => 'નવો વ્યવહાર';

  @override
  String get txnSaveTemplate => 'ટેમ્પ્લેટ તરીકે સેવ કરો';

  @override
  String get txnReceivedIn => 'શેમાં મળ્યા';

  @override
  String get txnPaidFrom => 'શેમાંથી ચૂકવ્યા';

  @override
  String get category => 'કેટેગરી';

  @override
  String txnCategoryHint(String name) {
    return 'ખાતરી નથી? ડિફૉલ્ટ રીતે તે “$name” માં જશે.';
  }

  @override
  String get txnHolding => 'હોલ્ડિંગ (વૈકલ્પિક)';

  @override
  String get txnNotLinked => 'જોડાયેલું નથી';

  @override
  String get txnDebt => 'દેવું';

  @override
  String get txnChooseDebt => 'દેવું પસંદ કરો';

  @override
  String txnDebtYouPay(String name) {
    return '$name · તમે આપશો';
  }

  @override
  String txnDebtYouReceive(String name) {
    return '$name · તમને મળશે';
  }

  @override
  String get details => 'વિગતો';

  @override
  String get date => 'તારીખ';

  @override
  String get time => 'સમય';

  @override
  String get txnMerchant => 'દુકાન / મેળવનાર';

  @override
  String get txnLocation => 'જગ્યા · વૈકલ્પિક';

  @override
  String get pickOnMap => 'નકશા પર પસંદ કરો';

  @override
  String get useCurrentLocation => 'હાલનું લોકેશન વાપરો';

  @override
  String get txnNote => 'શા માટે? નોંધ ઉમેરો (શોધી શકાય)';

  @override
  String get txnTags => 'ટૅગ, જેમ કે #કામ #ભાગ';

  @override
  String get receipt => 'રસીદ';

  @override
  String get receiptCamera => 'કૅમેરા';

  @override
  String get receiptGallery => 'ગૅલરી';

  @override
  String get receiptPdf => 'PDF';

  @override
  String get receiptPdfAttached => 'PDF રસીદ જોડી છે';

  @override
  String get receiptPhotoAttached => 'રસીદનો ફોટો જોડ્યો છે';

  @override
  String get receiptRemove => 'રસીદ કાઢો';

  @override
  String get txnRecurringNote => 'આ પુનરાવર્તિત શ્રેણીનો ભાગ છે. ફેરફાર ફક્ત આના પર લાગુ થશે; શ્રેણી સેટિંગ્સ › પુનરાવર્તિત માં સંભાળો.';

  @override
  String get repeat => 'પુનરાવર્તન';

  @override
  String get txnRepeat => 'આ વ્યવહાર ફરી કરો';

  @override
  String txnRepeatNext(String frequency, String date) {
    return '$frequency · આગલું $date';
  }

  @override
  String get txnRepeatHelp => 'સમયપત્રક મુજબ આપમેળે ઉમેરે છે';

  @override
  String get neverEnds => 'ક્યારેય પૂરું નહીં';

  @override
  String endsOn(String date) {
    return '$date એ પૂરું';
  }

  @override
  String get clearEndDate => 'પૂરું થવાની તારીખ સાફ કરો';

  @override
  String get saveChanges => 'ફેરફાર સેવ કરો';

  @override
  String get txnSave => 'વ્યવહાર સેવ કરો';

  @override
  String get quickAdd => 'ઝટપટ ઉમેરો';

  @override
  String get continue_ => 'આગળ વધો';

  @override
  String get done => 'થઈ ગયું';

  @override
  String get notNow => 'હમણાં નહીં';

  @override
  String get remove => 'કાઢો';

  @override
  String get typeSpend => 'ખર્ચ';

  @override
  String get typeInvest => 'રોકાણ';

  @override
  String get typeIncome => 'આવક';

  @override
  String get typeDebt => 'દેવું';

  @override
  String get investKindFd => 'ફિક્સ્ડ ડિપોઝિટ';

  @override
  String get investKindMf => 'મ્યુચ્યુઅલ ફંડ';

  @override
  String get investKindStock => 'શેર';

  @override
  String get investKindGold => 'સોનું';

  @override
  String get investKindRetirement => 'નિવૃત્તિ (PPF/EPF/NPS)';

  @override
  String get investKindOther => 'અન્ય';

  @override
  String get reminderTypeBudget => 'બજેટ અલર્ટ (80% અને 100%)';

  @override
  String get reminderTypeDues => 'EMI અને કાર્ડ ભરવાની તારીખો';

  @override
  String get reminderTypeSip => 'SIP રિમાઇન્ડર';

  @override
  String get reminderTypeMaturity => 'FD મેચ્યોરિટી';

  @override
  String get reminderTypeFollowUp => 'મારે લેવાના પૈસાનું ફૉલો-અપ';

  @override
  String get reminderEmiTomorrow => 'EMI કાલે ભરવાની';

  @override
  String get reminderCardTomorrow => 'કાર્ડ બિલ કાલે ભરવાનું';

  @override
  String get reminderEmiToday => 'EMI આજે ભરવાની';

  @override
  String get reminderCardToday => 'કાર્ડ બિલ આજે ભરવાનું';

  @override
  String get reminderSipToday => 'SIP આજે';

  @override
  String reminderSipBody(String title, String amount) {
    return '$title: આજે $amount નું રોકાણ કરો.';
  }

  @override
  String reminderFdMatures(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'FD $n દિવસમાં મેચ્યોર થશે', one: 'FD કાલે મેચ્યોર થશે', zero: 'FD આજે મેચ્યોર થશે');
    return '$_temp0';
  }

  @override
  String reminderFdBody(String title, String amount, String date) {
    return '$title ($amount રોકાણ) $date એ મેચ્યોર થશે.';
  }

  @override
  String reminderFollowUp(String name) {
    return '$name સાથે ફૉલો-અપ કરો';
  }

  @override
  String reminderFollowUpBody(String name, String amount) {
    return '$name પાસેથી હજી $amount લેવાના બાકી છે.';
  }

  @override
  String budgetAlertFull(String name) {
    return '$name બજેટ પૂરું વપરાઈ ગયું';
  }

  @override
  String budgetAlert80(String name) {
    return '$name બજેટનો 80% વપરાઈ ગયો';
  }

  @override
  String budgetAlertBody(String used, String limit, String left) {
    return '$limit માંથી $used ખર્ચ · $left';
  }

  @override
  String daysLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n દિવસ બાકી', one: '1 દિવસ બાકી');
    return '$_temp0';
  }

  @override
  String get reminderTestTitle => 'રિમાઇન્ડર ચાલુ છે';

  @override
  String get reminderTestBody => 'બજેટ, ભરવાની તારીખો, SIP અને મેચ્યોરિટીની જાણ અહીં થશે. કંઈ પણ તમારા ફોનમાંથી બહાર જતું નથી.';

  @override
  String get smsAddDetails => 'વિગતો ઉમેરો';

  @override
  String get smsIgnore => 'અવગણો';

  @override
  String get undo => 'પાછું લો';

  @override
  String smsAmountFrom(String amount, String name) {
    return '$name પાસેથી $amount';
  }

  @override
  String smsAmountAt(String amount, String name) {
    return '$name પર $amount';
  }

  @override
  String smsAmountInto(String amount, String name) {
    return '$name માં $amount';
  }

  @override
  String smsMoneyReceived(String what) {
    return 'પૈસા મળ્યા: $what';
  }

  @override
  String smsNewExpense(String what) {
    return 'નવો ખર્ચ: $what';
  }

  @override
  String smsAddTo(String where) {
    return '$where માં ઉમેરવું છે?';
  }

  @override
  String smsIncomeAdded(String what) {
    return 'આવક ઉમેરી: $what';
  }

  @override
  String smsExpenseAdded(String what) {
    return 'ખર્ચ ઉમેર્યો: $what';
  }

  @override
  String get reminderChannelHelp => 'બજેટ અલર્ટ, ભરવાની તારીખો, SIP અને મેચ્યોરિટી રિમાઇન્ડર';

  @override
  String get smsChannelHelp => 'SMS માંથી વાંચેલો બેંક કે UPI વ્યવહાર ઉમેરતા પહેલાં પૂછે છે';

  @override
  String get unlockPrompt => 'Expense Manager અનલૉક કરો';

  @override
  String get daily => 'દરરોજ';

  @override
  String get weekly => 'સાપ્તાહિક';

  @override
  String get monthly => 'માસિક';

  @override
  String get yearly => 'વાર્ષિક';

  @override
  String get backupNeedsPassword => 'આ બેકઅપ પાસવર્ડથી સુરક્ષિત છે';

  @override
  String get backupWrongPassword => 'ખોટો પાસવર્ડ';

  @override
  String get backupInvalid => 'આ Expense Manager નો બેકઅપ નથી';

  @override
  String get backupDamaged => 'બેકઅપ ફાઇલ ખરાબ છે';

  @override
  String get backupTooNew => 'આ બેકઅપ ઍપના નવા વર્ઝનથી બન્યો છે. પહેલાં ઍપ અપડેટ કરો.';

  @override
  String get backupNever => 'ક્યારેય બેકઅપ લીધો નથી';

  @override
  String backupLast(String date) {
    return 'છેલ્લો બેકઅપ $date';
  }

  @override
  String get importNeedColumns => 'તારીખની કૉલમ અને રકમ (અથવા ડેબિટ/ક્રેડિટ) ની કૉલમ જોઈએ';

  @override
  String importInvalidDate(String value) {
    return 'ખોટી તારીખ \"$value\"';
  }

  @override
  String get importInvalidAmount => 'ખોટી રકમ';

  @override
  String get investmentsTitle => 'રોકાણ';

  @override
  String get budgetsTitle => 'બજેટ';

  @override
  String get pdfLocked => 'આ PDF પાસવર્ડથી સુરક્ષિત છે. લૉક વગરની નકલ સેવ કરો (પ્રિન્ટ → PDF તરીકે સેવ) અને તે ઇમ્પોર્ટ કરો.';

  @override
  String pdfUnreadable(String cause) {
    return 'આ PDF વાંચી શકાયું નહીં ($cause)';
  }

  @override
  String get bankStatement => 'બેંક સ્ટેટમેન્ટ';

  @override
  String get emi => 'EMI';

  @override
  String get cardBill => 'કાર્ડ બિલ';

  @override
  String reminderDueTomorrowBody(String title, String what) {
    return '$title: $what કાલે ભરવાનું છે.';
  }

  @override
  String reminderDueTomorrowAmountBody(String title, String what, String amount) {
    return '$title: $amount નું $what કાલે ભરવાનું છે.';
  }

  @override
  String reminderDueTodayBody(String title, String what) {
    return '$title: $what આજે ભરવાનું છે.';
  }

  @override
  String reminderDueTodayAmountBody(String title, String what, String amount) {
    return '$title: $amount નું $what આજે ભરવાનું છે.';
  }

  @override
  String exportedOne(String what, String path) {
    return '$what ને $path માં એક્સપોર્ટ કર્યું';
  }

  @override
  String exportedMany(int n, String path) {
    return '$n ફાઇલો $path માં એક્સપોર્ટ કરી';
  }

  @override
  String get exportHelp => 'Excel અથવા Sheets માં ખૂલતી UTF-8 ફાઇલો. ઘણી ફાઇલો એક zip માં શેર થાય છે.';

  @override
  String exportZip(int n) {
    return '$n ફાઇલો એક્સપોર્ટ કરો (zip)';
  }

  @override
  String get export => 'એક્સપોર્ટ કરો';

  @override
  String get importPreview => 'ઇમ્પોર્ટ પ્રિવ્યૂ';

  @override
  String get importPdfEmpty => 'આ PDF માં કોઈ વ્યવહાર મળ્યો નહીં. નેટ બેંકિંગમાંથી CSV/Excel એક્સપોર્ટ અજમાવો.';

  @override
  String importFound(String bank, int n) {
    return '$bank · $n મળ્યા';
  }

  @override
  String get backupCreating => 'બેકઅપ બની રહ્યો છે…';

  @override
  String get backupEncrypting => 'બેકઅપ એન્ક્રિપ્ટ થઈ રહ્યો છે…';

  @override
  String backupSaved(String path) {
    return 'બેકઅપ $path માં સેવ થયો';
  }

  @override
  String get restoring => 'રીસ્ટોર થઈ રહ્યું છે…';

  @override
  String restoredN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n વ્યવહારો રીસ્ટોર થયા', one: '1 વ્યવહાર રીસ્ટોર થયો');
    return '$_temp0';
  }

  @override
  String addedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n વ્યવહારો ઉમેર્યા', one: '1 વ્યવહાર ઉમેર્યો');
    return '$_temp0';
  }

  @override
  String addedNSkipped(int n, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n વ્યવહારો ઉમેર્યા', one: '1 વ્યવહાર ઉમેર્યો');
    return '$_temp0 · $skipped પહેલેથી હાજર';
  }

  @override
  String get backupHelp => 'તમારા બધા ડેટા અને રસીદો સાથેની એક .ledger ફાઇલ. તેને Drive, Files અથવા કમ્પ્યુટર પર સેવ કરો.';

  @override
  String get backupProtect => 'પાસવર્ડથી સુરક્ષિત કરો';

  @override
  String get backupPasswordField => 'પાસવર્ડ (6+ અક્ષર)';

  @override
  String get confirmPassword => 'પાસવર્ડની પુષ્ટિ કરો';

  @override
  String get backupNoRecovery => 'ભૂલાયેલો પાસવર્ડ પાછો મેળવવાનો કોઈ રસ્તો નથી.';

  @override
  String get backUp => 'બેકઅપ લો';

  @override
  String get backupPassword => 'બેકઅપ પાસવર્ડ';

  @override
  String get password => 'પાસવર્ડ';

  @override
  String get unlock => 'અનલૉક કરો';

  @override
  String get restoreBackup => 'બેકઅપ રીસ્ટોર કરો';

  @override
  String backupMade(String date, String version) {
    return '$date એ બન્યો · ઍપ $version';
  }

  @override
  String get merge => 'જોડો';

  @override
  String get replace => 'બદલો';

  @override
  String get restoreMergeHelp => 'આ ફોનમાં જે નથી તે ઉમેરે છે. મળતી કેટેગરી, ચુકવણી રીતો અને ખાતાં ફરી વપરાય છે; જે વ્યવહારો પહેલેથી છે તે છોડી દેવાય છે.';

  @override
  String get restoreReplaceHelp => 'આ ફોનમાંનું બધું કાઢીને બેકઅપ વાપરે છે.';

  @override
  String get restoreConfirm => 'હું સમજું છું કે મારો હાલનો ડેટા ભૂંસાઈ જશે';

  @override
  String get backupReminder => 'બેકઅપ રિમાઇન્ડર';

  @override
  String get backupBannerNever => 'તમારો ડેટા ફક્ત આ ફોનમાં જ છે. બેકઅપ લો.';

  @override
  String backupBannerDue(String last) {
    return 'બેકઅપનો સમય · $last';
  }

  @override
  String get remindLater => 'પછી યાદ અપાવો';

  @override
  String importedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n વ્યવહારો ઇમ્પોર્ટ થયા', one: '1 વ્યવહાર ઇમ્પોર્ટ થયો');
    return '$_temp0';
  }

  @override
  String importLine(int n) {
    return 'લાઇન $n';
  }

  @override
  String get importDuplicate => 'ડુપ્લિકેટ';

  @override
  String importToDefault(String name) {
    return 'કેટેગરી → $name';
  }

  @override
  String importNewSub(String name) {
    return 'નવી પેટા-કેટેગરી: $name';
  }

  @override
  String importN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n વ્યવહારો ઇમ્પોર્ટ કરો', one: '1 વ્યવહાર ઇમ્પોર્ટ કરો');
    return '$_temp0';
  }

  @override
  String get finish => 'પૂરું કરો';

  @override
  String get skip => 'છોડો';

  @override
  String get onbWelcomeTitle => 'તમારા પૈસા, તમારા ફોનમાં';

  @override
  String get onbWelcomeBody => 'ખર્ચ, રોકાણ અને દેવું એક જ જગ્યાએ ટ્રૅક કરો. તમારો ડેટા આ ફોનમાં જ રહે છે. કોઈ અકાઉન્ટ નથી, કોઈ સર્વર નથી, કોઈ ટ્રૅકિંગ નથી.';

  @override
  String get onbGetStarted => 'શરૂ કરો';

  @override
  String get onbPointLocal => 'ફક્ત આ ડિવાઇસમાં સેવ';

  @override
  String get onbPointOffline => 'સંપૂર્ણ ઑફલાઇન ચાલે છે';

  @override
  String get onbPointExport => 'ગમે ત્યારે CSV કે PDF માં એક્સપોર્ટ';

  @override
  String get onbNameTitle => 'અમે તમને શું કહીએ?';

  @override
  String get onbNameBody => 'ફક્ત હોમ સ્ક્રીન પરના અભિવાદન માટે. વૈકલ્પિક.';

  @override
  String get onbCurrencyTitle => 'તમારું ચલણ પસંદ કરો';

  @override
  String get onbCurrencyBody => 'રકમ આ ચલણમાં દેખાશે. તમે પછી સેટિંગ્સમાં બદલી શકો છો.';

  @override
  String onbCurrencySample(String currency, String amount) {
    return '$currency · જેમ કે $amount';
  }

  @override
  String get onbSourceTitle => 'તમે શેમાંથી ચૂકવો છો?';

  @override
  String onbSourceBody(String name) {
    return 'તમારું મુખ્ય ખાતું ઉમેરો. તે નવા વ્યવહારોની ડિફૉલ્ટ ચુકવણી રીત બનશે. ખાલી રાખો તો $name થી શરૂઆત થશે.';
  }

  @override
  String get sourceKindCash => 'રોકડ';

  @override
  String get sourceNameField => 'નામ, જેમ કે HDFC બચત ખાતું';

  @override
  String get optional => 'વૈકલ્પિક';

  @override
  String get onbLocationTitle => 'જગ્યા આપમેળે નોંધવી છે?';

  @override
  String get onbLocationBody => 'લોકેશન ચાલુ હોય તો નવા વ્યવહારમાં તમે જ્યાં છો તે જગ્યા જોડાય છે. તે ફક્ત આ ફોનમાં તમારી એન્ટ્રી સાથે સેવ થાય છે. તમે જગ્યા જાતે પણ લખી શકો છો.';

  @override
  String get onbLocationContinue => 'લોકેશન વગર આગળ વધો';

  @override
  String get onbLocationAllow => 'લોકેશનની મંજૂરી આપો';

  @override
  String get onbLocationDenied => 'મંજૂરી મળી નહીં. તમે પછી સેટિંગ્સમાં ચાલુ કરી શકો છો.';

  @override
  String get onbSmsTitle => 'બેંક SMS પરથી ખર્ચ ઉમેરવા છે?';

  @override
  String get onbSmsBodyShortcuts =>
      'Shortcuts ઑટોમેશન દરેક બેંક, કાર્ડ કે UPI SMS અમને આપી શકે છે; અમે તેને આ ફોનમાં વાંચીએ છીએ અને નોટિફિકેશનમાંથી એક ટૅપમાં પૂછીએ છીએ કે ઉમેરવું કે નહીં. સેટઅપની રીત સેટિંગ્સ › SMS પરથી ખર્ચ માં છે.';

  @override
  String get onbSmsBody =>
      'બેંક, કાર્ડ કે UPI SMS આવે ત્યારે અમે તેને આ ફોનમાં વાંચીએ છીએ અને નોટિફિકેશનમાંથી એક ટૅપમાં પૂછીએ છીએ કે ઉમેરવું કે નહીં. OTP અને ઑફર છોડી દેવાય છે, અને કંઈ અપલોડ થતું નથી.';

  @override
  String get onbSmsContinue => 'SMS વગર આગળ વધો';

  @override
  String get turnOn => 'ચાલુ કરો';

  @override
  String get onbSmsAllow => 'SMS ની મંજૂરી આપો';

  @override
  String get onbSmsDenied => 'SMS ની મંજૂરી મળી નહીં. તમે પછી સેટિંગ્સ › SMS પરથી ખર્ચ માં ચાલુ કરી શકો છો.';

  @override
  String get onbLockTitle => 'ઍપ લૉક કરવી છે?';

  @override
  String get onbLockBody => 'ઍપ ખૂલે ત્યારે PIN (અથવા ફિંગરપ્રિન્ટ / ચહેરો) માગો, અને ઍપ સ્વિચરમાં રકમ છુપાવો. તમે ગમે ત્યારે સેટિંગ્સમાં બદલી શકો છો.';

  @override
  String get onbLockAction => 'PIN સેટ કરો';

  @override
  String get onbRemindersTitle => 'રિમાઇન્ડર જોઈએ છે?';

  @override
  String get onbRemindersBody =>
      'બજેટ 80% કે 100% પહોંચે ત્યારે, EMI કે કાર્ડ બિલ ભરવાના આગલા દિવસે, SIP ની તારીખે અને FD મેચ્યોર થાય તે પહેલાં જાણ. આ ફોનમાં જ નક્કી થાય છે; ક્યાંય કંઈ મોકલાતું નથી.';

  @override
  String get onbRemindersContinue => 'રિમાઇન્ડર વગર આગળ વધો';

  @override
  String get onbRemindersAllow => 'રિમાઇન્ડર ચાલુ કરો';

  @override
  String get onbRemindersDenied => 'નોટિફિકેશન બ્લૉક છે. તમે પછી સેટિંગ્સ › રિમાઇન્ડર અને અલર્ટ માં ચાલુ કરી શકો છો.';

  @override
  String get currencyInr => 'ભારતીય રૂપિયો';

  @override
  String get currencyUsd => 'અમેરિકન ડૉલર';

  @override
  String get currencyEur => 'યુરો';

  @override
  String get currencyGbp => 'બ્રિટિશ પાઉન્ડ';

  @override
  String get currencyAed => 'UAE દિરહામ';

  @override
  String get currencySgd => 'સિંગાપોર ડૉલર';

  @override
  String get currencyAud => 'ઑસ્ટ્રેલિયન ડૉલર';

  @override
  String get currencyCad => 'કેનેડિયન ડૉલર';

  @override
  String get goodMorning => 'સુપ્રભાત';

  @override
  String get goodAfternoon => 'નમસ્કાર';

  @override
  String get goodEvening => 'શુભ સાંજ';

  @override
  String get welcome => 'સ્વાગત છે';

  @override
  String get reminders => 'રિમાઇન્ડર';

  @override
  String homeSmsReview(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'SMS ના $n વ્યવહારો તપાસવાના છે', one: 'SMS નો 1 વ્યવહાર તપાસવાનો છે');
    return '$_temp0';
  }

  @override
  String get homeOutThisMonth => 'આ મહિને બહાર ગયેલા પૈસા';

  @override
  String homeOutIn(String month) {
    return '$month માં બહાર ગયેલા પૈસા';
  }

  @override
  String get invested => 'રોકાણ કર્યું';

  @override
  String homeInvestedThisMonth(String amount) {
    return 'આ મહિને +$amount';
  }

  @override
  String homeInvestedIn(String amount, String month) {
    return '$month માં +$amount';
  }

  @override
  String homeMonthlyEmi(String amount) {
    return '$amount/મહિને EMI';
  }

  @override
  String get comingUp => 'આવનારું';

  @override
  String get seeAll => 'બધું જુઓ';

  @override
  String get whereItWent => 'પૈસા ક્યાં ગયા';

  @override
  String get homeNoSpendYet => 'આ મહિને હજી કોઈ ખર્ચ નથી.';

  @override
  String homeNoSpendIn(String period) {
    return '$period માં કોઈ ખર્ચ નથી.';
  }

  @override
  String get recent => 'તાજેતરના';

  @override
  String get viewAll => 'બધું જુઓ';

  @override
  String get homeNoTxns => 'હજી કોઈ વ્યવહાર નથી';

  @override
  String get homeNoTxnsHelp => 'તમારો પહેલો ખર્ચ, રોકાણ કે આવક ઉમેરવા + દબાવો.';

  @override
  String homeNothingIn(String period) {
    return '$period માં કંઈ નથી';
  }

  @override
  String get homeNothingInHelp => 'તે મહિને કોઈ વ્યવહાર નોંધાયો નથી.';

  @override
  String homeOfIncome(String amount) {
    return '$amount આવકમાંથી';
  }

  @override
  String get spent => 'ખર્ચ';

  @override
  String get left => 'બાકી';

  @override
  String get catKindInvestment => 'રોકાણ';

  @override
  String catMove(String name) {
    return '$name ખસેડો';
  }

  @override
  String get catTopLevel => 'સૌથી ઉપર';

  @override
  String catUnder(String name) {
    return '$name ની નીચે';
  }

  @override
  String get catMoveOnlyLeaf => 'ફક્ત પેટા-કેટેગરી વગરની કેટેગરી જ બીજીની નીચે ખસેડી શકાય';

  @override
  String get catDefaultHelp => 'ડિફૉલ્ટ — કંઈ પસંદ ન હોય ત્યારે વપરાય છે';

  @override
  String get catAddSub => 'પેટા-કેટેગરી ઉમેરો';

  @override
  String get catMoveMenu => 'ખસેડો…';

  @override
  String get catMoveUnderMenu => 'નીચે ખસેડો…';

  @override
  String catArchive(String name) {
    return '$name આર્કાઇવ કરો';
  }

  @override
  String catArchived(String name) {
    return '$name આર્કાઇવ થઈ';
  }

  @override
  String get catAdd => 'કેટેગરી ઉમેરો';

  @override
  String get catSpendHelp => 'ગયેલા પૈસા — ખાવાનું, ભાડું, બિલ. પેટા-કેટેગરી ઉમેરવા ⋮ દબાવો.';

  @override
  String get catInvestHelp => 'બહાર ગયેલા પૈસા જે તમારી સંપત્તિ વધારે છે.';

  @override
  String get catIncomeHelp => 'આવતા પૈસા.';

  @override
  String catArchivedCount(int n) {
    return 'આર્કાઇવ ($n)';
  }

  @override
  String get catArchivedHelp => 'ઇતિહાસ માટે રાખેલી; નવા વ્યવહારમાં દેખાતી નથી';

  @override
  String catKindUnder(String kind, String parent) {
    return '$kind · $parent ની નીચે';
  }

  @override
  String get restore => 'રીસ્ટોર કરો';

  @override
  String catRestored(String name) {
    return '$name રીસ્ટોર થઈ';
  }

  @override
  String get catNew => 'નવી કેટેગરી';

  @override
  String catNewSub(String name) {
    return '$name માં નવી પેટા-કેટેગરી';
  }

  @override
  String get immediately => 'તરત';

  @override
  String seconds(int n) {
    return '$n સેકન્ડ';
  }

  @override
  String minutes(int n) {
    return '$n મિનિટ';
  }

  @override
  String get pinChoose => 'PIN પસંદ કરો';

  @override
  String get pinConfirm => 'તમારો PIN ફરી નાખો';

  @override
  String get pinDigits => '4–6 અંક નાખો';

  @override
  String get pinAgain => 'એ જ PIN ફરી નાખો';

  @override
  String pinCooldown(int n) {
    return 'ઘણા પ્રયાસો થયા. $n સેકન્ડ પછી ફરી પ્રયાસ કરો';
  }

  @override
  String get pinWrong => 'ખોટો PIN';

  @override
  String get pinCurrent => 'તમારો હાલનો PIN નાખો';

  @override
  String get lockOn => 'ઍપ લૉક ચાલુ છે';

  @override
  String get pinChanged => 'PIN બદલાયો';

  @override
  String get encryptTitle => 'ડેટાબેઝ એન્ક્રિપ્ટ કરવો છે?';

  @override
  String get encryptBody =>
      'તમારો ડેટા આ ફોનના સુરક્ષિત સ્ટોરેજમાં રાખેલી કીથી એન્ક્રિપ્ટ થશે. જો તે કી ખોવાઈ જાય (જેમ કે ઍપ ડેટા સાફ થાય), તો ડેટા પાછો મેળવી શકાશે નહીં — પહેલાં બેકઅપ એક્સપોર્ટ કરો.';

  @override
  String get encrypt => 'એન્ક્રિપ્ટ કરો';

  @override
  String get dbEncrypted => 'ડેટાબેઝ એન્ક્રિપ્ટ થયો';

  @override
  String get dbDecrypted => 'ડેટાબેઝ ડિક્રિપ્ટ થયો';

  @override
  String get appLock => 'ઍપ લૉક';

  @override
  String get lockWithPin => 'PIN થી લૉક કરો';

  @override
  String get lockWithPinHelp => 'ઍપ ખૂલે ત્યારે પૂછાય છે';

  @override
  String get changePin => 'PIN બદલો';

  @override
  String get unlockBiometric => 'ફિંગરપ્રિન્ટ / ચહેરાથી અનલૉક કરો';

  @override
  String get notAvailableDevice => 'આ ડિવાઇસ પર ઉપલબ્ધ નથી';

  @override
  String get lockAgainAfter => 'ઍપ છોડ્યા પછી ફરી લૉક';

  @override
  String get hideSwitcher => 'ઍપ સ્વિચરમાં છુપાવો';

  @override
  String get hideSwitcherHelp => 'તાજેતરની ઍપ્સનો પ્રિવ્યૂ ઝાંખો કરે છે અને સ્ક્રીનશૉટ અટકાવે છે';

  @override
  String get encryption => 'એન્ક્રિપ્શન';

  @override
  String get encryptDb => 'ડેટાબેઝ એન્ક્રિપ્ટ કરો';

  @override
  String get encryptKeyStored => 'કી ફોનના સુરક્ષિત સ્ટોરેજમાં છે';

  @override
  String get encryptUnavailable => 'આ ડેટાબેઝ માટે ઉપલબ્ધ નથી';

  @override
  String get budgetNew => 'નવું બજેટ';

  @override
  String budgetTabWeekly(String span) {
    return 'સાપ્તાહિક · $span';
  }

  @override
  String get budgetTabMonthly => 'માસિક · 1 તારીખથી મહિનાના અંત સુધી';

  @override
  String budgetOverBanner(String name, String amount) {
    return '$name $amount થી વધી ગયું';
  }

  @override
  String get budgetNoneWeekly => 'કોઈ સાપ્તાહિક બજેટ નથી';

  @override
  String get budgetNoneMonthly => 'કોઈ માસિક બજેટ નથી';

  @override
  String get budgetEmptyHelp => 'કોઈપણ કેટેગરીની મર્યાદા નક્કી કરો અને દરેક સમયગાળામાં ટ્રૅક કરો.';

  @override
  String get budgetCreate => 'બજેટ બનાવો';

  @override
  String get budgetGoalReached => 'લક્ષ્ય પૂરું';

  @override
  String budgetToGoal(String amount) {
    return 'લક્ષ્ય સુધી $amount બાકી';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount વધુ';
  }

  @override
  String budgetLeft(String amount, String perDay, String days) {
    return '$amount બાકી · $perDay/દિવસ · $days';
  }

  @override
  String get budgetAllInvestments => 'બધાં રોકાણ';

  @override
  String get budgetAllSpending => 'બધો ખર્ચ';

  @override
  String nCategories(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n કેટેગરી', one: '1 કેટેગરી');
    return '$_temp0';
  }

  @override
  String ofAmount(String amount) {
    return '$amount માંથી';
  }

  @override
  String get budgetNeedNameLimit => 'નામ અને મર્યાદા લખો';

  @override
  String get budgetEdit => 'બજેટ બદલો';

  @override
  String get budgetDelete => 'બજેટ કાઢી નાખો';

  @override
  String get budgetNameField => 'નામ, જેમ કે ખાવાનું';

  @override
  String budgetLimitField(String symbol) {
    return 'મર્યાદા ($symbol)';
  }

  @override
  String budgetSuggestion(String amount) {
    return 'છેલ્લા 3 મહિનામાં તમારી સરેરાશ $amount/મહિનો રહી · વાપરવા ટૅપ કરો';
  }

  @override
  String get budgetRepeats => 'દર વખતે પુનરાવર્તન';

  @override
  String budgetWeek(String span) {
    return 'અઠવાડિયું ($span)';
  }

  @override
  String get budgetMonth => 'મહિનો (1 તારીખ → અંત)';

  @override
  String get budgetGoal => 'રોકાણનું લક્ષ્ય';

  @override
  String get budgetGoalHelp => 'ખર્ચની મર્યાદાને બદલે રોકાણની રકમનું લક્ષ્ય ટ્રૅક કરો';

  @override
  String get budgetCounts => 'આ રોકાણ ગણાશે';

  @override
  String get budgetAppliesTo => 'શેના પર લાગુ (ખાલી = બધો ખર્ચ)';

  @override
  String get budgetRollover => 'વધેલી રકમ આગળ લઈ જાઓ';

  @override
  String get budgetAlert80Switch => '80% પર અલર્ટ';

  @override
  String get budgetAlertOver => 'મર્યાદા વટાવે ત્યારે અલર્ટ';

  @override
  String get budgetSave => 'બજેટ સેવ કરો';

  @override
  String get totalInvested => 'કુલ રોકાણ';

  @override
  String investThisMonth(String amount, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n હોલ્ડિંગ', one: '1 હોલ્ડિંગ');
    return 'આ મહિને +$amount · $_temp0';
  }

  @override
  String get investNoPrices => 'તમે મૂકેલી રકમ · લાઇવ ભાવ કે વળતર નહીં';

  @override
  String investMaturesOn(String name, String date) {
    return '$name $date એ મેચ્યોર થશે';
  }

  @override
  String get investNone => 'હજી કોઈ રોકાણ નથી';

  @override
  String get investNoneHelp => 'તમે શું રોકાણ કરો છો તે ટ્રૅક કરવા FD, SIP, શેર કે સોનું ઉમેરો.';

  @override
  String get investAdd => 'રોકાણ ઉમેરો';

  @override
  String investMatures(String date) {
    return '$date એ મેચ્યોર';
  }

  @override
  String nEntries(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n એન્ટ્રી', one: '1 એન્ટ્રી');
    return '$_temp0';
  }

  @override
  String get interestRate => 'વ્યાજ દર';

  @override
  String investStarted(String date) {
    return '$date એ શરૂ';
  }

  @override
  String investMaturesCap(String date) {
    return '$date એ મેચ્યોર';
  }

  @override
  String get institution => 'સંસ્થા';

  @override
  String get note => 'નોંધ';

  @override
  String contributions(int n) {
    return 'યોગદાન ($n)';
  }

  @override
  String get investNoMoney => 'હજી કોઈ પૈસા ઉમેર્યા નથી.';

  @override
  String get investAddMoney => 'પૈસા ઉમેરો';

  @override
  String get investMarkMatured => 'મેચ્યોર તરીકે માર્ક કરો';

  @override
  String get investCloseSold => 'બંધ / વેચ્યું';

  @override
  String get investReactivate => 'ફરી સક્રિય કરો';

  @override
  String get investNeedName => 'રોકાણને નામ આપો';

  @override
  String get investNameField => 'નામ, જેમ કે HDFC બેંક FD';

  @override
  String get investInstitutionField => 'બેંક / પ્લેટફૉર્મ (વૈકલ્પિક)';

  @override
  String get investAmountField => 'હમણાં રોકેલી રકમ (વૈકલ્પિક)';

  @override
  String get startDate => 'શરૂઆતની તારીખ';

  @override
  String get maturityDate => 'મેચ્યોરિટીની તારીખ (વૈકલ્પિક)';

  @override
  String get investSave => 'રોકાણ સેવ કરો';

  @override
  String get sourceKindBank => 'બેંક ખાતું';

  @override
  String get sourceKindWallet => 'UPI / વૉલેટ';

  @override
  String get sourceAdd => 'ચુકવણી રીત ઉમેરો';

  @override
  String get sourceDefaultHelp => 'દરેક નવા વ્યવહારમાં પહેલેથી પસંદ રહે છે';

  @override
  String sourceOutIn(String kind, String amount, String month) {
    return '$kind · $month માં $amount બહાર';
  }

  @override
  String sourceLimit(String amount) {
    return 'મર્યાદા $amount';
  }

  @override
  String sourceBalance(String amount) {
    return 'બેલેન્સ $amount';
  }

  @override
  String sourceOutstanding(String amount) {
    return '$amount બાકી';
  }

  @override
  String sourceCredit(String amount) {
    return '$amount ક્રેડિટ';
  }

  @override
  String get sourceNew => 'નવી ચુકવણી રીત';

  @override
  String get sourceLast4 => 'છેલ્લા 4 અંક (વૈકલ્પિક)';

  @override
  String sourceCreditLimit(String symbol) {
    return 'ક્રેડિટ મર્યાદા ($symbol)';
  }

  @override
  String sourceBalanceHelp(String amount) {
    return 'વૈકલ્પિક · ડિફૉલ્ટ $amount';
  }

  @override
  String get makeDefault => 'ડિફૉલ્ટ બનાવો';

  @override
  String sourceOutstandingField(String symbol) {
    return 'હાલનું બાકી ($symbol)';
  }

  @override
  String sourceBalanceField(String symbol) {
    return 'હાલનું બેલેન્સ ($symbol)';
  }

  @override
  String get sourceAdjustHelp => 'અહીંથી આગળ તમે ઉમેરેલા વ્યવહારો તેને બદલશે';

  @override
  String get pdfReport => 'PDF રિપોર્ટ';

  @override
  String get week => 'અઠવાડિયું';

  @override
  String get month => 'મહિનો';

  @override
  String get year => 'વર્ષ';

  @override
  String get previousPeriod => 'ગયો સમયગાળો';

  @override
  String get nextPeriod => 'આવતો સમયગાળો';

  @override
  String insightsDonutLabel(String spent, String invested) {
    return 'ખર્ચ $spent, રોકાણ $invested';
  }

  @override
  String get moneyOutLabel => 'બહાર ગયેલા પૈસા';

  @override
  String insightsSaved(int n) {
    return 'આવકનો $n% બચાવ્યો';
  }

  @override
  String get insightsNoEarlier => 'પહેલાનો ડેટા નથી';

  @override
  String insightsLessSpent(int n) {
    return '$n% ઓછો ખર્ચ';
  }

  @override
  String insightsMoreSpent(int n) {
    return '$n% વધુ ખર્ચ';
  }

  @override
  String get insightsThanPrevious => 'ગયા સમયગાળા કરતાં';

  @override
  String perDay(String amount) {
    return '$amount / દિવસ';
  }

  @override
  String get averageSpend => 'સરેરાશ ખર્ચ';

  @override
  String get monthByMonth => 'મહિને મહિને';

  @override
  String get weekByWeek => 'અઠવાડિયે અઠવાડિયે';

  @override
  String get dayByDay => 'દિવસે દિવસે';

  @override
  String get byCategory => 'કેટેગરી મુજબ';

  @override
  String get insightsNothing => 'આ સમયગાળામાં કંઈ નોંધાયું નથી.';

  @override
  String insightsDirect(String name) {
    return '$name (સીધું)';
  }

  @override
  String insightsCatRow(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n વ્યવહારો', one: '1 વ્યવહાર');
    return '$name  ·  $_temp0';
  }

  @override
  String get hideSubs => 'પેટા-કેટેગરી છુપાવો';

  @override
  String get showSubs => 'પેટા-કેટેગરી બતાવો';

  @override
  String get smsReadTitle => 'બેંક SMS વાંચવા છે?';

  @override
  String get smsReadBodyShortcuts =>
      'iPhone ઍપ SMS વાંચી શકતી નથી, તેથી Shortcuts ઑટોમેશન દરેક બેંક મેસેજ Expense Manager ને આપે છે. તે આ ફોનમાં વંચાય છે અને તમને પૂછવામાં આવે છે કે વ્યવહાર ઉમેરવો કે નહીં.\n\nક્યાંય કંઈ મોકલાતું નથી. OTP, ઑફર અને રિમાઇન્ડર છોડી દેવાય છે. હવે આ સ્ક્રીનનાં પગલાંથી ઑટોમેશન સેટ કરો.';

  @override
  String get smsReadBody =>
      'બેંક, કાર્ડ કે UPI SMS આવે ત્યારે Expense Manager તેને આ ફોનમાં વાંચે છે અને પૂછે છે કે વ્યવહાર ઉમેરવો કે નહીં.\n\nફક્ત ડેબિટ કે ક્રેડિટ થયેલી રકમવાળા મેસેજ જ રખાય છે, અને ક્યાંય કંઈ મોકલાતું નથી. OTP, ઑફર અને રિમાઇન્ડર છોડી દેવાય છે.';

  @override
  String get smsDenied => 'SMS ની મંજૂરી નકારાઈ. સિસ્ટમ સેટિંગ્સમાં Expense Manager ને મંજૂરી આપો.';

  @override
  String get smsNoNotifications => 'નોટિફિકેશન બ્લૉક છે, તેથી નવા ખર્ચ ફક્ત અહીં જ દેખાશે.';

  @override
  String addedThing(String what) {
    return '$what ઉમેર્યું';
  }

  @override
  String get smsAskToAdd => 'બેંક SMS ઉમેરવા માટે પૂછો';

  @override
  String get smsAskToAddHelp => 'આ ફોનમાં વંચાય છે · કંઈ અપલોડ થતું નથી';

  @override
  String get smsPermissionOff => 'SMS ની મંજૂરી બંધ છે, તેથી નવા મેસેજ વંચાતા નથી.';

  @override
  String get allow => 'મંજૂરી આપો';

  @override
  String get smsNothingToReview => 'તપાસવા માટે કંઈ નથી';

  @override
  String smsToReview(int n) {
    return 'તપાસવાના ($n)';
  }

  @override
  String get smsOnHelp => 'નવા બેંક અને UPI વ્યવહારો અહીં અને નોટિફિકેશનમાં દેખાય છે.';

  @override
  String get smsOffHelp => 'દરેક બેંક કે UPI વ્યવહારનો SMS આવે ત્યારે પૂછવામાં આવે તે માટે આ ચાલુ કરો.';

  @override
  String get smsStep1 => 'Shortcuts ખોલો → Automation → + (New Automation) → Message.';

  @override
  String smsStep2(String keyword) {
    return 'Message Contains: $keyword. Run Immediately પસંદ કરો, પછી Next.';
  }

  @override
  String smsStep3(String action) {
    return 'New Blank Automation → Add Action → \"$action\" (Expense Manager) શોધો.';
  }

  @override
  String get smsStep4 => 'ઍક્શનમાં Message ટૅપ કરો અને Shortcut Input પસંદ કરો. Done.';

  @override
  String smsStep5(String first, String second) {
    return 'વધુ બેંકો માટે \"$first\" અને \"$second\" સાથે આ જ ફરી કરો.';
  }

  @override
  String couldNotOpen(String url) {
    return '$url ખૂલી શક્યું નહીં';
  }

  @override
  String get smsSetupIphone => 'iPhone પર સેટઅપ';

  @override
  String get smsSetupIphoneHelp => 'iOS ઍપને SMS વાંચવા દેતું નથી. તેના બદલે Shortcuts ઑટોમેશન દરેક બેંક મેસેજ Expense Manager ને આપે છે (iOS 17 કે પછીનું પૂછ્યા વગર ચલાવે છે).';

  @override
  String get smsOpenShortcuts => 'Shortcuts ખોલો';

  @override
  String get smsGuide => 'ચિત્રો સાથેની ગાઇડ';

  @override
  String get sipStopTitle => 'આ SIP બંધ કરવી છે?';

  @override
  String get sipStopBody => 'પહેલેથી નોંધાયેલું યોગદાન આ રોકાણમાં રહેશે.';

  @override
  String get sipStop => 'SIP બંધ કરો';

  @override
  String get sipSetup => 'માસિક SIP સેટ કરો';

  @override
  String sipSummary(String amount, int day) {
    return 'SIP · દર મહિને $day તારીખે $amount';
  }

  @override
  String get paused => 'અટકાવેલું';

  @override
  String nextOn(String date) {
    return 'આગલું $date';
  }

  @override
  String nextOnFrom(String date, String source) {
    return 'આગલું $date · $source';
  }

  @override
  String get sipAuto => 'આપમેળે ઉમેરાય છે';

  @override
  String get sipReminderOnly => 'ફક્ત રિમાઇન્ડર · ચૂકવો ત્યારે નોંધો';

  @override
  String get stop => 'બંધ કરો';

  @override
  String get sipMonthly => 'માસિક SIP';

  @override
  String get sipEdit => 'SIP બદલો';

  @override
  String sipAmountField(String symbol) {
    return 'દર મહિનાની રકમ ($symbol)';
  }

  @override
  String get dayOfMonth => 'મહિનાની તારીખ';

  @override
  String get sipAutoOption => 'આપમેળે ઉમેરો';

  @override
  String get sipAutoOptionHelp => 'દર મહિને રોકાણનો વ્યવહાર નોંધે છે';

  @override
  String get sipRemindOption => 'ફક્ત યાદ અપાવો';

  @override
  String get sipRemindOptionHelp => 'આવનારામાં દેખાય છે; નોંધ તમે કરો છો';

  @override
  String get shareLog => 'લૉગ શેર કરો';

  @override
  String get clearLog => 'લૉગ સાફ કરો';

  @override
  String get logCleared => 'એરર લૉગ સાફ કર્યો';

  @override
  String get noErrors => 'કોઈ એરર નોંધાઈ નથી';

  @override
  String get noErrorsHelp => 'ક્રૅશ અને એરર ફક્ત આ ફોનમાં નોંધાય છે. બગ જણાવો ત્યારે લૉગ શેર કરો.';

  @override
  String reminderOn(String date) {
    return '$date એ રિમાઇન્ડર';
  }

  @override
  String get changeDate => 'તારીખ બદલો';

  @override
  String get remindMeOn => 'આ દિવસે યાદ અપાવો';

  @override
  String willRemind(String date) {
    return 'અમે તમને $date એ યાદ અપાવીશું';
  }

  @override
  String get savedTurnOnReminders => 'સેવ થયું. નોટિફિકેશન મેળવવા સેટિંગ્સ › રિમાઇન્ડર અને અલર્ટ ચાલુ કરો.';

  @override
  String get remindMe => 'યાદ અપાવો';

  @override
  String get locationUnavailable => 'હાલનું લોકેશન મળતું નથી. લોકેશનની મંજૂરી આપો અથવા શોધો.';

  @override
  String get pickLocation => 'જગ્યા પસંદ કરો';

  @override
  String get searchPlace => 'જગ્યા કે સરનામું શોધો';

  @override
  String get noPlaceMatches => 'કંઈ મળ્યું નહીં. બીજું નામ અજમાવો અથવા નકશા પર ટૅપ કરો.';

  @override
  String get placeName => 'જગ્યાનું નામ';

  @override
  String get tapMapForPin => 'પિન મૂકવા નકશા પર ટૅપ કરો';

  @override
  String pinWrongLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n પ્રયાસ બાકી', one: '1 પ્રયાસ બાકી');
    return 'ખોટો PIN · $_temp0';
  }

  @override
  String get appLocked => 'Expense Manager લૉક છે';

  @override
  String get ended => 'પૂરું';

  @override
  String get reminderOnly => 'ફક્ત રિમાઇન્ડર';

  @override
  String get deleteSchedule => 'આ શેડ્યૂલ કાઢી નાખવું છે?';

  @override
  String get deleteScheduleBody => 'હવે પછી કોઈ વ્યવહાર ઉમેરાશે નહીં. જે ઉમેરાઈ ગયા છે તે રહેશે.';

  @override
  String get recurring => 'પુનરાવર્તિત';

  @override
  String get nothingRecurring => 'હજી કંઈ પુનરાવર્તિત નથી';

  @override
  String get nothingRecurringHelp => 'વ્યવહાર ઉમેરતી વખતે “પુનરાવર્તન” ચાલુ કરો, અથવા કોઈ રોકાણ પર SIP સેટ કરો.';

  @override
  String get deleteRule => 'નિયમ કાઢી નાખો';

  @override
  String get editSchedule => 'શેડ્યૂલ બદલો';

  @override
  String get onTheDay => 'તે જ દિવસે';

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n દિવસ પહેલાં', one: '1 દિવસ પહેલાં');
    return '$_temp0';
  }

  @override
  String get notificationsBlocked => 'નોટિફિકેશન બ્લૉક છે. સિસ્ટમ સેટિંગ્સમાં Expense Manager ને મંજૂરી આપો.';

  @override
  String get testSent => 'ટેસ્ટ નોટિફિકેશન મોકલ્યું';

  @override
  String get notifications => 'નોટિફિકેશન';

  @override
  String get notificationsHelp => 'આ ફોનમાં નક્કી થાય છે · કોઈ સર્વર પર કંઈ મોકલાતું નથી';

  @override
  String get fdLeadTitle => 'FD મેચ્યોર થાય તે પહેલાં યાદ અપાવો';

  @override
  String remindersInfo(String time) {
    return 'રિમાઇન્ડર લગભગ $time એ આવે છે: ભરવાની તારીખો આગલા દિવસે અને તે જ દિવસે, SIP તેની તારીખે, અને બજેટ અલર્ટ દરેક બજેટ માટે એક વાર જ્યારે તે 80% અને 100% પહોંચે.';
  }

  @override
  String get sendTest => 'ટેસ્ટ નોટિફિકેશન મોકલો';

  @override
  String get tomorrow => 'કાલે';

  @override
  String inDays(int n) {
    return '$n દિવસમાં';
  }

  @override
  String get upcomingEmi => 'EMI ભરવાની';

  @override
  String get upcomingCard => 'કાર્ડ બિલ ભરવાનું';

  @override
  String get upcomingMaturity => 'મેચ્યોરિટી';

  @override
  String get upcomingSip => 'SIP ભરવાની';

  @override
  String get upcomingFollowUp => 'ફૉલો-અપ';

  @override
  String get nothingComingUp => 'કંઈ આવનારું નથી';

  @override
  String get nothingComingUpHelp => 'આવતા 60 દિવસની EMI, કાર્ડ બિલ અને FD મેચ્યોરિટી અહીં દેખાય છે.';

  @override
  String get txnDeleted => 'વ્યવહાર કાઢી નાખ્યો';

  @override
  String get txnGone => 'આ વ્યવહાર હવે અસ્તિત્વમાં નથી.';

  @override
  String get transaction => 'વ્યવહાર';

  @override
  String get dateTime => 'તારીખ અને સમય';

  @override
  String get location => 'જગ્યા';

  @override
  String get coordinates => 'કોઓર્ડિનેટ્સ';

  @override
  String get repeats => 'પુનરાવર્તન';

  @override
  String get duplicate => 'નકલ બનાવો';

  @override
  String get pdfReceipt => 'PDF રસીદ';

  @override
  String get open => 'ખોલો';

  @override
  String get receiptMissing => 'રસીદની ફાઇલ મળી નહીં';

  @override
  String get keyPlus => 'પ્લસ';

  @override
  String get keyMinus => 'માઇનસ';

  @override
  String get keyEquals => 'બરાબર';

  @override
  String get keyDecimal => 'દશાંશ';

  @override
  String get keyDoubleZero => 'ડબલ ઝીરો';

  @override
  String get keyBackspace => 'બૅકસ્પેસ';

  @override
  String allOf(String name) {
    return 'બધું $name';
  }

  @override
  String chartBarLabel(String label, String spent, String invested) {
    return '$label: ખર્ચ $spent, રોકાણ $invested';
  }

  @override
  String get pinMismatch => 'PIN મેળ ખાતા નથી. ફરી પ્રયાસ કરો.';

  @override
  String encryptFailed(String error) {
    return 'એન્ક્રિપ્શન બદલી શકાયું નહીં: $error';
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
  String get seedFood => 'ખાવા-પીવાનું';

  @override
  String get seedRent => 'ભાડું';

  @override
  String get seedShopping => 'ખરીદી';

  @override
  String get seedTransport => 'વાહનવ્યવહાર';

  @override
  String get seedBills => 'બિલ અને યુટિલિટી';

  @override
  String get seedHealth => 'આરોગ્ય';

  @override
  String get seedEntertainment => 'મનોરંજન';

  @override
  String get seedTravel => 'પ્રવાસ';

  @override
  String get seedOthers => 'અન્ય';

  @override
  String get seedFd => 'ફિક્સ્ડ ડિપોઝિટ';

  @override
  String get seedMutualFunds => 'મ્યુચ્યુઅલ ફંડ / SIP';

  @override
  String get seedRetirement => 'PPF / EPF / NPS';

  @override
  String get seedSalary => 'પગાર';

  @override
  String get seedOtherIncome => 'અન્ય આવક';
}
