import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the buyer enters a down payment of {'4500'} and a term of {60} months
Future<void> theBuyerEntersADownPaymentOfAndATermOfMonths(WidgetTester tester, String downPayment, num months) async {
  await enterField(tester, 'Cuota inicial', downPayment);
  final slider = tester.widget<Slider>(find.byType(Slider));
  if (slider.value != months) {
    slider.onChanged!(months.toDouble());
    await tester.pumpAndSettle();
  }
  expect(find.text('$months meses'), findsOneWidget);
}
