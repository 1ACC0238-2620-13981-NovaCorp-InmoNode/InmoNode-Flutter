import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/application/refresh_session_use_case.dart';
import 'package:inmonode/features/iam/domain/session.dart';
import 'package:inmonode/features/iam/domain/session_repository.dart';

class RestoreSessionUseCase {
  final SessionRepository sessionRepository;
  final RefreshSessionUseCase refreshSession;
  final DateTime Function() now;

  RestoreSessionUseCase({
    required this.sessionRepository,
    required this.refreshSession,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  /// The session kept from a previous launch, renewed if its access token expired.
  Future<Session?> execute() async {
    final session = await sessionRepository.load();
    if (session == null || !session.isExpired(now())) return session;
    try {
      return await refreshSession.execute();
    } on ApiException {
      // The server could not answer; keep the session and renew it with the next request.
      return session;
    }
  }
}
