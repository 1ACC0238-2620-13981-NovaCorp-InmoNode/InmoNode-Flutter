import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inmonode/core/formatting/formats.dart';
import 'package:inmonode/core/widgets/loading_button.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/quotations/domain/quotable_lot.dart';
import 'package:inmonode/features/quotations/presentation/quotation_result.dart';
import 'package:inmonode/features/quotations/presentation/simulation_view_model.dart';

/// The lot, the down payment and term inputs, and the simulated schedule (US-17).
///
/// It is a column for a scrolling parent, so it fits both the lot's page and the Simulador section.
class SimulationPanel extends StatefulWidget {
  final SimulationViewModel viewModel;

  const SimulationPanel({super.key, required this.viewModel});

  @override
  State<SimulationPanel> createState() => _SimulationPanelState();
}

class _SimulationPanelState extends State<SimulationPanel> {
  late final TextEditingController _initialPayment = TextEditingController(
    text: widget.viewModel.initialPayment,
  );

  @override
  void dispose() {
    _initialPayment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        final lot = viewModel.lot;
        final quotation = viewModel.quotation;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LotSummary(lot: lot),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _initialPayment,
                      enabled: !viewModel.lotUnavailable,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Cuota inicial',
                        prefixText: lot.currency == 'PEN' ? 'S/ ' : '${lot.currency} ',
                        helperText:
                            'Mínimo ${Formats.money(lot.minimumInitialPayment, currency: lot.currency)} '
                            '(${Formats.percent(lot.minInitialPercentage)} del precio)',
                        errorText: viewModel.initialPaymentError,
                        errorMaxLines: 3,
                      ),
                      onChanged: viewModel.updateInitialPayment,
                      onSubmitted: (_) => viewModel.simulate(),
                    ),
                    const SizedBox(height: 20),
                    _TermPicker(viewModel: viewModel),
                    const SizedBox(height: 16),
                    if (viewModel.errorMessage != null) ...[
                      MessageBanner.error(viewModel.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    LoadingButton(
                      label: quotation == null ? 'Simular financiamiento' : 'Volver a simular',
                      isLoading: viewModel.isSimulating,
                      onPressed: viewModel.lotUnavailable ? null : viewModel.simulate,
                    ),
                  ],
                ),
              ),
            ),
            if (quotation != null) ...[
              const SizedBox(height: 24),
              QuotationResult(quotation: quotation),
            ],
          ],
        );
      },
    );
  }
}

class _LotSummary extends StatelessWidget {
  final QuotableLot lot;

  const _LotSummary({required this.lot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conditions = [
      'Cuota inicial mínima ${Formats.percent(lot.minInitialPercentage)}',
      'Tasa de interés anual ${Formats.rate(lot.annualInterestRate)}',
      'Hasta ${_months(lot.maxTermMonths)}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: Text('Lote ${lot.lotCode}', style: theme.textTheme.titleLarge)),
            Text(
              Formats.money(lot.price, currency: lot.currency),
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('${lot.projectName} · ${Formats.area(lot.area)}', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(conditions.join(' · '), style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _TermPicker extends StatelessWidget {
  final SimulationViewModel viewModel;

  const _TermPicker({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = viewModel.lot.maxTermMonths;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Plazo', style: theme.textTheme.bodyMedium)),
            Text(_months(viewModel.termMonths), style: theme.textTheme.titleMedium),
          ],
        ),
        if (max > 1)
          // One stop per month; with up to hundreds of them, their tick marks would only clutter the track.
          SliderTheme(
            data: SliderTheme.of(context).copyWith(tickMarkShape: SliderTickMarkShape.noTickMark),
            child: Slider(
              value: viewModel.termMonths.toDouble(),
              min: 1,
              max: max.toDouble(),
              divisions: max - 1,
              label: _months(viewModel.termMonths),
              semanticFormatterCallback: (value) => _months(value.round()),
              onChanged: viewModel.lotUnavailable ? null : (value) => viewModel.updateTermMonths(value.round()),
            ),
          ),
      ],
    );
  }
}

String _months(int months) => months == 1 ? '1 mes' : '$months meses';
