import 'package:flutter/foundation.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/application/register_account_use_case.dart';
import 'package:inmonode/features/iam/domain/account.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterAccountUseCase registerAccount;

  RegisterViewModel({required this.registerAccount});

  bool isLoading = false;
  String? errorMessage;

  /// US-14, Escenario 2: the email already has an account.
  bool emailAlreadyRegistered = false;

  /// The new account, still inactive, or `null` when the registration was rejected.
  Future<Account?> submit(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    emailAlreadyRegistered = false;
    notifyListeners();
    try {
      return await registerAccount.execute(email, password);
    } on ApiException catch (e) {
      emailAlreadyRegistered = e.code == 'USER_CONFLICT';
      errorMessage = e.message;
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
