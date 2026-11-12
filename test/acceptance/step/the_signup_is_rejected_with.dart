import 'package:flutter_test/flutter_test.dart';

/// Usage: the sign-up is rejected with {'El correo ya está registrado; usa la recuperación de contraseña'}
Future<void> theSignupIsRejectedWith(WidgetTester tester, String message) async {
  expect(find.text(message), findsOneWidget);
  expect(find.text('Revisa tu correo'), findsNothing);
}
