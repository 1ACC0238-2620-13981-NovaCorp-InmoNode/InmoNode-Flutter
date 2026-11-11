import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/core/network/token_provider.dart';
import 'package:inmonode/features/iam/application/refresh_session_use_case.dart';
import 'package:inmonode/features/iam/domain/session_repository.dart';

/// Supplies the stored session to [AuthorizedClient] and renews it when it expires.
class SessionTokenProvider implements TokenProvider {
  final SessionRepository sessionRepository;
  final RefreshSessionUseCase refreshSession;

  /// Called when the session can no longer be renewed, so the app returns to sign-in.
  final void Function() onSessionEnded;
  final DateTime Function() now;

  // Refresh tokens are single-use: concurrent requests must share one renewal, or the second
  // one would replay a used token and the server would revoke the whole session.
  Future<bool>? _pendingRefresh;

  SessionTokenProvider({
    required this.sessionRepository,
    required this.refreshSession,
    required this.onSessionEnded,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  @override
  Future<String?> accessToken() async {
    final session = await sessionRepository.load();
    if (session == null || !session.isExpired(now())) return session?.accessToken;
    await refresh();
    return (await sessionRepository.load())?.accessToken;
  }

  @override
  Future<bool> refresh() {
    return _pendingRefresh ??= _refresh().whenComplete(() => _pendingRefresh = null);
  }

  Future<bool> _refresh() async {
    try {
      final renewed = await refreshSession.execute();
      if (renewed == null) onSessionEnded();
      return renewed != null;
    } on ApiException {
      return false;
    }
  }
}
