import 'package:expense_manager/data/recent_searches.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/ui/screens/transactions_screen.dart';
import 'package:expense_manager/ui/screens/txn_detail_screen.dart';
import 'package:expense_manager/ui/screens/txn_form_screen.dart';
import 'package:expense_manager/ui/widgets/highlight.dart';
import 'package:expense_manager/ui/widgets/map_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/maps.dart';
import '../helpers.dart';

/// The emphasised pieces of every [HighlightedText] on screen.
Iterable<String> highlighted(WidgetTester tester) => tester
    .widgetList<Text>(find.descendant(of: find.byType(HighlightedText), matching: find.byType(Text)))
    .expand((t) => (t.textSpan! as TextSpan).children!.cast<TextSpan>())
    .where((span) => span.style?.backgroundColor != null)
    .map((span) => span.text!);

Future<void> tapScope(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(key)));
}

void main() {
  setUp(() => useFakeMaps(addTearDown));

  test('matchRanges merges overlapping words and labels cover every value', () {
    expect(matchRanges('Team dinner', 'din dinner'), [(5, 11)]);
    expect(matchRanges('abcabc', 'bc'), [(1, 3), (4, 6)]);
    expect(matchRanges('x', ''), isEmpty);
    expect(SearchScope.values.map(scopeLabel), ['All', 'Notes', 'Merchant', 'Amount', 'Place']);
    expect(TxnSort.values.map(sortLabel).toSet().length, 4);
  });

  testWidgets('scopes narrow the search and matches are highlighted', (tester) async {
    final s = makeState();
    seed(s);
    await pumpScreen(tester, s, const TransactionsScreen());
    expect(find.byKey(const Key('search-scopes')), findsNothing);
    await tester.tap(find.byKey(const Key('search')));
    await tester.pump();
    expect(find.byKey(const Key('search-scopes')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('search')), 'dinner');
    await tester.pump();
    expect(find.text('Swiggy'), findsOneWidget); // plain title, no match
    expect(highlighted(tester), everyElement('dinner'));
    expect(highlighted(tester).length, 2); // note snippets of Swiggy and Toit

    await tapScope(tester, 'scope-merchant');
    await tester.pump();
    expect(find.text('Search merchants'), findsOneWidget);
    expect(find.text('No transactions match "dinner".'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search')), 'swi');
    await tester.pump();
    expect(highlighted(tester), ['Swi']);

    await tapScope(tester, 'scope-place');
    await tester.enterText(find.byKey(const Key('search')), 'indira');
    await tester.pump();
    expect(find.text('Search places'), findsOneWidget);
    expect(highlighted(tester), ['Indira']);

    await tapScope(tester, 'scope-notes');
    await tester.enterText(find.byKey(const Key('search')), 'work');
    await tester.pump();
    expect(find.text('Search notes and #tags'), findsOneWidget);
    expect(highlighted(tester), ['work']); // from the tags line

    await tapScope(tester, 'scope-amount');
    await tester.enterText(find.byKey(const Key('search')), '486');
    await tester.pump();
    expect(find.text('Exact amount, e.g. 450 or ₹1,200'), findsOneWidget);
    expect(find.text('Swiggy'), findsOneWidget);
    final amount = tester.widget<Container>(find.ancestor(of: find.text('−₹486'), matching: find.byType(Container)).first);
    expect(amount.color, isNotNull);

    await tapScope(tester, 'scope-all');
    await tester.pump();
    expect(find.text('Search merchant, note, #tag, amount…'), findsOneWidget);
  });

  testWidgets('sort by amount drops day headers and shows dates on rows', (tester) async {
    final s = makeState();
    seed(s);
    await pumpScreen(tester, s, const TransactionsScreen());
    expect(find.text('Yesterday'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sort')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sort-amountDesc')));
    await tester.pumpAndSettle();
    final names = tester.widgetList<Text>(find.descendant(of: find.byKey(const Key('txn-list')), matching: find.byType(Text))).map((t) => t.data).toList();
    expect(names.indexOf('Salary'), lessThan(names.indexOf('Uber')));
    expect(find.text('Yesterday'), findsNothing);
    expect(find.textContaining('· Yesterday'), findsWidgets);

    await tester.tap(find.byKey(const Key('sort')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sort-oldest')));
    await tester.pumpAndSettle();
    expect(find.text('Yesterday'), findsOneWidget);
  });

  testWidgets('recent searches: saved on submit and on open, reused, removed, cleared', (tester) async {
    final s = makeState();
    seed(s);
    final recent = RecentSearches(s.settings);
    await pumpScreen(tester, s, const TransactionsScreen());
    await tester.tap(find.byKey(const Key('search')));
    await tester.pump();
    expect(find.byKey(const Key('recent-searches')), findsNothing); // nothing saved yet

    await tester.enterText(find.byKey(const Key('search')), 'uber');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(recent.items, ['uber']);

    await tester.enterText(find.byKey(const Key('search')), 'toit');
    await tester.pump();
    await tester.tap(find.text('Toit'));
    await tester.pumpAndSettle();
    expect(find.byType(TxnDetailScreen), findsOneWidget);
    expect(recent.items, ['toit', 'uber']);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('clear-search')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('search')));
    await tester.pump();
    expect(find.byKey(const Key('recent-searches')), findsOneWidget);
    await tester.tap(find.text('uber'));
    await tester.pump();
    expect(find.text('Uber'), findsOneWidget);
    expect(recent.items.first, 'uber');

    await tester.tap(find.byKey(const Key('clear-search')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('search')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('remove-recent-0')));
    await tester.pump();
    expect(recent.items, ['toit']);
    await tester.tap(find.byKey(const Key('clear-recent')));
    await tester.pump();
    expect(recent.items, isEmpty);
    expect(find.byKey(const Key('recent-searches')), findsNothing);
  });

  testWidgets('swipe right edits, swipe left deletes with undo', (tester) async {
    final s = makeState();
    seed(s);
    await pumpScreen(tester, s, const TransactionsScreen());
    await tester.drag(find.text('Uber'), const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(find.byType(TxnFormScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Uber'), findsOneWidget); // edit swipe springs back

    await tester.drag(find.text('Uber'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Uber'), findsNothing);
    expect(find.text('Transaction deleted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Uber'), findsOneWidget);
  });

  testWidgets('detail shows a map preview that opens the maps app', (tester) async {
    final s = makeState();
    seed(s);
    final maps = useFakeMaps(addTearDown);
    final swiggy = s.txns.list(const TxnFilter(search: 'swiggy')).single.txn;
    await pumpScreen(tester, s, TxnDetailScreen(id: swiggy.id!));
    await tester.pumpAndSettle();
    expect(find.byType(MapPreview), findsOneWidget);
    expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
    expect(maps.tiles.requests, greaterThan(0));
    await tester.tap(find.byKey(const Key('map-preview')));
    expect(maps.opened.single, (12.97, 77.64, 'Indiranagar'));

    final uber = s.txns.list(const TxnFilter(search: 'uber')).single.txn;
    await pumpScreen(tester, s, TxnDetailScreen(id: uber.id!));
    expect(find.byType(MapPreview), findsNothing);
  });
}
