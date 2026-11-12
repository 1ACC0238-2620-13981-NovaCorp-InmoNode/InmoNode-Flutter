import 'package:flutter/material.dart';
import 'package:inmonode/core/widgets/loading_button.dart';
import 'package:inmonode/features/catalog/domain/financing_rules.dart';
import 'package:inmonode/features/catalog_admin/domain/new_project.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_validators.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_view_model.dart';
import 'package:inmonode/features/catalog_admin/presentation/catalog_feedback_banner.dart';

/// US-51: a new draft project, with its stages and the financing rules of its lots.
class NewProjectForm extends StatefulWidget {
  final AdminCatalogViewModel viewModel;

  const NewProjectForm({super.key, required this.viewModel});

  @override
  State<NewProjectForm> createState() => _NewProjectFormState();
}

class _NewProjectFormState extends State<NewProjectForm> {
  static const _decimal = TextInputType.numberWithOptions(decimal: true);
  static const _signedDecimal = TextInputType.numberWithOptions(decimal: true, signed: true);

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _coverImageUrl = TextEditingController();
  final _stages = TextEditingController();
  final _minDownPayment = TextEditingController();
  final _interestRate = TextEditingController();
  final _maxTermMonths = TextEditingController();
  final _lateFeeRate = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _name,
      _location,
      _latitude,
      _longitude,
      _coverImageUrl,
      _stages,
      _minDownPayment,
      _interestRate,
      _maxTermMonths,
      _lateFeeRate,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final viewModel = widget.viewModel;
    if (viewModel.isBusy) return;
    if (!_formKey.currentState!.validate()) {
      viewModel.reportInvalidForm(CatalogAction.createProject);
      return;
    }
    final coverImageUrl = _coverImageUrl.text.trim();
    final project = NewProject(
      name: _name.text.trim(),
      location: _location.text.trim(),
      latitude: AdminCatalogValidators.parseDecimal(_latitude.text),
      longitude: AdminCatalogValidators.parseDecimal(_longitude.text),
      coverImageUrl: coverImageUrl.isEmpty ? null : coverImageUrl,
      financingRules: FinancingRules(
        minDownPaymentPercentage: AdminCatalogValidators.parseDecimal(_minDownPayment.text)!,
        annualInterestRate: AdminCatalogValidators.parseDecimal(_interestRate.text)!,
        maxTermMonths: AdminCatalogValidators.parseMonths(_maxTermMonths.text)!,
        lateFeeRate: AdminCatalogValidators.parseDecimal(_lateFeeRate.text)!,
      ),
      stages: AdminCatalogValidators.parseStages(_stages.text),
    );
    if (await viewModel.submitProject(project) && mounted) _formKey.currentState!.reset();
  }

  Widget _field(
    TextEditingController controller,
    String label,
    FormFieldValidator<String> validator, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
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
          Text('Crear proyecto', style: Theme.of(context).textTheme.titleLarge),
          _field(
            _name,
            'Nombre *',
            (value) => AdminCatalogValidators.requiredText(value, maxLength: AdminCatalogValidators.maxNameLength),
          ),
          _field(
            _location,
            'Ubicación *',
            (value) => AdminCatalogValidators.requiredText(value, maxLength: AdminCatalogValidators.maxLocationLength),
          ),
          _field(
            _latitude,
            'Latitud',
            (value) => AdminCatalogValidators.latitude(value, longitude: _longitude.text),
            hint: '-12.0464',
            keyboardType: _signedDecimal,
          ),
          _field(
            _longitude,
            'Longitud',
            (value) => AdminCatalogValidators.longitude(value, latitude: _latitude.text),
            hint: '-77.0428',
            keyboardType: _signedDecimal,
          ),
          _field(
            _coverImageUrl,
            'URL de imagen de portada',
            (value) =>
                AdminCatalogValidators.optionalText(value, maxLength: AdminCatalogValidators.maxCoverImageUrlLength),
            keyboardType: TextInputType.url,
          ),
          _field(_stages, 'Etapas separadas por comas *', AdminCatalogValidators.stages, hint: 'Norte, Sur'),
          _field(
            _minDownPayment,
            'Cuota inicial mínima (%) *',
            AdminCatalogValidators.percentage,
            hint: '10',
            keyboardType: _decimal,
          ),
          _field(
            _interestRate,
            'Interés anual (%) *',
            AdminCatalogValidators.percentage,
            hint: '12.5',
            keyboardType: _decimal,
          ),
          _field(
            _maxTermMonths,
            'Plazo máximo (meses) *',
            AdminCatalogValidators.months,
            hint: '60',
            keyboardType: TextInputType.number,
          ),
          _field(_lateFeeRate, 'Mora (%) *', AdminCatalogValidators.percentage, hint: '1.5', keyboardType: _decimal),
          CatalogFeedbackBanner(viewModel.feedbackFor(CatalogAction.createProject)),
          const SizedBox(height: 12),
          LoadingButton(
            label: 'Crear proyecto borrador',
            isLoading: viewModel.running == CatalogAction.createProject,
            onPressed: viewModel.isBusy ? null : _submit,
          ),
        ],
      ),
    );
  }
}
