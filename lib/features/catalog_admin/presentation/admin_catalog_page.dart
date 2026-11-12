import 'package:flutter/material.dart';
import 'package:inmonode/core/formatting/formats.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_project.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_labels.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_validators.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_view_model.dart';
import 'package:inmonode/features/catalog_admin/presentation/catalog_feedback_banner.dart';
import 'package:inmonode/features/catalog_admin/presentation/new_lot_form.dart';
import 'package:inmonode/features/catalog_admin/presentation/new_project_form.dart';

/// "Catálogo" section of `CATALOG_ADMIN`: creates a draft project (US-51), registers its lots (US-52) and
/// publishes the project and then each lot (US-53).
///
/// The view model holds the project being worked on, so it lives as long as this section: it is created
/// once and discarded when the session ends.
class AdminCatalogPage extends StatefulWidget {
  final AdminCatalogViewModel Function() createViewModel;

  const AdminCatalogPage({super.key, required this.createViewModel});

  @override
  State<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends State<AdminCatalogPage> {
  late final AdminCatalogViewModel _viewModel = widget.createViewModel();
  final _openFormKey = GlobalKey<FormState>();
  final _projectId = TextEditingController();

  @override
  void dispose() {
    _projectId.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _openProject() {
    if (_viewModel.isBusy) return;
    if (!_openFormKey.currentState!.validate()) return;
    _viewModel.openProject(AdminCatalogValidators.parseProjectId(_projectId.text)!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final viewModel = _viewModel;
        final project = viewModel.project;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Catálogo', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'Crea un proyecto, registra sus lotes como borradores y publícalos cuando estén listos.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                NewProjectForm(viewModel: viewModel),
                const Divider(height: 48),
                Text('Continuar con un proyecto', style: theme.textTheme.titleLarge),
                Form(
                  key: _openFormKey,
                  child: TextFormField(
                    controller: _projectId,
                    decoration: const InputDecoration(
                      labelText: 'ID del proyecto',
                      helperText: 'Los borradores no se listan: usa el ID que se mostró al crearlo.',
                    ),
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                    validator: AdminCatalogValidators.projectId,
                    onFieldSubmitted: (_) => _openProject(),
                  ),
                ),
                CatalogFeedbackBanner(viewModel.feedbackFor(CatalogAction.openProject)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: viewModel.isBusy ? null : _openProject,
                    child: const Text('Cargar proyecto'),
                  ),
                ),
                if (project != null) ...[
                  const SizedBox(height: 8),
                  _ProjectSummary(viewModel: viewModel, project: project),
                  const SizedBox(height: 32),
                  NewLotForm(key: ValueKey(project.id), viewModel: viewModel, project: project),
                  const SizedBox(height: 32),
                  _LotList(viewModel: viewModel, project: project),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The open project and its publication (US-53).
class _ProjectSummary extends StatelessWidget {
  final AdminCatalogViewModel viewModel;
  final AdminProject project;

  const _ProjectSummary({required this.viewModel, required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${project.name} · ${AdminCatalogLabels.projectStatus(project.status)} · ID ${project.id}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text('${project.location} · Etapas: ${project.stages.join(', ')}'),
        CatalogFeedbackBanner(viewModel.feedbackFor(CatalogAction.publishProject)),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: viewModel.isBusy || project.isPublished ? null : viewModel.publishSelectedProject,
          child: const Text('Publicar proyecto'),
        ),
      ],
    );
  }
}

/// The lots of the open project; each draft is published from its own card (US-53).
class _LotList extends StatelessWidget {
  final AdminCatalogViewModel viewModel;
  final AdminProject project;

  const _LotList({required this.viewModel, required this.project});

  @override
  Widget build(BuildContext context) {
    final lots = viewModel.lots;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Lotes', style: Theme.of(context).textTheme.titleLarge),
        if (lots.isEmpty) const Text('Aún no hay lotes registrados.'),
        if (!project.isPublished && lots.any((lot) => lot.isDraft))
          const Text('Publica el proyecto para poder publicar sus lotes.'),
        for (final lot in lots) _LotCard(viewModel: viewModel, project: project, lot: lot),
      ],
    );
  }
}

class _LotCard extends StatelessWidget {
  final AdminCatalogViewModel viewModel;
  final AdminProject project;
  final AdminLot lot;

  const _LotCard({required this.viewModel, required this.project, required this.lot});

  @override
  Widget build(BuildContext context) {
    final feedback = viewModel.feedbackFor(CatalogAction.publishLot, lotId: lot.id);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text('${lot.code} · Etapa ${lot.stageName}'),
            subtitle: Text(
              '${AdminCatalogLabels.lotStatus(lot.status)} · ${Formats.area(lot.area)} · '
              '${Formats.money(lot.price, currency: lot.currency)}',
            ),
            trailing: lot.isDraft
                ? TextButton(
                    onPressed: viewModel.isBusy || !project.isPublished ? null : () => viewModel.publishDraftLot(lot),
                    child: const Text('Publicar lote'),
                  )
                : null,
          ),
          if (feedback != null)
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: CatalogFeedbackBanner(feedback)),
        ],
      ),
    );
  }
}
