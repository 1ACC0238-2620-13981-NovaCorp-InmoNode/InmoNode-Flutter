import 'package:flutter/material.dart';
import 'package:inmonode/features/iam/presentation/session_view_model.dart';

/// Field agents work in the native Android app (InmoNode-Mobile), not here.
class UnsupportedRolePage extends StatelessWidget {
  final SessionViewModel sessionViewModel;

  const UnsupportedRolePage({super.key, required this.sessionViewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.phone_android, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Esta cuenta es de Agente Comercial de Campo',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Registra prospectos y separaciones desde la aplicación InmoNode Mobile.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ListenableBuilder(
                    listenable: sessionViewModel,
                    builder: (context, child) => OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      onPressed: sessionViewModel.isSigningOut ? null : sessionViewModel.signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
