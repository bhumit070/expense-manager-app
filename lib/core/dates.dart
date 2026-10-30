/// Date and budget-period helpers. Weeks start on [weekStartDay] (Monday by
/// default) and months run from the 1st to the last day, both in local time.
library;

import 'package:intl/intl.dart';

import '../l10n/l10n.dart';

// Month and weekday names in the app's language (Intl.defaultLocale, set
// with the language). 1 Jan 2024 was a Monday.
List<String> _names(String pattern, DateTime Function(int i) at, int n) => [for (var i = 0; i < n; i++) DateFormat(pattern).format(at(i))];
List<String> get monthsShort => _names('MMM', (i) => DateTime(2024, i + 1), 12);
List<String> get monthsLong => _names('MMMM', (i) => DateTime(2024, i + 1), 12);
List<String> get weekdaysShort => _names('EEE', (i) => DateTime(2024, 1, i + 1), 7);
List<String> get weekdaysLong => _names('EEEE', (i) => DateTime(2024, 1, i + 1), 7);

/// Days a week can start on, offered in Settings.
const weekStartChoices = [DateTime.monday, DateTime.sunday, DateTime.saturday];

/// First day of the week ([DateTime.monday] … [DateTime.sunday]) for weekly
/// budgets and insights. Set from Settings → Week starts on.
int weekStartDay = DateTime.monday;

/// Reads a stored week-start value, falling back to Monday.
int parseWeekStart(String? value) {
  final d = int.tryParse(value ?? '');
  return d != null && d >= DateTime.monday && d <= DateTime.sunday ? d : DateTime.monday;
}

/// "Mon–Sun", "Sun–Sat": the current week's first and last day.
String get weekSpanLabel => '${weekdaysShort[weekStartDay - 1]}–${weekdaysShort[(weekStartDay + 5) % 7]}';

enum PeriodKind { week, month, year }

DateTime dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

/// A half-open time range `[start, end)`.
class Period {
  const Period(this.kind, this.start, this.end);

  final PeriodKind kind;
  final DateTime start;
  final DateTime end;

  factory Period.of(PeriodKind kind, DateTime anchor) {
    switch (kind) {
      case PeriodKind.week:
        final s = dayStart(anchor).subtract(Duration(days: (anchor.weekday - weekStartDay) % 7));
        final start = DateTime(s.year, s.month, s.day);
        return Period(kind, start, DateTime(start.year, start.month, start.day + 7));
      case PeriodKind.month:
        return Period(kind, DateTime(anchor.year, anchor.month), DateTime(anchor.year, anchor.month + 1));
      case PeriodKind.year:
        return Period(kind, DateTime(anchor.year), DateTime(anchor.year + 1));
    }
  }

  /// Last instant-inclusive day of the period.
  DateTime get lastDay => DateTime(end.year, end.month, end.day - 1);

  int get days => DateTime.utc(end.year, end.month, end.day).difference(DateTime.utc(start.year, start.month, start.day)).inDays;

  Period get next => Period.of(kind, end);
  Period get previous => Period.of(kind, start.subtract(const Duration(days: 1)));

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);

  /// Whole days left including today; 0 if the period has ended.
  int daysLeft(DateTime now) {
    if (!now.isBefore(end)) return 0;
    if (now.isBefore(start)) return days;
    final today = DateTime.utc(now.year, now.month, now.day);
    return DateTime.utc(end.year, end.month, end.day).difference(today).inDays;
  }

  /// Fraction of the period elapsed at [now], clamped to 0..1.
  double elapsed(DateTime now) {
    if (!now.isAfter(start)) return 0;
    if (!now.isBefore(end)) return 1;
    return now.difference(start).inSeconds / end.difference(start).inSeconds;
  }

  String get label {
    switch (kind) {
      case PeriodKind.week:
        return '${shortDate(start)} – ${shortDate(lastDay)}';
      case PeriodKind.month:
        return DateFormat.yMMMM().format(start);
      case PeriodKind.year:
        return '${start.year}';
    }
  }

  String get rangeLabel => '${shortDate(start)} – ${shortDate(lastDay)}';

  @override
  bool operator ==(Object other) => other is Period && other.kind == kind && other.start == start;

  @override
  int get hashCode => Object.hash(kind, start);
}

/// "25 Oct" (English); other languages use their own day-month order.
String shortDate(DateTime d) => _en ? '${d.day} ${monthsShort[d.month - 1]}' : DateFormat.MMMd().format(d);

/// "25 Oct 2026".
String dayMonthYear(DateTime d) => _en ? '${shortDate(d)} ${d.year}' : DateFormat.yMMMd().format(d);

/// "Sat, 25 Oct 2026".
String longDate(DateTime d) => _en ? '${weekdaysShort[d.weekday - 1]}, ${shortDate(d)} ${d.year}' : DateFormat.yMMMEd().format(d);

/// "Sat, 25 Oct", with the year when it is not [now]'s.
String weekdayDate(DateTime d, DateTime now) {
  if (d.year != now.year) return longDate(d);
  return _en ? '${weekdaysShort[d.weekday - 1]}, ${shortDate(d)}' : DateFormat.MMMEd().format(d);
}

String timeOfDay(DateTime d) {
  if (!_en) return DateFormat.jm().format(d);
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
}

bool get _en => Intl.getCurrentLocale().startsWith('en');

/// "Today", "Yesterday" or "Sat, 25 Oct" relative to [now].
String relativeDay(DateTime d, DateTime now) {
  final diff = dayStart(now).difference(dayStart(d)).inDays;
  if (diff == 0) return currentL10n.today;
  if (diff == 1) return currentL10n.yesterday;
  return weekdayDate(d, now);
}

/// ISO-ish date for CSV: 2026-10-28 21:41.
String isoDateTime(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}

/// Parses `2026-10-28`, `2026-10-28 21:41`, `28/10/2026`, `28-10-2026`.
DateTime? parseFlexibleDate(String input) {
  final s = input.trim();
  final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})(?:[ T](\d{1,2}):(\d{2}))?').firstMatch(s);
  if (iso != null) {
    return _safe(int.parse(iso[1]!), int.parse(iso[2]!), int.parse(iso[3]!), int.tryParse(iso[4] ?? '') ?? 0, int.tryParse(iso[5] ?? '') ?? 0);
  }
  final dmy = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$').firstMatch(s);
  if (dmy != null) {
    return _safe(int.parse(dmy[3]!), int.parse(dmy[2]!), int.parse(dmy[1]!), 0, 0);
  }
  return null;
}

DateTime? _safe(int y, int m, int d, int h, int min) {
  if (m < 1 || m > 12 || d < 1 || d > 31 || h > 23 || min > 59) return null;
  final dt = DateTime(y, m, d, h, min);
  return dt.month == m ? dt : null;
}
