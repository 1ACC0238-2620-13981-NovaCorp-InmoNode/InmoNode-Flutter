import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/application/request_password_reset_use_case.dart';

/// Requests the emailed link to choose a new password.
class ForgotPasswordViewModel extends ChangeNotifier {
  /// The Web Services send nothing to the same account within 60 s.
  static const int cooldownSeconds = 60;

  final RequestPasswordResetUseCase requestPasswordReset;

  ForgotPasswordViewModel({required this.requestPasswordReset});

  /// The email the link was requested for; `null` while the user is still typing it.
  String? sentTo;
  int secondsLeft = 0;
  bool isSending = false;
  String? message;
  String? errorMessage;

  Timer? _timer;
  bool _disposed = false;

  bool get canResend => sentTo != null && !isSending && secondsLeft == 0;

  Future<void> send(String email) async {
    if (isSending) return;
    await _request(email);
  }

  Future<void> resend() async {
    if (!canResend) return;
    await _request(sentTo!);
    // The server answers the same whether or not the account exists, so the message cannot be sure.
    if (errorMessage == null) {
      message = 'Si la cuenta está activa, te enviamos un nuevo enlace. El anterior ya no sirve.';
      notifyListeners();
    }
  }

  /// Goes back to the form, e.g. after a typo in the email.
  void changeEmail() {
    _timer?.cancel();
    sentTo = null;
    secondsLeft = 0;
    message = null;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> _request(String email) async {
    isSending = true;
    message = null;
    errorMessage = null;
    notifyListeners();
    try {
      await requestPasswordReset.execute(email);
      sentTo = email;
      _startCooldown();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  void _startCooldown() {
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
