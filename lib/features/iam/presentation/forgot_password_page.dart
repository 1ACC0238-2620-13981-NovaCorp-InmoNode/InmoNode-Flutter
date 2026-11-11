import 'package:flutter/material.dart';
import 'package:inmonode/core/di/dependency_injection.dart';
import 'package:inmonode/core/widgets/loading_button.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/iam/presentation/auth_scaffold.dart';
import 'package:inmonode/features/iam/presentation/auth_validators.dart';
import 'package:inmonode/features/iam/presentation/forgot_password_view_model.dart';

/// Asks for the account's email and sends it a link to choose a new password.
class ForgotPasswordPage extends StatefulWidget {
  final ForgotPasswordViewModel viewModel;

  /// The email typed on the page that opened this one, if any.
  final String initialEmail;

  const ForgotPasswordPage({
    super.key,
    required this.viewModel,
    this.initialEmail = '',
  });

  static Route<void> route({String email = ''}) {
    final viewModel = getIt<ForgotPasswordViewModel>();
    return MaterialPageRoute(
      builder: (_) => ForgotPasswordPage(viewModel: viewModel, initialEmail: email),
    );
  }

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _emailController.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.viewModel.send(_emailController.text.trim());
  }

  void _goToSignIn() => Navigator.of(context).popUntil((route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        final sentTo = viewModel.sentTo;
        return sentTo == null ? _buildForm(viewModel) : _buildSent(viewModel, sentTo);
      },
    );
  }

  Widget _buildForm(ForgotPasswordViewModel viewModel) {
    return AuthScaffold(
      title: 'Recuperar contraseña',
      subtitle: 'Ingresa el correo de tu cuenta y te enviaremos un enlace para elegir una nueva contraseña.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.done,
              validator: AuthValidators.email,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (viewModel.errorMessage != null) ...[
              const SizedBox(height: 16),
              MessageBanner.error(viewModel.errorMessage!),
            ],
            const SizedBox(height: 24),
            LoadingButton(
              label: 'Enviar enlace',
              isLoading: viewModel.isSending,
              onPressed: _submit,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _goToSignIn,
              child: const Text('Volver a iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSent(ForgotPasswordViewModel viewModel, String sentTo) {
    return AuthScaffold(
      title: 'Revisa tu correo',
      // The server answers the same whether or not the account exists, so the message cannot be sure.
      subtitle:
          'Si $sentTo pertenece a una cuenta activa, te enviamos un enlace para elegir una nueva '
          'contraseña. El enlace vence en 30 minutos y solo se puede usar una vez.',
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
            onPressed: _goToSignIn,
            child: const Text('Ir a iniciar sesión'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: viewModel.canResend ? viewModel.resend : null,
            child: Text(
              viewModel.isSending
                  ? 'Enviando…'
                  : viewModel.secondsLeft > 0
                  ? 'Reenviar enlace en ${viewModel.secondsLeft} s'
                  : 'Reenviar enlace',
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: viewModel.isSending ? null : viewModel.changeEmail,
            child: const Text('Usar otro correo'),
          ),
        ],
      ),
    );
  }
}
