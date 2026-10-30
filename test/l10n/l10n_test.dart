import 'dart:convert';
import 'dart:io';

import 'package:expense_manager/app.dart';
import 'package:expense_manager/core/dates.dart';
import 'package:expense_manager/core/money.dart';
import 'package:expense_manager/data/database.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/l10n/app_localizations_en.dart';
import 'package:expense_manager/l10n/l10n.dart';
import 'package:expense_manager/services/pdf_report.dart';
import 'package:expense_manager/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' show Intl;

import '../helpers.dart';

/// Placeholder names used in an ARB message, ignoring plural branch bodies.
Set<String> placeholders(String message) => {for (final m in RegExp(r'(?<![=\w])\{(\w+)[,}]').allMatches(message)) m[1]!};

void main() {
  tearDown(() => applyLocale(const Locale('en')));

  test('every offered language has a complete ARB with the same placeholders', () {
    Map<String, dynamic> arb(String code) => jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map<String, dynamic>;
    final en = arb('en');
    final keys = en.keys.where((k) => !k.startsWith('@')).toSet();
    expect(appLanguages.map((l) => l.code), ['en', 'fr', 'ja', 'hi', 'gu', 'or']);
    for (final lang in appLanguages.skip(1)) {
      final tr = arb(lang.code);
      expect(tr['@@locale'], lang.code);
      expect(tr.keys.where((k) => !k.startsWith('@')).toSet(), keys, reason: lang.code);
      for (final k in keys) {
        expect(placeholders(tr[k] as String), placeholders(en[k] as String), reason: '${lang.code}.$k');
        expect((tr[k] as String).contains('plural,'), (en[k] as String).contains('plural,'), reason: '${lang.code}.$k');
      }
    }
  });

  test('the delegate supports exactly the offered languages', () {
    expect(AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(), appLanguages.map((l) => l.code).toSet());
    expect(AppLocalizations.delegate.isSupported(const Locale('en', 'IN')), isTrue);
    expect(AppLocalizations.delegate.isSupported(const Locale('de')), isFalse);
    expect(AppLocalizations.delegate.shouldReload(AppLocalizations.delegate), isFalse);
    expect(lookupAppLocalizations(const Locale('hi')).navHome, 'होम');
    expect(() => lookupAppLocalizations(const Locale('de')), throwsFlutterError);
  });

  test('resolveLocale: a stored choice, else the first offered device language, else English', () {
    expect(resolveLocale('ja', const [Locale('fr')]), const Locale('ja'));
    expect(resolveLocale(null, const [Locale('de'), Locale('gu', 'IN'), Locale('fr')]), const Locale('gu'));
    expect(resolveLocale('xx', const [Locale('de')]), const Locale('en'));
    expect(resolveLocale(null).languageCode, 'en');
  });

  test('applyLocale switches strings and date formatting used outside widgets', () {
    final d = DateTime(2026, 10, 24, 21, 5);
    final now = DateTime(2026, 10, 28);
    expect([shortDate(d), longDate(d), dayMonthYear(d), weekdayDate(d, now), timeOfDay(d)], ['24 Oct', 'Sat, 24 Oct 2026', '24 Oct 2026', 'Sat, 24 Oct', '9:05 PM']);
    applyLocale(const Locale('fr'));
    expect(currentL10n.navHome, 'Accueil');
    expect(Intl.defaultLocale, 'fr');
    expect(monthsLong.first, 'janvier');
    expect(weekdaysShort.first, 'lun.');
    expect(Period.of(PeriodKind.month, d).label, 'octobre 2026');
    expect([shortDate(d), longDate(d), dayMonthYear(d), weekdayDate(d, now), timeOfDay(d)], ['24 oct.', 'sam. 24 oct. 2026', '24 oct. 2026', 'sam. 24 oct.', '21:05']);
    expect(weekdayDate(DateTime(2025, 3, 1), now), longDate(DateTime(2025, 3, 1)));
    expect(relativeDay(now, now), 'Aujourd’hui');
    expect(relativeDay(now.subtract(const Duration(days: 1)), now), 'Hier');
  });

  test('currency names follow the language', () {
    expect(inr.localName, 'Indian rupee');
    applyLocale(const Locale('hi'));
    expect([for (final c in currencies) c.localName].first, 'भारतीय रुपया');
    expect(const Currency('XYZ', 'X', 'Made up').localName, 'Made up');
  });

  test('starter categories and Cash are created in the device language', () {
    final db = openAppDatabase(null);
    expect(db.select("SELECT name FROM sources WHERE kind = 'cash'").single['name'], 'Cash');
    expect(db.select('SELECT name FROM categories WHERE is_default = 1').single['name'], 'Others');
    relabelSeed(db, AppLocalizationsEn(), lookupAppLocalizations(const Locale('gu')));
    expect(db.select("SELECT name FROM sources WHERE kind = 'cash'").single['name'], 'રોકડ');
    expect(db.select('SELECT name FROM categories WHERE is_default = 1').single['name'], 'અન્ય');
    db.close();
  });

  test('changing language before setup renames untouched starter data; after setup it does not', () {
    final s = makeState(onboarded: false);
    s.catalog.renameCategory(catId(s, 'Rent'), 'Flat rent');
    s.language = 'fr';
    expect(s.language, 'fr');
    expect(s.locale, const Locale('fr'));
    expect(s.catalog.defaultCategory().name, 'Autres');
    expect(s.catalog.findCategoryByName('Flat rent'), isNotNull);
    expect(s.catalog.sources().single.name, 'Espèces');
    s.completeOnboarding();
    s.language = null;
    expect(s.language, isNull);
    expect(s.locale, const Locale('en'));
    expect(currentL10n.localeName, 'en');
    expect(s.catalog.defaultCategory().name, 'Autres');
    s.settings.set('language', 'de');
    expect(s.language, isNull);
  });

  test('the PDF report is in French for French, and English for scripts the PDF fonts lack', () async {
    final p = Period.of(PeriodKind.month, kNow);
    Future<String> title() async => latin1.decode(await buildPdfReport(period: p, totals: const Totals(), spendByCategory: const [], transactions: const []), allowInvalid: true);
    applyLocale(const Locale('fr'));
    expect(await title(), contains('octobre 2026'));
    applyLocale(const Locale('ja'));
    expect(await title(), contains('October 2026'));
    expect(Intl.defaultLocale, 'ja');
  });

  testWidgets('the app installs the delegates and titles itself from the ARB', (tester) async {
    await tester.pumpWidget(ExpenseApp(state: makeState()));
    await tester.pump();
    final ctx = tester.element(find.text('Home'));
    expect(AppLocalizations.of(ctx).navHome, 'Home');
    expect(tester.widget<Title>(find.byType(Title)).title, 'Expense Manager');
    expect(find.byTooltip('Add transaction'), findsOneWidget);
    expect(['Insights', 'Invest', 'Debts'].every((t) => find.text(t).evaluate().isNotEmpty), isTrue);
  });

  testWidgets('every language renders the home screen', (tester) async {
    final s = makeState();
    seed(s);
    await tester.pumpWidget(ExpenseApp(state: s));
    for (final lang in appLanguages) {
      s.language = lang.code;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: lang.code);
      expect(find.text(lookupAppLocalizations(Locale(lang.code)).navInsights), findsOneWidget, reason: lang.code);
    }
  });

  testWidgets('the welcome step offers every language and switches on tap', (tester) async {
    final s = makeState(onboarded: false);
    await tester.pumpWidget(ExpenseApp(state: s));
    await tester.pumpAndSettle();
    expect(find.text('Your money, on your phone'), findsOneWidget);
    for (final lang in appLanguages) {
      expect(find.byKey(Key('onboarding-language-${lang.code}')), findsOneWidget);
    }
    await tester.tap(find.byKey(const Key('onboarding-language-hi')));
    await tester.pumpAndSettle();
    expect(s.language, 'hi');
    expect(find.text('आपका पैसा, आपके फ़ोन पर'), findsOneWidget);
    expect(s.catalog.defaultCategory().name, 'अन्य');
  });

  testWidgets('Settings › Language switches the app and back to the device language', (tester) async {
    final s = makeState();
    await pumpScreen(tester, s, const SettingsScreen());
    expect(find.text('Device language'), findsOneWidget);
    await tester.tap(find.byKey(const Key('language')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-language-ja')));
    await tester.pumpAndSettle();
    expect(s.language, 'ja');
    expect(find.text('日本語'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
    await tester.tap(find.byKey(const Key('language')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-language-')));
    await tester.pumpAndSettle();
    expect(s.language, isNull);
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.byKey(const Key('language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(s.language, isNull);
  });

  testWidgets('context.l10n falls back to the current language without a delegate', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            l10n = context.l10n;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(l10n, isA<AppLocalizationsEn>());
    expect(l10n.appTitle, 'Expense Manager');
  });
}
