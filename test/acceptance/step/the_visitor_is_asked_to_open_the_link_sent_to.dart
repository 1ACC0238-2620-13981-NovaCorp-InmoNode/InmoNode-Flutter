import 'package:flutter_test/flutter_test.dart';

/// Usage: the visitor is asked to open the link sent to {'ana@mail.com'}
Future<void> theVisitorIsAskedToOpenTheLinkSentTo(WidgetTester tester, String email) async {
  expect(find.text('Revisa tu correo'), findsOneWidget);
  expect(find.textContaining('Enviamos un enlace de verificación a $email.'), findsOneWidget);
}
