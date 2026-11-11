import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';
import 'package:inmonode/features/catalog/presentation/project_card.dart';
import 'package:inmonode/features/catalog/presentation/project_detail_page.dart';
import 'package:inmonode/features/catalog/presentation/projects_view_model.dart';

/// "Proyectos" section of the buyer: the published projects as cards (US-15).
class ProjectsPage extends StatefulWidget {
  static const double _minCardWidth = 300;
  static const double _gap = 16;

  final ProjectsViewModel viewModel;

  const ProjectsPage({super.key, required this.viewModel});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  void _open(ProjectSummary project) {
    Navigator.of(context).push(ProjectDetailPage.route(project));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        return RefreshIndicator(
          onRefresh: viewModel.load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(viewModel: viewModel)),
              if (!viewModel.hasLoaded)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: viewModel.errorMessage == null
                      ? const Center(child: CircularProgressIndicator())
                      : _LoadError(message: viewModel.errorMessage!, onRetry: viewModel.load),
                )
              else if (viewModel.projects.isEmpty)
                const SliverFillRemaining(hasScrollBody: false, child: _EmptyCatalog())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: _ProjectGrid(projects: viewModel.projects, onOpen: _open),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final ProjectsViewModel viewModel;

  const _Header({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Proyectos', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Explora los proyectos publicados, sus precios y la disponibilidad de lotes.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Actualizar',
                onPressed: viewModel.isLoading ? null : viewModel.load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          // A refresh keeps the cards on screen and reports its progress or failure above them.
          if (viewModel.hasLoaded && viewModel.isLoading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (viewModel.hasLoaded && viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            MessageBanner.error(viewModel.errorMessage!),
          ],
        ],
      ),
    );
  }
}

/// Cards in as many columns as fit, each row as tall as its tallest card.
class _ProjectGrid extends StatelessWidget {
  final List<ProjectSummary> projects;
  final ValueChanged<ProjectSummary> onOpen;

  const _ProjectGrid({required this.projects, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    const gap = ProjectsPage._gap;
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final columns = math.max(
          1,
          ((constraints.crossAxisExtent + gap) / (ProjectsPage._minCardWidth + gap)).floor(),
        );
        final rows = (projects.length / columns).ceil();
        return SliverList.separated(
          itemCount: rows,
          separatorBuilder: (_, _) => const SizedBox(height: gap),
          itemBuilder: (context, row) => IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var column = 0; column < columns; column++) ...[
                  if (column > 0) const SizedBox(width: gap),
                  Expanded(
                    child: row * columns + column < projects.length
                        ? ProjectCard(
                            project: projects[row * columns + column],
                            onTap: () => onOpen(projects[row * columns + column]),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Aún no hay proyectos publicados', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Cuando la inmobiliaria publique un proyecto, lo verás aquí.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MessageBanner.error(message),
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
}
