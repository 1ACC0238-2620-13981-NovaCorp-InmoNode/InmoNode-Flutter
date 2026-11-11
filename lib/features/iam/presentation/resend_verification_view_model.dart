import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/application/resend_verification_use_case.dart';

class ResendVerificationViewModel extends ChangeNotifier {
  /// The Web Services ignore a new request for the same email within 60 s.
  static const int cooldownSeconds = 60;

  final ResendVerificationUseCase resendVerification;

  ResendVerificationViewModel({required this.resendVerification});

  int secondsLeft = 0;
  bool isSending = false;
  String? message;
  String? errorMessage;

  Timer? _timer;
  bool _disposed = false;

  bool get canResend => !isSending && secondsLeft == 0;

  /// Starts the wait after an email was sent, e.g. right after registering.
  void startCooldown() {
    _timer?.cancel();
    secondsLeft = cooldownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsLeft--;
      if (secondsLeft <= 0) {
        secondsLeft = 0;
        timer.cancel();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> resend(String email) async {
    if (!canResend) return;
    isSending = true;
    message = null;
    errorMessage = null;
    notifyListeners();
    try {
      await resendVerification.execute(email);
      // The server answers the same whether or not the account exists, so the message cannot be sure.
      message = 'Si la cuenta está pendiente de verificación, te enviamos un nuevo enlace.';
      startCooldown();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
