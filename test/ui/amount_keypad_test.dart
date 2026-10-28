import 'package:expense_manager/ui/widgets/amount_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

AmountInput typed(String keys) {
  final a = AmountInput();
  for (final k in keys.split(' ')) {
    a.press(k);
  }
  return a;
}

void main() {
  test('plainAmount', () {
    expect([plainAmount(125000), plainAmount(1250), plainAmount(5)], ['1250', '12.50', '0.05']);
  });

  test('digits, decimals and limits', () {
    expect(AmountInput().value, isNull);
    expect(AmountInput().display, '0');
    expect(typed('0 0 5').text, '5');
    expect(typed('. 5').text, '0.5');
    expect(typed('1 . 2 . 5 9').text, '1.25');
    expect(typed('1 . 2 5').value, 125);
    expect(typed('1 .').value, 100);
    expect(typed('1 2 3 4 5 6 7 8 9 1').text, '123456789');
    expect(typed('1 2 3 4 5 6 . 5').display, '1,23,456.5');
    expect(typed('1 00').text, '100');
    expect(typed('1 2 ⌫').text, '1');
    expect(typed('⌫').text, '');
    expect(typed('1 2 C').text, '');
  });

  test('maths with + and −', () {
    expect(typed('+').text, '');
    final a = typed('1 0 0 + 2 0 . 5 0 − 1 0');
    expect(a.text, '100+20.50−10');
    expect(a.hasMath, isTrue);
    expect(a.value, 11050);
    expect(a.display, '100+20.50−10');
    expect(typed('1 0 + −').text, '10−');
    expect(typed('1 0 . +').text, '10+');
    expect(typed('1 0 +').hasMath, isFalse);
    expect(typed('1 0 + 5 =').text, '15');
    expect(typed('1 0 − 2 0 =').text, '');
    expect(typed('=').text, '');
    expect(typed('5 − 5 . 2 5 =').text, '');
    expect(typed('1 0 + . 5 =').text, '10.50');
  });

  testWidgets('keys report presses; long-press backspace clears', (tester) async {
    final keys = <String>[];
    await pumpScreen(
      tester,
      makeState(),
      Scaffold(
        body: AmountKeypad(accent: Colors.red, onKey: keys.add),
      ),
    );
    for (final k in ['1', 'back', 'plus', 'minus', 'eq', '00', '.']) {
      await tester.tap(find.byKey(Key('key-$k')));
    }
    await tester.longPress(find.byKey(const Key('key-back')));
    expect(keys, ['1', '⌫', '+', '−', '=', '00', '.', 'C']);
    expect(find.bySemanticsLabel('Backspace'), findsOneWidget);
  });
}
