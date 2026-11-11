import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/domain/account.dart';
import 'package:inmonode/features/iam/domain/auth_repository.dart';
import 'package:inmonode/features/iam/domain/session.dart';
import 'package:inmonode/features/iam/domain/session_repository.dart';
import 'package:inmonode/features/iam/domain/user_role.dart';

final DateTime fixedNow = DateTime.utc(2026, 11, 11, 12);

Session testSession({
  String accessToken = 'access-1',
  String refreshToken = 'refresh-1',
  DateTime? expiresAt,
  UserRole role = UserRole.buyer,
}) {
  return Session(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresAt: expiresAt ?? fixedNow.add(const Duration(hours: 1)),
    userId: 7,
    email: 'ana@mail.com',
    role: role,
  );
}

Account testAccount({AccountStatus status = AccountStatus.inactive}) {
  return Account(id: 7, email: 'ana@mail.com', role: UserRole.buyer, status: status);
}

ApiException apiError(int statusCode, String code, [String message = 'Mensaje del servidor']) {
  return ApiException(statusCode: statusCode, code: code, message: message);
}

class FakeAuthRepository implements AuthRepository {
  Future<Account> Function(String email, String password)? onRegister;
  Future<Account> Function(String token)? onVerifyEmail;
  Future<Session> Function(String email, String password)? onSignIn;
  Future<Session> Function(String refreshToken)? onRefresh;
  Future<void> Function(String refreshToken)? onSignOut;
  Future<void> Function(String email)? onRequestPasswordReset;
  Future<void> Function(String token, String newPassword)? onResetPassword;

  final List<String> registeredEmails = [];
  final List<String> signedInEmails = [];
  final List<String> resentTo = [];
  final List<String> refreshedTokens = [];
  final List<String> signedOutTokens = [];
  final List<String> passwordResetsRequested = [];

  @override
  Future<Account> register(String email, String password) {
    registeredEmails.add(email);
    return onRegister!(email, password);
  }

  @override
  Future<Account> verifyEmail(String token) => onVerifyEmail!(token);

  @override
  Future<void> resendVerification(String email) async => resentTo.add(email);

  @override
  Future<Session> signIn(String email, String password) {
    signedInEmails.add(email);
    return onSignIn!(email, password);
  }

  @override
  Future<Session> refresh(String refreshToken) {
    refreshedTokens.add(refreshToken);
    return onRefresh!(refreshToken);
  }

  @override
  Future<void> signOut(String refreshToken) async {
    signedOutTokens.add(refreshToken);
    await onSignOut?.call(refreshToken);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    passwordResetsRequested.add(email);
    await onRequestPasswordReset?.call(email);
  }

  @override
  Future<void> resetPassword(String token, String newPassword) {
    return onResetPassword!(token, newPassword);
  }
}

class InMemorySessionRepository implements SessionRepository {
  Session? session;

  InMemorySessionRepository([this.session]);

  @override
  Future<Session?> load() async => session;

  @override
  Future<void> save(Session session) async => this.session = session;

  @override
  Future<void> clear() async => session = null;
}
