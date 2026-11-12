import 'package:flutter/material.dart';
import 'package:inmonode/core/di/dependency_injection.dart';
import 'package:inmonode/core/widgets/section_placeholder.dart';
import 'package:inmonode/features/catalog/presentation/projects_page.dart';
import 'package:inmonode/features/catalog/presentation/projects_view_model.dart';
import 'package:inmonode/features/catalog_admin/application/catalog_commands.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_page.dart';
import 'package:inmonode/features/iam/domain/user_role.dart';
import 'package:inmonode/features/iam/presentation/profile_page.dart';
import 'package:inmonode/features/iam/presentation/session_view_model.dart';
import 'package:inmonode/features/main/role_shell.dart';
import 'package:inmonode/features/main/unsupported_role_page.dart';
import 'package:inmonode/features/quotations/presentation/simulator_page.dart';
import 'package:inmonode/features/quotations/presentation/simulator_view_model.dart';

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
            builder: (_) => ProjectsPage(viewModel: getIt<ProjectsViewModel>()),
          ),
          ShellSection(
            label: 'Simulador',
            icon: Icons.calculate_outlined,
            selectedIcon: Icons.calculate,
            builder: (_) => SimulatorPage(
              createViewModel: () => getIt<SimulatorViewModel>(),
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
            builder: (_) =>
                AdminCatalogPage(commands: getIt<CatalogCommands>()),
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
      UserRole.fieldAgent => UnsupportedRolePage(
        sessionViewModel: sessionViewModel,
      ),
    };
  }
}
