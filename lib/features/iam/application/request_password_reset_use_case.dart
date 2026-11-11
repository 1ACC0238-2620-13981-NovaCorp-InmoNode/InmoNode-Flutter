import 'package:inmonode/features/iam/domain/auth_repository.dart';

class RequestPasswordResetUseCase {
  final AuthRepository repository;

  const RequestPasswordResetUseCase({required this.repository});

  Future<void> execute(String email) {
    return repository.requestPasswordReset(email.trim());
  }
}
