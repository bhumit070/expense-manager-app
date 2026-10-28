import 'package:expense_manager/core/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('groupIndian', () {
    test('groups lakhs and crores', () {
      expect(groupIndian(0), '0');
      expect(groupIndian(999), '999');
      expect(groupIndian(1000), '1,000');
      expect(groupIndian(100000), '1,00,000');
      expect(groupIndian(1234567), '12,34,567');
      expect(groupIndian(123456789), '12,34,56,789');
      expect(groupIndian(-48600), '48,600');
    });
  });

  group('formatInr', () {
    test('whole rupees', () => expect(formatInr(4860000), '₹48,600'));
    test('paise shown only when non-zero', () => expect(formatInr(1250), '₹12.50'));
    test('negative uses minus sign', () => expect(formatInr(-48600), '−₹486'));
    test('signed positive', () => expect(formatInr(250000, signed: true), '+₹2,500'));
    test('signed zero has no sign', () => expect(formatInr(0, signed: true), '₹0'));
  });

  group('formatInrCompact', () {
    test('ranges', () {
      expect(formatInrCompact(95000), '₹950');
      expect(formatInrCompact(1850000), '₹18.5K');
      expect(formatInrCompact(100000), '₹1K');
      expect(formatInrCompact(120800000), '₹12.08L');
      expect(formatInrCompact(1000000000), '₹1Cr');
      expect(formatInrCompact(1234567800), '₹1.23Cr');
      expect(formatInrCompact(-1850000), '−₹18.5K');
    });
  });

  group('parseInr', () {
    test('valid inputs', () {
      expect(parseInr('486'), 48600);
      expect(parseInr('₹ 1,234.5'), 123450);
      expect(parseInr('12.05'), 1205);
      expect(parseInr('-20'), -2000);
      expect(parseInr('−20'), -2000);
    });
    test('invalid inputs', () {
      expect(parseInr(''), isNull);
      expect(parseInr('  '), isNull);
      expect(parseInr('abc'), isNull);
      expect(parseInr('1.234'), isNull);
      expect(parseInr('1..2'), isNull);
    });
  });

  group('currencies', () {
    tearDown(() => currentCurrency = inr);

    test('lookup falls back to INR', () {
      expect(currencyByCode('USD').symbol, r'$');
      expect(currencyByCode('XYZ'), same(inr));
      expect(currencyByCode(null), same(inr));
      expect(currencies.map((c) => c.code).toSet().length, currencies.length);
    });

    test('western grouping', () {
      expect(groupWestern(0), '0');
      expect(groupWestern(999), '999');
      expect(groupWestern(1000), '1,000');
      expect(groupWestern(1234567), '1,234,567');
      expect(groupWestern(-123456), '123,456');
    });

    test('formatting follows the current currency', () {
      currentCurrency = currencyByCode('USD');
      expect(currencySymbol, r'$');
      expect(formatInr(123456789), r'$1,234,567.89');
      expect(formatInr(-48600), r'−$486');
      expect(formatInrCompact(95000), r'$950');
      expect(formatInrCompact(1850000), r'$18.5K');
      expect(formatInrCompact(123400000), r'$1.23M');
      expect(formatInrCompact(250000000000), r'$2.5B');
      expect(formatInrCompact(-1850000), r'−$18.5K');
      currentCurrency = currencyByCode('AED');
      expect(currencySymbol, 'AED');
      expect(formatInr(100000), 'AED 1,000');
    });

    test('parse ignores any supported symbol', () {
      expect(parseInr(r'S$ 1,234.50'), 123450);
      expect(parseInr(r'$20'), 2000);
      expect(parseInr('€5'), 500);
      expect(parseInr('AED 7'), 700);
      expect(parseInr(r'S$'), isNull);
    });
  });
}
