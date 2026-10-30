// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Expense Manager';

  @override
  String get navHome => 'ホーム';

  @override
  String get navInsights => '分析';

  @override
  String get navInvest => '投資';

  @override
  String get navDebts => '負債';

  @override
  String get addTransaction => '取引を追加';

  @override
  String get ok => 'OK';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get none => 'なし';

  @override
  String get notSet => '未設定';

  @override
  String get on => 'オン';

  @override
  String get off => 'オフ';

  @override
  String get unknown => '不明';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String nActive(int count) {
    return '$count 件有効';
  }

  @override
  String get locationDenied => '位置情報の許可がありません — 場所は手入力できます。';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLocalOnly => 'データはこの端末から出ません。端末内に保存され、サーバーはありません。機種変更時はバックアップを書き出してください。';

  @override
  String get settingsProfile => 'プロフィール';

  @override
  String get settingsName => '名前';

  @override
  String get settingsYourName => 'あなたの名前';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageDevice => '端末の言語';

  @override
  String get settingsDefaults => '既定値';

  @override
  String get settingsDefaultSource => '既定の支払い方法';

  @override
  String get settingsDefaultSourceHelp => '新しい取引で最初に選択されます';

  @override
  String get settingsSources => '支払い方法';

  @override
  String get settingsCategories => 'カテゴリ';

  @override
  String get settingsCategoriesHelp => '未分類の取引は既定のカテゴリに入ります';

  @override
  String settingsDefaultCategory(String name) {
    return '既定：$name';
  }

  @override
  String get settingsCurrency => '通貨';

  @override
  String get settingsCurrencyHelp => '金額の表示だけが変わります。換算はしません。';

  @override
  String get settingsRecurring => '定期的な取引';

  @override
  String get settingsWeekStart => '週の始まり';

  @override
  String get settingsWeekStartHelp => '週ごとの予算と分析の週表示に使われます。';

  @override
  String settingsWeekSpan(String span) {
    return '週ごとの予算と分析の期間：$span';
  }

  @override
  String get settingsData => 'データ';

  @override
  String get settingsExportCsv => 'CSV を書き出す';

  @override
  String get settingsExportCsvHelp => '取引・投資・負債・予算';

  @override
  String get settingsExportPdf => '今月を PDF で書き出す';

  @override
  String get settingsImport => 'CSV または PDF 明細を読み込む';

  @override
  String get settingsImportHelp => 'HDFC・SBI・ICICI など多くの銀行 PDF、または CSV';

  @override
  String get settingsBackUp => '今すぐバックアップ';

  @override
  String get settingsBackUpHelp => '.ledger ファイル 1 つ、パスワードは任意';

  @override
  String get settingsRestore => 'バックアップから復元';

  @override
  String get settingsPrivacyGroup => 'プライバシーと権限';

  @override
  String get settingsLocation => '取引に位置情報を付ける';

  @override
  String get settingsAppLock => 'アプリのロックとプライバシー';

  @override
  String get smsTitle => 'SMS から支出を追加';

  @override
  String get remindersTitle => 'リマインダーと通知';

  @override
  String get settingsAbout => 'このアプリについて';

  @override
  String get settingsVersion => 'バージョン';

  @override
  String get settingsPrivacy => 'プライバシー';

  @override
  String get settingsPrivacyHelp => 'データ収集なし・オフラインで動作';

  @override
  String get settingsPrivacyBody =>
      'Expense Manager にはアカウントもサーバーも分析もありません。入力した内容はすべてこの端末のデータベースに保存され、あなた自身がファイルを書き出したり共有したりしたときだけ外に出ます。\n\n位置情報は許可したときだけ、自分の取引に場所を付けるためにのみ読み取ります。地図を開くと OpenStreetMap から地図タイルを読み込みます。「SMS から支出を追加」をオンにすると、銀行の SMS をこの端末内でのみ読み取ります。';

  @override
  String get settingsReadPolicy => 'ポリシー全文を読む';

  @override
  String get settingsSourceCode => 'GitHub のソースコード';

  @override
  String get settingsLicenses => 'オープンソースライセンス';

  @override
  String get settingsSupport => 'サポート';

  @override
  String get diagnosticsTitle => '診断';

  @override
  String get settingsDiagnosticsHelp => '端末内のエラーログ · 表示・共有・消去';

  @override
  String get settingsReportIssue => '問題を報告';

  @override
  String get settingsReportIssueHelp => 'GitHub の Issue を開きます · GitHub アカウントが必要';

  @override
  String settingsNoBrowser(String url) {
    return '$url を開くブラウザがありません';
  }

  @override
  String get add => '追加';

  @override
  String get edit => '編集';

  @override
  String get clear => 'クリア';

  @override
  String get nothingHere => '何もありません';

  @override
  String get dueToday => '今日が期限';

  @override
  String get dueTomorrow => '明日が期限';

  @override
  String dueInDays(int n) {
    return '$n 日後が期限';
  }

  @override
  String overdueByDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 日超過');
    return '$_temp0';
  }

  @override
  String debtRemindMessage(String person, String amount) {
    return '$person さん、$amount の件でちょっとしたリマインドです。ご都合のよいときで大丈夫です。よろしくお願いします！';
  }

  @override
  String debtRemindMessageFor(String person, String amount, String reason) {
    return '$person さん、$reason の $amount の件でちょっとしたリマインドです。ご都合のよいときで大丈夫です。よろしくお願いします！';
  }

  @override
  String get debtRemindSubject => 'リマインド';

  @override
  String get debtYouOwe => '借りている額';

  @override
  String get debtOwedToYou => '貸している額';

  @override
  String debtMonthlyEmi(String amount) {
    return 'ローン返済 月 $amount';
  }

  @override
  String get debtToCollect => '回収予定';

  @override
  String get debtIOwe => '借り';

  @override
  String get debtOwedToMe => '貸し';

  @override
  String get debtSettled => '完済';

  @override
  String get debtEmpty => 'ローン、クレジットカード、貸し借りしたお金がここに表示されます。';

  @override
  String get debtFooter => 'ここで記録したローン返済やカード支払いは「支出」ではなく「負債」として数えるので、毎月の支出が正確に保たれます。';

  @override
  String debtPayTitle(String name) {
    return '$name を支払いますか？';
  }

  @override
  String debtPayBody(String amount) {
    return '$amount のカード支払いを記録します。「支出」ではなく「負債」として数えます。';
  }

  @override
  String debtPayBodyFrom(String amount, String source) {
    return '$source から $amount のカード支払いを記録します。「支出」ではなく「負債」として数えます。';
  }

  @override
  String debtPayAmount(String amount) {
    return '$amount を支払う';
  }

  @override
  String debtBillMerchant(String name) {
    return '$name の請求';
  }

  @override
  String debtPaymentRecorded(String amount) {
    return '$amount のカード支払いを記録しました';
  }

  @override
  String debtEmi(String amount) {
    return '返済 $amount';
  }

  @override
  String debtDueOn(int day) {
    return '毎月 $day 日期限';
  }

  @override
  String debtLeftOf(String amount) {
    return '$amount のうち残り';
  }

  @override
  String debtStatement(String amount) {
    return '明細 $amount';
  }

  @override
  String debtStatementDue(String amount, String date) {
    return '明細 $amount · 期限 $date';
  }

  @override
  String get debtPaid => '支払い済み';

  @override
  String debtUnpaid(String amount) {
    return '未払い $amount';
  }

  @override
  String debtEmisPaid(int paid, int total) {
    return '$total 回中 $paid 回返済済み';
  }

  @override
  String debtPaymentsRecorded(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 件の支払いを記録');
    return '$_temp0';
  }

  @override
  String get debtReopen => '再開';

  @override
  String get debtSettle => '完済にする';

  @override
  String get debtRemind => 'リマインド';

  @override
  String get debtRecordPayment => '支払いを記録';

  @override
  String get debtRecordRepayment => '返済を記録';

  @override
  String debtPayNow(String amount) {
    return '今すぐ支払う · $amount';
  }

  @override
  String get debtNeedNameAmount => '名前と金額を入力してください';

  @override
  String get debtAddTitle => '負債を追加';

  @override
  String get debtEditTitle => '負債を編集';

  @override
  String get debtKindLoan => 'ローン';

  @override
  String get debtKindCard => 'クレジットカード';

  @override
  String get debtKindPersonal => '個人間';

  @override
  String get debtFieldName => '名前（例：自動車ローン）';

  @override
  String get debtFieldParty => '貸し手 / 相手（任意）';

  @override
  String debtFieldPrincipal(String symbol) {
    return '総額（$symbol）';
  }

  @override
  String get debtFieldRate => '金利 %（任意）';

  @override
  String get debtFieldEmi => '毎月の返済額（任意）';

  @override
  String get debtFieldEmis => '返済回数（任意）';

  @override
  String get debtFieldDueDay => '毎月の期限日（任意）';

  @override
  String debtFieldStatement(String symbol) {
    return '最新の明細額（$symbol、任意）';
  }

  @override
  String get debtStatementDueDate => '明細の支払期限';

  @override
  String debtDueDate(String date) {
    return '期限 $date';
  }

  @override
  String get debtSave => '負債を保存';

  @override
  String get all => 'すべて';

  @override
  String get amount => '金額';

  @override
  String get delete => '削除';

  @override
  String get type => '種類';

  @override
  String get min => '最小';

  @override
  String get max => '最大';

  @override
  String get searchScopeNotes => 'メモ';

  @override
  String get searchScopeMerchant => '店名';

  @override
  String get searchScopePlace => '場所';

  @override
  String get sortNewest => '新しい順';

  @override
  String get sortOldest => '古い順';

  @override
  String get sortAmountDesc => '金額：高い順';

  @override
  String get sortAmountAsc => '金額：低い順';

  @override
  String get transactionsTitle => '取引';

  @override
  String get sort => '並べ替え';

  @override
  String get searchHintAll => '店名・メモ・#タグ・金額で検索…';

  @override
  String get searchHintNotes => 'メモと #タグを検索';

  @override
  String get searchHintMerchant => '店名を検索';

  @override
  String searchHintAmount(String symbol) {
    return '金額ぴったり（例：450 や ${symbol}1,200）';
  }

  @override
  String get searchHintPlace => '場所を検索';

  @override
  String get clearSearch => '検索をクリア';

  @override
  String get filters => 'フィルター';

  @override
  String get allCategories => 'すべてのカテゴリ';

  @override
  String get previousMonth => '前の月';

  @override
  String get nextMonth => '次の月';

  @override
  String get allTime => '全期間';

  @override
  String nTransactions(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 件の取引');
    return '$_temp0';
  }

  @override
  String moneyOut(String amount) {
    return '出金 $amount';
  }

  @override
  String moneyIn(String amount) {
    return '入金 $amount';
  }

  @override
  String noTxnMatch(String query) {
    return '「$query」に一致する取引はありません。';
  }

  @override
  String get noTxnInPeriod => 'この期間の取引はありません。';

  @override
  String get recentSearches => '最近の検索';

  @override
  String get removeRecentSearch => '最近の検索から削除';

  @override
  String get resetAll => 'すべてリセット';

  @override
  String get searchCategories => 'カテゴリを検索';

  @override
  String amountIn(String symbol) {
    return '金額（$symbol）';
  }

  @override
  String get paidVia => '支払い方法';

  @override
  String get applyFilters => 'フィルターを適用';

  @override
  String get txnNeedAmount => '0 より大きい金額を入力してください';

  @override
  String txnTemplateSaved(String name) {
    return '「$name」をテンプレートとして保存しました';
  }

  @override
  String deleteNamed(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get txnTemplateDeleteBody => 'テンプレートは削除されます。作成済みの取引は残ります。';

  @override
  String get txnNeedDebt => 'この支払いがどの負債のものか選んでください';

  @override
  String get txnEditTitle => '取引を編集';

  @override
  String get txnNewTitle => '新しい取引';

  @override
  String get txnSaveTemplate => 'テンプレートとして保存';

  @override
  String get txnReceivedIn => '入金先';

  @override
  String get txnPaidFrom => '支払い元';

  @override
  String get category => 'カテゴリ';

  @override
  String txnCategoryHint(String name) {
    return '迷ったら？既定では「$name」に入ります。';
  }

  @override
  String get txnHolding => '保有資産（任意）';

  @override
  String get txnNotLinked => '関連付けなし';

  @override
  String get txnDebt => '負債';

  @override
  String get txnChooseDebt => '負債を選択';

  @override
  String txnDebtYouPay(String name) {
    return '$name · 支払う';
  }

  @override
  String txnDebtYouReceive(String name) {
    return '$name · 受け取る';
  }

  @override
  String get details => '詳細';

  @override
  String get date => '日付';

  @override
  String get time => '時刻';

  @override
  String get txnMerchant => '店名 / 支払先';

  @override
  String get txnLocation => '場所 · 任意';

  @override
  String get pickOnMap => '地図で選ぶ';

  @override
  String get useCurrentLocation => '現在地を使う';

  @override
  String get txnNote => '理由は？メモを追加（検索可能）';

  @override
  String get txnTags => 'タグ（例：#仕事 #割り勘）';

  @override
  String get receipt => 'レシート';

  @override
  String get receiptCamera => 'カメラ';

  @override
  String get receiptGallery => 'ギャラリー';

  @override
  String get receiptPdf => 'PDF';

  @override
  String get receiptPdfAttached => 'PDF のレシートを添付済み';

  @override
  String get receiptPhotoAttached => 'レシートの写真を添付済み';

  @override
  String get receiptRemove => 'レシートを削除';

  @override
  String get txnRecurringNote => '定期的な取引の一部です。変更はこの 1 件だけに適用されます。定期設定は「設定 › 定期的な取引」で管理します。';

  @override
  String get repeat => '繰り返し';

  @override
  String get txnRepeat => 'この取引を繰り返す';

  @override
  String txnRepeatNext(String frequency, String date) {
    return '$frequency · 次回 $date';
  }

  @override
  String get txnRepeatHelp => 'スケジュールどおりに自動で追加します';

  @override
  String get neverEnds => '終了しない';

  @override
  String endsOn(String date) {
    return '$date に終了';
  }

  @override
  String get clearEndDate => '終了日をクリア';

  @override
  String get saveChanges => '変更を保存';

  @override
  String get txnSave => '取引を保存';

  @override
  String get quickAdd => 'クイック追加';

  @override
  String get continue_ => '続ける';

  @override
  String get done => '完了';

  @override
  String get notNow => '今はしない';

  @override
  String get remove => '削除';

  @override
  String get typeSpend => '支出';

  @override
  String get typeInvest => '投資';

  @override
  String get typeIncome => '収入';

  @override
  String get typeDebt => '負債';

  @override
  String get investKindFd => '定期預金';

  @override
  String get investKindMf => '投資信託';

  @override
  String get investKindStock => '株式';

  @override
  String get investKindGold => '金';

  @override
  String get investKindRetirement => '年金（PPF/EPF/NPS）';

  @override
  String get investKindOther => 'その他';

  @override
  String get reminderTypeBudget => '予算アラート（80% と 100%）';

  @override
  String get reminderTypeDues => 'ローンとカードの支払期限';

  @override
  String get reminderTypeSip => '積立（SIP）のリマインダー';

  @override
  String get reminderTypeMaturity => '定期預金の満期';

  @override
  String get reminderTypeFollowUp => '貸したお金の催促';

  @override
  String get reminderEmiTomorrow => '明日はローン返済日';

  @override
  String get reminderCardTomorrow => '明日はカードの支払日';

  @override
  String get reminderEmiToday => '今日はローン返済日';

  @override
  String get reminderCardToday => '今日はカードの支払日';

  @override
  String get reminderSipToday => '今日は積立日';

  @override
  String reminderSipBody(String title, String amount) {
    return '$title：今日 $amount を積み立てます。';
  }

  @override
  String reminderFdMatures(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 日後に定期預金が満期', one: '明日定期預金が満期', zero: '今日定期預金が満期');
    return '$_temp0';
  }

  @override
  String reminderFdBody(String title, String amount, String date) {
    return '$title（$amount 預け入れ）は $date に満期です。';
  }

  @override
  String reminderFollowUp(String name) {
    return '$name さんに催促';
  }

  @override
  String reminderFollowUpBody(String name, String amount) {
    return '$name さんはまだ $amount を返していません。';
  }

  @override
  String budgetAlertFull(String name) {
    return '$name の予算を使い切りました';
  }

  @override
  String budgetAlert80(String name) {
    return '$name の予算の 80% を使いました';
  }

  @override
  String budgetAlertBody(String used, String limit, String left) {
    return '$limit のうち $used 使用 · $left';
  }

  @override
  String daysLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '残り $n 日');
    return '$_temp0';
  }

  @override
  String get reminderTestTitle => 'リマインダーはオンです';

  @override
  String get reminderTestBody => '予算、支払期限、積立、満期のお知らせがここに届きます。データは端末から出ません。';

  @override
  String get smsAddDetails => '詳細を追加';

  @override
  String get smsIgnore => '無視';

  @override
  String get undo => '元に戻す';

  @override
  String smsAmountFrom(String amount, String name) {
    return '$name から $amount';
  }

  @override
  String smsAmountAt(String amount, String name) {
    return '$name で $amount';
  }

  @override
  String smsAmountInto(String amount, String name) {
    return '$name に $amount';
  }

  @override
  String smsMoneyReceived(String what) {
    return '入金：$what';
  }

  @override
  String smsNewExpense(String what) {
    return '新しい支出：$what';
  }

  @override
  String smsAddTo(String where) {
    return '$where に追加しますか？';
  }

  @override
  String smsIncomeAdded(String what) {
    return '収入を追加：$what';
  }

  @override
  String smsExpenseAdded(String what) {
    return '支出を追加：$what';
  }

  @override
  String get reminderChannelHelp => '予算アラート、支払期限、積立、満期のリマインダー';

  @override
  String get smsChannelHelp => 'SMS から読み取った銀行・UPI の取引を追加する前に確認します';

  @override
  String get unlockPrompt => 'Expense Manager のロックを解除';

  @override
  String get daily => '毎日';

  @override
  String get weekly => '毎週';

  @override
  String get monthly => '毎月';

  @override
  String get yearly => '毎年';

  @override
  String get backupNeedsPassword => 'このバックアップはパスワードで保護されています';

  @override
  String get backupWrongPassword => 'パスワードが違います';

  @override
  String get backupInvalid => 'Expense Manager のバックアップではありません';

  @override
  String get backupDamaged => 'バックアップファイルが壊れています';

  @override
  String get backupTooNew => 'このバックアップは新しいバージョンのアプリで作成されています。先にアプリを更新してください。';

  @override
  String get backupNever => 'バックアップなし';

  @override
  String backupLast(String date) {
    return '最終バックアップ $date';
  }

  @override
  String get importNeedColumns => '日付の列と金額（または出金/入金）の列が必要です';

  @override
  String importInvalidDate(String value) {
    return '無効な日付「$value」';
  }

  @override
  String get importInvalidAmount => '無効な金額';

  @override
  String get investmentsTitle => '投資';

  @override
  String get budgetsTitle => '予算';

  @override
  String get pdfLocked => 'この PDF はパスワードで保護されています。ロックのないコピー（プリント → PDF として保存）を保存して読み込んでください。';

  @override
  String pdfUnreadable(String cause) {
    return 'この PDF を読み取れませんでした（$cause）';
  }

  @override
  String get bankStatement => '銀行明細';

  @override
  String get emi => 'ローン返済';

  @override
  String get cardBill => 'カードの請求';

  @override
  String reminderDueTomorrowBody(String title, String what) {
    return '$title：$what は明日が期限です。';
  }

  @override
  String reminderDueTomorrowAmountBody(String title, String what, String amount) {
    return '$title：$what $amount は明日が期限です。';
  }

  @override
  String reminderDueTodayBody(String title, String what) {
    return '$title：$what は今日が期限です。';
  }

  @override
  String reminderDueTodayAmountBody(String title, String what, String amount) {
    return '$title：$what $amount は今日が期限です。';
  }

  @override
  String exportedOne(String what, String path) {
    return '$what を $path に書き出しました';
  }

  @override
  String exportedMany(int n, String path) {
    return '$n 個のファイルを $path に書き出しました';
  }

  @override
  String get exportHelp => 'Excel や Sheets で開ける UTF-8 ファイルです。複数のファイルは 1 つの zip で共有します。';

  @override
  String exportZip(int n) {
    return '$n 個のファイルを書き出す（zip）';
  }

  @override
  String get export => '書き出す';

  @override
  String get importPreview => '読み込みのプレビュー';

  @override
  String get importPdfEmpty => 'この PDF に取引が見つかりません。ネットバンキングの CSV/Excel 書き出しをお試しください。';

  @override
  String importFound(String bank, int n) {
    return '$bank · $n 件見つかりました';
  }

  @override
  String get backupCreating => 'バックアップを作成中…';

  @override
  String get backupEncrypting => 'バックアップを暗号化中…';

  @override
  String backupSaved(String path) {
    return 'バックアップを $path に保存しました';
  }

  @override
  String get restoring => '復元中…';

  @override
  String restoredN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 件の取引を復元しました');
    return '$_temp0';
  }

  @override
  String addedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 件の取引を追加しました');
    return '$_temp0';
  }

  @override
  String addedNSkipped(int n, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 件の取引を追加しました');
    return '$_temp0 · $skipped 件は既存';
  }

  @override
  String get backupHelp => 'すべてのデータとレシートを含む .ledger ファイル 1 つ。ドライブ、ファイル、パソコンに保存してください。';

  @override
  String get backupProtect => 'パスワードで保護';

  @override
  String get backupPasswordField => 'パスワード（6 文字以上）';

  @override
  String get confirmPassword => 'パスワードの確認';

  @override
  String get backupNoRecovery => 'パスワードを忘れると復元する方法はありません。';

  @override
  String get backUp => 'バックアップ';

  @override
  String get backupPassword => 'バックアップのパスワード';

  @override
  String get password => 'パスワード';

  @override
  String get unlock => 'ロック解除';

  @override
  String get restoreBackup => 'バックアップを復元';

  @override
  String backupMade(String date, String version) {
    return '$date 作成 · アプリ $version';
  }

  @override
  String get merge => '統合';

  @override
  String get replace => '置き換え';

  @override
  String get restoreMergeHelp => 'この端末にないものを追加します。同じカテゴリ、支払い方法、口座は再利用し、既にある取引はスキップします。';

  @override
  String get restoreReplaceHelp => 'この端末のデータをすべて削除し、バックアップの内容を使います。';

  @override
  String get restoreConfirm => '現在のデータが消去されることを理解しました';

  @override
  String get backupReminder => 'バックアップのリマインダー';

  @override
  String get backupBannerNever => 'データはこの端末にしかありません。バックアップを作成しましょう。';

  @override
  String backupBannerDue(String last) {
    return 'バックアップの時期です · $last';
  }

  @override
  String get remindLater => '後で通知';

  @override
  String importedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 件の取引を読み込みました');
    return '$_temp0';
  }

  @override
  String importLine(int n) {
    return '$n 行目';
  }

  @override
  String get importDuplicate => '重複';

  @override
  String importToDefault(String name) {
    return 'カテゴリ → $name';
  }

  @override
  String importNewSub(String name) {
    return '新しいサブカテゴリ：$name';
  }

  @override
  String importN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 件の取引を読み込む');
    return '$_temp0';
  }

  @override
  String get finish => '完了';

  @override
  String get skip => 'スキップ';

  @override
  String get onbWelcomeTitle => 'あなたのお金を、あなたの端末で';

  @override
  String get onbWelcomeBody => '支出、投資、負債をまとめて管理。データはこの端末に保存され、アカウントもサーバーも追跡もありません。';

  @override
  String get onbGetStarted => 'はじめる';

  @override
  String get onbPointLocal => 'この端末にのみ保存';

  @override
  String get onbPointOffline => '完全にオフラインで動作';

  @override
  String get onbPointExport => 'いつでも CSV や PDF に書き出し';

  @override
  String get onbNameTitle => '何とお呼びしましょう？';

  @override
  String get onbNameBody => 'ホーム画面のあいさつにだけ使います。任意です。';

  @override
  String get onbCurrencyTitle => '通貨を選んでください';

  @override
  String get onbCurrencyBody => '金額はこの通貨で表示されます。後で設定から変更できます。';

  @override
  String onbCurrencySample(String currency, String amount) {
    return '$currency · 例：$amount';
  }

  @override
  String get onbSourceTitle => 'どこから支払いますか？';

  @override
  String onbSourceBody(String name) {
    return 'メインの口座を追加してください。新しい取引の既定の支払い方法になります。空欄のままなら $name で始めます。';
  }

  @override
  String get sourceKindCash => '現金';

  @override
  String get sourceNameField => '名前（例：普通預金）';

  @override
  String get optional => '任意';

  @override
  String get onbLocationTitle => '場所を自動で記録しますか？';

  @override
  String get onbLocationBody => '位置情報をオンにすると、新しい取引に今いる場所が付きます。この端末の記録と一緒にだけ保存されます。場所は手入力することもできます。';

  @override
  String get onbLocationContinue => '位置情報なしで続ける';

  @override
  String get onbLocationAllow => '位置情報を許可';

  @override
  String get onbLocationDenied => '許可されませんでした。後で設定からオンにできます。';

  @override
  String get onbSmsTitle => '銀行の SMS から支出を追加しますか？';

  @override
  String get onbSmsBodyShortcuts => 'ショートカットのオートメーションで、銀行・カード・UPI の SMS をアプリに渡せます。この端末内で読み取り、追加するかどうかを通知からワンタップで確認します。設定方法は「設定 › SMS から支出を追加」にあります。';

  @override
  String get onbSmsBody => '銀行・カード・UPI の SMS が届くと、この端末内で読み取り、追加するかどうかを通知からワンタップで確認します。OTP や広告はスキップし、何もアップロードしません。';

  @override
  String get onbSmsContinue => 'SMS なしで続ける';

  @override
  String get turnOn => 'オンにする';

  @override
  String get onbSmsAllow => 'SMS を許可';

  @override
  String get onbSmsDenied => 'SMS の権限が許可されませんでした。後で「設定 › SMS から支出を追加」からオンにできます。';

  @override
  String get onbLockTitle => 'アプリをロックしますか？';

  @override
  String get onbLockBody => 'アプリを開くときに PIN（または指紋 / 顔）を求め、アプリ切り替え画面では金額を隠します。設定からいつでも変更できます。';

  @override
  String get onbLockAction => 'PIN を設定';

  @override
  String get onbRemindersTitle => 'リマインダーを受け取りますか？';

  @override
  String get onbRemindersBody => '予算が 80% や 100% に達したとき、ローンやカードの支払期限の前日、積立日、定期預金の満期前にお知らせします。この端末で計画され、どこにも送信されません。';

  @override
  String get onbRemindersContinue => 'リマインダーなしで続ける';

  @override
  String get onbRemindersAllow => 'リマインダーをオンにする';

  @override
  String get onbRemindersDenied => '通知がブロックされています。後で「設定 › リマインダーと通知」からオンにできます。';

  @override
  String get currencyInr => 'インド・ルピー';

  @override
  String get currencyUsd => '米ドル';

  @override
  String get currencyEur => 'ユーロ';

  @override
  String get currencyGbp => '英ポンド';

  @override
  String get currencyAed => 'UAE ディルハム';

  @override
  String get currencySgd => 'シンガポール・ドル';

  @override
  String get currencyAud => 'オーストラリア・ドル';

  @override
  String get currencyCad => 'カナダ・ドル';

  @override
  String get goodMorning => 'おはようございます';

  @override
  String get goodAfternoon => 'こんにちは';

  @override
  String get goodEvening => 'こんばんは';

  @override
  String get welcome => 'ようこそ';

  @override
  String get reminders => 'リマインダー';

  @override
  String homeSmsReview(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'SMS からの取引 $n 件を確認');
    return '$_temp0';
  }

  @override
  String get homeOutThisMonth => '今月の出金';

  @override
  String homeOutIn(String month) {
    return '$monthの出金';
  }

  @override
  String get invested => '投資額';

  @override
  String homeInvestedThisMonth(String amount) {
    return '今月 +$amount';
  }

  @override
  String homeInvestedIn(String amount, String month) {
    return '$month +$amount';
  }

  @override
  String homeMonthlyEmi(String amount) {
    return '返済 月 $amount';
  }

  @override
  String get comingUp => '今後の予定';

  @override
  String get seeAll => 'すべて表示';

  @override
  String get whereItWent => '使いみち';

  @override
  String get homeNoSpendYet => '今月はまだ支出がありません。';

  @override
  String homeNoSpendIn(String period) {
    return '$period の支出はありません。';
  }

  @override
  String get recent => '最近';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get homeNoTxns => 'まだ取引がありません';

  @override
  String get homeNoTxnsHelp => '+ をタップして最初の支出、投資、収入を追加しましょう。';

  @override
  String homeNothingIn(String period) {
    return '$period は何もありません';
  }

  @override
  String get homeNothingInHelp => 'その月の取引は記録されていません。';

  @override
  String homeOfIncome(String amount) {
    return '収入 $amount のうち';
  }

  @override
  String get spent => '支出';

  @override
  String get left => '残り';

  @override
  String get catKindInvestment => '投資';

  @override
  String catMove(String name) {
    return '$name を移動';
  }

  @override
  String get catTopLevel => '最上位';

  @override
  String catUnder(String name) {
    return '$name の下へ';
  }

  @override
  String get catMoveOnlyLeaf => 'サブカテゴリのないカテゴリだけを別のカテゴリの下に移動できます';

  @override
  String get catDefaultHelp => '既定 — 何も選ばないときに使われます';

  @override
  String get catAddSub => 'サブカテゴリを追加';

  @override
  String get catMoveMenu => '移動…';

  @override
  String get catMoveUnderMenu => '下へ移動…';

  @override
  String catArchive(String name) {
    return '$name をアーカイブ';
  }

  @override
  String catArchived(String name) {
    return '$name をアーカイブしました';
  }

  @override
  String get catAdd => 'カテゴリを追加';

  @override
  String get catSpendHelp => '使ったお金 — 食費、家賃、光熱費など。⋮ をタップしてサブカテゴリを追加。';

  @override
  String get catInvestHelp => '出ていっても資産を増やすお金。';

  @override
  String get catIncomeHelp => '入ってくるお金。';

  @override
  String catArchivedCount(int n) {
    return 'アーカイブ済み（$n）';
  }

  @override
  String get catArchivedHelp => '履歴のために残しています。新しい取引では選べません';

  @override
  String catKindUnder(String kind, String parent) {
    return '$kind · $parent の下';
  }

  @override
  String get restore => '復元';

  @override
  String catRestored(String name) {
    return '$name を復元しました';
  }

  @override
  String get catNew => '新しいカテゴリ';

  @override
  String catNewSub(String name) {
    return '$name の新しいサブカテゴリ';
  }

  @override
  String get immediately => 'すぐに';

  @override
  String seconds(int n) {
    return '$n 秒';
  }

  @override
  String minutes(int n) {
    return '$n 分';
  }

  @override
  String get pinChoose => 'PIN を決めてください';

  @override
  String get pinConfirm => 'PIN をもう一度入力';

  @override
  String get pinDigits => '4〜6 桁の数字を入力';

  @override
  String get pinAgain => '同じ PIN をもう一度入力してください';

  @override
  String pinCooldown(int n) {
    return '試行回数が多すぎます。$n 秒後にもう一度お試しください';
  }

  @override
  String get pinWrong => 'PIN が違います';

  @override
  String get pinCurrent => '現在の PIN を入力';

  @override
  String get lockOn => 'アプリのロックがオンになりました';

  @override
  String get pinChanged => 'PIN を変更しました';

  @override
  String get encryptTitle => 'データベースを暗号化しますか？';

  @override
  String get encryptBody => 'データは、この端末の安全な保存領域にある鍵で暗号化されます。その鍵を失うと（アプリのデータを消去した場合など）データを復元できません — 先にバックアップを書き出してください。';

  @override
  String get encrypt => '暗号化';

  @override
  String get dbEncrypted => 'データベースを暗号化しました';

  @override
  String get dbDecrypted => 'データベースの暗号化を解除しました';

  @override
  String get appLock => 'アプリのロック';

  @override
  String get lockWithPin => 'PIN でロック';

  @override
  String get lockWithPinHelp => 'アプリを開くときに求めます';

  @override
  String get changePin => 'PIN を変更';

  @override
  String get unlockBiometric => '指紋 / 顔でロック解除';

  @override
  String get notAvailableDevice => 'この端末では利用できません';

  @override
  String get lockAgainAfter => 'アプリを離れてから再ロックするまで';

  @override
  String get hideSwitcher => 'アプリ切り替え画面で隠す';

  @override
  String get hideSwitcherHelp => '最近のアプリのプレビューをぼかし、スクリーンショットを禁止します';

  @override
  String get encryption => '暗号化';

  @override
  String get encryptDb => 'データベースを暗号化';

  @override
  String get encryptKeyStored => '鍵は端末の安全な保存領域にあります';

  @override
  String get encryptUnavailable => 'このデータベースでは利用できません';

  @override
  String get budgetNew => '新しい予算';

  @override
  String budgetTabWeekly(String span) {
    return '毎週 · $span';
  }

  @override
  String get budgetTabMonthly => '毎月 · 1 日〜月末';

  @override
  String budgetOverBanner(String name, String amount) {
    return '$name が $amount 超過しています';
  }

  @override
  String get budgetNoneWeekly => '週ごとの予算はありません';

  @override
  String get budgetNoneMonthly => '月ごとの予算はありません';

  @override
  String get budgetEmptyHelp => '好きなカテゴリに上限を設定して、期間ごとに管理しましょう。';

  @override
  String get budgetCreate => '予算を作成';

  @override
  String get budgetGoalReached => '目標達成';

  @override
  String budgetToGoal(String amount) {
    return '目標まであと $amount';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount 超過';
  }

  @override
  String budgetLeft(String amount, String perDay, String days) {
    return '残り $amount · 1 日 $perDay · $days';
  }

  @override
  String get budgetAllInvestments => 'すべての投資';

  @override
  String get budgetAllSpending => 'すべての支出';

  @override
  String nCategories(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n カテゴリ');
    return '$_temp0';
  }

  @override
  String ofAmount(String amount) {
    return '$amount 中';
  }

  @override
  String get budgetNeedNameLimit => '名前と上限を入力してください';

  @override
  String get budgetEdit => '予算を編集';

  @override
  String get budgetDelete => '予算を削除';

  @override
  String get budgetNameField => '名前（例：食費）';

  @override
  String budgetLimitField(String symbol) {
    return '上限（$symbol）';
  }

  @override
  String budgetSuggestion(String amount) {
    return '過去 3 か月の平均は月 $amount です · タップで使用';
  }

  @override
  String get budgetRepeats => '繰り返しの単位';

  @override
  String budgetWeek(String span) {
    return '週（$span）';
  }

  @override
  String get budgetMonth => '月（1 日 → 月末）';

  @override
  String get budgetGoal => '投資目標';

  @override
  String get budgetGoalHelp => '支出の上限ではなく、投資額の目標を管理します';

  @override
  String get budgetCounts => '対象の投資';

  @override
  String get budgetAppliesTo => '対象（空欄 = すべての支出）';

  @override
  String get budgetRollover => '使わなかった分を繰り越す';

  @override
  String get budgetAlert80Switch => '80% で通知';

  @override
  String get budgetAlertOver => '超過したら通知';

  @override
  String get budgetSave => '予算を保存';

  @override
  String get totalInvested => '投資総額';

  @override
  String investThisMonth(String amount, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 件の保有');
    return '今月 +$amount · $_temp0';
  }

  @override
  String get investNoPrices => '投入した金額 · 時価や損益は表示しません';

  @override
  String investMaturesOn(String name, String date) {
    return '$name は $date に満期';
  }

  @override
  String get investNone => 'まだ投資がありません';

  @override
  String get investNoneHelp => '定期預金、積立、株式、金を追加して、投資額を記録しましょう。';

  @override
  String get investAdd => '投資を追加';

  @override
  String investMatures(String date) {
    return '$date 満期';
  }

  @override
  String nEntries(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 件');
    return '$_temp0';
  }

  @override
  String get interestRate => '金利';

  @override
  String investStarted(String date) {
    return '$date 開始';
  }

  @override
  String investMaturesCap(String date) {
    return '$date 満期';
  }

  @override
  String get institution => '金融機関';

  @override
  String get note => 'メモ';

  @override
  String contributions(int n) {
    return '入金履歴（$n）';
  }

  @override
  String get investNoMoney => 'まだ入金がありません。';

  @override
  String get investAddMoney => '入金を追加';

  @override
  String get investMarkMatured => '満期にする';

  @override
  String get investCloseSold => '解約 / 売却';

  @override
  String get investReactivate => '再び有効にする';

  @override
  String get investNeedName => '投資に名前を付けてください';

  @override
  String get investNameField => '名前（例：HDFC 銀行 定期預金）';

  @override
  String get investInstitutionField => '銀行 / サービス（任意）';

  @override
  String get investAmountField => '今の投資額（任意）';

  @override
  String get startDate => '開始日';

  @override
  String get maturityDate => '満期日（任意）';

  @override
  String get investSave => '投資を保存';

  @override
  String get sourceKindBank => '銀行口座';

  @override
  String get sourceKindWallet => 'UPI / ウォレット';

  @override
  String get sourceAdd => '支払い方法を追加';

  @override
  String get sourceDefaultHelp => '新しい取引で毎回最初に選択されます';

  @override
  String sourceOutIn(String kind, String amount, String month) {
    return '$kind · $monthの出金 $amount';
  }

  @override
  String sourceLimit(String amount) {
    return '限度額 $amount';
  }

  @override
  String sourceBalance(String amount) {
    return '残高 $amount';
  }

  @override
  String sourceOutstanding(String amount) {
    return '未払い $amount';
  }

  @override
  String sourceCredit(String amount) {
    return '$amount の貸方残高';
  }

  @override
  String get sourceNew => '新しい支払い方法';

  @override
  String get sourceLast4 => '下 4 桁（任意）';

  @override
  String sourceCreditLimit(String symbol) {
    return '利用限度額（$symbol）';
  }

  @override
  String sourceBalanceHelp(String amount) {
    return '任意 · 既定は $amount';
  }

  @override
  String get makeDefault => '既定にする';

  @override
  String sourceOutstandingField(String symbol) {
    return '現在の未払い額（$symbol）';
  }

  @override
  String sourceBalanceField(String symbol) {
    return '現在の残高（$symbol）';
  }

  @override
  String get sourceAdjustHelp => 'ここから先は追加した取引で調整されます';

  @override
  String get pdfReport => 'PDF レポート';

  @override
  String get week => '週';

  @override
  String get month => '月';

  @override
  String get year => '年';

  @override
  String get previousPeriod => '前の期間';

  @override
  String get nextPeriod => '次の期間';

  @override
  String insightsDonutLabel(String spent, String invested) {
    return '支出 $spent、投資 $invested';
  }

  @override
  String get moneyOutLabel => '出金';

  @override
  String insightsSaved(int n) {
    return '収入の $n% を貯蓄';
  }

  @override
  String get insightsNoEarlier => '以前のデータなし';

  @override
  String insightsLessSpent(int n) {
    return '支出 $n% 減';
  }

  @override
  String insightsMoreSpent(int n) {
    return '支出 $n% 増';
  }

  @override
  String get insightsThanPrevious => '前の期間と比べて';

  @override
  String perDay(String amount) {
    return '1 日 $amount';
  }

  @override
  String get averageSpend => '平均支出';

  @override
  String get monthByMonth => '月ごと';

  @override
  String get weekByWeek => '週ごと';

  @override
  String get dayByDay => '日ごと';

  @override
  String get byCategory => 'カテゴリ別';

  @override
  String get insightsNothing => 'この期間の記録はありません。';

  @override
  String insightsDirect(String name) {
    return '$name（直接）';
  }

  @override
  String insightsCatRow(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 件');
    return '$name  ·  $_temp0';
  }

  @override
  String get hideSubs => 'サブカテゴリを隠す';

  @override
  String get showSubs => 'サブカテゴリを表示';

  @override
  String get smsReadTitle => '銀行の SMS を読み取りますか？';

  @override
  String get smsReadBodyShortcuts =>
      'iPhone のアプリは SMS を読めないため、ショートカットのオートメーションが銀行のメッセージを Expense Manager に渡します。この端末内で読み取り、取引を追加するかどうか確認します。\n\nどこにも送信しません。OTP、広告、リマインダーはスキップします。次に、この画面の手順でオートメーションを設定してください。';

  @override
  String get smsReadBody => '銀行・カード・UPI の SMS が届くと、Expense Manager がこの端末内で読み取り、取引を追加するかどうか確認します。\n\n出金または入金の金額が書かれたメッセージだけを保存し、どこにも送信しません。OTP、広告、リマインダーはスキップします。';

  @override
  String get smsDenied => 'SMS の権限が拒否されました。システム設定で Expense Manager に許可してください。';

  @override
  String get smsNoNotifications => '通知がブロックされているため、新しい支出はここにだけ表示されます。';

  @override
  String addedThing(String what) {
    return '$what を追加しました';
  }

  @override
  String get smsAskToAdd => '銀行の SMS を追加するか確認する';

  @override
  String get smsAskToAddHelp => 'この端末内で読み取り · アップロードなし';

  @override
  String get smsPermissionOff => 'SMS の権限がオフのため、新しいメッセージは読み取られません。';

  @override
  String get allow => '許可';

  @override
  String get smsNothingToReview => '確認するものはありません';

  @override
  String smsToReview(int n) {
    return '確認待ち（$n）';
  }

  @override
  String get smsOnHelp => '新しい銀行・UPI の取引がここと通知に表示されます。';

  @override
  String get smsOffHelp => 'オンにすると、銀行・UPI の取引の SMS が届くたびに確認します。';

  @override
  String get smsStep1 => 'ショートカット → オートメーション → +（新規オートメーション）→ メッセージ を開きます。';

  @override
  String smsStep2(String keyword) {
    return 'メッセージに含む：$keyword。「すぐに実行」を選び、「次へ」。';
  }

  @override
  String smsStep3(String action) {
    return '新規の空のオートメーション → アクションを追加 →「$action」（Expense Manager）を検索。';
  }

  @override
  String get smsStep4 => 'アクション内の「メッセージ」をタップし、「ショートカットの入力」を選んで完了。';

  @override
  String smsStep5(String first, String second) {
    return 'より多くの銀行に対応するため「$first」と「$second」でも同じ設定をします。';
  }

  @override
  String couldNotOpen(String url) {
    return '$url を開けませんでした';
  }

  @override
  String get smsSetupIphone => 'iPhone での設定';

  @override
  String get smsSetupIphoneHelp => 'iOS ではアプリが SMS を読めません。代わりにショートカットのオートメーションが銀行のメッセージを Expense Manager に渡します（iOS 17 以降は確認なしで実行されます）。';

  @override
  String get smsOpenShortcuts => 'ショートカットを開く';

  @override
  String get smsGuide => '画像付きガイド';

  @override
  String get sipStopTitle => 'この積立を停止しますか？';

  @override
  String get sipStopBody => '記録済みの入金はこの投資に残ります。';

  @override
  String get sipStop => '積立を停止';

  @override
  String get sipSetup => '毎月の積立を設定';

  @override
  String sipSummary(String amount, int day) {
    return '積立 · 毎月 $day 日に $amount';
  }

  @override
  String get paused => '一時停止中';

  @override
  String nextOn(String date) {
    return '次回 $date';
  }

  @override
  String nextOnFrom(String date, String source) {
    return '次回 $date · $source';
  }

  @override
  String get sipAuto => '自動で追加';

  @override
  String get sipReminderOnly => 'リマインダーのみ · 支払ったら記録してください';

  @override
  String get stop => '停止';

  @override
  String get sipMonthly => '毎月の積立';

  @override
  String get sipEdit => '積立を編集';

  @override
  String sipAmountField(String symbol) {
    return '毎月の金額（$symbol）';
  }

  @override
  String get dayOfMonth => '毎月の日';

  @override
  String get sipAutoOption => '自動で追加する';

  @override
  String get sipAutoOptionHelp => '毎月、投資の取引を記録します';

  @override
  String get sipRemindOption => 'リマインダーのみ';

  @override
  String get sipRemindOptionHelp => '今後の予定に表示し、記録はご自身で行います';

  @override
  String get shareLog => 'ログを共有';

  @override
  String get clearLog => 'ログを消去';

  @override
  String get logCleared => 'エラーログを消去しました';

  @override
  String get noErrors => 'エラーの記録はありません';

  @override
  String get noErrorsHelp => 'クラッシュやエラーはこの端末にのみ記録されます。不具合を報告するときはログを共有してください。';

  @override
  String reminderOn(String date) {
    return '$date にリマインド';
  }

  @override
  String get changeDate => '日付を変更';

  @override
  String get remindMeOn => 'リマインドする日';

  @override
  String willRemind(String date) {
    return '$date にお知らせします';
  }

  @override
  String get savedTurnOnReminders => '保存しました。通知を受け取るには「設定 › リマインダーと通知」をオンにしてください。';

  @override
  String get remindMe => 'リマインド';

  @override
  String get locationUnavailable => '現在地を取得できません。位置情報を許可するか、検索してください。';

  @override
  String get pickLocation => '場所を選ぶ';

  @override
  String get searchPlace => '場所や住所を検索';

  @override
  String get noPlaceMatches => '見つかりません。別の名前で探すか、地図をタップしてください。';

  @override
  String get placeName => '場所の名前';

  @override
  String get tapMapForPin => '地図をタップしてピンを置きます';

  @override
  String pinWrongLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '残り $n 回');
    return 'PIN が違います · $_temp0';
  }

  @override
  String get appLocked => 'Expense Manager はロックされています';

  @override
  String get ended => '終了';

  @override
  String get reminderOnly => 'リマインダーのみ';

  @override
  String get deleteSchedule => 'このスケジュールを削除しますか？';

  @override
  String get deleteScheduleBody => '今後は取引が追加されません。追加済みの取引は残ります。';

  @override
  String get recurring => '定期';

  @override
  String get nothingRecurring => '定期的な取引はまだありません';

  @override
  String get nothingRecurringHelp => '取引を追加するときに「繰り返し」をオンにするか、投資で積立を設定してください。';

  @override
  String get deleteRule => 'ルールを削除';

  @override
  String get editSchedule => 'スケジュールを編集';

  @override
  String get onTheDay => '当日';

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n 日前');
    return '$_temp0';
  }

  @override
  String get notificationsBlocked => '通知がブロックされています。システム設定で Expense Manager に許可してください。';

  @override
  String get testSent => 'テスト通知を送信しました';

  @override
  String get notifications => '通知';

  @override
  String get notificationsHelp => 'この端末で計画 · サーバーには何も送信しません';

  @override
  String get fdLeadTitle => '定期預金の満期前に知らせる';

  @override
  String remindersInfo(String time) {
    return 'リマインダーは $time 頃に届きます：支払期限は前日と当日、積立はその日、予算アラートは 80% と 100% に達したときに予算ごとに 1 回です。';
  }

  @override
  String get sendTest => 'テスト通知を送信';

  @override
  String get tomorrow => '明日';

  @override
  String inDays(int n) {
    return '$n 日後';
  }

  @override
  String get upcomingEmi => 'ローン返済';

  @override
  String get upcomingCard => 'カードの支払い';

  @override
  String get upcomingMaturity => '満期';

  @override
  String get upcomingSip => '積立';

  @override
  String get upcomingFollowUp => '催促';

  @override
  String get nothingComingUp => '今後の予定はありません';

  @override
  String get nothingComingUpHelp => '今後 60 日間のローン返済、カードの請求、定期預金の満期がここに表示されます。';

  @override
  String get txnDeleted => '取引を削除しました';

  @override
  String get txnGone => 'この取引はもう存在しません。';

  @override
  String get transaction => '取引';

  @override
  String get dateTime => '日時';

  @override
  String get location => '場所';

  @override
  String get coordinates => '座標';

  @override
  String get repeats => '繰り返し';

  @override
  String get duplicate => '複製';

  @override
  String get pdfReceipt => 'PDF のレシート';

  @override
  String get open => '開く';

  @override
  String get receiptMissing => 'レシートのファイルが見つかりません';

  @override
  String get keyPlus => 'プラス';

  @override
  String get keyMinus => 'マイナス';

  @override
  String get keyEquals => 'イコール';

  @override
  String get keyDecimal => '小数点';

  @override
  String get keyDoubleZero => 'ゼロゼロ';

  @override
  String get keyBackspace => '削除';

  @override
  String allOf(String name) {
    return '$nameすべて';
  }

  @override
  String chartBarLabel(String label, String spent, String invested) {
    return '$label：支出 $spent、投資 $invested';
  }

  @override
  String get pinMismatch => 'PIN が一致しません。もう一度お試しください。';

  @override
  String encryptFailed(String error) {
    return '暗号化を変更できませんでした：$error';
  }

  @override
  String get pdfTitle => '支出レポート';

  @override
  String pdfTitleFor(String period) {
    return '支出レポート $period';
  }

  @override
  String get pdfDebtPaid => '負債の支払い';

  @override
  String get pdfSpendByCategory => 'カテゴリ別の支出';

  @override
  String pdfTransactions(int n) {
    return '取引（$n）';
  }

  @override
  String get seedFood => '食費・外食';

  @override
  String get seedRent => '家賃';

  @override
  String get seedShopping => '買い物';

  @override
  String get seedTransport => '交通';

  @override
  String get seedBills => '光熱費・通信費';

  @override
  String get seedHealth => '医療・健康';

  @override
  String get seedEntertainment => '娯楽';

  @override
  String get seedTravel => '旅行';

  @override
  String get seedOthers => 'その他';

  @override
  String get seedFd => '定期預金';

  @override
  String get seedMutualFunds => '投資信託 / 積立';

  @override
  String get seedRetirement => 'PPF / EPF / NPS';

  @override
  String get seedSalary => '給与';

  @override
  String get seedOtherIncome => 'その他の収入';
}
