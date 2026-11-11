import 'package:inmonode/features/iam/domain/account.dart';
import 'package:inmonode/features/iam/domain/auth_repository.dart';
import 'package:inmonode/features/iam/domain/session.dart';
import 'package:inmonode/features/iam/domain/user_role.dart';
import 'package:inmonode/features/iam/infrastructure/jwt_claims.dart';
import 'package:inmonode/features/iam/infrastructure/remote/auth_api.dart';
import 'package:inmonode/features/iam/infrastructure/remote/token_dto.dart';
import 'package:inmonode/features/iam/infrastructure/remote/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;
  final DateTime Function() now;

  AuthRepositoryImpl({required this.api, DateTime Function()? now})
    : now = now ?? DateTime.now;

  @override
  Future<Account> register(String email, String password) async {
    return _toAccount(await api.register(email, password));
  }

  @override
  Future<Account> verifyEmail(String token) async {
    return _toAccount(await api.verifyEmail(token));
  }

  @override
  Future<void> resendVerification(String email) => api.resendVerification(email);

  @override
  Future<Session> signIn(String email, String password) async {
    return _toSession(await api.login(email, password));
  }

  @override
  Future<Session> refresh(String refreshToken) async {
    return _toSession(await api.refresh(refreshToken));
  }

  @override
  Future<void> signOut(String refreshToken) => api.logout(refreshToken);

  Account _toAccount(UserDto dto) {
    return Account(
      id: dto.id,
      email: dto.email,
      role: UserRole.fromApiName(dto.role),
      status: dto.status == 'ACTIVE' ? AccountStatus.active : AccountStatus.inactive,
    );
  }

  Session _toSession(TokenDto dto) {
    final claims = JwtClaims.decode(dto.token);
    return Session(
      accessToken: dto.token,
      refreshToken: dto.refreshToken,
      // Counted from the device clock, so a skewed clock does not expire the token early.
      expiresAt: now().add(Duration(seconds: dto.expiresIn)),
      userId: claims.userId,
      email: claims.email,
      role: UserRole.fromApiName(claims.role),
    );
  }
}
