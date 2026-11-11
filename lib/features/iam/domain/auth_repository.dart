import 'package:inmonode/features/iam/domain/account.dart';
import 'package:inmonode/features/iam/domain/session.dart';

abstract class AuthRepository {
  Future<Account> register(String email, String password);

  Future<Account> verifyEmail(String token);

  Future<void> resendVerification(String email);

  Future<Session> signIn(String email, String password);

  /// Exchanges the single-use [refreshToken] for a new session.
  Future<Session> refresh(String refreshToken);

  Future<void> signOut(String refreshToken);
}
