/// Money helpers. Amounts are stored as integer minor units (paise for INR,
/// cents for USD…; always 1/100) to avoid floating-point rounding errors.
library;

const int paisePerRupee = 100;

/// A display currency. Amounts are not converted; this only changes how
/// they are written.
class Currency {
  const Currency(this.code, this.symbol, this.name, {this.indianGrouping = false, String? asciiSymbol}) : asciiSymbol = asciiSymbol ?? symbol;

  final String code;
  final String symbol;
  final String name;

  /// Lakh/crore grouping (12,34,567) and K/L/Cr compact suffixes.
  final bool indianGrouping;

  /// Symbol safe for the built-in PDF fonts.
  final String asciiSymbol;
}

const inr = Currency('INR', '₹', 'Indian rupee', indianGrouping: true, asciiSymbol: 'Rs ');

const currencies = [
  inr,
  Currency('USD', r'$', 'US dollar'),
  Currency('EUR', '€', 'Euro', asciiSymbol: 'EUR '),
  Currency('GBP', '£', 'British pound', asciiSymbol: 'GBP '),
  Currency('AED', 'AED ', 'UAE dirham'),
  Currency('SGD', r'S$', 'Singapore dollar'),
  Currency('AUD', r'A$', 'Australian dollar'),
  Currency('CAD', r'C$', 'Canadian dollar'),
];

/// Looks up a currency by ISO code, falling back to INR.
Currency currencyByCode(String? code) => currencies.firstWhere((c) => c.code == code, orElse: () => inr);

/// The currency used by [formatInr] and friends. Set by `AppState`.
Currency currentCurrency = inr;

/// Symbol for input labels and prefixes, e.g. `₹`, `$`, `AED`.
String get currencySymbol => currentCurrency.symbol.trim();

/// Groups digits the western way: 1234567 -> 1,234,567.
String groupWestern(int value) {
  final digits = value.abs().toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

/// Longest first so `S$` is stripped before `$`.
final _symbolsLongestFirst = currencies.map((c) => c.symbol.trim()).toList()..sort((a, b) => b.length.compareTo(a.length));

String _group(int value) => currentCurrency.indianGrouping ? groupIndian(value) : groupWestern(value);

/// Groups digits the Indian way: 1234567 -> 12,34,567.
String groupIndian(int value) {
  final digits = value.abs().toString();
  if (digits.length <= 3) return digits;
  final last3 = digits.substring(digits.length - 3);
  var rest = digits.substring(0, digits.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

/// Formats minor units in [currentCurrency], e.g. `₹1,23,456`, `−₹486`,
/// `+₹2,500`, `₹12.50` (or `$1,234,567` for USD).
///
/// [signed] prefixes `+` for positive values; negatives always get `−`.
/// Paise are only shown when non-zero.
String formatInr(int paise, {bool signed = false}) {
  final negative = paise < 0;
  final abs = paise.abs();
  final rupees = abs ~/ paisePerRupee;
  final rem = abs % paisePerRupee;
  final body = rem == 0 ? _group(rupees) : '${_group(rupees)}.${rem.toString().padLeft(2, '0')}';
  final sign = negative ? '−' : (signed && paise > 0 ? '+' : '');
  return '$sign${currentCurrency.symbol}$body';
}

/// Compact form for tight spaces: ₹950, ₹18.5K, ₹12.08L, ₹1.2Cr
/// (K/M/B for non-INR currencies).
String formatInrCompact(int paise) {
  final negative = paise < 0;
  final rupees = paise.abs() / paisePerRupee;
  String out;
  if (!currentCurrency.indianGrouping) {
    if (rupees >= 1000000000) {
      out = '${_trim(rupees / 1000000000, 2)}B';
    } else if (rupees >= 1000000) {
      out = '${_trim(rupees / 1000000, 2)}M';
    } else if (rupees >= 1000) {
      out = '${_trim(rupees / 1000, 1)}K';
    } else {
      out = rupees.round().toString();
    }
  } else if (rupees >= 10000000) {
    out = '${_trim(rupees / 10000000, 2)}Cr';
  } else if (rupees >= 100000) {
    out = '${_trim(rupees / 100000, 2)}L';
  } else if (rupees >= 1000) {
    out = '${_trim(rupees / 1000, 1)}K';
  } else {
    out = rupees.round().toString();
  }
  return '${negative ? '−' : ''}${currentCurrency.symbol}$out';
}

String _trim(double v, int decimals) {
  var s = v.toStringAsFixed(decimals);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  }
  return s;
}

/// Parses user input like `1,234.5`, `₹ 486`, `-20` into paise.
/// Any supported currency symbol is ignored. Returns null when the input
/// is not a valid amount.
int? parseInr(String input) {
  var cleaned = input;
  for (final symbol in _symbolsLongestFirst) {
    cleaned = cleaned.replaceAll(symbol, '');
  }
  cleaned = cleaned.replaceAll(RegExp(r'[,\s]'), '').replaceAll('−', '-');
  if (cleaned.isEmpty) return null;
  final match = RegExp(r'^-?\d+(\.\d{1,2})?$').firstMatch(cleaned);
  if (match == null) return null;
  final negative = cleaned.startsWith('-');
  final unsigned = negative ? cleaned.substring(1) : cleaned;
  final parts = unsigned.split('.');
  final rupees = int.parse(parts[0]);
  final paise = parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0;
  final total = rupees * paisePerRupee + paise;
  return negative ? -total : total;
}
