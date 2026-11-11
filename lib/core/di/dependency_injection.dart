import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:inmonode/core/network/authorized_client.dart';
import 'package:inmonode/core/network/token_provider.dart';
import 'package:inmonode/features/catalog/application/get_project_detail_use_case.dart';
import 'package:inmonode/features/catalog/application/get_published_projects_use_case.dart';
import 'package:inmonode/features/catalog/domain/project_repository.dart';
import 'package:inmonode/features/catalog/infrastructure/project_repository_impl.dart';
import 'package:inmonode/features/catalog/infrastructure/remote/project_api.dart';
import 'package:inmonode/features/catalog/presentation/project_detail_view_model.dart';
import 'package:inmonode/features/catalog/presentation/projects_view_model.dart';
import 'package:inmonode/features/iam/application/refresh_session_use_case.dart';
import 'package:inmonode/features/iam/application/register_account_use_case.dart';
import 'package:inmonode/features/iam/application/request_password_reset_use_case.dart';
import 'package:inmonode/features/iam/application/resend_verification_use_case.dart';
import 'package:inmonode/features/iam/application/reset_password_use_case.dart';
import 'package:inmonode/features/iam/application/restore_session_use_case.dart';
import 'package:inmonode/features/iam/application/session_token_provider.dart';
import 'package:inmonode/features/iam/application/sign_in_use_case.dart';
import 'package:inmonode/features/iam/application/sign_out_use_case.dart';
import 'package:inmonode/features/iam/application/verify_email_use_case.dart';
import 'package:inmonode/features/iam/domain/auth_repository.dart';
import 'package:inmonode/features/iam/domain/session_repository.dart';
import 'package:inmonode/features/iam/infrastructure/auth_repository_impl.dart';
import 'package:inmonode/features/iam/infrastructure/remote/auth_api.dart';
import 'package:inmonode/features/iam/infrastructure/session_repository_impl.dart';
import 'package:inmonode/features/iam/presentation/forgot_password_view_model.dart';
import 'package:inmonode/features/iam/presentation/login_view_model.dart';
import 'package:inmonode/features/iam/presentation/register_view_model.dart';
import 'package:inmonode/features/iam/presentation/resend_verification_view_model.dart';
import 'package:inmonode/features/iam/presentation/reset_password_view_model.dart';
import 'package:inmonode/features/iam/presentation/session_view_model.dart';
import 'package:inmonode/features/iam/presentation/verify_email_view_model.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  _setupIam();
  _setupNetwork();
  _setupCatalog();
}

void _setupCatalog() {
  getIt.registerLazySingleton<ProjectApi>(() => ProjectApi());
  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(api: getIt<ProjectApi>()),
  );
  getIt.registerLazySingleton<GetPublishedProjectsUseCase>(
    () => GetPublishedProjectsUseCase(repository: getIt<ProjectRepository>()),
  );
  getIt.registerLazySingleton<GetProjectDetailUseCase>(
    () => GetProjectDetailUseCase(repository: getIt<ProjectRepository>()),
  );
  // A navigation section, not a pushed page: it keeps its catalog while the user switches sections.
  getIt.registerLazySingleton<ProjectsViewModel>(
    () => ProjectsViewModel(getPublishedProjects: getIt<GetPublishedProjectsUseCase>()),
  );
  getIt.registerFactory<ProjectDetailViewModel>(
    () => ProjectDetailViewModel(getProjectDetail: getIt<GetProjectDetailUseCase>()),
  );
}

/// Protected endpoints use `getIt<AuthorizedClient>()`, which sends the session's access token.
void _setupNetwork() {
  getIt.registerLazySingleton<TokenProvider>(
    () => SessionTokenProvider(
      sessionRepository: getIt<SessionRepository>(),
      refreshSession: getIt<RefreshSessionUseCase>(),
      onSessionEnded: () => getIt<SessionViewModel>().expire(),
    ),
  );
  getIt.registerLazySingleton<AuthorizedClient>(
    () => AuthorizedClient(tokenProvider: getIt<TokenProvider>()),
  );
}

void _setupIam() {
  getIt.registerLazySingleton<AuthApi>(() => AuthApi());
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(api: getIt<AuthApi>()),
  );
  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(storage: const FlutterSecureStorage()),
  );

  getIt.registerLazySingleton<RegisterAccountUseCase>(
    () => RegisterAccountUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ResendVerificationUseCase>(
    () => ResendVerificationUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<RequestPasswordResetUseCase>(
    () => RequestPasswordResetUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(
      authRepository: getIt<AuthRepository>(),
      sessionRepository: getIt<SessionRepository>(),
    ),
  );
  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(
      authRepository: getIt<AuthRepository>(),
      sessionRepository: getIt<SessionRepository>(),
    ),
  );
  getIt.registerLazySingleton<RefreshSessionUseCase>(
    () => RefreshSessionUseCase(
      authRepository: getIt<AuthRepository>(),
      sessionRepository: getIt<SessionRepository>(),
    ),
  );
  getIt.registerLazySingleton<RestoreSessionUseCase>(
    () => RestoreSessionUseCase(
      sessionRepository: getIt<SessionRepository>(),
      refreshSession: getIt<RefreshSessionUseCase>(),
    ),
  );

  getIt.registerLazySingleton<SessionViewModel>(
    () => SessionViewModel(
      restoreSession: getIt<RestoreSessionUseCase>(),
      endSession: getIt<SignOutUseCase>(),
    ),
  );
  // Page view models start fresh each time their page opens.
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(
      signIn: getIt<SignInUseCase>(),
      sessionViewModel: getIt<SessionViewModel>(),
    ),
  );
  getIt.registerFactory<RegisterViewModel>(
    () => RegisterViewModel(registerAccount: getIt<RegisterAccountUseCase>()),
  );
  getIt.registerFactory<ResendVerificationViewModel>(
    () => ResendVerificationViewModel(
      resendVerification: getIt<ResendVerificationUseCase>(),
    ),
  );
  getIt.registerFactory<VerifyEmailViewModel>(
    () => VerifyEmailViewModel(verifyEmail: getIt<VerifyEmailUseCase>()),
  );
  getIt.registerFactory<ForgotPasswordViewModel>(
    () => ForgotPasswordViewModel(
      requestPasswordReset: getIt<RequestPasswordResetUseCase>(),
    ),
  );
  getIt.registerFactory<ResetPasswordViewModel>(
    () => ResetPasswordViewModel(resetPassword: getIt<ResetPasswordUseCase>()),
  );
}
