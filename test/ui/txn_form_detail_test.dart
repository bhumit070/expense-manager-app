import 'dart:async';

import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/services/location.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:expense_manager/ui/screens/txn_detail_screen.dart';
import 'package:expense_manager/ui/screens/txn_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

TxnView byMerchant(AppState s, String m) => s.txns.list(const TxnFilter(), limit: 100).firstWhere((v) => v.txn.merchant == m);

void main() {
  group('TxnFormScreen', () {
    testWidgets('validates amount, then saves a spend with defaults, tags and location', (tester) async {
      final loc = FakeLocation()..place = const Place(name: 'Indiranagar', lat: 12.9, lng: 77.6);
      final s = makeState(location: loc);
      final ids = seed(s);
      await pumpRoute(tester, s, const TxnFormScreen());
      await tester.pump();
      expect(tester.widget<TextField>(find.byKey(const Key('place'))).controller!.text, 'Indiranagar');
      expect(find.text('Not sure? It goes to “Others” by default.'), findsOneWidget);
      expect(find.text('Wed, 28 Oct 2026'), findsOneWidget);
      expect(find.text('9:41 PM'), findsOneWidget);

      await tester.tap(find.byKey(const Key('save-txn')));
      await tester.pump();
      expect(find.text('Enter an amount greater than zero'), findsWidgets);

      await typeAmount(tester, '1250.5');
      await tester.enterText(find.byKey(const Key('merchant')), 'Cafe');
      await tester.enterText(find.byKey(const Key('note')), 'Coffee with team');
      await tester.enterText(find.byKey(const Key('tags')), '#Work, split ##');
      await tester.tap(find.text('ICICI Card ••07'));
      await tester.pump();
      // tapping locate again keeps the typed place
      await tester.tap(find.byKey(const Key('locate')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('save-txn')));
      await tester.pumpAndSettle();

      final v = byMerchant(s, 'Cafe');
      expect(v.txn.amount, 125050);
      expect(v.category.name, 'Others');
      expect(v.txn.sourceId, ids.card);
      expect(v.txn.tags, ['#work', '#split']);
      expect(v.txn.place, 'Indiranagar');
      expect(v.txn.lat, 12.9);
      expect(v.txn.occurredAt, kNow);
    });

    testWidgets('picks category, date and time; cancel keeps values', (tester) async {
      final s = makeState()..locationEnabled = false;
      await pumpRoute(tester, s, const TxnFormScreen());
      await typeAmount(tester, '99');
      await tester.tap(find.byKey(Key('cat-${catId(s, 'Rent')}')));
      await tester.tap(find.byKey(const Key('pick-date')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pick-date')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pick-time')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pick-time')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-txn')));
      await tester.pumpAndSettle();
      final v = s.txns.list(const TxnFilter()).single;
      expect(v.category.name, 'Rent');
      expect(v.txn.occurredAt, DateTime(2026, 10, 15, 21, 41));
      expect(v.txn.place, isNull);
      expect(v.txn.lat, isNull);
      expect(s.location is FakeLocation && (s.location as FakeLocation).lookups == 0, isTrue);
    });

    testWidgets('invest links a holding, income shows "Received in", debt needs a debt', (tester) async {
      final s = makeState()..locationEnabled = false;
      final ids = seed(s);
      await pumpRoute(tester, s, const TxnFormScreen());
      await tester.tap(find.text('Invest'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('holding')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nifty 50 Index').last);
      await tester.pumpAndSettle();
      await typeAmount(tester, '10000');
      await tester.tap(find.byKey(const Key('save-txn')));
      await tester.pumpAndSettle();
      expect(s.planning.holdings().firstWhere((h) => h.investment.id == ids.sip).invested, 2000000);

      await pumpRoute(tester, s, const TxnFormScreen(initialType: TxnType.income));
      expect(find.text('Received in'), findsOneWidget);
      await tester.tap(find.text('Debt'));
      await tester.pump();
      expect(find.text('Category'), findsNothing);
      await typeAmount(tester, '500');
      await tester.tap(find.byKey(const Key('save-txn')));
      await tester.pump();
      expect(find.text('Pick which debt this payment belongs to'), findsWidgets);
      await tester.tap(find.byKey(const Key('debt')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rahul · you receive').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-txn')));
      await tester.pumpAndSettle();
      final repaid = s.planning.debts(direction: DebtDirection.owedToMe).single;
      expect(repaid.paid, 250000 + 50000);
      expect(find.text('Car loan · you pay'), findsNothing);
    });

    testWidgets('edits an existing transaction with paise and clears location', (tester) async {
      final s = makeState();
      seed(s);
      final swiggy = byMerchant(s, 'Swiggy');
      s.txns.update(
        Txn(
          id: swiggy.txn.id,
          type: TxnType.spend,
          amount: 1250,
          categoryId: swiggy.txn.categoryId,
          sourceId: swiggy.txn.sourceId,
          occurredAt: swiggy.txn.occurredAt,
          merchant: 'Swiggy',
          place: 'X',
          lat: 1,
          lng: 2,
        ),
      );
      await pumpRoute(tester, s, TxnFormScreen(existing: s.txns.byId(swiggy.txn.id!)));
      expect(find.text('Edit transaction'), findsOneWidget);
      expect(amountShown(tester), '12.50');
      await tester.enterText(find.byKey(const Key('place')), '');
      await tester.tap(find.byKey(const Key('save-txn')));
      await tester.pumpAndSettle();
      final v = s.txns.byId(swiggy.txn.id!)!;
      expect([v.txn.place, v.txn.lat, v.txn.lng], [null, null, null]);
      expect(v.txn.occurredAt, swiggy.txn.occurredAt);
      expect((s.location as FakeLocation).lookups, 0);
    });

    testWidgets('duplicate creates a new transaction dated now', (tester) async {
      final s = makeState()..locationEnabled = false;
      seed(s);
      final uber = byMerchant(s, 'Uber');
      await pumpRoute(tester, s, TxnFormScreen(existing: uber, duplicate: true));
      expect(find.text('New transaction'), findsOneWidget);
      expect(amountShown(tester), '312');
      await tester.tap(find.byKey(const Key('save-txn')));
      await tester.pumpAndSettle();
      expect(s.txns.list(const TxnFilter(search: 'uber')).map((e) => e.txn.occurredAt), [kNow, DateTime(2026, 10, 27, 9)]);
    });

    testWidgets('shows a spinner while locating and survives leaving early', (tester) async {
      final loc = FakeLocation()..pending = Completer<Place?>();
      final s = makeState(location: loc);
      await pumpScreen(
        tester,
        s,
        Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const TxnFormScreen())),
              child: const Text('open'),
            );
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      loc.pending!.complete(const Place(name: 'Late', lat: 0, lng: 0));
      await tester.pump();
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('no sources hides the Paid from section; null place keeps field empty', (tester) async {
      final s = makeState();
      s.catalog.archiveSource(s.catalog.defaultSource()!.id);
      await pumpRoute(tester, s, const TxnFormScreen());
      await tester.pump();
      expect(find.text('Paid from'), findsNothing);
      expect(tester.widget<TextField>(find.byKey(const Key('place'))).controller!.text, '');
    });
  });

  group('TxnDetailScreen', () {
    testWidgets('shows details, note, tags and location', (tester) async {
      final s = makeState();
      seed(s);
      await pumpScreen(tester, s, TxnDetailScreen(id: byMerchant(s, 'Swiggy').txn.id!));
      expect(find.text('−₹486'), findsOneWidget);
      expect(find.text('Team dinner after sprint demo'), findsOneWidget);
      expect(find.text('#work'), findsOneWidget);
      expect(find.text('Indiranagar'), findsOneWidget);
      expect(find.text('12.9700, 77.6400'), findsOneWidget);
      expect(find.text('HDFC Savings ••42'), findsOneWidget);
    });

    testWidgets('income without note or source shows inflow layout', (tester) async {
      final s = makeState();
      final id = s.txns.insert(Txn(type: TxnType.income, amount: 100, categoryId: s.catalog.firstOf(CategoryKind.income).id, sourceId: null, occurredAt: kNow));
      await pumpScreen(tester, s, TxnDetailScreen(id: id));
      expect(find.text('Received in'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      expect(find.text('NOTE'), findsNothing);
      expect(find.text('+₹1'), findsOneWidget);
    });

    testWidgets('tags only, edit and duplicate navigation', (tester) async {
      final s = makeState()..locationEnabled = false;
      final id = s.txns.insert(Txn(type: TxnType.spend, amount: 100, categoryId: 1, sourceId: null, occurredAt: kNow, tags: const ['#x']));
      await pumpScreen(tester, s, TxnDetailScreen(id: id));
      expect(find.text('NOTE'), findsOneWidget);
      await tester.tap(find.byKey(const Key('edit')));
      await tester.pumpAndSettle();
      expect(find.text('Edit transaction'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('duplicate')));
      await tester.pumpAndSettle();
      expect(find.text('New transaction'), findsOneWidget);
    });

    testWidgets('delete pops with undo, and a missing id shows an empty state', (tester) async {
      final s = makeState();
      seed(s);
      final id = byMerchant(s, 'Uber').txn.id!;
      await pumpScreen(
        tester,
        s,
        Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TxnDetailScreen(id: id))),
                child: const Text('open'),
              ),
            );
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete')));
      await tester.pumpAndSettle();
      expect(s.txns.byId(id), isNull);
      expect(find.text('Transaction deleted'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(s.txns.byId(id), isNotNull);

      await pumpScreen(tester, s, const TxnDetailScreen(id: 99999));
      expect(find.text('This transaction no longer exists.'), findsOneWidget);
    });
  });
}
