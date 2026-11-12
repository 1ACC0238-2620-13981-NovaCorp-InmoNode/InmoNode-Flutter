import 'package:flutter/material.dart';
import 'package:inmonode/core/formatting/formats.dart';
import 'package:inmonode/core/widgets/loading_button.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_project.dart';
import 'package:inmonode/features/catalog_admin/domain/new_lot.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_validators.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_view_model.dart';
import 'package:inmonode/features/catalog_admin/presentation/catalog_feedback_banner.dart';

/// US-52: a new draft lot of [project], with its measures, price and WGS84 boundary.
class NewLotForm extends StatefulWidget {
  final AdminCatalogViewModel viewModel;
  final AdminProject project;

  const NewLotForm({super.key, required this.viewModel, required this.project});

  @override
  State<NewLotForm> createState() => _NewLotFormState();
}

class _NewLotFormState extends State<NewLotForm> {
  static const _decimal = TextInputType.numberWithOptions(decimal: true);

  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _area = TextEditingController();
  final _front = TextEditingController();
  final _depth = TextEditingController();
  final _price = TextEditingController();
  final _boundary = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_code, _area, _front, _depth, _price, _boundary]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final viewModel = widget.viewModel;
    if (viewModel.isBusy) return;
    if (!_formKey.currentState!.validate()) {
      viewModel.reportInvalidForm(CatalogAction.registerLot);
      return;
    }
    final lot = NewLot(
      code: _code.text.trim(),
      stageName: viewModel.stage!,
      area: AdminCatalogValidators.parseDecimal(_area.text)!,
      front: AdminCatalogValidators.parseDecimal(_front.text),
      depth: AdminCatalogValidators.parseDecimal(_depth.text),
      price: Formats.parseAmount(_price.text)!,
      boundary: AdminCatalogValidators.parseBoundary(_boundary.text)!,
    );
    // The stage stays chosen for the next lot.
    if (await viewModel.submitLot(lot) && mounted) _formKey.currentState!.reset();
  }

  Widget _field(
    TextEditingController controller,
    String label,
    FormFieldValidator<String> validator, {
    String? hint,
    int lines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      decoration: InputDecoration(labelText: label, hintText: hint),
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Registrar lote', style: Theme.of(context).textTheme.titleLarge),
          _field(
            _code,
            'Código del lote *',
            (value) => AdminCatalogValidators.requiredText(value, maxLength: AdminCatalogValidators.maxLotCodeLength),
            hint: 'N-01',
          ),
          DropdownButtonFormField<String>(
            initialValue: viewModel.stage,
            decoration: const InputDecoration(labelText: 'Etapa *'),
            items: [for (final stage in widget.project.stages) DropdownMenuItem(value: stage, child: Text(stage))],
            onChanged: viewModel.isBusy ? null : viewModel.selectStage,
            validator: (value) => value == null ? 'Elige la etapa del lote' : null,
          ),
          _field(
            _area,
            'Área (m²) *',
            (value) => AdminCatalogValidators.decimal(value, positive: true),
            keyboardType: _decimal,
          ),
          _field(
            _front,
            'Frente (m), si aplica',
            (value) => AdminCatalogValidators.decimal(value, required: false, positive: true),
            keyboardType: _decimal,
          ),
          _field(
            _depth,
            'Fondo (m), si aplica',
            (value) => AdminCatalogValidators.decimal(value, required: false, positive: true),
            keyboardType: _decimal,
          ),
          _field(_price, 'Precio (S/) *', AdminCatalogValidators.price, hint: '45000', keyboardType: _decimal),
          _field(
            _boundary,
            'Polígono: longitud,latitud por línea *',
            AdminCatalogValidators.boundary,
            hint: '-77.0428,-12.0464\n-77.0427,-12.0464\n-77.0427,-12.0465',
            lines: 5,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 4),
          const Text('Ingresa al menos tres vértices; la app cerrará el polígono.'),
          CatalogFeedbackBanner(viewModel.feedbackFor(CatalogAction.registerLot)),
          const SizedBox(height: 12),
          LoadingButton(
            label: 'Registrar lote borrador',
            isLoading: viewModel.running == CatalogAction.registerLot,
            onPressed: viewModel.isBusy ? null : _submit,
          ),
        ],
      ),
    );
  }
}
