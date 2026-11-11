import 'package:flutter/material.dart';
import 'package:inmonode/features/catalog/presentation/catalog_labels.dart';

/// Thumbnail of a project. A sold-out project is dimmed and labeled "Vendido totalmente" (US-15, Scenario 2).
class ProjectCover extends StatelessWidget {
  final String? imageUrl;
  final bool soldOut;

  const ProjectCover({super.key, required this.imageUrl, required this.soldOut});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (url == null || url.isEmpty)
          const _CoverPlaceholder()
        else
          Image.network(
            url,
            fit: BoxFit.cover,
            // On Web, image hosts without CORS headers still load through an <img> element.
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            errorBuilder: (_, _, _) => const _CoverPlaceholder(),
            loadingBuilder: (_, child, progress) => progress == null ? child : const _CoverPlaceholder(),
          ),
        if (soldOut) ...[
          ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
          const Positioned(top: 12, left: 12, child: SoldOutLabel()),
        ],
      ],
    );
  }
}

class SoldOutLabel extends StatelessWidget {
  const SoldOutLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.error, borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          CatalogLabels.soldOut.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colors.onError,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Icon(Icons.apartment, size: 48, color: colors.onSurfaceVariant),
    );
  }
}
