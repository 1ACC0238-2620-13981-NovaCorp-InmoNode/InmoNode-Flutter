import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: the schedule lists {60} monthly installments
Future<void> theScheduleListsMonthlyInstallments(WidgetTester tester, num count) async {
  expect(find.text('Cronograma de cuotas'), findsOneWidget);
  final schedule = tester.widget<DataTable>(find.byType(DataTable));
  expect(schedule.rows, hasLength(count));
}
