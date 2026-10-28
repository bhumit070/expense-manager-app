import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/add_spend_flow.dart';
import '../helpers.dart';

void main() {
  // The device integration test's flow, run headless so CI covers it.
  testWidgets('skip onboarding, add a spend, see it in list, insights and budget', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await addSpendFlow(tester, makeState(onboarded: false));
  });
}
