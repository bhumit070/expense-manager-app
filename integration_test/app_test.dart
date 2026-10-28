import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers.dart';
import 'add_spend_flow.dart';

// Run on a device or emulator:
//   flutter test integration_test --flavor dev -d <device-id>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('skip onboarding, add a spend, see it in list, insights and budget', (tester) async {
    await addSpendFlow(tester, makeState(onboarded: false, now: DateTime.now()));
  });
}
