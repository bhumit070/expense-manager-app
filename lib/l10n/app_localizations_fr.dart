// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Expense Manager';

  @override
  String get navHome => 'Accueil';

  @override
  String get navInsights => 'Analyses';

  @override
  String get navInvest => 'Investir';

  @override
  String get navDebts => 'Dettes';

  @override
  String get addTransaction => 'Ajouter une transaction';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get none => 'Aucun';

  @override
  String get notSet => 'Non défini';

  @override
  String get on => 'Activé';

  @override
  String get off => 'Désactivé';

  @override
  String get unknown => 'Inconnu';

  @override
  String get today => 'Aujourd’hui';

  @override
  String get yesterday => 'Hier';

  @override
  String nActive(int count) {
    return '$count actifs';
  }

  @override
  String get locationDenied => 'Accès à la position refusé — vous pouvez toujours saisir un lieu.';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLocalOnly => 'Vos données ne quittent jamais ce téléphone. Stockées localement, sans serveur. Exportez une sauvegarde pour changer d’appareil.';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsName => 'Nom';

  @override
  String get settingsYourName => 'Votre nom';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageDevice => 'Langue de l’appareil';

  @override
  String get settingsDefaults => 'Par défaut';

  @override
  String get settingsDefaultSource => 'Moyen de paiement par défaut';

  @override
  String get settingsDefaultSourceHelp => 'Présélectionné pour les nouvelles transactions';

  @override
  String get settingsSources => 'Moyens de paiement';

  @override
  String get settingsCategories => 'Catégories';

  @override
  String get settingsCategoriesHelp => 'Les entrées sans catégorie vont dans celle par défaut';

  @override
  String settingsDefaultCategory(String name) {
    return 'Par défaut : $name';
  }

  @override
  String get settingsCurrency => 'Devise';

  @override
  String get settingsCurrencyHelp => 'Change l’affichage des montants. Rien n’est converti.';

  @override
  String get settingsRecurring => 'Transactions récurrentes';

  @override
  String get settingsWeekStart => 'Début de semaine';

  @override
  String get settingsWeekStartHelp => 'Les budgets hebdomadaires et la vue semaine des analyses suivent ce réglage.';

  @override
  String settingsWeekSpan(String span) {
    return 'Budgets et analyses hebdomadaires : $span';
  }

  @override
  String get settingsData => 'Données';

  @override
  String get settingsExportCsv => 'Exporter en CSV';

  @override
  String get settingsExportCsvHelp => 'Transactions, investissements, dettes, budgets';

  @override
  String get settingsExportPdf => 'Exporter ce mois en PDF';

  @override
  String get settingsImport => 'Importer un CSV ou un relevé PDF';

  @override
  String get settingsImportHelp => 'HDFC, SBI, ICICI et la plupart des PDF bancaires, ou un export CSV';

  @override
  String get settingsBackUp => 'Sauvegarder maintenant';

  @override
  String get settingsBackUpHelp => 'Un fichier .ledger, mot de passe facultatif';

  @override
  String get settingsRestore => 'Restaurer une sauvegarde';

  @override
  String get settingsPrivacyGroup => 'Confidentialité et autorisations';

  @override
  String get settingsLocation => 'Position sur les transactions';

  @override
  String get settingsAppLock => 'Verrouillage et confidentialité';

  @override
  String get smsTitle => 'Dépenses depuis les SMS';

  @override
  String get remindersTitle => 'Rappels et alertes';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsPrivacyHelp => 'Aucune donnée collectée · fonctionne hors ligne';

  @override
  String get settingsPrivacyBody =>
      'Expense Manager n’a ni compte, ni serveur, ni statistiques. Tout ce que vous saisissez est stocké dans une base de données sur ce téléphone et n’en sort que lorsque vous exportez ou partagez vous-même un fichier.\n\nLa position n’est lue que si vous l’autorisez, et uniquement pour étiqueter vos propres transactions. Les tuiles de carte sont chargées depuis OpenStreetMap lorsque vous ouvrez une carte. Les SMS bancaires sont lus, sur ce téléphone uniquement, si vous activez Dépenses depuis les SMS.';

  @override
  String get settingsReadPolicy => 'Lire la politique complète';

  @override
  String get settingsSourceCode => 'Code source sur GitHub';

  @override
  String get settingsLicenses => 'Licences open source';

  @override
  String get settingsSupport => 'Assistance';

  @override
  String get diagnosticsTitle => 'Diagnostic';

  @override
  String get settingsDiagnosticsHelp => 'Journal d’erreurs local · afficher, partager ou effacer';

  @override
  String get settingsReportIssue => 'Signaler un problème';

  @override
  String get settingsReportIssueHelp => 'Ouvre un ticket GitHub · nécessite un compte GitHub';

  @override
  String settingsNoBrowser(String url) {
    return 'Aucun navigateur pour ouvrir $url';
  }

  @override
  String get add => 'Ajouter';

  @override
  String get edit => 'Modifier';

  @override
  String get clear => 'Effacer';

  @override
  String get nothingHere => 'Rien ici';

  @override
  String get dueToday => 'À payer aujourd’hui';

  @override
  String get dueTomorrow => 'À payer demain';

  @override
  String dueInDays(int n) {
    return 'À payer dans $n jours';
  }

  @override
  String overdueByDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'En retard de $n jours', one: 'En retard de 1 jour');
    return '$_temp0';
  }

  @override
  String debtRemindMessage(String person, String amount) {
    return 'Bonjour $person, petit rappel amical concernant les $amount. Quand cela vous arrange. Merci !';
  }

  @override
  String debtRemindMessageFor(String person, String amount, String reason) {
    return 'Bonjour $person, petit rappel amical concernant les $amount pour $reason. Quand cela vous arrange. Merci !';
  }

  @override
  String get debtRemindSubject => 'Rappel amical';

  @override
  String get debtYouOwe => 'Vous devez';

  @override
  String get debtOwedToYou => 'On vous doit';

  @override
  String debtMonthlyEmi(String amount) {
    return '$amount/mois de mensualités';
  }

  @override
  String get debtToCollect => 'à récupérer';

  @override
  String get debtIOwe => 'Je dois';

  @override
  String get debtOwedToMe => 'On me doit';

  @override
  String get debtSettled => 'Réglées';

  @override
  String get debtEmpty => 'Les prêts, cartes de crédit et l’argent prêté ou emprunté apparaissent ici.';

  @override
  String get debtFooter => 'Les mensualités et paiements de carte enregistrés ici comptent comme Dette, pas comme Dépense — vos dépenses mensuelles restent justes.';

  @override
  String debtPayTitle(String name) {
    return 'Payer $name ?';
  }

  @override
  String debtPayBody(String amount) {
    return 'Enregistre un paiement de carte de $amount. Il compte comme Dette, pas comme Dépense.';
  }

  @override
  String debtPayBodyFrom(String amount, String source) {
    return 'Enregistre un paiement de carte de $amount depuis $source. Il compte comme Dette, pas comme Dépense.';
  }

  @override
  String debtPayAmount(String amount) {
    return 'Payer $amount';
  }

  @override
  String debtBillMerchant(String name) {
    return 'Facture $name';
  }

  @override
  String debtPaymentRecorded(String amount) {
    return 'Paiement de carte de $amount enregistré';
  }

  @override
  String debtEmi(String amount) {
    return 'Mensualité $amount';
  }

  @override
  String debtDueOn(int day) {
    return 'échéance le $day';
  }

  @override
  String debtLeftOf(String amount) {
    return 'restant sur $amount';
  }

  @override
  String debtStatement(String amount) {
    return 'Relevé $amount';
  }

  @override
  String debtStatementDue(String amount, String date) {
    return 'Relevé $amount · échéance $date';
  }

  @override
  String get debtPaid => 'Payé';

  @override
  String debtUnpaid(String amount) {
    return 'Impayé $amount';
  }

  @override
  String debtEmisPaid(int paid, int total) {
    return '$paid mensualités payées sur $total';
  }

  @override
  String debtPaymentsRecorded(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n paiements enregistrés', one: '1 paiement enregistré');
    return '$_temp0';
  }

  @override
  String get debtReopen => 'Rouvrir';

  @override
  String get debtSettle => 'Régler';

  @override
  String get debtRemind => 'Relancer';

  @override
  String get debtRecordPayment => 'Enregistrer un paiement';

  @override
  String get debtRecordRepayment => 'Enregistrer un remboursement';

  @override
  String debtPayNow(String amount) {
    return 'Payer · $amount';
  }

  @override
  String get debtNeedNameAmount => 'Ajoutez un nom et le montant';

  @override
  String get debtAddTitle => 'Ajouter une dette';

  @override
  String get debtEditTitle => 'Modifier la dette';

  @override
  String get debtKindLoan => 'Prêt';

  @override
  String get debtKindCard => 'Carte de crédit';

  @override
  String get debtKindPersonal => 'Personnel';

  @override
  String get debtFieldName => 'Nom, ex. Prêt auto';

  @override
  String get debtFieldParty => 'Prêteur / personne (facultatif)';

  @override
  String debtFieldPrincipal(String symbol) {
    return 'Montant total ($symbol)';
  }

  @override
  String get debtFieldRate => 'Taux d’intérêt % (facultatif)';

  @override
  String get debtFieldEmi => 'Mensualité (facultatif)';

  @override
  String get debtFieldEmis => 'Nombre de mensualités (facultatif)';

  @override
  String get debtFieldDueDay => 'Jour d’échéance du mois (facultatif)';

  @override
  String debtFieldStatement(String symbol) {
    return 'Total du dernier relevé ($symbol, facultatif)';
  }

  @override
  String get debtStatementDueDate => 'Date d’échéance du relevé';

  @override
  String debtDueDate(String date) {
    return 'Échéance $date';
  }

  @override
  String get debtSave => 'Enregistrer la dette';

  @override
  String get all => 'Tout';

  @override
  String get amount => 'Montant';

  @override
  String get delete => 'Supprimer';

  @override
  String get type => 'Type';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get searchScopeNotes => 'Notes';

  @override
  String get searchScopeMerchant => 'Commerçant';

  @override
  String get searchScopePlace => 'Lieu';

  @override
  String get sortNewest => 'Plus récentes';

  @override
  String get sortOldest => 'Plus anciennes';

  @override
  String get sortAmountDesc => 'Montant : décroissant';

  @override
  String get sortAmountAsc => 'Montant : croissant';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get sort => 'Trier';

  @override
  String get searchHintAll => 'Commerçant, note, #tag, montant…';

  @override
  String get searchHintNotes => 'Rechercher notes et #tags';

  @override
  String get searchHintMerchant => 'Rechercher des commerçants';

  @override
  String searchHintAmount(String symbol) {
    return 'Montant exact, ex. 450 ou ${symbol}1,200';
  }

  @override
  String get searchHintPlace => 'Rechercher des lieux';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get filters => 'Filtres';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get previousMonth => 'Mois précédent';

  @override
  String get nextMonth => 'Mois suivant';

  @override
  String get allTime => 'Depuis le début';

  @override
  String nTransactions(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n transactions', one: '1 transaction');
    return '$_temp0';
  }

  @override
  String moneyOut(String amount) {
    return 'Sorties $amount';
  }

  @override
  String moneyIn(String amount) {
    return 'Entrées $amount';
  }

  @override
  String noTxnMatch(String query) {
    return 'Aucune transaction ne correspond à « $query ».';
  }

  @override
  String get noTxnInPeriod => 'Aucune transaction sur cette période.';

  @override
  String get recentSearches => 'Recherches récentes';

  @override
  String get removeRecentSearch => 'Retirer des recherches récentes';

  @override
  String get resetAll => 'Tout réinitialiser';

  @override
  String get searchCategories => 'Rechercher des catégories';

  @override
  String amountIn(String symbol) {
    return 'Montant ($symbol)';
  }

  @override
  String get paidVia => 'Payé via';

  @override
  String get applyFilters => 'Appliquer les filtres';

  @override
  String get txnNeedAmount => 'Saisissez un montant supérieur à zéro';

  @override
  String txnTemplateSaved(String name) {
    return '« $name » enregistré comme modèle';
  }

  @override
  String deleteNamed(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get txnTemplateDeleteBody => 'Le modèle est supprimé. Les transactions créées avec restent.';

  @override
  String get txnNeedDebt => 'Choisissez la dette concernée par ce paiement';

  @override
  String get txnEditTitle => 'Modifier la transaction';

  @override
  String get txnNewTitle => 'Nouvelle transaction';

  @override
  String get txnSaveTemplate => 'Enregistrer comme modèle';

  @override
  String get txnReceivedIn => 'Reçu sur';

  @override
  String get txnPaidFrom => 'Payé depuis';

  @override
  String get category => 'Catégorie';

  @override
  String txnCategoryHint(String name) {
    return 'Vous hésitez ? Elle va dans « $name » par défaut.';
  }

  @override
  String get txnHolding => 'Placement (facultatif)';

  @override
  String get txnNotLinked => 'Non lié';

  @override
  String get txnDebt => 'Dette';

  @override
  String get txnChooseDebt => 'Choisir une dette';

  @override
  String txnDebtYouPay(String name) {
    return '$name · vous payez';
  }

  @override
  String txnDebtYouReceive(String name) {
    return '$name · vous recevez';
  }

  @override
  String get details => 'Détails';

  @override
  String get date => 'Date';

  @override
  String get time => 'Heure';

  @override
  String get txnMerchant => 'Commerçant / bénéficiaire';

  @override
  String get txnLocation => 'Lieu · facultatif';

  @override
  String get pickOnMap => 'Choisir sur la carte';

  @override
  String get useCurrentLocation => 'Utiliser ma position';

  @override
  String get txnNote => 'Pourquoi ? Ajoutez une note (recherchable)';

  @override
  String get txnTags => 'Tags, ex. #travail #partage';

  @override
  String get receipt => 'Reçu';

  @override
  String get receiptCamera => 'Appareil photo';

  @override
  String get receiptGallery => 'Galerie';

  @override
  String get receiptPdf => 'PDF';

  @override
  String get receiptPdfAttached => 'Reçu PDF joint';

  @override
  String get receiptPhotoAttached => 'Photo du reçu jointe';

  @override
  String get receiptRemove => 'Retirer le reçu';

  @override
  String get txnRecurringNote => 'Fait partie d’une série récurrente. Les modifications ne s’appliquent qu’à celle-ci ; gérez la série dans Paramètres › Récurrentes.';

  @override
  String get repeat => 'Répéter';

  @override
  String get txnRepeat => 'Répéter cette transaction';

  @override
  String txnRepeatNext(String frequency, String date) {
    return '$frequency · prochaine le $date';
  }

  @override
  String get txnRepeatHelp => 'L’ajoute automatiquement selon le calendrier';

  @override
  String get neverEnds => 'Sans fin';

  @override
  String endsOn(String date) {
    return 'Se termine le $date';
  }

  @override
  String get clearEndDate => 'Effacer la date de fin';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get txnSave => 'Enregistrer la transaction';

  @override
  String get quickAdd => 'Ajout rapide';

  @override
  String get continue_ => 'Continuer';

  @override
  String get done => 'Terminé';

  @override
  String get notNow => 'Plus tard';

  @override
  String get remove => 'Retirer';

  @override
  String get typeSpend => 'Dépense';

  @override
  String get typeInvest => 'Investissement';

  @override
  String get typeIncome => 'Revenu';

  @override
  String get typeDebt => 'Dette';

  @override
  String get investKindFd => 'Dépôts à terme';

  @override
  String get investKindMf => 'Fonds communs';

  @override
  String get investKindStock => 'Actions';

  @override
  String get investKindGold => 'Or';

  @override
  String get investKindRetirement => 'Retraite (PPF/EPF/NPS)';

  @override
  String get investKindOther => 'Autre';

  @override
  String get reminderTypeBudget => 'Alertes de budget (80 % et 100 %)';

  @override
  String get reminderTypeDues => 'Échéances de prêts et de cartes';

  @override
  String get reminderTypeSip => 'Rappels de SIP';

  @override
  String get reminderTypeMaturity => 'Échéance des dépôts à terme';

  @override
  String get reminderTypeFollowUp => 'Relances pour l’argent qu’on me doit';

  @override
  String get reminderEmiTomorrow => 'Mensualité demain';

  @override
  String get reminderCardTomorrow => 'Facture de carte demain';

  @override
  String get reminderEmiToday => 'Mensualité aujourd’hui';

  @override
  String get reminderCardToday => 'Facture de carte aujourd’hui';

  @override
  String get reminderSipToday => 'SIP aujourd’hui';

  @override
  String reminderSipBody(String title, String amount) {
    return '$title : investir $amount aujourd’hui.';
  }

  @override
  String reminderFdMatures(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Dépôt à terme échu dans $n jours', one: 'Dépôt à terme échu demain', zero: 'Dépôt à terme échu aujourd’hui');
    return '$_temp0';
  }

  @override
  String reminderFdBody(String title, String amount, String date) {
    return '$title ($amount investis) arrive à échéance le $date.';
  }

  @override
  String reminderFollowUp(String name) {
    return 'Relancer $name';
  }

  @override
  String reminderFollowUpBody(String name, String amount) {
    return '$name vous doit encore $amount.';
  }

  @override
  String budgetAlertFull(String name) {
    return 'Budget $name épuisé';
  }

  @override
  String budgetAlert80(String name) {
    return '80 % du budget $name utilisé';
  }

  @override
  String budgetAlertBody(String used, String limit, String left) {
    return '$used sur $limit dépensés · $left';
  }

  @override
  String daysLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n jours restants', one: '1 jour restant');
    return '$_temp0';
  }

  @override
  String get reminderTestTitle => 'Les rappels sont activés';

  @override
  String get reminderTestBody => 'Vous serez prévenu ici des budgets, échéances, SIP et dépôts arrivant à terme. Rien ne quitte votre téléphone.';

  @override
  String get smsAddDetails => 'Ajouter des détails';

  @override
  String get smsIgnore => 'Ignorer';

  @override
  String get undo => 'Annuler';

  @override
  String smsAmountFrom(String amount, String name) {
    return '$amount de $name';
  }

  @override
  String smsAmountAt(String amount, String name) {
    return '$amount chez $name';
  }

  @override
  String smsAmountInto(String amount, String name) {
    return '$amount sur $name';
  }

  @override
  String smsMoneyReceived(String what) {
    return 'Argent reçu : $what';
  }

  @override
  String smsNewExpense(String what) {
    return 'Nouvelle dépense : $what';
  }

  @override
  String smsAddTo(String where) {
    return 'Ajouter à $where ?';
  }

  @override
  String smsIncomeAdded(String what) {
    return 'Revenu ajouté : $what';
  }

  @override
  String smsExpenseAdded(String what) {
    return 'Dépense ajoutée : $what';
  }

  @override
  String get reminderChannelHelp => 'Alertes de budget, échéances, SIP et dépôts à terme';

  @override
  String get smsChannelHelp => 'Demande avant d’ajouter une transaction bancaire ou UPI lue dans un SMS';

  @override
  String get unlockPrompt => 'Déverrouiller Expense Manager';

  @override
  String get daily => 'Quotidien';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearly => 'Annuel';

  @override
  String get backupNeedsPassword => 'Cette sauvegarde est protégée par mot de passe';

  @override
  String get backupWrongPassword => 'Mot de passe incorrect';

  @override
  String get backupInvalid => 'Ce n’est pas une sauvegarde Expense Manager';

  @override
  String get backupDamaged => 'Le fichier de sauvegarde est endommagé';

  @override
  String get backupTooNew => 'Cette sauvegarde a été créée par une version plus récente de l’application. Mettez d’abord l’application à jour.';

  @override
  String get backupNever => 'Jamais sauvegardé';

  @override
  String backupLast(String date) {
    return 'Dernière sauvegarde $date';
  }

  @override
  String get importNeedColumns => 'Il faut une colonne de date et une colonne de montant (ou débit/crédit)';

  @override
  String importInvalidDate(String value) {
    return 'Date invalide « $value »';
  }

  @override
  String get importInvalidAmount => 'Montant invalide';

  @override
  String get investmentsTitle => 'Investissements';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get pdfLocked => 'Ce PDF est protégé par mot de passe. Enregistrez une copie déverrouillée (Imprimer → Enregistrer en PDF) et importez-la.';

  @override
  String pdfUnreadable(String cause) {
    return 'Impossible de lire ce PDF ($cause)';
  }

  @override
  String get bankStatement => 'Relevé bancaire';

  @override
  String get emi => 'Mensualité';

  @override
  String get cardBill => 'Facture de carte';

  @override
  String reminderDueTomorrowBody(String title, String what) {
    return '$title : $what à payer demain.';
  }

  @override
  String reminderDueTomorrowAmountBody(String title, String what, String amount) {
    return '$title : $what de $amount à payer demain.';
  }

  @override
  String reminderDueTodayBody(String title, String what) {
    return '$title : $what à payer aujourd’hui.';
  }

  @override
  String reminderDueTodayAmountBody(String title, String what, String amount) {
    return '$title : $what de $amount à payer aujourd’hui.';
  }

  @override
  String exportedOne(String what, String path) {
    return '$what exporté vers $path';
  }

  @override
  String exportedMany(int n, String path) {
    return '$n fichiers exportés vers $path';
  }

  @override
  String get exportHelp => 'Fichiers UTF-8 lisibles dans Excel ou Sheets. Plusieurs fichiers sont partagés dans un zip.';

  @override
  String exportZip(int n) {
    return 'Exporter $n fichiers (zip)';
  }

  @override
  String get export => 'Exporter';

  @override
  String get importPreview => 'Aperçu de l’import';

  @override
  String get importPdfEmpty => 'Aucune transaction trouvée dans ce PDF. Essayez l’export CSV/Excel de votre banque en ligne.';

  @override
  String importFound(String bank, int n) {
    return '$bank · $n trouvées';
  }

  @override
  String get backupCreating => 'Création de la sauvegarde…';

  @override
  String get backupEncrypting => 'Chiffrement de la sauvegarde…';

  @override
  String backupSaved(String path) {
    return 'Sauvegarde enregistrée dans $path';
  }

  @override
  String get restoring => 'Restauration…';

  @override
  String restoredN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n transactions restaurées', one: '1 transaction restaurée');
    return '$_temp0';
  }

  @override
  String addedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n transactions ajoutées', one: '1 transaction ajoutée');
    return '$_temp0';
  }

  @override
  String addedNSkipped(int n, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n transactions ajoutées', one: '1 transaction ajoutée');
    return '$_temp0 · $skipped déjà présentes';
  }

  @override
  String get backupHelp => 'Un fichier .ledger avec toutes vos données et vos reçus. Enregistrez-le sur Drive, Fichiers ou un ordinateur.';

  @override
  String get backupProtect => 'Protéger par mot de passe';

  @override
  String get backupPasswordField => 'Mot de passe (6 caractères min.)';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get backupNoRecovery => 'Un mot de passe oublié ne peut pas être récupéré.';

  @override
  String get backUp => 'Sauvegarder';

  @override
  String get backupPassword => 'Mot de passe de la sauvegarde';

  @override
  String get password => 'Mot de passe';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get restoreBackup => 'Restaurer la sauvegarde';

  @override
  String backupMade(String date, String version) {
    return 'Créée le $date · appli $version';
  }

  @override
  String get merge => 'Fusionner';

  @override
  String get replace => 'Remplacer';

  @override
  String get restoreMergeHelp => 'Ajoute ce qui manque sur ce téléphone. Les catégories, moyens de paiement et comptes identiques sont réutilisés ; les transactions déjà présentes sont ignorées.';

  @override
  String get restoreReplaceHelp => 'Supprime tout sur ce téléphone et utilise la sauvegarde à la place.';

  @override
  String get restoreConfirm => 'Je comprends que mes données actuelles seront effacées';

  @override
  String get backupReminder => 'Rappel de sauvegarde';

  @override
  String get backupBannerNever => 'Vos données n’existent que sur ce téléphone. Faites une sauvegarde.';

  @override
  String backupBannerDue(String last) {
    return 'Il est temps de sauvegarder · $last';
  }

  @override
  String get remindLater => 'Me le rappeler plus tard';

  @override
  String importedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n transactions importées', one: '1 transaction importée');
    return '$_temp0';
  }

  @override
  String importLine(int n) {
    return 'Ligne $n';
  }

  @override
  String get importDuplicate => 'Doublon';

  @override
  String importToDefault(String name) {
    return 'Catégorie → $name';
  }

  @override
  String importNewSub(String name) {
    return 'Nouvelle sous-catégorie : $name';
  }

  @override
  String importN(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Importer $n transactions', one: 'Importer 1 transaction');
    return '$_temp0';
  }

  @override
  String get finish => 'Terminer';

  @override
  String get skip => 'Passer';

  @override
  String get onbWelcomeTitle => 'Votre argent, sur votre téléphone';

  @override
  String get onbWelcomeBody => 'Suivez dépenses, investissements et dettes au même endroit. Vos données restent sur ce téléphone. Pas de compte, pas de serveur, pas de pistage.';

  @override
  String get onbGetStarted => 'Commencer';

  @override
  String get onbPointLocal => 'Stocké uniquement sur cet appareil';

  @override
  String get onbPointOffline => 'Fonctionne entièrement hors ligne';

  @override
  String get onbPointExport => 'Export CSV ou PDF à tout moment';

  @override
  String get onbNameTitle => 'Comment doit-on vous appeler ?';

  @override
  String get onbNameBody => 'Utilisé uniquement pour le message d’accueil. Facultatif.';

  @override
  String get onbCurrencyTitle => 'Choisissez votre devise';

  @override
  String get onbCurrencyBody => 'Les montants s’affichent dans cette devise. Vous pourrez la changer dans les Paramètres.';

  @override
  String onbCurrencySample(String currency, String amount) {
    return '$currency · ex. $amount';
  }

  @override
  String get onbSourceTitle => 'Avec quoi payez-vous ?';

  @override
  String onbSourceBody(String name) {
    return 'Ajoutez votre compte principal. Il devient le moyen de paiement par défaut des nouvelles transactions. Laissez vide pour commencer avec $name.';
  }

  @override
  String get sourceKindCash => 'Espèces';

  @override
  String get sourceNameField => 'Nom, ex. Compte courant';

  @override
  String get optional => 'Facultatif';

  @override
  String get onbLocationTitle => 'Enregistrer les lieux automatiquement ?';

  @override
  String get onbLocationBody =>
      'Avec la position activée, les nouvelles transactions reçoivent le lieu où vous êtes. Il est enregistré uniquement avec vos entrées sur ce téléphone. Vous pouvez toujours saisir un lieu à la place.';

  @override
  String get onbLocationContinue => 'Continuer sans la position';

  @override
  String get onbLocationAllow => 'Autoriser la position';

  @override
  String get onbLocationDenied => 'L’autorisation n’a pas été accordée. Vous pourrez l’activer plus tard dans les Paramètres.';

  @override
  String get onbSmsTitle => 'Ajouter les dépenses depuis les SMS bancaires ?';

  @override
  String get onbSmsBodyShortcuts =>
      'Une automatisation Raccourcis peut nous transmettre chaque SMS bancaire, de carte ou UPI ; nous le lisons sur ce téléphone et vous demandons s’il faut l’ajouter — en un geste depuis la notification. Paramètres › Dépenses depuis les SMS explique comment la configurer.';

  @override
  String get onbSmsBody =>
      'Quand un SMS bancaire, de carte ou UPI arrive, nous le lisons sur ce téléphone et vous demandons s’il faut l’ajouter — en un geste depuis la notification. Les codes OTP et les offres sont ignorés, et rien n’est envoyé.';

  @override
  String get onbSmsContinue => 'Continuer sans les SMS';

  @override
  String get turnOn => 'Activer';

  @override
  String get onbSmsAllow => 'Autoriser les SMS';

  @override
  String get onbSmsDenied => 'L’autorisation SMS n’a pas été accordée. Vous pourrez l’activer plus tard dans Paramètres › Dépenses depuis les SMS.';

  @override
  String get onbLockTitle => 'Verrouiller l’application ?';

  @override
  String get onbLockBody => 'Demander un code PIN (ou votre empreinte / visage) à l’ouverture, et masquer les montants dans le sélecteur d’applications. Modifiable à tout moment dans les Paramètres.';

  @override
  String get onbLockAction => 'Définir un PIN';

  @override
  String get onbRemindersTitle => 'Recevoir des rappels ?';

  @override
  String get onbRemindersBody =>
      'Une alerte quand un budget atteint 80 % ou 100 %, la veille d’une mensualité ou d’une facture de carte, aux dates de SIP et avant l’échéance d’un dépôt à terme. Planifié sur ce téléphone ; rien n’est envoyé.';

  @override
  String get onbRemindersContinue => 'Continuer sans rappels';

  @override
  String get onbRemindersAllow => 'Activer les rappels';

  @override
  String get onbRemindersDenied => 'Les notifications sont bloquées. Vous pourrez les activer plus tard dans Paramètres › Rappels et alertes.';

  @override
  String get currencyInr => 'Roupie indienne';

  @override
  String get currencyUsd => 'Dollar américain';

  @override
  String get currencyEur => 'Euro';

  @override
  String get currencyGbp => 'Livre sterling';

  @override
  String get currencyAed => 'Dirham des EAU';

  @override
  String get currencySgd => 'Dollar de Singapour';

  @override
  String get currencyAud => 'Dollar australien';

  @override
  String get currencyCad => 'Dollar canadien';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get reminders => 'Rappels';

  @override
  String homeSmsReview(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n transactions SMS à vérifier', one: '1 transaction SMS à vérifier');
    return '$_temp0';
  }

  @override
  String get homeOutThisMonth => 'Sorties ce mois-ci';

  @override
  String homeOutIn(String month) {
    return 'Sorties en $month';
  }

  @override
  String get invested => 'Investi';

  @override
  String homeInvestedThisMonth(String amount) {
    return '+$amount ce mois-ci';
  }

  @override
  String homeInvestedIn(String amount, String month) {
    return '+$amount en $month';
  }

  @override
  String homeMonthlyEmi(String amount) {
    return '$amount/mois de mensualités';
  }

  @override
  String get comingUp => 'À venir';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get whereItWent => 'Où est passé l’argent';

  @override
  String get homeNoSpendYet => 'Aucune dépense ce mois-ci.';

  @override
  String homeNoSpendIn(String period) {
    return 'Aucune dépense en $period.';
  }

  @override
  String get recent => 'Récentes';

  @override
  String get viewAll => 'Tout afficher';

  @override
  String get homeNoTxns => 'Aucune transaction';

  @override
  String get homeNoTxnsHelp => 'Touchez + pour ajouter votre première dépense, investissement ou revenu.';

  @override
  String homeNothingIn(String period) {
    return 'Rien en $period';
  }

  @override
  String get homeNothingInHelp => 'Aucune transaction enregistrée ce mois-là.';

  @override
  String homeOfIncome(String amount) {
    return 'sur $amount de revenus';
  }

  @override
  String get spent => 'Dépensé';

  @override
  String get left => 'Reste';

  @override
  String get catKindInvestment => 'Investissement';

  @override
  String catMove(String name) {
    return 'Déplacer $name';
  }

  @override
  String get catTopLevel => 'Premier niveau';

  @override
  String catUnder(String name) {
    return 'Sous $name';
  }

  @override
  String get catMoveOnlyLeaf => 'Seules les catégories sans sous-catégories peuvent être déplacées sous une autre';

  @override
  String get catDefaultHelp => 'Par défaut — utilisée quand rien n’est choisi';

  @override
  String get catAddSub => 'Ajouter une sous-catégorie';

  @override
  String get catMoveMenu => 'Déplacer…';

  @override
  String get catMoveUnderMenu => 'Déplacer sous…';

  @override
  String catArchive(String name) {
    return 'Archiver $name';
  }

  @override
  String catArchived(String name) {
    return '$name archivé';
  }

  @override
  String get catAdd => 'Ajouter une catégorie';

  @override
  String get catSpendHelp => 'L’argent dépensé — nourriture, loyer, factures. Touchez ⋮ pour ajouter des sous-catégories.';

  @override
  String get catInvestHelp => 'L’argent sorti qui fait encore grandir votre patrimoine.';

  @override
  String get catIncomeHelp => 'L’argent qui rentre.';

  @override
  String catArchivedCount(int n) {
    return 'Archivées ($n)';
  }

  @override
  String get catArchivedHelp => 'Conservées pour l’historique ; non proposées pour les nouvelles transactions';

  @override
  String catKindUnder(String kind, String parent) {
    return '$kind · sous $parent';
  }

  @override
  String get restore => 'Restaurer';

  @override
  String catRestored(String name) {
    return '$name restauré';
  }

  @override
  String get catNew => 'Nouvelle catégorie';

  @override
  String catNewSub(String name) {
    return 'Nouvelle sous-catégorie dans $name';
  }

  @override
  String get immediately => 'Immédiatement';

  @override
  String seconds(int n) {
    return '$n s';
  }

  @override
  String minutes(int n) {
    return '$n min';
  }

  @override
  String get pinChoose => 'Choisissez un PIN';

  @override
  String get pinConfirm => 'Confirmez votre PIN';

  @override
  String get pinDigits => 'Saisissez 4 à 6 chiffres';

  @override
  String get pinAgain => 'Saisissez à nouveau le même PIN';

  @override
  String pinCooldown(int n) {
    return 'Trop de tentatives. Réessayez dans $n s';
  }

  @override
  String get pinWrong => 'PIN incorrect';

  @override
  String get pinCurrent => 'Saisissez votre PIN actuel';

  @override
  String get lockOn => 'Le verrouillage est activé';

  @override
  String get pinChanged => 'PIN modifié';

  @override
  String get encryptTitle => 'Chiffrer la base de données ?';

  @override
  String get encryptBody =>
      'Vos données seront chiffrées avec une clé conservée dans le stockage sécurisé de ce téléphone. Si cette clé est perdue (par exemple si les données de l’appli sont effacées), les données ne pourront pas être récupérées — exportez d’abord une sauvegarde.';

  @override
  String get encrypt => 'Chiffrer';

  @override
  String get dbEncrypted => 'Base de données chiffrée';

  @override
  String get dbDecrypted => 'Base de données déchiffrée';

  @override
  String get appLock => 'Verrouillage';

  @override
  String get lockWithPin => 'Verrouiller avec un PIN';

  @override
  String get lockWithPinHelp => 'Demandé à l’ouverture de l’application';

  @override
  String get changePin => 'Changer le PIN';

  @override
  String get unlockBiometric => 'Déverrouiller par empreinte / visage';

  @override
  String get notAvailableDevice => 'Non disponible sur cet appareil';

  @override
  String get lockAgainAfter => 'Verrouiller à nouveau après avoir quitté l’application';

  @override
  String get hideSwitcher => 'Masquer dans le sélecteur d’applications';

  @override
  String get hideSwitcherHelp => 'Floute l’aperçu des applications récentes et bloque les captures d’écran';

  @override
  String get encryption => 'Chiffrement';

  @override
  String get encryptDb => 'Chiffrer la base de données';

  @override
  String get encryptKeyStored => 'Clé conservée dans le stockage sécurisé du téléphone';

  @override
  String get encryptUnavailable => 'Non disponible pour cette base de données';

  @override
  String get budgetNew => 'Nouveau budget';

  @override
  String budgetTabWeekly(String span) {
    return 'Hebdomadaire · $span';
  }

  @override
  String get budgetTabMonthly => 'Mensuel · du 1er à la fin';

  @override
  String budgetOverBanner(String name, String amount) {
    return '$name est dépassé de $amount';
  }

  @override
  String get budgetNoneWeekly => 'Aucun budget hebdomadaire';

  @override
  String get budgetNoneMonthly => 'Aucun budget mensuel';

  @override
  String get budgetEmptyHelp => 'Fixez une limite pour n’importe quelle catégorie et suivez-la à chaque cycle.';

  @override
  String get budgetCreate => 'Créer un budget';

  @override
  String get budgetGoalReached => 'Objectif atteint';

  @override
  String budgetToGoal(String amount) {
    return '$amount avant l’objectif';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Dépassé de $amount';
  }

  @override
  String budgetLeft(String amount, String perDay, String days) {
    return '$amount restants · $perDay/jour · $days';
  }

  @override
  String get budgetAllInvestments => 'Tous les investissements';

  @override
  String get budgetAllSpending => 'Toutes les dépenses';

  @override
  String nCategories(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n catégories', one: '1 catégorie');
    return '$_temp0';
  }

  @override
  String ofAmount(String amount) {
    return 'sur $amount';
  }

  @override
  String get budgetNeedNameLimit => 'Ajoutez un nom et une limite';

  @override
  String get budgetEdit => 'Modifier le budget';

  @override
  String get budgetDelete => 'Supprimer le budget';

  @override
  String get budgetNameField => 'Nom, ex. Alimentation';

  @override
  String budgetLimitField(String symbol) {
    return 'Limite ($symbol)';
  }

  @override
  String budgetSuggestion(String amount) {
    return 'Moyenne de $amount/mois sur les 3 derniers mois · touchez pour l’utiliser';
  }

  @override
  String get budgetRepeats => 'Se répète chaque';

  @override
  String budgetWeek(String span) {
    return 'Semaine ($span)';
  }

  @override
  String get budgetMonth => 'Mois (du 1er à la fin)';

  @override
  String get budgetGoal => 'Objectif d’investissement';

  @override
  String get budgetGoalHelp => 'Suivez un objectif d’argent investi au lieu d’un plafond de dépenses';

  @override
  String get budgetCounts => 'Compte ces investissements';

  @override
  String get budgetAppliesTo => 'S’applique à (vide = toutes les dépenses)';

  @override
  String get budgetRollover => 'Reporter le montant non dépensé';

  @override
  String get budgetAlert80Switch => 'Alerte à 80 %';

  @override
  String get budgetAlertOver => 'Alerte en cas de dépassement';

  @override
  String get budgetSave => 'Enregistrer le budget';

  @override
  String get totalInvested => 'Total investi';

  @override
  String investThisMonth(String amount, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n placements', one: '1 placement');
    return '+$amount ce mois-ci · $_temp0';
  }

  @override
  String get investNoPrices => 'Montants versés · pas de cours ni de rendement en direct';

  @override
  String investMaturesOn(String name, String date) {
    return '$name arrive à échéance le $date';
  }

  @override
  String get investNone => 'Aucun investissement';

  @override
  String get investNoneHelp => 'Ajoutez un dépôt à terme, un SIP, des actions ou de l’or pour suivre ce que vous investissez.';

  @override
  String get investAdd => 'Ajouter un investissement';

  @override
  String investMatures(String date) {
    return 'échéance $date';
  }

  @override
  String nEntries(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n entrées', one: '1 entrée');
    return '$_temp0';
  }

  @override
  String get interestRate => 'Taux d’intérêt';

  @override
  String investStarted(String date) {
    return 'Débuté le $date';
  }

  @override
  String investMaturesCap(String date) {
    return 'Échéance $date';
  }

  @override
  String get institution => 'Établissement';

  @override
  String get note => 'Note';

  @override
  String contributions(int n) {
    return 'Versements ($n)';
  }

  @override
  String get investNoMoney => 'Aucun versement pour l’instant.';

  @override
  String get investAddMoney => 'Ajouter de l’argent';

  @override
  String get investMarkMatured => 'Marquer comme échu';

  @override
  String get investCloseSold => 'Clôturer / vendu';

  @override
  String get investReactivate => 'Marquer à nouveau actif';

  @override
  String get investNeedName => 'Donnez un nom à l’investissement';

  @override
  String get investNameField => 'Nom, ex. Dépôt à terme HDFC';

  @override
  String get investInstitutionField => 'Banque / plateforme (facultatif)';

  @override
  String get investAmountField => 'Montant investi maintenant (facultatif)';

  @override
  String get startDate => 'Date de début';

  @override
  String get maturityDate => 'Date d’échéance (facultatif)';

  @override
  String get investSave => 'Enregistrer l’investissement';

  @override
  String get sourceKindBank => 'Compte bancaire';

  @override
  String get sourceKindWallet => 'UPI / portefeuille';

  @override
  String get sourceAdd => 'Ajouter un moyen de paiement';

  @override
  String get sourceDefaultHelp => 'Présélectionné pour chaque nouvelle transaction';

  @override
  String sourceOutIn(String kind, String amount, String month) {
    return '$kind · $amount sortis en $month';
  }

  @override
  String sourceLimit(String amount) {
    return 'plafond $amount';
  }

  @override
  String sourceBalance(String amount) {
    return 'Solde $amount';
  }

  @override
  String sourceOutstanding(String amount) {
    return '$amount à rembourser';
  }

  @override
  String sourceCredit(String amount) {
    return '$amount de crédit';
  }

  @override
  String get sourceNew => 'Nouveau moyen de paiement';

  @override
  String get sourceLast4 => '4 derniers chiffres (facultatif)';

  @override
  String sourceCreditLimit(String symbol) {
    return 'Plafond de crédit ($symbol)';
  }

  @override
  String sourceBalanceHelp(String amount) {
    return 'Facultatif · $amount par défaut';
  }

  @override
  String get makeDefault => 'Définir par défaut';

  @override
  String sourceOutstandingField(String symbol) {
    return 'Encours actuel ($symbol)';
  }

  @override
  String sourceBalanceField(String symbol) {
    return 'Solde actuel ($symbol)';
  }

  @override
  String get sourceAdjustHelp => 'Les transactions ajoutées l’ajusteront à partir d’ici';

  @override
  String get pdfReport => 'Rapport PDF';

  @override
  String get week => 'Semaine';

  @override
  String get month => 'Mois';

  @override
  String get year => 'Année';

  @override
  String get previousPeriod => 'Période précédente';

  @override
  String get nextPeriod => 'Période suivante';

  @override
  String insightsDonutLabel(String spent, String invested) {
    return 'Dépensé $spent, investi $invested';
  }

  @override
  String get moneyOutLabel => 'Sorties';

  @override
  String insightsSaved(int n) {
    return '$n % des revenus épargnés';
  }

  @override
  String get insightsNoEarlier => 'Pas de données antérieures';

  @override
  String insightsLessSpent(int n) {
    return '$n % de dépenses en moins';
  }

  @override
  String insightsMoreSpent(int n) {
    return '$n % de dépenses en plus';
  }

  @override
  String get insightsThanPrevious => 'que la période précédente';

  @override
  String perDay(String amount) {
    return '$amount / jour';
  }

  @override
  String get averageSpend => 'dépense moyenne';

  @override
  String get monthByMonth => 'Mois par mois';

  @override
  String get weekByWeek => 'Semaine par semaine';

  @override
  String get dayByDay => 'Jour par jour';

  @override
  String get byCategory => 'Par catégorie';

  @override
  String get insightsNothing => 'Rien d’enregistré sur cette période.';

  @override
  String insightsDirect(String name) {
    return '$name (direct)';
  }

  @override
  String insightsCatRow(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n transactions', one: '1 transaction');
    return '$name  ·  $_temp0';
  }

  @override
  String get hideSubs => 'Masquer les sous-catégories';

  @override
  String get showSubs => 'Afficher les sous-catégories';

  @override
  String get smsReadTitle => 'Lire les SMS bancaires ?';

  @override
  String get smsReadBodyShortcuts =>
      'Les applis iPhone ne peuvent pas lire les SMS : une automatisation Raccourcis transmet donc chaque message bancaire à Expense Manager. Il est lu sur ce téléphone et l’appli vous demande s’il faut ajouter la transaction.\n\nRien n’est envoyé. Les codes OTP, offres et rappels sont ignorés. Ensuite, configurez l’automatisation en suivant les étapes de cet écran.';

  @override
  String get smsReadBody =>
      'Quand un SMS bancaire, de carte ou UPI arrive, Expense Manager le lit sur ce téléphone et vous demande s’il faut ajouter la transaction.\n\nSeuls les messages indiquant un montant débité ou crédité sont conservés, et rien n’est envoyé. Les codes OTP, offres et rappels sont ignorés.';

  @override
  String get smsDenied => 'L’autorisation SMS a été refusée. Autorisez-la pour Expense Manager dans les réglages du système.';

  @override
  String get smsNoNotifications => 'Les notifications sont bloquées : les nouvelles dépenses n’apparaîtront qu’ici.';

  @override
  String addedThing(String what) {
    return 'Ajouté : $what';
  }

  @override
  String get smsAskToAdd => 'Proposer d’ajouter les SMS bancaires';

  @override
  String get smsAskToAddHelp => 'Lus sur ce téléphone · rien n’est envoyé';

  @override
  String get smsPermissionOff => 'L’autorisation SMS est désactivée : les nouveaux messages ne sont pas lus.';

  @override
  String get allow => 'Autoriser';

  @override
  String get smsNothingToReview => 'Rien à vérifier';

  @override
  String smsToReview(int n) {
    return 'À vérifier ($n)';
  }

  @override
  String get smsOnHelp => 'Les nouvelles transactions bancaires et UPI apparaissent ici et en notification.';

  @override
  String get smsOffHelp => 'Activez cette option pour être sollicité à chaque SMS de transaction bancaire ou UPI.';

  @override
  String get smsStep1 => 'Ouvrez Raccourcis → Automatisation → + (Nouvelle automatisation) → Message.';

  @override
  String smsStep2(String keyword) {
    return 'Le message contient : $keyword. Choisissez Exécuter immédiatement, puis Suivant.';
  }

  @override
  String smsStep3(String action) {
    return 'Nouvelle automatisation vierge → Ajouter une action → recherchez « $action » (Expense Manager).';
  }

  @override
  String get smsStep4 => 'Touchez Message dans l’action et choisissez Entrée du raccourci. Terminé.';

  @override
  String smsStep5(String first, String second) {
    return 'Répétez avec « $first » et « $second » pour couvrir plus de banques.';
  }

  @override
  String couldNotOpen(String url) {
    return 'Impossible d’ouvrir $url';
  }

  @override
  String get smsSetupIphone => 'Configuration sur iPhone';

  @override
  String get smsSetupIphoneHelp =>
      'iOS ne permet pas aux applis de lire les SMS. Une automatisation Raccourcis transmet donc chaque message bancaire à Expense Manager (iOS 17 ou ultérieur l’exécute sans demander).';

  @override
  String get smsOpenShortcuts => 'Ouvrir Raccourcis';

  @override
  String get smsGuide => 'Guide illustré';

  @override
  String get sipStopTitle => 'Arrêter ce SIP ?';

  @override
  String get sipStopBody => 'Les versements déjà enregistrés restent sur cet investissement.';

  @override
  String get sipStop => 'Arrêter le SIP';

  @override
  String get sipSetup => 'Mettre en place un SIP mensuel';

  @override
  String sipSummary(String amount, int day) {
    return 'SIP · $amount le $day du mois';
  }

  @override
  String get paused => 'En pause';

  @override
  String nextOn(String date) {
    return 'Prochain le $date';
  }

  @override
  String nextOnFrom(String date, String source) {
    return 'Prochain le $date · $source';
  }

  @override
  String get sipAuto => 'Ajouté automatiquement';

  @override
  String get sipReminderOnly => 'Rappel uniquement · enregistrez-le en payant';

  @override
  String get stop => 'Arrêter';

  @override
  String get sipMonthly => 'SIP mensuel';

  @override
  String get sipEdit => 'Modifier le SIP';

  @override
  String sipAmountField(String symbol) {
    return 'Montant par mois ($symbol)';
  }

  @override
  String get dayOfMonth => 'Jour du mois';

  @override
  String get sipAutoOption => 'L’ajouter automatiquement';

  @override
  String get sipAutoOptionHelp => 'Enregistre l’investissement chaque mois';

  @override
  String get sipRemindOption => 'Me le rappeler seulement';

  @override
  String get sipRemindOptionHelp => 'Il apparaît dans À venir ; vous l’enregistrez';

  @override
  String get shareLog => 'Partager le journal';

  @override
  String get clearLog => 'Effacer le journal';

  @override
  String get logCleared => 'Journal d’erreurs effacé';

  @override
  String get noErrors => 'Aucune erreur enregistrée';

  @override
  String get noErrorsHelp => 'Les plantages et erreurs sont consignés sur ce téléphone uniquement. Partagez le journal si vous signalez un bug.';

  @override
  String reminderOn(String date) {
    return 'Rappel le $date';
  }

  @override
  String get changeDate => 'Changer la date';

  @override
  String get remindMeOn => 'Me le rappeler le';

  @override
  String willRemind(String date) {
    return 'Nous vous le rappellerons le $date';
  }

  @override
  String get savedTurnOnReminders => 'Enregistré. Activez Paramètres › Rappels et alertes pour recevoir une notification.';

  @override
  String get remindMe => 'Me le rappeler';

  @override
  String get locationUnavailable => 'Position actuelle indisponible. Autorisez l’accès à la position ou faites une recherche.';

  @override
  String get pickLocation => 'Choisir un lieu';

  @override
  String get searchPlace => 'Rechercher un lieu ou une adresse';

  @override
  String get noPlaceMatches => 'Aucun résultat. Essayez un autre nom ou touchez la carte.';

  @override
  String get placeName => 'Nom du lieu';

  @override
  String get tapMapForPin => 'Touchez la carte pour placer un repère';

  @override
  String pinWrongLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n tentatives restantes', one: '1 tentative restante');
    return 'PIN incorrect · $_temp0';
  }

  @override
  String get appLocked => 'Expense Manager est verrouillé';

  @override
  String get ended => 'Terminée';

  @override
  String get reminderOnly => 'rappel uniquement';

  @override
  String get deleteSchedule => 'Supprimer cette planification ?';

  @override
  String get deleteScheduleBody => 'Aucune nouvelle transaction ne sera ajoutée. Celles déjà ajoutées restent.';

  @override
  String get recurring => 'Récurrentes';

  @override
  String get nothingRecurring => 'Aucune récurrence';

  @override
  String get nothingRecurringHelp => 'Activez « Répéter » en ajoutant une transaction, ou mettez en place un SIP sur un investissement.';

  @override
  String get deleteRule => 'Supprimer la règle';

  @override
  String get editSchedule => 'Modifier la planification';

  @override
  String get onTheDay => 'Le jour même';

  @override
  String daysBefore(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n jours avant', one: '1 jour avant');
    return '$_temp0';
  }

  @override
  String get notificationsBlocked => 'Les notifications sont bloquées. Autorisez-les pour Expense Manager dans les réglages du système.';

  @override
  String get testSent => 'Notification de test envoyée';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsHelp => 'Planifiées sur ce téléphone · rien n’est envoyé à un serveur';

  @override
  String get fdLeadTitle => 'Me prévenir avant l’échéance d’un dépôt à terme';

  @override
  String remindersInfo(String time) {
    return 'Les rappels arrivent vers $time : les échéances la veille et le jour même, les SIP à leur date, et les alertes de budget une fois par budget à 80 % et 100 %.';
  }

  @override
  String get sendTest => 'Envoyer une notification de test';

  @override
  String get tomorrow => 'Demain';

  @override
  String inDays(int n) {
    return 'dans $n jours';
  }

  @override
  String get upcomingEmi => 'Mensualité';

  @override
  String get upcomingCard => 'Facture de carte';

  @override
  String get upcomingMaturity => 'Échéance';

  @override
  String get upcomingSip => 'SIP';

  @override
  String get upcomingFollowUp => 'Relance';

  @override
  String get nothingComingUp => 'Rien à venir';

  @override
  String get nothingComingUpHelp => 'Les mensualités, factures de carte et échéances de dépôts des 60 prochains jours apparaissent ici.';

  @override
  String get txnDeleted => 'Transaction supprimée';

  @override
  String get txnGone => 'Cette transaction n’existe plus.';

  @override
  String get transaction => 'Transaction';

  @override
  String get dateTime => 'Date et heure';

  @override
  String get location => 'Lieu';

  @override
  String get coordinates => 'Coordonnées';

  @override
  String get repeats => 'Répétition';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String get pdfReceipt => 'Reçu PDF';

  @override
  String get open => 'Ouvrir';

  @override
  String get receiptMissing => 'Fichier du reçu introuvable';

  @override
  String get keyPlus => 'Plus';

  @override
  String get keyMinus => 'Moins';

  @override
  String get keyEquals => 'Égal';

  @override
  String get keyDecimal => 'Virgule';

  @override
  String get keyDoubleZero => 'Double zéro';

  @override
  String get keyBackspace => 'Effacer';

  @override
  String allOf(String name) {
    return 'Tout $name';
  }

  @override
  String chartBarLabel(String label, String spent, String invested) {
    return '$label : dépensé $spent, investi $invested';
  }

  @override
  String get pinMismatch => 'Les PIN ne correspondent pas. Réessayez.';

  @override
  String encryptFailed(String error) {
    return 'Impossible de modifier le chiffrement : $error';
  }

  @override
  String get pdfTitle => 'Rapport de dépenses';

  @override
  String pdfTitleFor(String period) {
    return 'Rapport de dépenses $period';
  }

  @override
  String get pdfDebtPaid => 'Dettes payées';

  @override
  String get pdfSpendByCategory => 'Dépenses par catégorie';

  @override
  String pdfTransactions(int n) {
    return 'Transactions ($n)';
  }

  @override
  String get seedFood => 'Alimentation et restaurants';

  @override
  String get seedRent => 'Loyer';

  @override
  String get seedShopping => 'Achats';

  @override
  String get seedTransport => 'Transport';

  @override
  String get seedBills => 'Factures et charges';

  @override
  String get seedHealth => 'Santé';

  @override
  String get seedEntertainment => 'Loisirs';

  @override
  String get seedTravel => 'Voyages';

  @override
  String get seedOthers => 'Autres';

  @override
  String get seedFd => 'Dépôt à terme';

  @override
  String get seedMutualFunds => 'Fonds communs / SIP';

  @override
  String get seedRetirement => 'PPF / EPF / NPS';

  @override
  String get seedSalary => 'Salaire';

  @override
  String get seedOtherIncome => 'Autres revenus';
}
