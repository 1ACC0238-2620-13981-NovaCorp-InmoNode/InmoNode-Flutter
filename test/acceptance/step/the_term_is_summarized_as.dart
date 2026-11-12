import 'package:flutter_test/flutter_test.dart';

/// Usage: the term is summarized as {'60 cuotas, la última de S/ 897.84 por redondeo'}
Future<void> theTermIsSummarizedAs(WidgetTester tester, String summary) async {
  expect(find.text(summary), findsOneWidget);
}
