import '../l10n/l10n.dart';
import '../core/dates.dart';
import '../core/money.dart';

/// Banks with a dedicated statement layout. Everything else uses [generic].
enum StatementBank { hdfc, sbi, icici, generic }

String bankLabel(StatementBank b) => switch (b) {
  StatementBank.hdfc => 'HDFC Bank',
  StatementBank.sbi => 'SBI',
  StatementBank.icici => 'ICICI Bank',
  StatementBank.generic => currentL10n.bankStatement,
};

/// One transaction read from a statement.
class StatementRow {
  const StatementRow({required this.date, required this.description, required this.amount, required this.credit});

  final DateTime date;
  final String description;

  /// Paise, always positive.
  final int amount;

  /// Money came in (deposit) rather than went out.
  final bool credit;
}

/// How one bank lays out its statement table.
class _Layout {
  const _Layout({required this.start, required this.stop, this.serial = false});

  /// Header line of the transactions table; rows before it are ignored.
  final RegExp start;

  /// A line that ends the table (summary, footer).
  final RegExp stop;

  /// Rows begin with a serial number before the date.
  final bool serial;
}

final _layouts = {
  StatementBank.hdfc: _Layout(start: RegExp(r'^Date\s+Narration', caseSensitive: false), stop: RegExp(r'STATEMENT SUMMARY|Generated On:', caseSensitive: false)),
  StatementBank.sbi: _Layout(start: RegExp(r'^Txn Date\s+Value Date', caseSensitive: false), stop: RegExp(r'computer generated statement', caseSensitive: false)),
  StatementBank.icici: _Layout(start: RegExp(r'^S\.? ?No\.?\s+Value Date', caseSensitive: false), stop: RegExp(r'^Total\b|Legends? (?:for|used)', caseSensitive: false), serial: true),
  StatementBank.generic: _Layout(start: RegExp(r'(?!)'), stop: RegExp(r'(?!)')),
};

/// Guesses the bank from the statement's text.
StatementBank detectBank(List<String> lines) {
  final head = lines.take(40).join('\n').toLowerCase();
  if (head.contains('hdfc bank')) return StatementBank.hdfc;
  if (head.contains('state bank of india') || head.contains('sbin0')) return StatementBank.sbi;
  if (head.contains('icici bank')) return StatementBank.icici;
  return StatementBank.generic;
}

const _months = {'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6, 'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12};
const _datePattern = r'(\d{1,2})[/-](\d{1,2})[/-](\d{2}|\d{4})\b|(\d{1,2})[ -](Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*[ ,-]+(\d{2}|\d{4})\b';
final _leadingDate = RegExp('^(?:$_datePattern)', caseSensitive: false);
final _anyDate = RegExp('(?<![\\d/-])(?:$_datePattern)', caseSensitive: false);
final _money = RegExp(r'(?:^|\s)((?:\d{1,3}(?:,\d{2,3})+|\d+)\.\d{2})(?:\s*(Dr|Cr)\b\.?)?\s*$', caseSensitive: false);
final _opening = RegExp(r'opening balance|balance as on|b/f\b|brought forward', caseSensitive: false);
final _noise = RegExp(r'^page\s*\d|\bpage \d+ of \d+|statement of account', caseSensitive: false);
final _creditWords = RegExp(r'\b(?:CR|CREDIT|SALARY|SAL|INT\.?PD|INTEREST|REFUND|REVERSAL|DEPOSIT|BY TRANSFER|BY CLEARING|CASH DEP)\b', caseSensitive: false);

DateTime? _date(RegExpMatch m) {
  int year(String y) => y.length == 2 ? 2000 + int.parse(y) : int.parse(y);
  final (d, mo, y) = m[1] != null ? (int.parse(m[1]!), int.parse(m[2]!), year(m[3]!)) : (int.parse(m[4]!), _months[m[5]!.toLowerCase()]!, year(m[6]!));
  return parseFlexibleDate('${y.toString().padLeft(4, '0')}-$mo-$d');
}

/// Pulls trailing amounts (with optional Dr/Cr) off the end of [s].
(String, List<(int, String?)>) _trailingAmounts(String s) {
  final found = <(int, String?)>[];
  var rest = s;
  for (var m = _money.firstMatch(rest); m != null; m = _money.firstMatch(rest)) {
    found.insert(0, (parseInr(m[1]!)!, m[2]?.toLowerCase()));
    rest = rest.substring(0, m.start);
  }
  return (rest, found);
}

/// Parses statement text lines into transactions.
///
/// Each row starts with a date (after a serial number for ICICI) and ends with
/// the amount and usually the running balance. Debit vs credit comes from an
/// explicit Dr/Cr marker, else the change in balance, else narration keywords.
/// Lines without a date continue the previous row's narration.
List<StatementRow> parseStatement(List<String> lines, {StatementBank? bank}) {
  final layout = _layouts[bank ?? detectBank(lines)]!;
  final hasTable = lines.any(layout.start.hasMatch);
  var inTable = !hasTable;
  int? balance;
  final out = <StatementRow>[];
  var open = false;
  for (final raw in lines) {
    final line = raw.trim();
    if (!inTable) {
      inTable = layout.start.hasMatch(line);
      continue;
    }
    if (layout.start.hasMatch(line) || _noise.hasMatch(line)) {
      open = false;
      continue;
    }
    if (layout.stop.hasMatch(line)) {
      if (hasTable) inTable = false;
      open = false;
      continue;
    }
    var body = line;
    if (layout.serial) body = body.replaceFirst(RegExp(r'^\d{1,4}\s+(?=\d)'), '');
    final dm = _leadingDate.firstMatch(body);
    final (rest, amounts) = _trailingAmounts(body);
    if (_opening.hasMatch(line) && amounts.isNotEmpty) {
      balance = amounts.last.$1 * (amounts.last.$2 == 'dr' ? -1 : 1);
      open = false;
      continue;
    }
    if (dm == null || amounts.isEmpty) {
      if (open && dm == null && amounts.isEmpty && out.isNotEmpty && out.last.description.length < 120) {
        final prev = out.removeLast();
        out.add(StatementRow(date: prev.date, description: '${prev.description} $line'.trim(), amount: prev.amount, credit: prev.credit));
      }
      // A dated line without an amount is not ours; stop gluing text onto the last row.
      if (dm != null) open = false;
      continue;
    }
    final date = _date(dm);
    if (date == null) continue;
    final description = rest.substring(dm.end).replaceAll(_anyDate, ' ').replaceAll(RegExp(r'\b\d{9,}\b'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    var (amount, marker) = amounts.length >= 2 ? amounts[amounts.length - 2] : amounts.last;
    final newBalance = amounts.length >= 2 ? amounts.last.$1 * (amounts.last.$2 == 'dr' ? -1 : 1) : null;
    bool credit;
    if (amounts.length >= 3 && (amount == 0 || amounts[amounts.length - 3].$1 == 0)) {
      // Withdrawal and deposit columns both printed, one of them 0.00.
      credit = amount != 0;
      if (!credit) amount = amounts[amounts.length - 3].$1;
    } else if (marker != null) {
      credit = marker == 'cr';
    } else if (balance != null && newBalance != null && (newBalance - balance).abs() == amount) {
      credit = newBalance > balance;
    } else {
      credit = _creditWords.hasMatch(description);
    }
    if (newBalance != null) balance = newBalance;
    if (amount == 0) continue;
    out.add(StatementRow(date: date, description: description, amount: amount, credit: credit));
    open = true;
  }
  return out;
}

/// Rows in the CSV shape `buildImport` understands (date, description, debit, credit).
List<List<String>> statementToRows(List<StatementRow> rows) => [
  ['date', 'description', 'debit', 'credit'],
  for (final r in rows)
    [isoDateTime(r.date).substring(0, 10), r.description, r.credit ? '' : (r.amount / paisePerRupee).toStringAsFixed(2), r.credit ? (r.amount / paisePerRupee).toStringAsFixed(2) : ''],
];
