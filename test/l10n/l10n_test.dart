import 'package:expense_manager/app.dart';
import 'package:expense_manager/l10n/app_localizations_en.dart';
import 'package:expense_manager/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('English is the only locale for now; others are rejected', () {
    expect(AppLocalizations.supportedLocales, [const Locale('en')]);
    expect(AppLocalizations.delegate.isSupported(const Locale('en', 'IN')), isTrue);
    expect(AppLocalizations.delegate.isSupported(const Locale('fr')), isFalse);
    expect(AppLocalizations.delegate.shouldReload(AppLocalizations.delegate), isFalse);
    expect(lookupAppLocalizations(const Locale('en')).localeName, 'en');
    expect(() => lookupAppLocalizations(const Locale('fr')), throwsFlutterError);
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

  testWidgets('context.l10n falls back to English without a delegate', (tester) async {
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
