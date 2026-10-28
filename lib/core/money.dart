/// Money helpers. Amounts are stored as integer paise (1 rupee = 100 paise)
/// to avoid floating-point rounding errors.
library;

const int paisePerRupee = 100;

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

/// Formats paise as rupees, e.g. `₹1,23,456`, `−₹486`, `+₹2,500`, `₹12.50`.
///
/// [signed] prefixes `+` for positive values; negatives always get `−`.
/// Paise are only shown when non-zero.
String formatInr(int paise, {bool signed = false}) {
  final negative = paise < 0;
  final abs = paise.abs();
  final rupees = abs ~/ paisePerRupee;
  final rem = abs % paisePerRupee;
  final body = rem == 0 ? groupIndian(rupees) : '${groupIndian(rupees)}.${rem.toString().padLeft(2, '0')}';
  final sign = negative ? '−' : (signed && paise > 0 ? '+' : '');
  return '$sign₹$body';
}

/// Compact form for tight spaces: ₹950, ₹18.5K, ₹12.08L, ₹1.2Cr.
String formatInrCompact(int paise) {
  final negative = paise < 0;
  final rupees = paise.abs() / paisePerRupee;
  String out;
  if (rupees >= 10000000) {
    out = '${_trim(rupees / 10000000, 2)}Cr';
  } else if (rupees >= 100000) {
    out = '${_trim(rupees / 100000, 2)}L';
  } else if (rupees >= 1000) {
    out = '${_trim(rupees / 1000, 1)}K';
  } else {
    out = rupees.round().toString();
  }
  return '${negative ? '−' : ''}₹$out';
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
/// Returns null when the input is not a valid amount.
int? parseInr(String input) {
  final cleaned = input.replaceAll(RegExp(r'[₹,\s]'), '').replaceAll('−', '-');
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
