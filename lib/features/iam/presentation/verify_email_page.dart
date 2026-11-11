import 'package:flutter/material.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/iam/presentation/auth_scaffold.dart';
import 'package:inmonode/features/iam/presentation/auth_validators.dart';
import 'package:inmonode/features/iam/presentation/verification_sent_page.dart';
import 'package:inmonode/features/iam/presentation/verify_email_view_model.dart';

/// Opened from the verification email on Web: activates the account with the link's token.
class VerifyEmailPage extends StatefulWidget {
  final String token;
  final VerifyEmailViewModel viewModel;

  /// Leaves the verification and goes on to sign-in.
  final VoidCallback onContinue;

  const VerifyEmailPage({
    super.key,
    required this.token,
    required this.viewModel,
    required this.onContinue,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.verify(widget.token);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _requestNewLink() {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    widget.onContinue();
    navigator.push(
      VerificationSentPage.route(_emailController.text.trim(), resendOnOpen: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        return switch (viewModel.status) {
          VerificationStatus.verifying => const AuthScaffold(
            title: 'Verificando tu cuenta…',
            child: Center(child: CircularProgressIndicator()),
          ),
          VerificationStatus.verified => AuthScaffold(
            title: '¡Cuenta activada!',
            subtitle: 'Ya puedes iniciar sesión con ${viewModel.email}.',
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: widget.onContinue,
              child: const Text('Iniciar sesión'),
            ),
          ),
          VerificationStatus.failed => AuthScaffold(
            title: 'No pudimos activar tu cuenta',
            child: _buildFailure(viewModel),
          ),
        };
      },
    );
  }

  Widget _buildFailure(VerifyEmailViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MessageBanner.error(viewModel.errorMessage!),
        const SizedBox(height: 16),
        if (viewModel.canRetry) ...[
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () => viewModel.verify(widget.token),
            child: const Text('Reintentar'),
          ),
          const SizedBox(height: 16),
        ],
        const Text('Ingresa tu correo para recibir un nuevo enlace de verificación.'),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: AuthValidators.email,
            onFieldSubmitted: (_) => _requestNewLink(),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: _requestNewLink,
          child: const Text('Enviar nuevo enlace'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.onContinue,
          child: const Text('Ir a iniciar sesión'),
        ),
      ],
    );
  }
}
