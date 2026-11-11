import 'package:flutter/material.dart';
import 'package:inmonode/core/widgets/loading_button.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/iam/presentation/auth_scaffold.dart';
import 'package:inmonode/features/iam/presentation/auth_validators.dart';
import 'package:inmonode/features/iam/presentation/register_view_model.dart';
import 'package:inmonode/features/iam/presentation/verification_sent_page.dart';

class RegisterPage extends StatefulWidget {
  final RegisterViewModel viewModel;

  const RegisterPage({super.key, required this.viewModel});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final account = await widget.viewModel.submit(email, _passwordController.text);
    if (account == null || !mounted) return;
    Navigator.of(context).pushReplacement(VerificationSentPage.route(account.email));
  }

  void _showPasswordRecovery() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: const Text(
          'La recuperación de contraseña estará disponible en una próxima versión de inmoNode.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        return AuthScaffold(
          title: 'Crear cuenta',
          subtitle: 'Te enviaremos un enlace a tu correo para activar la cuenta.',
          child: AutofillGroup(
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
                    textInputAction: TextInputAction.next,
                    validator: AuthValidators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
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
                  if (viewModel.emailAlreadyRegistered) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                          child: const Text('Iniciar sesión'),
                        ),
                        TextButton(
                          onPressed: _showPasswordRecovery,
                          child: const Text('¿Olvidaste tu contraseña?'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  LoadingButton(
                    label: 'Crear cuenta',
                    isLoading: viewModel.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
