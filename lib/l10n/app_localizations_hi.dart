// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Expense Manager';

  @override
  String get navHome => 'होम';

  @override
  String get navInsights => 'विश्लेषण';

  @override
  String get navInvest => 'निवेश';

  @override
  String get navDebts => 'कर्ज़';

  @override
  String get addTransaction => 'लेन-देन जोड़ें';

  @override
  String get ok => 'ठीक है';

  @override
  String get save => 'सेव करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get none => 'कोई नहीं';

  @override
  String get notSet => 'सेट नहीं';

  @override
  String get on => 'चालू';

  @override
  String get off => 'बंद';

  @override
  String get unknown => 'अज्ञात';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String nActive(int count) {
    return '$count सक्रिय';
  }

  @override
  String get locationDenied => 'लोकेशन की अनुमति नहीं मिली — आप जगह खुद लिख सकते हैं।';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsLocalOnly => 'आपका डेटा इस फ़ोन से बाहर नहीं जाता। यह फ़ोन पर ही सेव रहता है, कोई सर्वर नहीं। डिवाइस बदलने के लिए बैकअप एक्सपोर्ट करें।';

  @override
  String get settingsProfile => 'प्रोफ़ाइल';

  @override
  String get settingsName => 'नाम';

  @override
  String get settingsYourName => 'आपका नाम';

  @override
  String get settingsAppearance => 'रूप-रंग';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageDevice => 'डिवाइस की भाषा';

  @override
  String get settingsDefaults => 'डिफ़ॉल्ट';

  @override
  String get settingsDefaultSource => 'डिफ़ॉल्ट भुगतान तरीका';

  @override
  String get settingsDefaultSourceHelp => 'नए लेन-देन में पहले से चुना रहता है';

  @override
  String get settingsSources => 'भुगतान के तरीके';

  @override
  String get settingsCategories => 'श्रेणियाँ';

  @override
  String get settingsCategoriesHelp => 'बिना श्रेणी वाली एंट्री डिफ़ॉल्ट श्रेणी में जाती हैं';

  @override
  String settingsDefaultCategory(String name) {
    return 'डिफ़ॉल्ट: $name';
  }

  @override
  String get settingsCurrency => 'मुद्रा';

  @override
  String get settingsCurrencyHelp => 'सिर्फ़ रकम दिखाने का तरीका बदलता है। कुछ भी कन्वर्ट नहीं होता।';

  @override
  String get settingsRecurring => 'दोहराए जाने वाले लेन-देन';

  @override
  String get settingsWeekStart => 'हफ़्ता शुरू होता है';

  @override
  String get settingsWeekStartHelp => 'साप्ताहिक बजट और विश्लेषण का साप्ताहिक व्यू इसी के अनुसार चलते हैं।';

  @override
  String settingsWeekSpan(String span) {
    return 'साप्ताहिक बजट और विश्लेषण $span चलते हैं';
  }

  @override
  String get settingsData => 'डेटा';

  @override
  String get settingsExportCsv => 'CSV एक्सपोर्ट करें';

  @override
  String get settingsExportCsvHelp => 'लेन-देन, निवेश, कर्ज़, बजट';

  @override
  String get settingsExportPdf => 'इस महीने का PDF एक्सपोर्ट करें';

  @override
  String get settingsImport => 'CSV या PDF स्टेटमेंट इंपोर्ट करें';

  @override
  String get settingsImportHelp => 'HDFC, SBI, ICICI और ज़्यादातर बैंकों के PDF, या CSV एक्सपोर्ट';

  @override
  String get settingsBackUp => 'अभी बैकअप लें';

  @override
  String get settingsBackUpHelp => 'एक .ledger फ़ाइल, पासवर्ड वैकल्पिक';

  @override
  String get settingsRestore => 'बैकअप से रीस्टोर करें';

  @override
  String get settingsPrivacyGroup => 'प्राइवेसी और अनुमतियाँ';

  @override
  String get settingsLocation => 'लेन-देन पर लोकेशन';

  @override
  String get settingsAppLock => 'ऐप लॉक और प्राइवेसी';

  @override
  String get smsTitle => 'SMS से खर्च';

  @override
  String get remindersTitle => 'रिमाइंडर और अलर्ट';

  @override
  String get settingsAbout => 'जानकारी';

  @override
  String get settingsVersion => 'वर्ज़न';

  @override
  String get settingsPrivacy => 'प्राइवेसी';

  @override
  String get settingsPrivacyHelp => 'कोई डेटा इकट्ठा नहीं · ऑफ़लाइन चलता है';

  @override
  String get settingsPrivacyBody =>
      'Expense Manager में कोई अकाउंट, सर्वर या एनालिटिक्स नहीं है। आप जो भी लिखते हैं वह इसी फ़ोन के डेटाबेस में सेव होता है और तभी बाहर जाता है जब आप खुद कोई फ़ाइल एक्सपोर्ट या शेयर करते हैं।\n\nलोकेशन सिर्फ़ आपकी अनुमति पर और सिर्फ़ आपके लेन-देन पर जगह लिखने के लिए पढ़ी जाती है। मैप खोलने पर मैप टाइल्स OpenStreetMap से लोड होती हैं। SMS से खर्च चालू करने पर बैंक SMS सिर्फ़ इसी फ़ोन पर पढ़े जाते हैं।';

  @override
  String get settingsReadPolicy => 'पूरी पॉलिसी पढ़ें';

  @override
  String get settingsSourceCode => 'GitHub पर सोर्स कोड';

  @override
  String get settingsLicenses => 'ओपन-सोर्स लाइसेंस';

  @override
  String get settingsSupport => 'सहायता';

  @override
  String get diagnosticsTitle => 'डायग्नोस्टिक्स';

  @override
  String get settingsDiagnosticsHelp => 'फ़ोन पर एरर लॉग · देखें, शेयर करें या मिटाएँ';

  @override
  String get settingsReportIssue => 'समस्या बताएँ';

  @override
  String get settingsReportIssueHelp => 'GitHub इश्यू खोलता है · GitHub अकाउंट चाहिए';

  @override
  String settingsNoBrowser(String url) {
    return '$url खोलने के लिए कोई ब्राउज़र नहीं मिला';
  }

  @override
  String get add => 'जोड़ें';

  @override
  String get edit => 'बदलें';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get nothingHere => 'यहाँ कुछ नहीं है';

  @override
  String get dueToday => 'आज देय';

  @override
  String get dueTomorrow => 'कल देय';

  @override
  String dueInDays(int n) {
    return '$n दिन में देय';
  }

  @override
  String overdueByDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n दिन से बकाया', one: '1 दिन से बकाया');
    return '$_temp0';
  }

  @override
  String debtRemindMessage(String person, String amount) {
    return 'नमस्ते $person, $amount के बारे में एक छोटा-सा रिमाइंडर। जब आपको सुविधा हो तब दे दीजिए। धन्यवाद!';
  }

  @override
  String debtRemindMessageFor(String person, String amount, String reason) {
    return 'नमस्ते $person, $reason के $amount के बारे में एक छोटा-सा रिमाइंडर। जब आपको सुविधा हो तब दे दीजिए। धन्यवाद!';
  }

  @override
  String get debtRemindSubject => 'दोस्ताना रिमाइंडर';

  @override
  String get debtYouOwe => 'आपको देना है';

  @override
  String get debtOwedToYou => 'आपको मिलना है';

  @override
  String debtMonthlyEmi(String amount) {
    return '$amount/माह EMI में';
  }

  @override
  String get debtToCollect => 'वसूलना है';

  @override
  String get debtIOwe => 'मुझे देना है';

  @override
  String get debtOwedToMe => 'मुझे मिलना है';

  @override
  String get debtSettled => 'चुकता';

  @override
  String get debtEmpty => 'लोन, क्रेडिट कार्ड और उधार दिया या लिया पैसा यहाँ दिखता है।';

  @override
  String get debtFooter => 'यहाँ दर्ज EMI और कार्ड भुगतान खर्च नहीं, कर्ज़ गिने जाते हैं — ताकि आपका मासिक खर्च सही रहे।';

  @override
  String debtPayTitle(String name) {
    return '$name का भुगतान करें?';
  }

  @override
  String debtPayBody(String amount) {
    return '$amount का कार्ड भुगतान दर्ज होगा। यह खर्च नहीं, कर्ज़ गिना जाएगा।';
  }

  @override
  String debtPayBodyFrom(String amount, String source) {
    return '$source से $amount का कार्ड भुगतान दर्ज होगा। यह खर्च नहीं, कर्ज़ गिना जाएगा।';
  }

  @override
  String debtPayAmount(String amount) {
    return '$amount चुकाएँ';
  }

  @override
  String debtBillMerchant(String name) {
    return '$name बिल';
  }

  @override
  String debtPaymentRecorded(String amount) {
    return '$amount का कार्ड भुगतान दर्ज हुआ';
  }

  @override
  String debtEmi(String amount) {
    return 'EMI $amount';
  }

  @override
  String debtDueOn(int day) {
    return '$day तारीख को देय';
  }

  @override
  String debtLeftOf(String amount) {
    return '$amount में से बाकी';
  }

  @override
  String debtStatement(String amount) {
    return 'स्टेटमेंट $amount';
  }

  @override
  String debtStatementDue(String amount, String date) {
    return 'स्टेटमेंट $amount · देय $date';
  }

  @override
  String get debtPaid => 'चुकाया';

  @override
  String debtUnpaid(String amount) {
    return 'बकाया $amount';
  }

  @override
  String debtEmisPaid(int paid, int total) {
    return '$total में से $paid EMI चुकाई';
  }

  @override
  String debtPaymentsRecorded(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n भुगतान दर्ज', one: '1 भुगतान दर्ज');
    return '$_temp0';
  }

  @override
  String get debtReopen => 'फिर खोलें';

  @override
  String get debtSettle => 'चुकता करें';

  @override
  String get debtRemind => 'याद दिलाएँ';

  @override
  String get debtRecordPayment => 'भुगतान दर्ज करें';

  @override
  String get debtRecordRepayment => 'वापसी दर्ज करें';

  @override
  String debtPayNow(String amount) {
    return 'अभी चुकाएँ · $amount';
  }

  @override
  String get debtNeedNameAmount => 'नाम और रकम लिखें';

  @override
  String get debtAddTitle => 'कर्ज़ जोड़ें';

  @override
  String get debtEditTitle => 'कर्ज़ बदलें';

  @override
  String get debtKindLoan => 'लोन';

  @override
  String get debtKindCard => 'क्रेडिट कार्ड';

  @override
  String get debtKindPersonal => 'निजी';

  @override
  String get debtFieldName => 'नाम, जैसे कार लोन';

  @override
  String get debtFieldParty => 'देने वाला / व्यक्ति (वैकल्पिक)';

  @override
  String debtFieldPrincipal(String symbol) {
    return 'कुल रकम ($symbol)';
  }

  @override
  String get debtFieldRate => 'ब्याज दर % (वैकल्पिक)';

  @override
  String get debtFieldEmi => 'EMI / मासिक भुगतान (वैकल्पिक)';

  @override
  String get debtFieldEmis => 'EMI की संख्या (वैकल्पिक)';

  @override
  String get debtFieldDueDay => 'महीने की देय तारीख (वैकल्पिक)';

  @override
  String debtFieldStatement(String symbol) {
    return 'पिछले स्टेटमेंट की कुल रकम ($symbol, वैकल्पिक)';
  }

  @override
  String get debtStatementDueDate => 'स्टेटमेंट की देय तारीख';

  @override
  String debtDueDate(String date) {
    return 'देय $date';
  }

  @override
  String get debtSave => 'कर्ज़ सेव करें';

  @override
  String get all => 'सभी';

  @override
  String get amount => 'रकम';

  @override
  String get delete => 'हटाएँ';

  @override
  String get type => 'प्रकार';

  @override
  String get min => 'न्यूनतम';

  @override
  String get max => 'अधिकतम';

  @override
  String get searchScopeNotes => 'नोट';

  @override
  String get searchScopeMerchant => 'दुकान';

  @override
  String get searchScopePlace => 'जगह';

  @override
  String get sortNewest => 'नए पहले';

  @override
  String get sortOldest => 'पुराने पहले';

  @override
  String get sortAmountDesc => 'रकम: ज़्यादा से कम';

  @override
  String get sortAmountAsc => 'रकम: कम से ज़्यादा';

  @override
  String get transactionsTitle => 'लेन-देन';

  @override
  String get sort => 'क्रम';

  @override
  String get searchHintAll => 'दुकान, नोट, #टैग, रकम खोजें…';

  @override
  String get searchHintNotes => 'नोट और #टैग खोजें';

  @override
  String get searchHintMerchant => 'दुकानें खोजें';

  @override
  String searchHintAmount(String symbol) {
    return 'सटीक रकम, जैसे 450 या ${symbol}1,200';
  }

  @override
  String get searchHintPlace => 'जगहें खोजें';

  @override
  String get clearSearch => 'खोज साफ़ करें';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get allCategories => 'सभी श्रेणियाँ';

  @override
  String get previousMonth => 'पिछला महीना';

  @override
  String get nextMonth => 'अगला महीना';

  @override
  String get allTime => 'अब तक';

  @override
  String nTransactions(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n लेन-देन', one: '1 लेन-देन');
    return '$_temp0';
  }

  @override
  String moneyOut(String amount) {
    return 'बाहर $amount';
  }

  @override
  String moneyIn(String amount) {
    return 'अंदर $amount';
  }

  @override
  String noTxnMatch(String query) {
    return '\"$query\" से मेल खाता कोई लेन-देन नहीं।';
  }

  @override
  String get noTxnInPeriod => 'इस अवधि में कोई लेन-देन नहीं।';

  @override
  String get recentSearches => 'हाल की खोजें';

  @override
  String get removeRecentSearch => 'हाल की खोजों से हटाएँ';

  @override
  String get resetAll => 'सब रीसेट करें';

  @override
  String get searchCategories => 'श्रेणियाँ खोजें';

  @override
  String amountIn(String symbol) {
    return 'रकम ($symbol)';
  }

  @override
  String get paidVia => 'भुगतान का तरीका';

  @override
  String get applyFilters => 'फ़िल्टर लागू करें';

  @override
  String get txnNeedAmount => 'शून्य से ज़्यादा रकम लिखें';

  @override
  String txnTemplateSaved(String name) {
    return '“$name” टेम्पलेट के रूप में सेव हुआ';
  }

  @override
  String deleteNamed(String name) {
    return '“$name” हटाएँ?';
  }

  @override
  String get txnTemplateDeleteBody => 'टेम्पलेट हट जाएगा। इससे बने लेन-देन बने रहेंगे।';

  @override
  String get txnNeedDebt => 'चुनें कि यह भुगतान किस कर्ज़ का है';

  @override
  String get txnEditTitle => 'लेन-देन बदलें';

  @override
  String get txnNewTitle => 'नया लेन-देन';

  @override
  String get txnSaveTemplate => 'टेम्पलेट के रूप में सेव करें';

  @override
  String get txnReceivedIn => 'किसमें मिला';

  @override
  String get txnPaidFrom => 'किससे चुकाया';

  @override
  String get category => 'श्रेणी';

  @override
  String txnCategoryHint(String name) {
    return 'पक्का नहीं? डिफ़ॉल्ट रूप से यह “$name” में जाएगा।';
  }

  @override
  String get txnHolding => 'होल्डिंग (वैकल्पिक)';

  @override
  String get txnNotLinked => 'जुड़ा नहीं';

  @override
  String get txnDebt => 'कर्ज़';

  @override
  String get txnChooseDebt => 'कर्ज़ चुनें';

  @override
  String txnDebtYouPay(String name) {
    return '$name · आप देंगे';
  }

  @override
  String txnDebtYouReceive(String name) {
    return '$name · आपको मिलेगा';
  }

  @override
  String get details => 'विवरण';

  @override
  String get date => 'तारीख';

  @override
  String get time => 'समय';

  @override
  String get txnMerchant => 'दुकान / पाने वाला';

  @override
  String get txnLocation => 'जगह · वैकल्पिक';

  @override
  String get pickOnMap => 'मैप पर चुनें';

  @override
  String get useCurrentLocation => 'मौजूदा लोकेशन इस्तेमाल करें';

  @override
  String get txnNote => 'क्यों? नोट जोड़ें (खोज में आता है)';

  @override
  String get txnTags => 'टैग, जैसे #काम #बँटवारा';

  @override
  String get receipt => 'रसीद';

  @override
  String get receiptCamera => 'कैमरा';

  @override
  String get receiptGallery => 'गैलरी';

  @override
  String get receiptPdf => 'PDF';

  @override
  String get receiptPdfAttached => 'PDF रसीद जुड़ी है';

  @override
  String get receiptPhotoAttached => 'रसीद की फ़ोटो जुड़ी है';

  @override
  String get receiptRemove => 'रसीद हटाएँ';

  @override
  String get txnRecurringNote => 'यह दोहराई जाने वाली सीरीज़ का हिस्सा है। बदलाव सिर्फ़ इसी पर लागू होंगे; सीरीज़ को सेटिंग्स › दोहराए जाने वाले में संभालें।';

  @override
  String get repeat => 'दोहराएँ';

  @override
  String get txnRepeat => 'यह लेन-देन दोहराएँ';

  @override
  String txnRepeatNext(String frequency, String date) {
    return '$frequency · अगला $date';
  }

  @override
  String get txnRepeatHelp => 'समय पर अपने आप जोड़ देता है';

  @override
  String get neverEnds => 'कभी खत्म नहीं';

  @override
  String endsOn(String date) {
    return '$date को खत्म';
  }

  @override
  String get clearEndDate => 'खत्म होने की तारीख हटाएँ';

  @override
  String get saveChanges => 'बदलाव सेव करें';

  @override
  String get txnSave => 'लेन-देन सेव करें';

  @override
  String get quickAdd => 'झटपट जोड़ें';

  @override
  String get continue_ => 'आगे बढ़ें';

  @override
  String get done => 'हो गया';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get remove => 'हटाएँ';

  @override
  String get typeSpend => 'खर्च';

  @override
  String get typeInvest => 'निवेश';

  @override
  String get typeIncome => 'आय';

  @override
  String get typeDebt => 'कर्ज़';

  @override
  String get investKindFd => 'फ़िक्स्ड डिपॉज़िट';

  @override
  String get investKindMf => 'म्यूचुअल फ़ंड';

  @override
  String get investKindStock => 'शेयर';

  @override
  String get investKindGold => 'सोना';

  @override
  String get investKindRetirement => 'रिटायरमेंट (PPF/EPF/NPS)';

  @override
  String get investKindOther => 'अन्य';

  @override
  String get reminderTypeBudget => 'बजट अलर्ट (80% और 100%)';

  @override
  String get reminderTypeDues => 'EMI और कार्ड की देय तारीखें';

  @override
  String get reminderTypeSip => 'SIP रिमाइंडर';

  @override
  String get reminderTypeMaturity => 'FD मैच्योरिटी';

  @override
  String get reminderTypeFollowUp => 'मुझे मिलने वाले पैसे का फ़ॉलो-अप';

  @override
  String get reminderEmiTomorrow => 'EMI कल देय';

  @override
  String get reminderCardTomorrow => 'कार्ड बिल कल देय';

  @override
  String get reminderEmiToday => 'EMI आज देय';

  @override
  String get reminderCardToday => 'कार्ड बिल आज देय';

  @override
  String get reminderSipToday => 'SIP आज देय';

  @override
  String reminderSipBody(String title, String amount) {
    return '$title: आज $amount निवेश करें।';
  }

  @override
  String reminderFdMatures(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'FD $n दिन में मैच्योर होगी', one: 'FD कल मैच्योर होगी', zero: 'FD आज मैच्योर होगी');
    return '$_temp0';
  }

  @override
  String reminderFdBody(String title, String amount, String date) {
    return '$title ($amount निवेश) $date को मैच्योर होगी।';
  }

  @override
  String reminderFollowUp(String name) {
    return '$name से फ़ॉलो-अप करें';
  }

  @override
  String reminderFollowUpBody(String name, String amount) {
    return '$name को अभी भी आपको $amount देने हैं।';
  }

  @override
  String budgetAlertFull(String name) {
    return '$name बजट पूरा खर्च हो गया';
  }

  @override
  String budgetAlert80(String name) {
    return '$name बजट का 80% खर्च हो गया';
  }

  @override
  String budgetAlertBody(String used, String limit, String left) {
    return '$limit में से $used खर्च · $left';
  }

  @override
  String daysLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n दिन बाकी', one: '1 दिन बाकी');
    return '$_temp0';
  }

  @override
  String get reminderTestTitle => 'रिमाइंडर चालू हैं';

  @override
  String get reminderTestBody => 'बजट, देय तारीखों, SIP और मैच्योरिटी की सूचना यहाँ मिलेगी। कुछ भी आपके फ़ोन से बाहर नहीं जाता।';

  @override
  String get smsAddDetails => 'विवरण जोड़ें';

  @override
  String get smsIgnore => 'अनदेखा करें';

  @override
  String get undo => 'वापस लें';

  @override
  String smsAmountFrom(String amount, String name) {
    return '$name से $amount';
  }

  @override
  String smsAmountAt(String amount, String name) {
    return '$name पर $amount';
  }

  @override
  String smsAmountInto(String amount, String name) {
    return '$name में $amount';
  }

  @override
  String smsMoneyReceived(String what) {
    return 'पैसे मिले: $what';
  }

  @override
  String smsNewExpense(String what) {
    return 'नया खर्च: $what';
  }

  @override
  String smsAddTo(String where) {
    return '$where में जोड़ें?';
  }

  @override
  String smsIncomeAdded(String what) {
    return 'आय जोड़ी गई: $what';
  }

  @override
  String smsExpenseAdded(String what) {
    return 'खर्च जोड़ा गया: $what';
  }

  @override
  String get reminderChannelHelp => 'बजट अलर्ट, देय तारीखें, SIP और मैच्योरिटी रिमाइंडर';

  @override
  String get smsChannelHelp => 'SMS से पढ़े गए बैंक या UPI लेन-देन को जोड़ने से पहले पूछता है';

  @override
  String get unlockPrompt => 'Expense Manager अनलॉक करें';

  @override
  String get daily => 'रोज़';

  @override
  String get weekly => 'साप्ताहिक';

  @override
  String get monthly => 'मासिक';

  @override
  String get yearly => 'सालाना';

  @override
  String get backupNeedsPassword => 'यह बैकअप पासवर्ड से सुरक्षित है';

  @override
  String get backupWrongPassword => 'गलत पासवर्ड';

  @override
  String get backupInvalid => 'यह Expense Manager का बैकअप नहीं है';

  @override
  String get backupDamaged => 'बैकअप फ़ाइल खराब है';

  @override
  String get backupTooNew => 'यह बैकअप ऐप के नए वर्ज़न से बना है। पहले ऐप अपडेट करें।';

  @override
  String get backupNever => 'कभी बैकअप नहीं लिया';

  @override
  String backupLast(String date) {
    return 'पिछला बैकअप $date';
  }

  @override
  String get importNeedColumns => 'तारीख का कॉलम और रकम (या डेबिट/क्रेडिट) का कॉलम चाहिए';

  @override
  String importInvalidDate(String value) {
    return 'गलत तारीख \"$value\"';
  }

  @override
  String get importInvalidAmount => 'गलत रकम';

  @override
  String get investmentsTitle => 'निवेश';

  @override
  String get budgetsTitle => 'बजट';

  @override
  String get pdfLocked => 'यह PDF पासवर्ड से सुरक्षित है। बिना लॉक की कॉपी सेव करें (प्रिंट → PDF के रूप में सेव) और उसे इंपोर्ट करें।';

  @override
  String pdfUnreadable(String cause) {
    return 'यह PDF पढ़ा नहीं जा सका ($cause)';
  }

  @override
  String get bankStatement => 'बैंक स्टेटमेंट';

  @override
  String get emi => 'EMI';

  @override
  String get cardBill => 'कार्ड बिल';

  @override
  String reminderDueTomorrowBody(String title, String what) {
    return '$title: $what कल देय है।';
  }

  @override
  String reminderDueTomorrowAmountBody(String title, String what, String amount) {
    return '$title: $amount का $what कल देय है।';
  }

  @override
  String reminderDueTodayBody(String title, String what) {
    return '$title: $what आज देय है।';
  }

  @override
  String reminderDueTodayAmountBody(String title, String what, String amount) {
    return '$title: $amount का $what आज देय है।';
  }

  @override
  String exportedOne(String what, String path) {
    return '$what को $path में एक्सपोर्ट किया';
  }

  @override
  String exportedMany(int n, String path) {
    return '$n फ़ाइलें $path में एक्सपोर्ट कीं';
  }

  @override
  String get exportHelp => 'UTF-8 फ़ाइलें जो Excel या Sheets में खुलती हैं। कई फ़ाइलें एक zip में शेयर होती हैं।';

  @override
  String exportZip(int n) {
    return '$n फ़ाइलें एक्सपोर्ट करें (zip)';
  }

  @override
  String get export => 'एक्सपोर्ट करें';

  @override
  String get importPreview => 'इंपोर्ट प्रीव्यू';

  @override
  String get importPdfEmpty => 'इस PDF में कोई लेन-देन नहीं मिला। नेट बैंकिंग से CSV/Excel एक्सपोर्ट आज़माएँ।';

  @override
  String importFound(String bank, int n) {
    return '$bank · $n मिले';
  }

  @override
  String get backupCreating => 'बैकअप बन रहा है…';

  @override
  String get backupEncrypting => 'बैकअप एन्क्रिप्ट हो रहा है…';

  @override
  String backupSaved(String path) {
    return 'बैकअप $path में सेव हुआ';
  }

  @override
  String get restoring => 'रीस्टोर हो रहा है…';

  @override
  String restoredN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n लेन-देन रीस्टोर हुए', one: '1 लेन-देन रीस्टोर हुआ');
    return '$_temp0';
  }

  @override
  String addedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n लेन-देन जोड़े', one: '1 लेन-देन जोड़ा');
    return '$_temp0';
  }

  @override
  String addedNSkipped(int n, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n लेन-देन जोड़े', one: '1 लेन-देन जोड़ा');
    return '$_temp0 · $skipped पहले से मौजूद';
  }

  @override
  String get backupHelp => 'आपके सारे डेटा और रसीदों वाली एक .ledger फ़ाइल। इसे Drive, Files या कंप्यूटर पर सेव करें।';

  @override
  String get backupProtect => 'पासवर्ड से सुरक्षित करें';

  @override
  String get backupPasswordField => 'पासवर्ड (6+ अक्षर)';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get backupNoRecovery => 'भूला हुआ पासवर्ड वापस पाने का कोई तरीका नहीं है।';

  @override
  String get backUp => 'बैकअप लें';

  @override
  String get backupPassword => 'बैकअप पासवर्ड';

  @override
  String get password => 'पासवर्ड';

  @override
  String get unlock => 'अनलॉक करें';

  @override
  String get restoreBackup => 'बैकअप रीस्टोर करें';

  @override
  String backupMade(String date, String version) {
    return '$date को बना · ऐप $version';
  }

  @override
  String get merge => 'मिलाएँ';

  @override
  String get replace => 'बदलें';

  @override
  String get restoreMergeHelp => 'जो इस फ़ोन पर नहीं है वह जोड़ता है। मिलती-जुलती श्रेणियाँ, भुगतान तरीके और खाते दोबारा इस्तेमाल होते हैं; जो लेन-देन पहले से हैं वे छोड़ दिए जाते हैं।';

  @override
  String get restoreReplaceHelp => 'इस फ़ोन का सब कुछ हटाकर बैकअप इस्तेमाल करता है।';

  @override
  String get restoreConfirm => 'मैं समझता/समझती हूँ कि मेरा मौजूदा डेटा मिट जाएगा';

  @override
  String get backupReminder => 'बैकअप रिमाइंडर';

  @override
  String get backupBannerNever => 'आपका डेटा सिर्फ़ इसी फ़ोन पर है। बैकअप लें।';

  @override
  String backupBannerDue(String last) {
    return 'बैकअप का समय · $last';
  }

  @override
  String get remindLater => 'बाद में याद दिलाएँ';

  @override
  String importedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n लेन-देन इंपोर्ट हुए', one: '1 लेन-देन इंपोर्ट हुआ');
    return '$_temp0';
  }

  @override
  String importLine(int n) {
    return 'पंक्ति $n';
  }

  @override
  String get importDuplicate => 'डुप्लिकेट';

  @override
  String importToDefault(String name) {
    return 'श्रेणी → $name';
  }

  @override
  String importNewSub(String name) {
    return 'नई उप-श्रेणी: $name';
  }

  @override
  String importN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n लेन-देन इंपोर्ट करें', one: '1 लेन-देन इंपोर्ट करें');
    return '$_temp0';
  }

  @override
  String get finish => 'पूरा करें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get onbWelcomeTitle => 'आपका पैसा, आपके फ़ोन पर';

  @override
  String get onbWelcomeBody => 'खर्च, निवेश और कर्ज़ एक ही जगह ट्रैक करें। आपका डेटा इसी फ़ोन पर रहता है। कोई अकाउंट नहीं, कोई सर्वर नहीं, कोई ट्रैकिंग नहीं।';

  @override
  String get onbGetStarted => 'शुरू करें';

  @override
  String get onbPointLocal => 'सिर्फ़ इसी डिवाइस पर सेव';

  @override
  String get onbPointOffline => 'पूरी तरह ऑफ़लाइन चलता है';

  @override
  String get onbPointExport => 'कभी भी CSV या PDF में एक्सपोर्ट करें';

  @override
  String get onbNameTitle => 'हम आपको क्या कहें?';

  @override
  String get onbNameBody => 'सिर्फ़ होम स्क्रीन पर अभिवादन के लिए। वैकल्पिक।';

  @override
  String get onbCurrencyTitle => 'अपनी मुद्रा चुनें';

  @override
  String get onbCurrencyBody => 'रकम इसी मुद्रा में दिखेगी। आप इसे बाद में सेटिंग्स में बदल सकते हैं।';

  @override
  String onbCurrencySample(String currency, String amount) {
    return '$currency · जैसे $amount';
  }

  @override
  String get onbSourceTitle => 'आप कहाँ से भुगतान करते हैं?';

  @override
  String onbSourceBody(String name) {
    return 'अपना मुख्य खाता जोड़ें। यह नए लेन-देन का डिफ़ॉल्ट भुगतान तरीका बनेगा। खाली छोड़ने पर $name से शुरुआत होगी।';
  }

  @override
  String get sourceKindCash => 'नकद';

  @override
  String get sourceNameField => 'नाम, जैसे HDFC बचत खाता';

  @override
  String get optional => 'वैकल्पिक';

  @override
  String get onbLocationTitle => 'जगह अपने आप लिखें?';

  @override
  String get onbLocationBody => 'लोकेशन चालू होने पर नए लेन-देन में आपकी मौजूदा जगह जुड़ जाती है। यह सिर्फ़ इसी फ़ोन पर आपकी एंट्री के साथ सेव होती है। आप चाहें तो जगह खुद भी लिख सकते हैं।';

  @override
  String get onbLocationContinue => 'लोकेशन के बिना आगे बढ़ें';

  @override
  String get onbLocationAllow => 'लोकेशन की अनुमति दें';

  @override
  String get onbLocationDenied => 'अनुमति नहीं मिली। आप इसे बाद में सेटिंग्स में चालू कर सकते हैं।';

  @override
  String get onbSmsTitle => 'बैंक SMS से खर्च जोड़ें?';

  @override
  String get onbSmsBodyShortcuts =>
      'Shortcuts ऑटोमेशन हर बैंक, कार्ड या UPI SMS हमें दे सकता है; हम उसे इसी फ़ोन पर पढ़ते हैं और नोटिफ़िकेशन से एक टैप में पूछते हैं कि जोड़ना है या नहीं। सेटअप का तरीका सेटिंग्स › SMS से खर्च में है।';

  @override
  String get onbSmsBody =>
      'बैंक, कार्ड या UPI SMS आने पर हम उसे इसी फ़ोन पर पढ़ते हैं और नोटिफ़िकेशन से एक टैप में पूछते हैं कि जोड़ना है या नहीं। OTP और ऑफ़र छोड़ दिए जाते हैं, और कुछ भी अपलोड नहीं होता।';

  @override
  String get onbSmsContinue => 'SMS के बिना आगे बढ़ें';

  @override
  String get turnOn => 'चालू करें';

  @override
  String get onbSmsAllow => 'SMS की अनुमति दें';

  @override
  String get onbSmsDenied => 'SMS की अनुमति नहीं मिली। आप इसे बाद में सेटिंग्स › SMS से खर्च में चालू कर सकते हैं।';

  @override
  String get onbLockTitle => 'ऐप लॉक करें?';

  @override
  String get onbLockBody => 'ऐप खुलने पर PIN (या फ़िंगरप्रिंट / फ़ेस) माँगें, और ऐप स्विचर में रकम छिपाएँ। आप इसे कभी भी सेटिंग्स में बदल सकते हैं।';

  @override
  String get onbLockAction => 'PIN सेट करें';

  @override
  String get onbRemindersTitle => 'रिमाइंडर चाहिए?';

  @override
  String get onbRemindersBody =>
      'बजट 80% या 100% पहुँचने पर, EMI या कार्ड बिल की देय तारीख से एक दिन पहले, SIP की तारीख पर और FD मैच्योर होने से पहले सूचना। यह इसी फ़ोन पर तय होता है; कुछ भी कहीं नहीं भेजा जाता।';

  @override
  String get onbRemindersContinue => 'रिमाइंडर के बिना आगे बढ़ें';

  @override
  String get onbRemindersAllow => 'रिमाइंडर चालू करें';

  @override
  String get onbRemindersDenied => 'नोटिफ़िकेशन ब्लॉक हैं। आप इन्हें बाद में सेटिंग्स › रिमाइंडर और अलर्ट में चालू कर सकते हैं।';

  @override
  String get currencyInr => 'भारतीय रुपया';

  @override
  String get currencyUsd => 'अमेरिकी डॉलर';

  @override
  String get currencyEur => 'यूरो';

  @override
  String get currencyGbp => 'ब्रिटिश पाउंड';

  @override
  String get currencyAed => 'यूएई दिरहम';

  @override
  String get currencySgd => 'सिंगापुर डॉलर';

  @override
  String get currencyAud => 'ऑस्ट्रेलियाई डॉलर';

  @override
  String get currencyCad => 'कनाडाई डॉलर';

  @override
  String get goodMorning => 'सुप्रभात';

  @override
  String get goodAfternoon => 'नमस्कार';

  @override
  String get goodEvening => 'शुभ संध्या';

  @override
  String get welcome => 'स्वागत है';

  @override
  String get reminders => 'रिमाइंडर';

  @override
  String homeSmsReview(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'SMS से $n लेन-देन जाँचने हैं', one: 'SMS से 1 लेन-देन जाँचना है');
    return '$_temp0';
  }

  @override
  String get homeOutThisMonth => 'इस महीने बाहर गया पैसा';

  @override
  String homeOutIn(String month) {
    return '$month में बाहर गया पैसा';
  }

  @override
  String get invested => 'निवेश किया';

  @override
  String homeInvestedThisMonth(String amount) {
    return 'इस महीने +$amount';
  }

  @override
  String homeInvestedIn(String amount, String month) {
    return '$month में +$amount';
  }

  @override
  String homeMonthlyEmi(String amount) {
    return '$amount/माह EMI';
  }

  @override
  String get comingUp => 'आने वाले';

  @override
  String get seeAll => 'सब देखें';

  @override
  String get whereItWent => 'पैसा कहाँ गया';

  @override
  String get homeNoSpendYet => 'इस महीने अभी तक कोई खर्च नहीं।';

  @override
  String homeNoSpendIn(String period) {
    return '$period में कोई खर्च नहीं।';
  }

  @override
  String get recent => 'हाल के';

  @override
  String get viewAll => 'सब देखें';

  @override
  String get homeNoTxns => 'अभी तक कोई लेन-देन नहीं';

  @override
  String get homeNoTxnsHelp => 'अपना पहला खर्च, निवेश या आय जोड़ने के लिए + दबाएँ।';

  @override
  String homeNothingIn(String period) {
    return '$period में कुछ नहीं';
  }

  @override
  String get homeNothingInHelp => 'उस महीने कोई लेन-देन दर्ज नहीं हुआ।';

  @override
  String homeOfIncome(String amount) {
    return '$amount आय में से';
  }

  @override
  String get spent => 'खर्च';

  @override
  String get left => 'बाकी';

  @override
  String get catKindInvestment => 'निवेश';

  @override
  String catMove(String name) {
    return '$name को ले जाएँ';
  }

  @override
  String get catTopLevel => 'सबसे ऊपर';

  @override
  String catUnder(String name) {
    return '$name के नीचे';
  }

  @override
  String get catMoveOnlyLeaf => 'सिर्फ़ बिना उप-श्रेणी वाली श्रेणियाँ ही किसी दूसरी के नीचे ले जाई जा सकती हैं';

  @override
  String get catDefaultHelp => 'डिफ़ॉल्ट — जब कुछ न चुना जाए तब इस्तेमाल होती है';

  @override
  String get catAddSub => 'उप-श्रेणी जोड़ें';

  @override
  String get catMoveMenu => 'ले जाएँ…';

  @override
  String get catMoveUnderMenu => 'नीचे ले जाएँ…';

  @override
  String catArchive(String name) {
    return '$name आर्काइव करें';
  }

  @override
  String catArchived(String name) {
    return '$name आर्काइव हुई';
  }

  @override
  String get catAdd => 'श्रेणी जोड़ें';

  @override
  String get catSpendHelp => 'जो पैसा चला गया — खाना, किराया, बिल। उप-श्रेणी जोड़ने के लिए ⋮ दबाएँ।';

  @override
  String get catInvestHelp => 'बाहर गया पैसा जो आपकी संपत्ति बढ़ाता है।';

  @override
  String get catIncomeHelp => 'आने वाला पैसा।';

  @override
  String catArchivedCount(int n) {
    return 'आर्काइव ($n)';
  }

  @override
  String get catArchivedHelp => 'इतिहास के लिए रखी गई; नए लेन-देन में नहीं दिखती';

  @override
  String catKindUnder(String kind, String parent) {
    return '$kind · $parent के नीचे';
  }

  @override
  String get restore => 'रीस्टोर करें';

  @override
  String catRestored(String name) {
    return '$name रीस्टोर हुई';
  }

  @override
  String get catNew => 'नई श्रेणी';

  @override
  String catNewSub(String name) {
    return '$name में नई उप-श्रेणी';
  }

  @override
  String get immediately => 'तुरंत';

  @override
  String seconds(int n) {
    return '$n सेकंड';
  }

  @override
  String minutes(int n) {
    return '$n मिनट';
  }

  @override
  String get pinChoose => 'PIN चुनें';

  @override
  String get pinConfirm => 'अपना PIN दोबारा डालें';

  @override
  String get pinDigits => '4–6 अंक डालें';

  @override
  String get pinAgain => 'वही PIN फिर से डालें';

  @override
  String pinCooldown(int n) {
    return 'बहुत ज़्यादा कोशिशें। $n सेकंड बाद फिर कोशिश करें';
  }

  @override
  String get pinWrong => 'गलत PIN';

  @override
  String get pinCurrent => 'अपना मौजूदा PIN डालें';

  @override
  String get lockOn => 'ऐप लॉक चालू है';

  @override
  String get pinChanged => 'PIN बदल गया';

  @override
  String get encryptTitle => 'डेटाबेस एन्क्रिप्ट करें?';

  @override
  String get encryptBody =>
      'आपका डेटा इस फ़ोन के सुरक्षित स्टोरेज में रखी एक की से एन्क्रिप्ट होगा। अगर वह की खो जाए (जैसे ऐप डेटा मिटाने पर), तो डेटा वापस नहीं मिल सकता — पहले बैकअप एक्सपोर्ट करें।';

  @override
  String get encrypt => 'एन्क्रिप्ट करें';

  @override
  String get dbEncrypted => 'डेटाबेस एन्क्रिप्ट हुआ';

  @override
  String get dbDecrypted => 'डेटाबेस डिक्रिप्ट हुआ';

  @override
  String get appLock => 'ऐप लॉक';

  @override
  String get lockWithPin => 'PIN से लॉक करें';

  @override
  String get lockWithPinHelp => 'ऐप खुलने पर पूछा जाता है';

  @override
  String get changePin => 'PIN बदलें';

  @override
  String get unlockBiometric => 'फ़िंगरप्रिंट / फ़ेस से अनलॉक करें';

  @override
  String get notAvailableDevice => 'इस डिवाइस पर उपलब्ध नहीं';

  @override
  String get lockAgainAfter => 'ऐप छोड़ने के बाद फिर से लॉक';

  @override
  String get hideSwitcher => 'ऐप स्विचर में छिपाएँ';

  @override
  String get hideSwitcherHelp => 'हाल के ऐप्स के प्रीव्यू को धुंधला करता है और स्क्रीनशॉट रोकता है';

  @override
  String get encryption => 'एन्क्रिप्शन';

  @override
  String get encryptDb => 'डेटाबेस एन्क्रिप्ट करें';

  @override
  String get encryptKeyStored => 'की फ़ोन के सुरक्षित स्टोरेज में रखी है';

  @override
  String get encryptUnavailable => 'इस डेटाबेस के लिए उपलब्ध नहीं';

  @override
  String get budgetNew => 'नया बजट';

  @override
  String budgetTabWeekly(String span) {
    return 'साप्ताहिक · $span';
  }

  @override
  String get budgetTabMonthly => 'मासिक · 1 तारीख से महीने के अंत तक';

  @override
  String budgetOverBanner(String name, String amount) {
    return '$name $amount से ज़्यादा हो गया';
  }

  @override
  String get budgetNoneWeekly => 'कोई साप्ताहिक बजट नहीं';

  @override
  String get budgetNoneMonthly => 'कोई मासिक बजट नहीं';

  @override
  String get budgetEmptyHelp => 'किसी भी श्रेणी की सीमा तय करें और हर अवधि में उसे ट्रैक करें।';

  @override
  String get budgetCreate => 'बजट बनाएँ';

  @override
  String get budgetGoalReached => 'लक्ष्य पूरा';

  @override
  String budgetToGoal(String amount) {
    return 'लक्ष्य तक $amount बाकी';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount ज़्यादा';
  }

  @override
  String budgetLeft(String amount, String perDay, String days) {
    return '$amount बाकी · $perDay/दिन · $days';
  }

  @override
  String get budgetAllInvestments => 'सभी निवेश';

  @override
  String get budgetAllSpending => 'सभी खर्च';

  @override
  String nCategories(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n श्रेणियाँ', one: '1 श्रेणी');
    return '$_temp0';
  }

  @override
  String ofAmount(String amount) {
    return '$amount में से';
  }

  @override
  String get budgetNeedNameLimit => 'नाम और सीमा लिखें';

  @override
  String get budgetEdit => 'बजट बदलें';

  @override
  String get budgetDelete => 'बजट हटाएँ';

  @override
  String get budgetNameField => 'नाम, जैसे खाना';

  @override
  String budgetLimitField(String symbol) {
    return 'सीमा ($symbol)';
  }

  @override
  String budgetSuggestion(String amount) {
    return 'पिछले 3 महीनों में आपका औसत $amount/माह रहा · इस्तेमाल करने के लिए दबाएँ';
  }

  @override
  String get budgetRepeats => 'हर बार दोहराएँ';

  @override
  String budgetWeek(String span) {
    return 'हफ़्ता ($span)';
  }

  @override
  String get budgetMonth => 'महीना (1 तारीख → अंत)';

  @override
  String get budgetGoal => 'निवेश लक्ष्य';

  @override
  String get budgetGoalHelp => 'खर्च की सीमा की जगह निवेश की रकम का लक्ष्य ट्रैक करें';

  @override
  String get budgetCounts => 'ये निवेश गिने जाएँगे';

  @override
  String get budgetAppliesTo => 'किस पर लागू (खाली = सभी खर्च)';

  @override
  String get budgetRollover => 'बचा हुआ पैसा आगे ले जाएँ';

  @override
  String get budgetAlert80Switch => '80% पर अलर्ट';

  @override
  String get budgetAlertOver => 'सीमा पार होने पर अलर्ट';

  @override
  String get budgetSave => 'बजट सेव करें';

  @override
  String get totalInvested => 'कुल निवेश';

  @override
  String investThisMonth(String amount, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n होल्डिंग', one: '1 होल्डिंग');
    return 'इस महीने +$amount · $_temp0';
  }

  @override
  String get investNoPrices => 'आपके डाले गए पैसे · लाइव भाव या रिटर्न नहीं';

  @override
  String investMaturesOn(String name, String date) {
    return '$name $date को मैच्योर होगी';
  }

  @override
  String get investNone => 'अभी तक कोई निवेश नहीं';

  @override
  String get investNoneHelp => 'आप जो निवेश करते हैं उसे ट्रैक करने के लिए FD, SIP, शेयर या सोना जोड़ें।';

  @override
  String get investAdd => 'निवेश जोड़ें';

  @override
  String investMatures(String date) {
    return '$date को मैच्योर';
  }

  @override
  String nEntries(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n एंट्री', one: '1 एंट्री');
    return '$_temp0';
  }

  @override
  String get interestRate => 'ब्याज दर';

  @override
  String investStarted(String date) {
    return '$date को शुरू';
  }

  @override
  String investMaturesCap(String date) {
    return '$date को मैच्योर';
  }

  @override
  String get institution => 'संस्था';

  @override
  String get note => 'नोट';

  @override
  String contributions(int n) {
    return 'योगदान ($n)';
  }

  @override
  String get investNoMoney => 'अभी तक कोई पैसा नहीं जोड़ा।';

  @override
  String get investAddMoney => 'पैसा जोड़ें';

  @override
  String get investMarkMatured => 'मैच्योर मार्क करें';

  @override
  String get investCloseSold => 'बंद / बेचा';

  @override
  String get investReactivate => 'फिर से सक्रिय करें';

  @override
  String get investNeedName => 'निवेश को नाम दें';

  @override
  String get investNameField => 'नाम, जैसे HDFC बैंक FD';

  @override
  String get investInstitutionField => 'बैंक / प्लेटफ़ॉर्म (वैकल्पिक)';

  @override
  String get investAmountField => 'अभी निवेश की गई रकम (वैकल्पिक)';

  @override
  String get startDate => 'शुरू होने की तारीख';

  @override
  String get maturityDate => 'मैच्योरिटी की तारीख (वैकल्पिक)';

  @override
  String get investSave => 'निवेश सेव करें';

  @override
  String get sourceKindBank => 'बैंक खाता';

  @override
  String get sourceKindWallet => 'UPI / वॉलेट';

  @override
  String get sourceAdd => 'भुगतान तरीका जोड़ें';

  @override
  String get sourceDefaultHelp => 'हर नए लेन-देन में पहले से चुना रहता है';

  @override
  String sourceOutIn(String kind, String amount, String month) {
    return '$kind · $month में $amount बाहर';
  }

  @override
  String sourceLimit(String amount) {
    return 'सीमा $amount';
  }

  @override
  String sourceBalance(String amount) {
    return 'बैलेंस $amount';
  }

  @override
  String sourceOutstanding(String amount) {
    return '$amount बकाया';
  }

  @override
  String sourceCredit(String amount) {
    return '$amount क्रेडिट';
  }

  @override
  String get sourceNew => 'नया भुगतान तरीका';

  @override
  String get sourceLast4 => 'आखिरी 4 अंक (वैकल्पिक)';

  @override
  String sourceCreditLimit(String symbol) {
    return 'क्रेडिट सीमा ($symbol)';
  }

  @override
  String sourceBalanceHelp(String amount) {
    return 'वैकल्पिक · डिफ़ॉल्ट $amount';
  }

  @override
  String get makeDefault => 'डिफ़ॉल्ट बनाएँ';

  @override
  String sourceOutstandingField(String symbol) {
    return 'अभी का बकाया ($symbol)';
  }

  @override
  String sourceBalanceField(String symbol) {
    return 'मौजूदा बैलेंस ($symbol)';
  }

  @override
  String get sourceAdjustHelp => 'यहाँ से आगे आपके जोड़े लेन-देन इसे बदलेंगे';

  @override
  String get pdfReport => 'PDF रिपोर्ट';

  @override
  String get week => 'हफ़्ता';

  @override
  String get month => 'महीना';

  @override
  String get year => 'साल';

  @override
  String get previousPeriod => 'पिछली अवधि';

  @override
  String get nextPeriod => 'अगली अवधि';

  @override
  String insightsDonutLabel(String spent, String invested) {
    return 'खर्च $spent, निवेश $invested';
  }

  @override
  String get moneyOutLabel => 'बाहर गया पैसा';

  @override
  String insightsSaved(int n) {
    return 'आय का $n% बचाया';
  }

  @override
  String get insightsNoEarlier => 'पहले का डेटा नहीं';

  @override
  String insightsLessSpent(int n) {
    return '$n% कम खर्च';
  }

  @override
  String insightsMoreSpent(int n) {
    return '$n% ज़्यादा खर्च';
  }

  @override
  String get insightsThanPrevious => 'पिछली अवधि से';

  @override
  String perDay(String amount) {
    return '$amount / दिन';
  }

  @override
  String get averageSpend => 'औसत खर्च';

  @override
  String get monthByMonth => 'महीने दर महीने';

  @override
  String get weekByWeek => 'हफ़्ते दर हफ़्ते';

  @override
  String get dayByDay => 'दिन दर दिन';

  @override
  String get byCategory => 'श्रेणी के अनुसार';

  @override
  String get insightsNothing => 'इस अवधि में कुछ दर्ज नहीं।';

  @override
  String insightsDirect(String name) {
    return '$name (सीधे)';
  }

  @override
  String insightsCatRow(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n लेन-देन', one: '1 लेन-देन');
    return '$name  ·  $_temp0';
  }

  @override
  String get hideSubs => 'उप-श्रेणियाँ छिपाएँ';

  @override
  String get showSubs => 'उप-श्रेणियाँ दिखाएँ';

  @override
  String get smsReadTitle => 'बैंक SMS पढ़ें?';

  @override
  String get smsReadBodyShortcuts =>
      'iPhone ऐप SMS नहीं पढ़ सकते, इसलिए Shortcuts ऑटोमेशन हर बैंक मैसेज Expense Manager को देता है। उसे इसी फ़ोन पर पढ़ा जाता है और आपसे पूछा जाता है कि लेन-देन जोड़ना है या नहीं।\n\nकुछ भी कहीं नहीं भेजा जाता। OTP, ऑफ़र और रिमाइंडर छोड़ दिए जाते हैं। आगे, इस स्क्रीन के चरणों से ऑटोमेशन सेट करें।';

  @override
  String get smsReadBody =>
      'बैंक, कार्ड या UPI SMS आने पर Expense Manager उसे इसी फ़ोन पर पढ़ता है और पूछता है कि लेन-देन जोड़ना है या नहीं।\n\nसिर्फ़ वे मैसेज रखे जाते हैं जिनमें डेबिट या क्रेडिट हुई रकम हो, और कुछ भी कहीं नहीं भेजा जाता। OTP, ऑफ़र और रिमाइंडर छोड़ दिए जाते हैं।';

  @override
  String get smsDenied => 'SMS की अनुमति नहीं दी गई। सिस्टम सेटिंग्स में Expense Manager को अनुमति दें।';

  @override
  String get smsNoNotifications => 'नोटिफ़िकेशन ब्लॉक हैं, इसलिए नए खर्च सिर्फ़ यहीं दिखेंगे।';

  @override
  String addedThing(String what) {
    return '$what जोड़ा';
  }

  @override
  String get smsAskToAdd => 'बैंक SMS जोड़ने के लिए पूछें';

  @override
  String get smsAskToAddHelp => 'इसी फ़ोन पर पढ़ा जाता है · कुछ भी अपलोड नहीं होता';

  @override
  String get smsPermissionOff => 'SMS की अनुमति बंद है, इसलिए नए मैसेज नहीं पढ़े जाते।';

  @override
  String get allow => 'अनुमति दें';

  @override
  String get smsNothingToReview => 'जाँचने के लिए कुछ नहीं';

  @override
  String smsToReview(int n) {
    return 'जाँचना है ($n)';
  }

  @override
  String get smsOnHelp => 'नए बैंक और UPI लेन-देन यहाँ और नोटिफ़िकेशन में दिखते हैं।';

  @override
  String get smsOffHelp => 'इसे चालू करें ताकि हर बैंक या UPI लेन-देन का SMS आने पर आपसे पूछा जाए।';

  @override
  String get smsStep1 => 'Shortcuts खोलें → Automation → + (New Automation) → Message।';

  @override
  String smsStep2(String keyword) {
    return 'Message Contains: $keyword। Run Immediately चुनें, फिर Next।';
  }

  @override
  String smsStep3(String action) {
    return 'New Blank Automation → Add Action → \"$action\" (Expense Manager) खोजें।';
  }

  @override
  String get smsStep4 => 'ऐक्शन में Message दबाएँ और Shortcut Input चुनें। Done।';

  @override
  String smsStep5(String first, String second) {
    return 'ज़्यादा बैंकों के लिए \"$first\" और \"$second\" के साथ यही दोहराएँ।';
  }

  @override
  String couldNotOpen(String url) {
    return '$url नहीं खुल सका';
  }

  @override
  String get smsSetupIphone => 'iPhone पर सेटअप';

  @override
  String get smsSetupIphoneHelp => 'iOS ऐप्स को SMS पढ़ने नहीं देता। इसकी जगह एक Shortcuts ऑटोमेशन हर बैंक मैसेज Expense Manager को देता है (iOS 17 या बाद वाला बिना पूछे चलाता है)।';

  @override
  String get smsOpenShortcuts => 'Shortcuts खोलें';

  @override
  String get smsGuide => 'तस्वीरों वाली गाइड';

  @override
  String get sipStopTitle => 'यह SIP रोकें?';

  @override
  String get sipStopBody => 'पहले से दर्ज योगदान इस निवेश में बने रहेंगे।';

  @override
  String get sipStop => 'SIP रोकें';

  @override
  String get sipSetup => 'मासिक SIP सेट करें';

  @override
  String sipSummary(String amount, int day) {
    return 'SIP · हर महीने $day तारीख को $amount';
  }

  @override
  String get paused => 'रुका हुआ';

  @override
  String nextOn(String date) {
    return 'अगला $date';
  }

  @override
  String nextOnFrom(String date, String source) {
    return 'अगला $date · $source';
  }

  @override
  String get sipAuto => 'अपने आप जुड़ता है';

  @override
  String get sipReminderOnly => 'सिर्फ़ रिमाइंडर · भुगतान करने पर दर्ज करें';

  @override
  String get stop => 'रोकें';

  @override
  String get sipMonthly => 'मासिक SIP';

  @override
  String get sipEdit => 'SIP बदलें';

  @override
  String sipAmountField(String symbol) {
    return 'हर महीने की रकम ($symbol)';
  }

  @override
  String get dayOfMonth => 'महीने की तारीख';

  @override
  String get sipAutoOption => 'अपने आप जोड़ें';

  @override
  String get sipAutoOptionHelp => 'हर महीने निवेश लेन-देन दर्ज करता है';

  @override
  String get sipRemindOption => 'सिर्फ़ याद दिलाएँ';

  @override
  String get sipRemindOptionHelp => 'आने वाले में दिखता है; दर्ज आप करते हैं';

  @override
  String get shareLog => 'लॉग शेयर करें';

  @override
  String get clearLog => 'लॉग मिटाएँ';

  @override
  String get logCleared => 'एरर लॉग मिटा दिया';

  @override
  String get noErrors => 'कोई एरर दर्ज नहीं';

  @override
  String get noErrorsHelp => 'क्रैश और एरर सिर्फ़ इसी फ़ोन पर दर्ज होते हैं। बग रिपोर्ट करते समय लॉग शेयर करें।';

  @override
  String reminderOn(String date) {
    return '$date को रिमाइंडर';
  }

  @override
  String get changeDate => 'तारीख बदलें';

  @override
  String get remindMeOn => 'इस दिन याद दिलाएँ';

  @override
  String willRemind(String date) {
    return 'हम आपको $date को याद दिलाएँगे';
  }

  @override
  String get savedTurnOnReminders => 'सेव हुआ। नोटिफ़िकेशन पाने के लिए सेटिंग्स › रिमाइंडर और अलर्ट चालू करें।';

  @override
  String get remindMe => 'याद दिलाएँ';

  @override
  String get locationUnavailable => 'मौजूदा लोकेशन नहीं मिल रही। लोकेशन की अनुमति दें या खोजें।';

  @override
  String get pickLocation => 'जगह चुनें';

  @override
  String get searchPlace => 'कोई जगह या पता खोजें';

  @override
  String get noPlaceMatches => 'कुछ नहीं मिला। कोई दूसरा नाम आज़माएँ या मैप पर टैप करें।';

  @override
  String get placeName => 'जगह का नाम';

  @override
  String get tapMapForPin => 'पिन लगाने के लिए मैप पर टैप करें';

  @override
  String pinWrongLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n कोशिशें बाकी', one: '1 कोशिश बाकी');
    return 'गलत PIN · $_temp0';
  }

  @override
  String get appLocked => 'Expense Manager लॉक है';

  @override
  String get ended => 'खत्म';

  @override
  String get reminderOnly => 'सिर्फ़ रिमाइंडर';

  @override
  String get deleteSchedule => 'यह शेड्यूल हटाएँ?';

  @override
  String get deleteScheduleBody => 'आगे कोई लेन-देन नहीं जुड़ेगा। जो पहले जुड़ चुके हैं वे बने रहेंगे।';

  @override
  String get recurring => 'दोहराए जाने वाले';

  @override
  String get nothingRecurring => 'अभी कुछ भी दोहराया नहीं जाता';

  @override
  String get nothingRecurringHelp => 'लेन-देन जोड़ते समय “दोहराएँ” चालू करें, या किसी निवेश पर SIP सेट करें।';

  @override
  String get deleteRule => 'नियम हटाएँ';

  @override
  String get editSchedule => 'शेड्यूल बदलें';

  @override
  String get onTheDay => 'उसी दिन';

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n दिन पहले', one: '1 दिन पहले');
    return '$_temp0';
  }

  @override
  String get notificationsBlocked => 'नोटिफ़िकेशन ब्लॉक हैं। सिस्टम सेटिंग्स में Expense Manager को अनुमति दें।';

  @override
  String get testSent => 'टेस्ट नोटिफ़िकेशन भेजा';

  @override
  String get notifications => 'नोटिफ़िकेशन';

  @override
  String get notificationsHelp => 'इसी फ़ोन पर तय होते हैं · किसी सर्वर पर कुछ नहीं भेजा जाता';

  @override
  String get fdLeadTitle => 'FD मैच्योर होने से पहले याद दिलाएँ';

  @override
  String remindersInfo(String time) {
    return 'रिमाइंडर लगभग $time पर आते हैं: देय तारीखें एक दिन पहले और उसी दिन, SIP अपनी तारीख पर, और बजट अलर्ट हर बजट के लिए एक बार जब वह 80% और 100% पहुँचे।';
  }

  @override
  String get sendTest => 'टेस्ट नोटिफ़िकेशन भेजें';

  @override
  String get tomorrow => 'कल';

  @override
  String inDays(int n) {
    return '$n दिन में';
  }

  @override
  String get upcomingEmi => 'EMI देय';

  @override
  String get upcomingCard => 'कार्ड बिल देय';

  @override
  String get upcomingMaturity => 'मैच्योरिटी';

  @override
  String get upcomingSip => 'SIP देय';

  @override
  String get upcomingFollowUp => 'फ़ॉलो-अप';

  @override
  String get nothingComingUp => 'कुछ आने वाला नहीं';

  @override
  String get nothingComingUpHelp => 'अगले 60 दिनों की EMI, कार्ड बिल और FD मैच्योरिटी यहाँ दिखती हैं।';

  @override
  String get txnDeleted => 'लेन-देन हटा दिया';

  @override
  String get txnGone => 'यह लेन-देन अब मौजूद नहीं है।';

  @override
  String get transaction => 'लेन-देन';

  @override
  String get dateTime => 'तारीख और समय';

  @override
  String get location => 'जगह';

  @override
  String get coordinates => 'निर्देशांक';

  @override
  String get repeats => 'दोहराव';

  @override
  String get duplicate => 'कॉपी बनाएँ';

  @override
  String get pdfReceipt => 'PDF रसीद';

  @override
  String get open => 'खोलें';

  @override
  String get receiptMissing => 'रसीद की फ़ाइल नहीं मिली';

  @override
  String get keyPlus => 'प्लस';

  @override
  String get keyMinus => 'माइनस';

  @override
  String get keyEquals => 'बराबर';

  @override
  String get keyDecimal => 'दशमलव';

  @override
  String get keyDoubleZero => 'डबल ज़ीरो';

  @override
  String get keyBackspace => 'बैकस्पेस';

  @override
  String allOf(String name) {
    return 'सभी $name';
  }

  @override
  String chartBarLabel(String label, String spent, String invested) {
    return '$label: खर्च $spent, निवेश $invested';
  }

  @override
  String get pinMismatch => 'PIN मेल नहीं खाए। फिर से कोशिश करें।';

  @override
  String encryptFailed(String error) {
    return 'एन्क्रिप्शन नहीं बदल सका: $error';
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
  String get seedFood => 'खाना-पीना';

  @override
  String get seedRent => 'किराया';

  @override
  String get seedShopping => 'खरीदारी';

  @override
  String get seedTransport => 'आवागमन';

  @override
  String get seedBills => 'बिल और यूटिलिटी';

  @override
  String get seedHealth => 'स्वास्थ्य';

  @override
  String get seedEntertainment => 'मनोरंजन';

  @override
  String get seedTravel => 'यात्रा';

  @override
  String get seedOthers => 'अन्य';

  @override
  String get seedFd => 'फ़िक्स्ड डिपॉज़िट';

  @override
  String get seedMutualFunds => 'म्यूचुअल फ़ंड / SIP';

  @override
  String get seedRetirement => 'PPF / EPF / NPS';

  @override
  String get seedSalary => 'वेतन';

  @override
  String get seedOtherIncome => 'अन्य आय';
}
