import 'package:flutter/material.dart';
import 'package:inmonode/core/di/dependency_injection.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/iam/presentation/auth_scaffold.dart';
import 'package:inmonode/features/iam/presentation/resend_verification_view_model.dart';

/// Asks the user to open the verification link and lets them request a new one.
class VerificationSentPage extends StatefulWidget {
  final String email;
  final ResendVerificationViewModel viewModel;

  /// Requests a new link on open, instead of assuming one was just sent.
  final bool resendOnOpen;

  const VerificationSentPage({
    super.key,
    required this.email,
    required this.viewModel,
    this.resendOnOpen = false,
  });

  static Route<void> route(String email, {bool resendOnOpen = false}) {
    final viewModel = getIt<ResendVerificationViewModel>();
    return MaterialPageRoute(
      builder: (_) => VerificationSentPage(
        email: email,
        viewModel: viewModel,
        resendOnOpen: resendOnOpen,
      ),
    );
  }

  @override
  State<VerificationSentPage> createState() => _VerificationSentPageState();
}

class _VerificationSentPageState extends State<VerificationSentPage> {
  @override
  void initState() {
    super.initState();
    if (widget.resendOnOpen) {
      widget.viewModel.resend(widget.email);
    } else {
      widget.viewModel.startCooldown();
    }
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        return AuthScaffold(
          title: 'Revisa tu correo',
          subtitle:
              'Enviamos un enlace de verificación a ${widget.email}. Ábrelo para activar tu cuenta; '
              'el enlace vence en 24 horas.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              if (viewModel.message != null) ...[
                MessageBanner.info(viewModel.message!),
                const SizedBox(height: 16),
              ],
              if (viewModel.errorMessage != null) ...[
                MessageBanner.error(viewModel.errorMessage!),
                const SizedBox(height: 16),
              ],
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Ir a iniciar sesión'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: viewModel.canResend ? () => viewModel.resend(widget.email) : null,
                child: Text(
                  viewModel.isSending
                      ? 'Enviando…'
                      : viewModel.secondsLeft > 0
                      ? 'Reenviar enlace en ${viewModel.secondsLeft} s'
                      : 'Reenviar enlace',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
