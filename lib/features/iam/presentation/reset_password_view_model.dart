import 'package:flutter/foundation.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/application/reset_password_use_case.dart';
import 'package:inmonode/features/iam/presentation/auth_validators.dart';

enum PasswordResetStatus { editing, done, linkInvalid }

class ResetPasswordViewModel extends ChangeNotifier {
  final ResetPasswordUseCase resetPassword;

  ResetPasswordViewModel({required this.resetPassword});

  PasswordResetStatus status = PasswordResetStatus.editing;
  bool isLoading = false;
  String? errorMessage;

  Future<void> submit(String token, String newPassword) async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await resetPassword.execute(token, newPassword);
      status = PasswordResetStatus.done;
    } on ApiException catch (e) {
      // Unknown, expired or already used: the server's message asks for a new link.
      if (e.code == 'INVALID_RESET_TOKEN') status = PasswordResetStatus.linkInvalid;
      errorMessage = e.code == 'VALIDATION_ERROR'
          ? 'La contraseña debe tener entre ${AuthValidators.minPasswordLength} y '
                '${AuthValidators.maxPasswordLength} caracteres.'
          : e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
