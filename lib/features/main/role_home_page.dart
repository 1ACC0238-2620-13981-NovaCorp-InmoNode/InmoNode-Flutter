import 'package:flutter/material.dart';
import 'package:inmonode/core/widgets/section_placeholder.dart';
import 'package:inmonode/features/iam/domain/user_role.dart';
import 'package:inmonode/features/iam/presentation/profile_page.dart';
import 'package:inmonode/features/iam/presentation/session_view_model.dart';
import 'package:inmonode/features/main/role_shell.dart';
import 'package:inmonode/features/main/unsupported_role_page.dart';

/// Sends each role to its own navigation. Each story replaces its placeholder with its page.
class RoleHomePage extends StatelessWidget {
  final UserRole role;
  final SessionViewModel sessionViewModel;

  const RoleHomePage({
    super.key,
    required this.role,
    required this.sessionViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final profile = ShellSection(
      label: 'Perfil',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      builder: (_) => ProfilePage(viewModel: sessionViewModel),
    );

    return switch (role) {
      UserRole.buyer => RoleShell(
        sections: [
          ShellSection(
            label: 'Proyectos',
            icon: Icons.apartment_outlined,
            selectedIcon: Icons.apartment,
            builder: (_) => const SectionPlaceholder(
              title: 'Proyectos',
              icon: Icons.apartment,
              message: 'El catálogo de proyectos estará disponible pronto (US-15).',
            ),
          ),
          ShellSection(
            label: 'Simulador',
            icon: Icons.calculate_outlined,
            selectedIcon: Icons.calculate,
            builder: (_) => const SectionPlaceholder(
              title: 'Simulador',
              icon: Icons.calculate,
              message: 'La simulación de financiamiento estará disponible pronto (US-17).',
            ),
          ),
          profile,
        ],
      ),
      UserRole.catalogAdmin => RoleShell(
        sections: [
          ShellSection(
            label: 'Catálogo',
            icon: Icons.map_outlined,
            selectedIcon: Icons.map,
            builder: (_) => const SectionPlaceholder(
              title: 'Catálogo',
              icon: Icons.map,
              message:
                  'El alta y la publicación de proyectos y lotes estarán disponibles pronto '
                  '(US-51, US-52 y US-53).',
            ),
          ),
          profile,
        ],
      ),
      UserRole.financeAdmin => RoleShell(
        sections: [
          ShellSection(
            label: 'Verificaciones',
            icon: Icons.fact_check_outlined,
            selectedIcon: Icons.fact_check,
            builder: (_) => const SectionPlaceholder(
              title: 'Verificaciones',
              icon: Icons.fact_check,
              message: 'La verificación de comprobantes llegará en el Release 2 (US-54).',
            ),
          ),
          profile,
        ],
      ),
      UserRole.fieldAgent => UnsupportedRolePage(sessionViewModel: sessionViewModel),
    };
  }
}
