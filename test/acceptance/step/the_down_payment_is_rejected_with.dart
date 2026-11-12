import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the down payment is rejected with {'La cuota inicial mínima es S/ 4,500.00 (10 % del precio).'}
Future<void> theDownPaymentIsRejectedWith(WidgetTester tester, String message) async {
  expect(find.descendant(of: field('Cuota inicial'), matching: find.text(message)), findsOneWidget);
}
