import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the project {'Las Dunas'} is tagged {'VENDIDO TOTALMENTE'}
Future<void> theProjectIsTagged(WidgetTester tester, String name, String tag) async {
  expect(find.descendant(of: projectCard(name), matching: find.text(tag)), findsOneWidget);
}
