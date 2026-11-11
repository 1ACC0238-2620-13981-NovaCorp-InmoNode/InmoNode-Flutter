import 'package:inmonode/features/iam/domain/auth_repository.dart';
import 'package:inmonode/features/iam/domain/session_repository.dart';

class SignOutUseCase {
  final AuthRepository authRepository;
  final SessionRepository sessionRepository;

  const SignOutUseCase({
    required this.authRepository,
    required this.sessionRepository,
  });

  /// Revokes the refresh token when the server can be reached; the local session is cleared anyway.
  Future<void> execute() async {
    final session = await sessionRepository.load();
    try {
      if (session != null) await authRepository.signOut(session.refreshToken);
    } on Exception {
      // The access token expires on its own; signing out must not depend on the network.
    } finally {
      await sessionRepository.clear();
    }
  }
}
