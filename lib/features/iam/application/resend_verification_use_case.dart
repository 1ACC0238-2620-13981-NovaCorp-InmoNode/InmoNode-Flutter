import 'package:inmonode/features/iam/domain/auth_repository.dart';

class ResendVerificationUseCase {
  final AuthRepository repository;

  const ResendVerificationUseCase({required this.repository});

  Future<void> execute(String email) {
    return repository.resendVerification(email.trim());
  }
}
