import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the field {'Ubicación *'} is marked with {'Completa este campo'}
Future<void> theFieldIsMarkedWith(WidgetTester tester, String label, String message) async {
  expect(find.descendant(of: field(label), matching: find.text(message)), findsOneWidget);
}
