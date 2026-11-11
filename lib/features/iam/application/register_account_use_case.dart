import 'package:inmonode/features/iam/domain/account.dart';
import 'package:inmonode/features/iam/domain/auth_repository.dart';

class RegisterAccountUseCase {
  final AuthRepository repository;

  const RegisterAccountUseCase({required this.repository});

  Future<Account> execute(String email, String password) {
    return repository.register(email.trim(), password);
  }
}
