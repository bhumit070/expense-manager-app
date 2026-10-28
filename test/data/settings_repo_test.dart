import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('get returns null for missing keys and set upserts', () {
    final s = makeState();
    expect(s.settings.get('theme'), isNull);
    s.settings.set('theme', 'dark');
    s.settings.set('theme', 'light');
    expect(s.settings.get('theme'), 'light');
  });
}
