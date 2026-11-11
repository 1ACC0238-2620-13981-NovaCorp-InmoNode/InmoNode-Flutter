import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/domain/auth_repository.dart';
import 'package:inmonode/features/iam/domain/session.dart';
import 'package:inmonode/features/iam/domain/session_repository.dart';

class RefreshSessionUseCase {
  final AuthRepository authRepository;
  final SessionRepository sessionRepository;

  const RefreshSessionUseCase({
    required this.authRepository,
    required this.sessionRepository,
  });

  /// Renews the stored session. Returns `null` when it can no longer be renewed and the user has
  /// to sign in again. Throws [ApiException] when the server could not answer.
  Future<Session?> execute() async {
    final current = await sessionRepository.load();
    if (current == null) return null;
    try {
      final renewed = await authRepository.refresh(current.refreshToken);
      await sessionRepository.save(renewed);
      return renewed;
    } on ApiException catch (e) {
      if (!e.isUnauthorized) rethrow;
      await sessionRepository.clear();
      return null;
    }
  }
}
