import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: the monthly installment is {'S/ 897.55'}
Future<void> theMonthlyInstallmentIs(WidgetTester tester, String amount) async {
  final highlight = find.ancestor(of: find.text('Cuota mensual'), matching: find.byType(Card)).first;
  expect(find.descendant(of: highlight, matching: find.text(amount)), findsOneWidget);
}
