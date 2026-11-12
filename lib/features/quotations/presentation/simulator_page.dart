import 'package:flutter/material.dart';
import 'package:inmonode/core/formatting/formats.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/quotations/presentation/simulation_panel.dart';
import 'package:inmonode/features/quotations/presentation/simulator_view_model.dart';

/// "Simulador" section of the buyer: pick a project and an available lot, then simulate it (US-17).
///
/// The view model holds the buyer's simulations, so it lives as long as this section: it is created
/// once and discarded when the session ends.
class SimulatorPage extends StatefulWidget {
  final SimulatorViewModel Function() createViewModel;

  const SimulatorPage({super.key, required this.createViewModel});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  late final SimulatorViewModel _viewModel = widget.createViewModel()..load();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final viewModel = _viewModel;
        final simulation = viewModel.simulation;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Simulador', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'Elige un lote disponible y calcula tus cuotas mensuales con las condiciones de su proyecto.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                if (!viewModel.hasLoaded)
                  viewModel.errorMessage == null
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _Retry(message: viewModel.errorMessage!, onRetry: viewModel.load)
                else if (viewModel.projects.isEmpty)
                  const MessageBanner.info('Por ahora no hay lotes disponibles para simular.')
                else ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 420,
                        child: DropdownButtonFormField<int>(
                          initialValue: viewModel.selectedProjectId,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Proyecto'),
                          items: [
                            for (final project in viewModel.projects)
                              DropdownMenuItem(value: project.id, child: Text(project.name)),
                          ],
                          onChanged: (id) {
                            if (id != null) viewModel.selectProject(id);
                          },
                        ),
                      ),
                      if (viewModel.selectedProjectId != null && viewModel.lots.isNotEmpty)
                        SizedBox(
                          width: 420,
                          child: DropdownButtonFormField<int>(
                            // A new project starts with no lot chosen.
                            key: ValueKey(viewModel.selectedProjectId),
                            initialValue: viewModel.selectedLot?.lotId,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Lote'),
                            items: [
                              for (final lot in viewModel.lots)
                                DropdownMenuItem(
                                  value: lot.lotId,
                                  child: Text(
                                    'Lote ${lot.lotCode} · ${Formats.area(lot.area)} · '
                                    '${Formats.money(lot.price, currency: lot.currency)}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (id) {
                              if (id != null) viewModel.selectLot(id);
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (viewModel.isLoadingLots)
                    const Center(child: CircularProgressIndicator())
                  else if (viewModel.lotsErrorMessage != null)
                    _Retry(
                      message: viewModel.lotsErrorMessage!,
                      onRetry: () => viewModel.selectProject(viewModel.selectedProjectId!),
                    )
                  else if (viewModel.selectedProjectId != null && viewModel.lots.isEmpty)
                    const MessageBanner.info('Este proyecto ya no tiene lotes disponibles. Elige otro proyecto.')
                  else if (simulation != null)
                    SimulationPanel(key: ObjectKey(simulation), viewModel: simulation)
                  else if (viewModel.selectedProjectId != null)
                    Text(
                      viewModel.lots.length == 1
                          ? 'Elige su único lote disponible para simular su financiamiento.'
                          : 'Elige uno de sus ${viewModel.lots.length} lotes disponibles para simular su financiamiento.',
                      style: theme.textTheme.bodyMedium,
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

class _Retry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _Retry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MessageBanner.error(message),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}
