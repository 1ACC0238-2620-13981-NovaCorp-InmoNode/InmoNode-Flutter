import 'package:flutter/foundation.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/application/verify_email_use_case.dart';

enum VerificationStatus { verifying, verified, failed }

class VerifyEmailViewModel extends ChangeNotifier {
  final VerifyEmailUseCase verifyEmail;

  VerifyEmailViewModel({required this.verifyEmail});

  VerificationStatus status = VerificationStatus.verifying;
  String? email;
  String? errorMessage;

  /// The server could not be reached, so trying the same link again may work.
  bool canRetry = false;

  Future<void> verify(String token) async {
    status = VerificationStatus.verifying;
    errorMessage = null;
    canRetry = false;
    notifyListeners();
    try {
      email = (await verifyEmail.execute(token)).email;
      status = VerificationStatus.verified;
    } on ApiException catch (e) {
      status = VerificationStatus.failed;
      canRetry = e.isNetworkError;
      errorMessage = e.code == 'VALIDATION_ERROR'
          ? 'El enlace de verificación no es válido, expiró o ya fue usado.'
          : e.message;
    }
    notifyListeners();
  }
}
