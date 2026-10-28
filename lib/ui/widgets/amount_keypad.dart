import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../theme/tokens.dart';
import 'common.dart';
import '../theme/icons.dart';

/// Paise as the user would type it: `1250`, `12.50`.
String plainAmount(int paise) => paise % paisePerRupee == 0 ? '${paise ~/ paisePerRupee}' : (paise / paisePerRupee).toStringAsFixed(2);

/// What has been typed on the [AmountKeypad]: numbers joined by + and −.
class AmountInput {
  AmountInput([this.text = '']);

  String text;

  static const _ops = ['+', '−'];
  static final _terms = RegExp(r'([+−]?)(\d+(?:\.\d*)?)');

  String get _current => text.split(RegExp('[+−]')).last;

  bool get _endsWithOp => text.isNotEmpty && _ops.contains(text[text.length - 1]);

  /// Applies one key: a digit, `.`, `00`, `+`, `−`, `⌫`, `C` or `=`.
  void press(String key) {
    switch (key) {
      case '⌫':
        if (text.isNotEmpty) text = text.substring(0, text.length - 1);
      case 'C':
        text = '';
      case '=':
        final v = value;
        text = v == null || v <= 0 ? '' : plainAmount(v);
      case '+' || '−':
        if (text.isEmpty) return;
        if (_endsWithOp || text.endsWith('.')) text = text.substring(0, text.length - 1);
        text += key;
      case '.':
        if (_current.contains('.')) return;
        text += _current.isEmpty ? '0.' : '.';
      case '00':
        press('0');
        press('0');
      default:
        final cur = _current;
        if (cur.contains('.') && cur.split('.').last.length >= 2) return;
        if (cur.replaceAll('.', '').length >= 9) return;
        if (cur == '0') {
          text = text.substring(0, text.length - 1) + key;
        } else {
          text += key;
        }
    }
  }

  /// True when the input contains maths to evaluate.
  bool get hasMath => _terms.allMatches(text).length > 1;

  /// The total in paise; null when nothing has been typed.
  int? get value {
    final terms = _terms.allMatches(text).toList();
    if (terms.isEmpty) return null;
    var total = 0;
    for (final m in terms) {
      final parts = m.group(2)!.split('.');
      final paise = int.parse(parts[0]) * paisePerRupee + (parts.length > 1 && parts[1].isNotEmpty ? int.parse(parts[1].padRight(2, '0')) : 0);
      total += m.group(1) == '−' ? -paise : paise;
    }
    return total;
  }

  /// [text] with Indian digit grouping, e.g. `1,25,000+500`.
  String get display {
    if (text.isEmpty) return '0';
    return text.replaceAllMapped(RegExp(r'\d+'), (m) {
      final before = m.start > 0 ? text[m.start - 1] : '';
      return before == '.' ? m.group(0)! : groupIndian(int.parse(m.group(0)!));
    });
  }
}

/// Calculator-style keypad for amounts.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({super.key, required this.onKey, required this.accent});

  final ValueChanged<String> onKey;
  final Color accent;

  static const _rows = [
    ['1', '2', '3', '⌫'],
    ['4', '5', '6', '+'],
    ['7', '8', '9', '−'],
    ['.', '0', '00', '='],
  ];

  static String keyName(String k) => switch (k) {
    '⌫' => 'back',
    '+' => 'plus',
    '−' => 'minus',
    '=' => 'eq',
    _ => k,
  };

  /// What a screen reader says for each key.
  static String keyLabel(String k) => switch (k) {
    '+' => 'Plus',
    '−' => 'Minus',
    '=' => 'Equals',
    '.' => 'Decimal point',
    '00' => 'Double zero',
    _ => k,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        for (final row in _rows)
          Row(
            children: [
              for (final k in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Material(
                      color: int.tryParse(k) != null || k == '.' || k == '00' ? c.surface : c.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        key: Key('key-${keyName(k)}'),
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onKey(k),
                        onLongPress: k == '⌫' ? () => onKey('C') : null,
                        child: SizedBox(
                          height: 52,
                          child: Center(
                            child: k == '⌫'
                                ? Icon(AppIcons.backspace, color: c.textMuted, semanticLabel: 'Backspace')
                                : Text(
                                    k,
                                    semanticsLabel: keyLabel(k),
                                    style: ts(22, weight: FontWeight.w600, color: k == '=' || k == '+' || k == '−' ? accent : c.text),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
