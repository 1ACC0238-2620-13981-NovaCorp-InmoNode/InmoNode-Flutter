import 'package:inmonode/features/iam/domain/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  const ResetPasswordUseCase({required this.repository});

  Future<void> execute(String token, String newPassword) {
    return repository.resetPassword(token, newPassword);
  }
}
