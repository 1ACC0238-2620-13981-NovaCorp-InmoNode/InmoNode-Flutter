import 'package:flutter/material.dart';
import 'package:inmonode/core/widgets/loading_button.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/iam/presentation/auth_scaffold.dart';
import 'package:inmonode/features/iam/presentation/auth_validators.dart';
import 'package:inmonode/features/iam/presentation/forgot_password_page.dart';
import 'package:inmonode/features/iam/presentation/reset_password_view_model.dart';

/// Opened from the password reset email on Web: sets a new password with the link's token.
class ResetPasswordPage extends StatefulWidget {
  final String token;
  final ResetPasswordViewModel viewModel;

  /// Leaves the reset and goes on to sign-in.
  final VoidCallback onContinue;

  const ResetPasswordPage({
    super.key,
    required this.token,
    required this.viewModel,
    required this.onContinue,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.viewModel.submit(widget.token, _passwordController.text);
  }

  void _requestNewLink() {
    final navigator = Navigator.of(context);
    widget.onContinue();
    navigator.push(ForgotPasswordPage.route());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        return switch (viewModel.status) {
          PasswordResetStatus.editing => _buildForm(viewModel),
          PasswordResetStatus.done => AuthScaffold(
            title: '¡Contraseña actualizada!',
            subtitle: 'Ya puedes iniciar sesión con tu nueva contraseña.',
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: widget.onContinue,
              child: const Text('Iniciar sesión'),
            ),
          ),
          PasswordResetStatus.linkInvalid => AuthScaffold(
            title: 'No pudimos cambiar tu contraseña',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MessageBanner.error(viewModel.errorMessage!),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: _requestNewLink,
                  child: const Text('Pedir un nuevo enlace'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: widget.onContinue,
                  child: const Text('Ir a iniciar sesión'),
                ),
              ],
            ),
          ),
        };
      },
    );
  }

  Widget _buildForm(ResetPasswordViewModel viewModel) {
    return AuthScaffold(
      title: 'Elige una nueva contraseña',
      subtitle: 'Después podrás iniciar sesión con ella.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  helperText: 'Al menos ${AuthValidators.minPasswordLength} caracteres',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                validator: AuthValidators.newPassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmationController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    AuthValidators.passwordConfirmation(value, _passwordController.text),
                onFieldSubmitted: (_) => _submit(),
              ),
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 16),
                MessageBanner.error(viewModel.errorMessage!),
              ],
              const SizedBox(height: 24),
              LoadingButton(
                label: 'Cambiar contraseña',
                isLoading: viewModel.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: viewModel.isLoading ? null : widget.onContinue,
                child: const Text('Ir a iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
