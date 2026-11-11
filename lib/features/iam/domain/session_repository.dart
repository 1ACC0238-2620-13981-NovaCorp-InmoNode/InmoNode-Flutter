import 'package:inmonode/features/iam/domain/session.dart';

/// Keeps the session between app launches.
abstract class SessionRepository {
  Future<Session?> load();

  Future<void> save(Session session);

  Future<void> clear();
}
