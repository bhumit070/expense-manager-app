import '../core/money.dart';

/// A money movement read from a bank / UPI / card SMS.
class BankSms {
  const BankSms({required this.amount, required this.credit, this.merchant = '', this.last4});

  /// Paise, always positive.
  final int amount;

  /// Money came in (credited / received) rather than went out.
  final bool credit;

  /// Who was paid (or who paid), cleaned up; empty when the SMS doesn't say.
  final String merchant;

  /// Last digits of the account or card, to match a payment source.
  final String? last4;

  @override
  String toString() => 'BankSms(${credit ? '+' : '-'}$amount, "$merchant", ${last4 ?? '-'})';
}

/// Messages that mention money but are not a completed transaction.
final _ignore = RegExp(
  r'\b(?:otp|one[- ]time password|verification code|will be (?:debited|charged|deducted)|is due|due (?:on|by|date)|min(?:imum)?\.? (?:amt|amount) due|'
  r'pre-?approved|offer|requested|collect request|declined|failed|unsuccessful|insufficient|not been (?:debited|processed)|e-?mandate|standing instruction|auto-?debit (?:is )?(?:scheduled|set))\b',
  caseSensitive: false,
);

final _debitWord = RegExp(r'\b(?:debited|spent|paid|sent|withdrawn|withdrawal|purchase|charged|txn of|transaction of|dr\.?)(?=\W|$)', caseSensitive: false);
final _creditWord = RegExp(r'\b(?:credited|received|deposited|refund(?:ed)?|cr\.?)(?=\W|$)', caseSensitive: false);

final _currencyAmount = RegExp(r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d+)?)', caseSensitive: false);
final _bareAmount = RegExp(r'\b(?:debited|credited)\s+(?:by|for|with)\s+([\d,]+(?:\.\d+)?)', caseSensitive: false);
final _balanceBefore = RegExp(r'(?:bal(?:ance)?|limit|avl\.?|available)[\s.:-]*(?:is|of)?[\s.:-]*$', caseSensitive: false);

final _account = RegExp(r'\b(?:a/c|ac|acct|account|card)(?:\s*(?:no\.?|number|ending(?:\s+(?:with|in))?))?[\s:.]*(?:[x*]+|\.{2,})?\s*(\d{3,6})\b', caseSensitive: false);

const _stop = r'(?=\s+on\b|\s+via\b|\s+ref\b|\s+refno\b|\s+upi\b|\s+using\b|\s+from\b|\s+txn\b|\s+avl\b|\s+info\b|\s+not you|\s+if not|\s*[.;,(]\s|\s*[.;]?$|-\s*[a-z]{2,}$)';
final _merchantPatterns = [
  RegExp(r';\s*(.+?)\s+credited\b', caseSensitive: false),
  RegExp(r'\bupi/(?:p2[am]/)?\d+/([^/\s]+)', caseSensitive: false),
  RegExp(r'\bon\s+\d[\w-]*\s+on\s+(.+?)' + _stop, caseSensitive: false),
  RegExp(r'\bat\s+(.+?)' + _stop, caseSensitive: false),
  RegExp(r'\b(?:trf to|paid to|sent to|transfer to|towards|to)\s+(?:vpa\s+)?(.+?)' + _stop, caseSensitive: false),
];
final _creditMerchantPatterns = [RegExp(r'\b(?:from|by)\s+(?:vpa\s+)?(.+?)' + _stop, caseSensitive: false), RegExp(r'\binfo[:\s-]+(.+?)' + _stop, caseSensitive: false)];

/// Text that names one of your own accounts rather than a counterparty.
final _notMerchant = RegExp(r'\b(?:a/c|ac|acct|account|card|your|bank|self|beneficiary)\b|^(?:rs|inr)\b|^[x*]+\d+$|^\d+$|^(?:the|a|an)$', caseSensitive: false);

/// Reads a transaction SMS. Returns null for OTPs, reminders, promotions,
/// failed payments and anything without an amount and a direction.
BankSms? parseBankSms(String body) {
  final text = body.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (text.isEmpty || _ignore.hasMatch(text)) return null;
  final debit = _debitWord.firstMatch(text);
  final creditMatch = _creditWord.firstMatch(text);
  if (debit == null && creditMatch == null) return null;
  final credit = debit == null || (creditMatch != null && creditMatch.start < debit.start);
  final amount = _amount(text);
  if (amount == null || amount <= 0) return null;
  return BankSms(amount: amount, credit: credit, merchant: _merchant(text, credit), last4: _last4(text));
}

int? _amount(String text) {
  for (final m in _currencyAmount.allMatches(text)) {
    if (_balanceBefore.hasMatch(text.substring(0, m.start))) continue;
    final v = parseInr(m[1]!.replaceFirst(RegExp(r'\.$'), ''));
    if (v != null) return v;
  }
  final bare = _bareAmount.firstMatch(text);
  return bare == null ? null : parseInr(bare[1]!);
}

String? _last4(String text) {
  final m = _account.firstMatch(text);
  if (m == null) return null;
  final digits = m[1]!;
  return digits.substring(digits.length - 4 < 0 ? 0 : digits.length - 4);
}

String _merchant(String text, bool credit) {
  for (final p in [if (credit) ..._creditMerchantPatterns, ..._merchantPatterns]) {
    for (final m in p.allMatches(text)) {
      final name = cleanMerchant(m[1]!);
      if (name.isNotEmpty) return name;
    }
  }
  return '';
}

/// "SWIGGY", "swiggy@icici", "Amazon Pay India." → "Swiggy", "Swiggy", "Amazon Pay India".
/// Returns '' when [raw] names one of your own accounts.
String cleanMerchant(String raw) {
  var s = raw.trim().replaceAll(RegExp(r'^(?:vpa|m/s\.?|mr\.?|ms\.?|mrs\.?)\s+', caseSensitive: false), '');
  if (s.contains('@')) s = s.split('@').first;
  s = s.replaceAll(RegExp(r'[._-]+'), ' ').replaceAll(RegExp(r'[^\w\s&]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (s.isEmpty || _notMerchant.hasMatch(s) || !RegExp('[a-zA-Z]').hasMatch(s)) return '';
  if (s.length > 40) s = s.substring(0, 40).trim();
  final shouting = s == s.toUpperCase() || s == s.toLowerCase();
  return shouting ? s.split(' ').map((w) => w.length <= 1 ? w.toUpperCase() : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ') : s;
}
