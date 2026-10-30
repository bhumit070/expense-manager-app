import 'package:expense_manager/core/dates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tue = DateTime(2026, 10, 28, 21, 41);

  group('Period.week', () {
    test('runs Monday to Sunday', () {
      final w = Period.of(PeriodKind.week, tue);
      expect(w.start, DateTime(2026, 10, 26));
      expect(w.end, DateTime(2026, 11, 2));
      expect(w.lastDay, DateTime(2026, 11, 1));
      expect(w.days, 7);
      expect(w.label, '26 Oct – 1 Nov');
    });
    test('Sunday belongs to the week that started on Monday', () {
      expect(Period.of(PeriodKind.week, DateTime(2026, 11, 1, 23, 59)).start, DateTime(2026, 10, 26));
      expect(Period.of(PeriodKind.week, DateTime(2026, 10, 26)).start, DateTime(2026, 10, 26));
    });
    test('next and previous', () {
      final w = Period.of(PeriodKind.week, tue);
      expect(w.next.start, DateTime(2026, 11, 2));
      expect(w.previous.start, DateTime(2026, 10, 19));
    });
    test('follows the chosen first day of the week', () {
      addTearDown(() => weekStartDay = DateTime.monday);
      expect(weekSpanLabel, 'Mon–Sun');
      weekStartDay = DateTime.sunday;
      final sun = Period.of(PeriodKind.week, tue);
      expect([sun.start, sun.lastDay, weekSpanLabel], [DateTime(2026, 10, 25), DateTime(2026, 10, 31), 'Sun–Sat']);
      expect(Period.of(PeriodKind.week, DateTime(2026, 10, 25, 9)).start, DateTime(2026, 10, 25), reason: 'Sunday starts its own week');
      weekStartDay = DateTime.saturday;
      final sat = Period.of(PeriodKind.week, tue);
      expect([sat.start, sat.end, weekSpanLabel], [DateTime(2026, 10, 24), DateTime(2026, 10, 31), 'Sat–Fri']);
      expect(sat.next.start, DateTime(2026, 10, 31));
    });
    test('parseWeekStart accepts 1–7 and falls back to Monday', () {
      expect([parseWeekStart('7'), parseWeekStart('6'), parseWeekStart(null), parseWeekStart('9'), parseWeekStart('x')], [7, 6, 1, 1, 1]);
    });
  });

  group('Period.month', () {
    test('1st to last day', () {
      final m = Period.of(PeriodKind.month, tue);
      expect(m.start, DateTime(2026, 10));
      expect(m.end, DateTime(2026, 11));
      expect(m.days, 31);
      expect(m.label, 'October 2026');
      expect(m.rangeLabel, '1 Oct – 31 Oct');
    });
    test('leap year February', () {
      expect(Period.of(PeriodKind.month, DateTime(2028, 2, 10)).days, 29);
      expect(Period.of(PeriodKind.month, DateTime(2026, 2, 10)).days, 28);
    });
    test('December rolls into next year', () {
      final d = Period.of(PeriodKind.month, DateTime(2026, 12, 31));
      expect(d.end, DateTime(2027));
      expect(d.next.label, 'January 2027');
      expect(Period.of(PeriodKind.month, DateTime(2026, 1, 3)).previous.label, 'December 2025');
    });
  });

  test('Period.year', () {
    final y = Period.of(PeriodKind.year, tue);
    expect(y.start, DateTime(2026));
    expect(y.days, 365);
    expect(y.label, '2026');
  });

  group('progress helpers', () {
    final m = Period.of(PeriodKind.month, tue);
    test('contains is half-open', () {
      expect(m.contains(DateTime(2026, 10)), isTrue);
      expect(m.contains(DateTime(2026, 11)), isFalse);
      expect(m.contains(DateTime(2026, 9, 30, 23, 59)), isFalse);
    });
    test('daysLeft includes today', () {
      expect(m.daysLeft(tue), 4);
      expect(m.daysLeft(DateTime(2026, 11, 1)), 0);
      expect(m.daysLeft(DateTime(2026, 9, 1)), 31);
    });
    test('elapsed is clamped', () {
      expect(m.elapsed(DateTime(2026, 9, 1)), 0);
      expect(m.elapsed(DateTime(2026, 12, 1)), 1);
      expect(m.elapsed(DateTime(2026, 10, 16, 12)), closeTo(0.5, 0.01));
    });
  });

  test('equality and hashCode', () {
    final a = Period.of(PeriodKind.month, DateTime(2026, 10, 3));
    final b = Period.of(PeriodKind.month, DateTime(2026, 10, 30));
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == Period.of(PeriodKind.week, DateTime(2026, 10, 3)), isFalse);
    expect(a == Object(), isFalse);
  });

  group('formatting', () {
    test('short/long/time', () {
      expect(shortDate(tue), '28 Oct');
      expect(longDate(tue), 'Wed, 28 Oct 2026');
      expect(timeOfDay(tue), '9:41 PM');
      expect(timeOfDay(DateTime(2026, 1, 1, 0, 5)), '12:05 AM');
      expect(timeOfDay(DateTime(2026, 1, 1, 12, 0)), '12:00 PM');
      expect(isoDateTime(DateTime(2026, 3, 4, 5, 6)), '2026-03-04 05:06');
    });
    test('relativeDay', () {
      expect(relativeDay(DateTime(2026, 10, 28, 1), tue), 'Today');
      expect(relativeDay(DateTime(2026, 10, 27, 23), tue), 'Yesterday');
      expect(relativeDay(DateTime(2026, 10, 25), tue), 'Sun, 25 Oct');
      expect(relativeDay(DateTime(2025, 10, 25), tue), 'Sat, 25 Oct 2025');
    });
  });

  group('parseFlexibleDate', () {
    test('accepted formats', () {
      expect(parseFlexibleDate('2026-10-28'), DateTime(2026, 10, 28));
      expect(parseFlexibleDate('2026-10-28 21:41'), DateTime(2026, 10, 28, 21, 41));
      expect(parseFlexibleDate('2026-10-28T08:05:00'), DateTime(2026, 10, 28, 8, 5));
      expect(parseFlexibleDate(' 28/10/2026 '), DateTime(2026, 10, 28));
      expect(parseFlexibleDate('1-2-2026'), DateTime(2026, 2, 1));
    });
    test('rejects invalid', () {
      expect(parseFlexibleDate('yesterday'), isNull);
      expect(parseFlexibleDate('2026-13-01'), isNull);
      expect(parseFlexibleDate('2026-02-30'), isNull);
      expect(parseFlexibleDate('2026-01-00'), isNull);
      expect(parseFlexibleDate('2026-01-01 24:00'), isNull);
      expect(parseFlexibleDate('2026-01-01 10:60'), isNull);
      expect(parseFlexibleDate('32/01/2026'), isNull);
    });
  });
}
