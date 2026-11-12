import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the project {'Los Pinos'} shows the price range {'S/ 45,000.00 – S/ 58,000.00'}
Future<void> theProjectShowsThePriceRange(WidgetTester tester, String name, String range) async {
  expect(find.descendant(of: projectCard(name), matching: find.text(range)), findsOneWidget);
}
