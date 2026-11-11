import 'package:flutter/material.dart';
import 'package:inmonode/features/iam/presentation/session_view_model.dart';
import 'package:inmonode/features/iam/presentation/user_role_label.dart';

class ProfilePage extends StatelessWidget {
  final SessionViewModel viewModel;

  const ProfilePage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final session = viewModel.session;
        if (session == null) return const SizedBox.shrink();
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      session.email.substring(0, 1).toUpperCase(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    session.email,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.role.label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: viewModel.isSigningOut ? null : viewModel.signOut,
                    icon: const Icon(Icons.logout),
                    label: Text(viewModel.isSigningOut ? 'Cerrando sesión…' : 'Cerrar sesión'),
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
