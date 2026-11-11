import 'package:flutter/foundation.dart';
import 'package:inmonode/features/iam/application/restore_session_use_case.dart';
import 'package:inmonode/features/iam/application/sign_out_use_case.dart';
import 'package:inmonode/features/iam/domain/session.dart';

enum SessionStatus { restoring, signedOut, signedIn }

/// App-wide session state: decides between sign-in and the navigation of the user's role.
class SessionViewModel extends ChangeNotifier {
  final RestoreSessionUseCase restoreSession;
  final SignOutUseCase endSession;

  SessionViewModel({required this.restoreSession, required this.endSession});

  SessionStatus status = SessionStatus.restoring;
  Session? session;
  bool isSigningOut = false;

  Future<void> restore() async {
    status = SessionStatus.restoring;
    notifyListeners();
    try {
      session = await restoreSession.execute();
    } finally {
      status = session == null ? SessionStatus.signedOut : SessionStatus.signedIn;
      notifyListeners();
    }
  }

  void onSignedIn(Session newSession) {
    session = newSession;
    status = SessionStatus.signedIn;
    notifyListeners();
  }

  Future<void> signOut() async {
    isSigningOut = true;
    notifyListeners();
    try {
      await endSession.execute();
    } finally {
      isSigningOut = false;
      expire();
    }
  }

  /// Returns to sign-in, e.g. when the session can no longer be renewed.
  void expire() {
    if (status == SessionStatus.signedOut) return;
    session = null;
    status = SessionStatus.signedOut;
    notifyListeners();
  }
}
