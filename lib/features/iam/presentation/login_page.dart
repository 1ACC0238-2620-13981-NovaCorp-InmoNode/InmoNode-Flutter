import 'package:flutter/material.dart';
import 'package:inmonode/core/di/dependency_injection.dart';
import 'package:inmonode/core/widgets/loading_button.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/iam/presentation/auth_scaffold.dart';
import 'package:inmonode/features/iam/presentation/auth_validators.dart';
import 'package:inmonode/features/iam/presentation/login_view_model.dart';
import 'package:inmonode/features/iam/presentation/register_page.dart';
import 'package:inmonode/features/iam/presentation/register_view_model.dart';
import 'package:inmonode/features/iam/presentation/verification_sent_page.dart';

class LoginPage extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginPage({super.key, required this.viewModel});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.viewModel.submit(_emailController.text, _passwordController.text);
  }

  void _openRegister() {
    final viewModel = getIt<RegisterViewModel>();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RegisterPage(viewModel: viewModel)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        return AuthScaffold(
          title: 'Iniciar sesión',
          subtitle: 'Explora proyectos, simula tu financiamiento y sigue tus adquisiciones.',
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
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    validator: AuthValidators.password,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    MessageBanner.error(viewModel.errorMessage!),
                  ],
                  if (viewModel.accountInactive)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          VerificationSentPage.route(
                            _emailController.text.trim(),
                            resendOnOpen: true,
                          ),
                        ),
                        child: const Text('Reenviar enlace de verificación'),
                      ),
                    ),
                  const SizedBox(height: 24),
                  LoadingButton(
                    label: 'Iniciar sesión',
                    isLoading: viewModel.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?'),
                      TextButton(
                        onPressed: viewModel.isLoading ? null : _openRegister,
                        child: const Text('Crear cuenta'),
                      ),
                    ],
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
