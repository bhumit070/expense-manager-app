import 'package:expense_manager/core/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flavor comes from --flavor, then the dart-define, else prod', () {
    expect(resolveFlavor(buildFlavor: 'dev'), Flavor.dev);
    expect(resolveFlavor(buildFlavor: 'prod', define: 'dev'), Flavor.prod);
    expect(resolveFlavor(buildFlavor: '', define: 'DEV'), Flavor.dev);
    expect(resolveFlavor(define: 'staging'), Flavor.prod);
    expect(resolveFlavor(), Flavor.prod);
    expect(currentFlavor, Flavor.prod);
  });

  test('dev and prod use separate databases', () {
    expect(databaseFileName(Flavor.prod), 'expense_manager.db');
    expect(databaseFileName(Flavor.dev), 'expense_manager_dev.db');
  });
}
