import 'package:expense_manager/ui/theme/icons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every app icon comes from the Lucide font', () {
    expect(AppIcons.all, isNotEmpty);
    for (final icon in AppIcons.all) {
      expect(icon.fontFamily, 'Lucide');
      expect(icon.fontPackage, 'lucide_icons_flutter');
    }
  });
}
