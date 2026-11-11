import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/iam/application/refresh_session_use_case.dart';
import 'package:inmonode/features/iam/application/restore_session_use_case.dart';
import 'package:inmonode/features/iam/application/sign_in_use_case.dart';
import 'package:inmonode/features/iam/application/sign_out_use_case.dart';
import 'package:inmonode/features/iam/presentation/login_page.dart';
import 'package:inmonode/features/iam/presentation/login_view_model.dart';
import 'package:inmonode/features/iam/presentation/session_view_model.dart';

import '../iam_fakes.dart';

void main() {
  late FakeAuthRepository auth;
  late LoginViewModel viewModel;

  setUp(() {
    auth = FakeAuthRepository();
    final sessions = InMemorySessionRepository();
    viewModel = LoginViewModel(
      signIn: SignInUseCase(authRepository: auth, sessionRepository: sessions),
      sessionViewModel: SessionViewModel(
        restoreSession: RestoreSessionUseCase(
          sessionRepository: sessions,
          refreshSession: RefreshSessionUseCase(authRepository: auth, sessionRepository: sessions),
        ),
        endSession: SignOutUseCase(authRepository: auth, sessionRepository: sessions),
      ),
    );
  });

  Future<void> pumpLoginPage(WidgetTester tester) {
    return tester.pumpWidget(MaterialApp(home: LoginPage(viewModel: viewModel)));
  }

  testWidgets('asks for the email and password before calling the server', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(auth.signedInEmails, isEmpty);
  });

  testWidgets('offers a new verification link to an account that is not active', (tester) async {
    auth.onSignIn = (_, _) async => throw apiError(
      403,
      'ACCOUNT_INACTIVE',
      'Cuenta no activa: verifica tu correo antes de iniciar sesión',
    );
    await pumpLoginPage(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'ana@mail.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Cuenta no activa: verifica tu correo antes de iniciar sesión'), findsOneWidget);
    expect(find.text('Reenviar enlace de verificación'), findsOneWidget);
  });
}
