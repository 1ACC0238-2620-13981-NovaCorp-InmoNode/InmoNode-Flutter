import 'package:inmonode/features/iam/domain/account.dart';
import 'package:inmonode/features/iam/domain/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository repository;

  const VerifyEmailUseCase({required this.repository});

  Future<Account> execute(String token) {
    return repository.verifyEmail(token);
  }
}
