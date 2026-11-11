import 'package:flutter/material.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';
import 'package:inmonode/features/catalog/presentation/catalog_labels.dart';
import 'package:inmonode/features/catalog/presentation/project_cover.dart';

/// Catalog card: thumbnail, location, price range and share of available lots (US-15, Scenario 1).
class ProjectCard extends StatelessWidget {
  final ProjectSummary project;
  final VoidCallback onTap;

  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ProjectCover(imageUrl: project.coverImageUrl, soldOut: project.soldOut),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  ProjectLocation(location: project.location),
                  const SizedBox(height: 12),
                  Text(
                    CatalogLabels.priceRange(project.priceRange),
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 12),
                  AvailabilityBar(project: project),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectLocation extends StatelessWidget {
  final String location;

  const ProjectLocation({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.place_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class AvailabilityBar extends StatelessWidget {
  final ProjectSummary project;

  const AvailabilityBar({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: (project.availabilityPercentage / 100).clamp(0, 1),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
          color: project.soldOut ? theme.colorScheme.error : null,
          semanticsLabel: 'Disponibilidad',
        ),
        const SizedBox(height: 6),
        Text(CatalogLabels.availability(project), style: theme.textTheme.bodySmall),
      ],
    );
  }
}
