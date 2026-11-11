import 'package:flutter/material.dart';
import 'package:inmonode/core/di/dependency_injection.dart';
import 'package:inmonode/features/iam/presentation/email_link.dart';
import 'package:inmonode/features/iam/presentation/login_page.dart';
import 'package:inmonode/features/iam/presentation/login_view_model.dart';
import 'package:inmonode/features/iam/presentation/reset_password_page.dart';
import 'package:inmonode/features/iam/presentation/reset_password_view_model.dart';
import 'package:inmonode/features/iam/presentation/session_view_model.dart';
import 'package:inmonode/features/iam/presentation/verify_email_page.dart';
import 'package:inmonode/features/iam/presentation/verify_email_view_model.dart';
import 'package:inmonode/features/main/role_home_page.dart';

/// Root of the app: an emailed link, sign-in or the navigation of the signed-in role.
class AppEntry extends StatefulWidget {
  final SessionViewModel sessionViewModel;

  /// The emailed link the app was opened with (Web), if any.
  final EmailLink? emailLink;

  const AppEntry({
    super.key,
    required this.sessionViewModel,
    this.emailLink,
  });

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  late final LoginViewModel _loginViewModel = getIt<LoginViewModel>();
  late final VerifyEmailViewModel _verifyEmailViewModel = getIt<VerifyEmailViewModel>();
  late final ResetPasswordViewModel _resetPasswordViewModel = getIt<ResetPasswordViewModel>();
  EmailLink? _emailLink;
  late SessionStatus _lastStatus;

  @override
  void initState() {
    super.initState();
    _emailLink = widget.emailLink;
    _lastStatus = widget.sessionViewModel.status;
    widget.sessionViewModel.addListener(_onSessionChanged);
    widget.sessionViewModel.restore();
  }

  @override
  void dispose() {
    widget.sessionViewModel.removeListener(_onSessionChanged);
    super.dispose();
  }

  /// When a session ends, drops any page it left open on top of the role's navigation.
  void _onSessionChanged() {
    final status = widget.sessionViewModel.status;
    if (_lastStatus == SessionStatus.signedIn && status == SessionStatus.signedOut) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    _lastStatus = status;
  }

  @override
  Widget build(BuildContext context) {
    final link = _emailLink;
    if (link != null) {
      void leaveLink() => setState(() => _emailLink = null);
      return switch (link.type) {
        EmailLinkType.verifyEmail => VerifyEmailPage(
          token: link.token,
          viewModel: _verifyEmailViewModel,
          onContinue: leaveLink,
        ),
        EmailLinkType.resetPassword => ResetPasswordPage(
          token: link.token,
          viewModel: _resetPasswordViewModel,
          onContinue: leaveLink,
        ),
      };
    }

    return ListenableBuilder(
      listenable: widget.sessionViewModel,
      builder: (context, child) {
        final sessionViewModel = widget.sessionViewModel;
        final session = sessionViewModel.session;
        return switch (sessionViewModel.status) {
          SessionStatus.restoring => const _SplashPage(),
          SessionStatus.signedOut => LoginPage(viewModel: _loginViewModel),
          SessionStatus.signedIn => RoleHomePage(
            key: ValueKey(session!.userId),
            role: session.role,
            sessionViewModel: sessionViewModel,
          ),
        };
      },
    );
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
