import 'package:inmonode/features/iam/domain/auth_repository.dart';
import 'package:inmonode/features/iam/domain/session.dart';
import 'package:inmonode/features/iam/domain/session_repository.dart';

class SignInUseCase {
  final AuthRepository authRepository;
  final SessionRepository sessionRepository;

  const SignInUseCase({
    required this.authRepository,
    required this.sessionRepository,
  });

  Future<Session> execute(String email, String password) async {
    final session = await authRepository.signIn(email.trim(), password);
    await sessionRepository.save(session);
    return session;
  }
}
