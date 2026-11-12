import 'package:flutter/material.dart';
import 'package:inmonode/core/di/dependency_injection.dart';
import 'package:inmonode/features/quotations/domain/quotable_lot.dart';
import 'package:inmonode/features/quotations/presentation/simulation_panel.dart';
import 'package:inmonode/features/quotations/presentation/simulation_view_model.dart';

/// The simulator of a lot, opened from its project's page.
class SimulationPage extends StatefulWidget {
  final SimulationViewModel viewModel;

  const SimulationPage({super.key, required this.viewModel});

  static Route<void> route(QuotableLot lot) {
    final viewModel = getIt<SimulationViewModel>(param1: lot);
    return MaterialPageRoute(builder: (_) => SimulationPage(viewModel: viewModel));
  }

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simular financiamiento')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [SimulationPanel(viewModel: widget.viewModel)],
          ),
        ),
      ),
    );
  }
}
