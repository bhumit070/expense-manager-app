@Tags(['perf'])
library;

import 'dart:math';

import 'package:expense_manager/core/dates.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Median wall time of [runs] calls to [body], in milliseconds.
double _ms(void Function() body, {int runs = 7}) {
  body(); // warm up the statement cache
  final times = <int>[];
  for (var i = 0; i < runs; i++) {
    final sw = Stopwatch()..start();
    body();
    times.add(sw.elapsedMicroseconds);
  }
  times.sort();
  return times[runs ~/ 2] / 1000;
}

void main() {
  test('aggregates over 10k transactions stay under 50 ms', () {
    final s = makeState();
    final rnd = Random(42);
    final cats = s.catalog.categories(kind: CategoryKind.spend).map((c) => c.id).toList();
    final source = s.catalog.defaultSource()!.id;
    const merchants = ['Swiggy', 'Uber', 'Amazon', 'BigBasket', 'Zomato', 'Airtel', 'Shell', 'Croma'];
    final start = DateTime(2025, 11, 1);
    s.txns.insertAll([
      for (var i = 0; i < 10000; i++)
        Txn(
          type: i % 10 == 0 ? TxnType.invest : TxnType.spend,
          amount: 1000 + rnd.nextInt(500000),
          categoryId: cats[rnd.nextInt(cats.length)],
          sourceId: source,
          occurredAt: start.add(Duration(minutes: rnd.nextInt(365 * 24 * 60))),
          merchant: merchants[rnd.nextInt(merchants.length)],
          note: i % 7 == 0 ? 'team dinner #work' : '',
        ),
    ]);
    final year = Period.of(PeriodKind.year, kNow);
    final monthP = month(kNow);
    final f = TxnFilter(from: year.start, to: year.end);
    final results = {
      'list (first page)': _ms(() => s.txns.list(f)),
      'totals (year)': _ms(() => s.txns.totals(f)),
      'dayTotals (year)': _ms(() => s.txns.dayTotals(f)),
      'byCategory (year)': _ms(() => s.txns.byCategory(year, TxnType.spend)),
      'buckets (year)': _ms(() => s.txns.buckets(year)),
      'buckets (month)': _ms(() => s.txns.buckets(monthP)),
      'search "dinner"': _ms(() => s.txns.list(const TxnFilter(search: 'dinner'))),
      'search amount scope': _ms(() => s.txns.list(const TxnFilter(search: '1200', scope: SearchScope.amount))),
    };
    // ignore: avoid_print
    results.forEach((k, v) => print('${k.padRight(22)} ${v.toStringAsFixed(2)} ms'));
    for (final e in results.entries) {
      expect(e.value, lessThan(50), reason: e.key);
    }
  });
}
