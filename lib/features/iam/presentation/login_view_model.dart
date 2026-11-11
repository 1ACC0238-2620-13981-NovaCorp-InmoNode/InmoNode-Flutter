import 'package:flutter/foundation.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/application/sign_in_use_case.dart';
import 'package:inmonode/features/iam/presentation/session_view_model.dart';

class LoginViewModel extends ChangeNotifier {
  final SignInUseCase signIn;
  final SessionViewModel sessionViewModel;

  LoginViewModel({required this.signIn, required this.sessionViewModel});

  bool isLoading = false;
  String? errorMessage;

  /// The account exists but its email has not been verified yet.
  bool accountInactive = false;

  Future<void> submit(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    accountInactive = false;
    notifyListeners();
    try {
      sessionViewModel.onSignedIn(await signIn.execute(email, password));
    } on ApiException catch (e) {
      errorMessage = e.message;
      accountInactive = e.code == 'ACCOUNT_INACTIVE';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
