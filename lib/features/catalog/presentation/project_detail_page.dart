import 'package:flutter/material.dart';
import 'package:inmonode/core/di/dependency_injection.dart';
import 'package:inmonode/core/formatting/formats.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/catalog/domain/financing_rules.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';
import 'package:inmonode/features/catalog/presentation/catalog_labels.dart';
import 'package:inmonode/features/catalog/presentation/project_card.dart';
import 'package:inmonode/features/catalog/presentation/project_cover.dart';
import 'package:inmonode/features/catalog/presentation/project_detail_view_model.dart';

/// A project with its financing conditions, stages and lots. The card's data shows while the rest loads.
class ProjectDetailPage extends StatefulWidget {
  final ProjectSummary summary;
  final ProjectDetailViewModel viewModel;

  const ProjectDetailPage({super.key, required this.summary, required this.viewModel});

  static Route<void> route(ProjectSummary summary) {
    final viewModel = getIt<ProjectDetailViewModel>();
    return MaterialPageRoute(
      builder: (_) => ProjectDetailPage(summary: summary, viewModel: viewModel),
    );
  }

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load(widget.summary.id);
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(summary.name)),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          final viewModel = widget.viewModel;
          final project = viewModel.project;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 21 / 9,
                      child: ProjectCover(
                        imageUrl: project?.coverImageUrl ?? summary.coverImageUrl,
                        soldOut: summary.soldOut,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(summary.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  ProjectLocation(location: summary.location),
                  const SizedBox(height: 16),
                  Text(
                    CatalogLabels.priceRange(summary.priceRange),
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 12),
                  AvailabilityBar(project: summary),
                  if (summary.soldOut) ...[
                    const SizedBox(height: 16),
                    const MessageBanner.info(
                      'Este proyecto está vendido totalmente. Lo mantenemos en el catálogo como referencia.',
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (viewModel.errorMessage != null) ...[
                    MessageBanner.error(viewModel.errorMessage!),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.tonal(
                        onPressed: viewModel.isLoading ? null : () => viewModel.load(summary.id),
                        child: const Text('Reintentar'),
                      ),
                    ),
                  ] else if (project == null)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    _FinancingRulesSection(rules: project.financingRules),
                    if (project.stages.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionTitle('Etapas'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [for (final stage in project.stages) Chip(label: Text(stage))],
                      ),
                    ],
                    const SizedBox(height: 24),
                    _SectionTitle(
                      'Lotes',
                      trailing: '${viewModel.availableLots} de ${viewModel.lots.length} disponibles',
                    ),
                    if (viewModel.lots.isEmpty)
                      const Text('Este proyecto aún no tiene lotes publicados.')
                    else
                      Card(
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (final (index, lot) in viewModel.lots.indexed) ...[
                              if (index > 0) const Divider(height: 1),
                              LotTile(lot: lot),
                            ],
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionTitle(this.title, {this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
          if (trailing != null) Text(trailing!, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _FinancingRulesSection extends StatelessWidget {
  final FinancingRules rules;

  const _FinancingRulesSection({required this.rules});

  @override
  Widget build(BuildContext context) {
    final facts = [
      ('Cuota inicial mínima', Formats.percent(rules.minDownPaymentPercentage)),
      ('Tasa de interés anual', Formats.percent(rules.annualInterestRate)),
      ('Plazo máximo', '${rules.maxTermMonths} meses'),
      ('Tasa de mora', Formats.percent(rules.lateFeeRate)),
    ];
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('Condiciones de financiamiento'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (label, value) in facts)
              SizedBox(
                width: 200,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(value, style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A lot with its code, measures, price and availability.
class LotTile extends StatelessWidget {
  final Lot lot;

  const LotTile({super.key, required this.lot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final front = lot.front;
    final depth = lot.depth;
    final measures = [
      Formats.area(lot.area),
      if (front != null && depth != null) '${Formats.meters(front)} × ${Formats.meters(depth)}',
    ];
    return ListTile(
      title: Text('Lote ${lot.code}'),
      subtitle: Text(measures.join(' · ')),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(Formats.money(lot.price, currency: lot.currency), style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          LotStatusLabel(status: lot.status),
        ],
      ),
    );
  }
}

class LotStatusLabel extends StatelessWidget {
  final LotStatus status;

  const LotStatusLabel({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      LotStatus.available => (colors.primaryContainer, colors.onPrimaryContainer),
      LotStatus.sold => (colors.errorContainer, colors.onErrorContainer),
      _ => (colors.surfaceContainerHighest, colors.onSurfaceVariant),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          CatalogLabels.lotStatus(status),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
