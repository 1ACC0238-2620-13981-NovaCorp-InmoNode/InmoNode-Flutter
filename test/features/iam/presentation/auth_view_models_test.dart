import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/application/refresh_session_use_case.dart';
import 'package:inmonode/features/iam/application/register_account_use_case.dart';
import 'package:inmonode/features/iam/application/restore_session_use_case.dart';
import 'package:inmonode/features/iam/application/sign_in_use_case.dart';
import 'package:inmonode/features/iam/application/sign_out_use_case.dart';
import 'package:inmonode/features/iam/application/verify_email_use_case.dart';
import 'package:inmonode/features/iam/domain/account.dart';
import 'package:inmonode/features/iam/presentation/login_view_model.dart';
import 'package:inmonode/features/iam/presentation/register_view_model.dart';
import 'package:inmonode/features/iam/presentation/session_view_model.dart';
import 'package:inmonode/features/iam/presentation/verify_email_view_model.dart';

import '../iam_fakes.dart';

void main() {
  late FakeAuthRepository auth;
  late InMemorySessionRepository sessions;
  late SessionViewModel sessionViewModel;

  setUp(() {
    auth = FakeAuthRepository();
    sessions = InMemorySessionRepository();
    sessionViewModel = SessionViewModel(
      restoreSession: RestoreSessionUseCase(
        sessionRepository: sessions,
        refreshSession: RefreshSessionUseCase(authRepository: auth, sessionRepository: sessions),
        now: () => fixedNow,
      ),
      endSession: SignOutUseCase(authRepository: auth, sessionRepository: sessions),
    );
  });

  group('RegisterViewModel', () {
    late RegisterViewModel viewModel;

    setUp(() {
      viewModel = RegisterViewModel(registerAccount: RegisterAccountUseCase(repository: auth));
    });

    test('returns the new account, still inactive', () async {
      auth.onRegister = (_, _) async => testAccount();

      final account = await viewModel.submit('ana@mail.com', 'secret123');

      expect(account?.status, AccountStatus.inactive);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('offers sign-in and password recovery when the email is already registered', () async {
      auth.onRegister = (_, _) async => throw apiError(
        409,
        'USER_CONFLICT',
        'El correo ya está registrado; usa la recuperación de contraseña',
      );

      final account = await viewModel.submit('ana@mail.com', 'secret123');

      expect(account, isNull);
      expect(viewModel.emailAlreadyRegistered, isTrue);
      expect(viewModel.errorMessage, contains('ya está registrado'));
    });

    test('shows other errors without the registered-email options', () async {
      auth.onRegister = (_, _) async => throw const ApiException.network();

      await viewModel.submit('ana@mail.com', 'secret123');

      expect(viewModel.emailAlreadyRegistered, isFalse);
      expect(viewModel.errorMessage, contains('No se pudo conectar'));
    });
  });

  group('LoginViewModel', () {
    late LoginViewModel viewModel;

    setUp(() {
      viewModel = LoginViewModel(
        signIn: SignInUseCase(authRepository: auth, sessionRepository: sessions),
        sessionViewModel: sessionViewModel,
      );
    });

    test('signs the user in', () async {
      final session = testSession();
      auth.onSignIn = (_, _) async => session;

      await viewModel.submit('ana@mail.com', 'secret123');

      expect(sessionViewModel.status, SessionStatus.signedIn);
      expect(sessionViewModel.session, same(session));
      expect(viewModel.errorMessage, isNull);
    });

    test('offers a new verification link when the account is not active', () async {
      auth.onSignIn = (_, _) async => throw apiError(403, 'ACCOUNT_INACTIVE', 'Cuenta no activa');

      await viewModel.submit('ana@mail.com', 'secret123');

      expect(viewModel.accountInactive, isTrue);
      expect(viewModel.errorMessage, 'Cuenta no activa');
      expect(sessionViewModel.session, isNull);
    });

    test('shows the rejection of wrong credentials', () async {
      auth.onSignIn = (_, _) async => throw apiError(401, 'INVALID_CREDENTIALS', 'Correo o contraseña inválidos');

      await viewModel.submit('ana@mail.com', 'wrong-pass');

      expect(viewModel.accountInactive, isFalse);
      expect(viewModel.errorMessage, 'Correo o contraseña inválidos');
    });
  });

  group('VerifyEmailViewModel', () {
    late VerifyEmailViewModel viewModel;

    setUp(() {
      viewModel = VerifyEmailViewModel(verifyEmail: VerifyEmailUseCase(repository: auth));
    });

    test('activates the account', () async {
      auth.onVerifyEmail = (_) async => testAccount(status: AccountStatus.active);

      await viewModel.verify('token-123');

      expect(viewModel.status, VerificationStatus.verified);
      expect(viewModel.email, 'ana@mail.com');
    });

    test('explains an invalid, expired or used link', () async {
      auth.onVerifyEmail = (_) async => throw apiError(400, 'VALIDATION_ERROR', 'Validación fallida');

      await viewModel.verify('token-123');

      expect(viewModel.status, VerificationStatus.failed);
      expect(viewModel.errorMessage, 'El enlace de verificación no es válido, expiró o ya fue usado.');
      expect(viewModel.canRetry, isFalse);
    });

    test('lets the user retry when the server could not be reached', () async {
      auth.onVerifyEmail = (_) async => throw const ApiException.network();

      await viewModel.verify('token-123');

      expect(viewModel.canRetry, isTrue);
    });
  });

  group('SessionViewModel', () {
    test('restores a kept session', () async {
      sessions.session = testSession();

      await sessionViewModel.restore();

      expect(sessionViewModel.status, SessionStatus.signedIn);
    });

    test('goes to sign-in when there is no session', () async {
      await sessionViewModel.restore();

      expect(sessionViewModel.status, SessionStatus.signedOut);
    });

    test('signs out', () async {
      sessions.session = testSession();
      await sessionViewModel.restore();

      await sessionViewModel.signOut();

      expect(sessionViewModel.status, SessionStatus.signedOut);
      expect(sessionViewModel.session, isNull);
      expect(sessions.session, isNull);
    });
  });
}
