import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the project {'Los Pinos'} is not tagged {'VENDIDO TOTALMENTE'}
Future<void> theProjectIsNotTagged(WidgetTester tester, String name, String tag) async {
  expect(projectCard(name), findsOneWidget);
  expect(find.descendant(of: projectCard(name), matching: find.text(tag)), findsNothing);
}
