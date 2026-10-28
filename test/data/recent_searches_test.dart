import 'package:expense_manager/data/recent_searches.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('keeps the newest 8 unique queries, removes and clears', () {
    final s = makeState();
    final r = RecentSearches(s.settings);
    expect(r.items, isEmpty);
    r.add('   ');
    expect(r.items, isEmpty);
    for (var i = 0; i < 10; i++) {
      r.add('q$i');
    }
    expect(r.items.length, RecentSearches.max);
    expect(r.items.first, 'q9');
    r.add(' Q3 ');
    expect(r.items.first, 'Q3');
    expect(r.items.where((x) => x.toLowerCase() == 'q3').length, 1);
    r.remove('Q3');
    expect(r.items.contains('Q3'), isFalse);
    r.clear();
    expect(r.items, isEmpty);
  });

  test('corrupt stored value reads as empty', () {
    final s = makeState();
    s.settings.set(RecentSearches.key, '{not json');
    expect(RecentSearches(s.settings).items, isEmpty);
    s.settings.set(RecentSearches.key, '["ok", 3]');
    expect(RecentSearches(s.settings).items, ['ok']);
  });
}
