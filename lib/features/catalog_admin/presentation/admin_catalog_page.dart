import 'package:flutter/material.dart';
import 'package:inmonode/core/network/api_exception.dart';

import '../application/catalog_commands.dart';
import '../domain/admin_catalog.dart';

class AdminCatalogPage extends StatefulWidget {
  final CatalogCommands commands;
  const AdminCatalogPage({super.key, required this.commands});

  @override
  State<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends State<AdminCatalogPage> {
  final inputs = <String, TextEditingController>{
    for (final name in [
      'projectId',
      'name',
      'location',
      'latitude',
      'longitude',
      'coverImageUrl',
      'minDownPaymentPercentage',
      'annualInterestRate',
      'maxTermMonths',
      'lateFeeRate',
      'stages',
    ])
      name: TextEditingController(),
  };
  AdminProject? project;
  String? message;
  bool busy = false;

  @override
  void dispose() {
    for (final controller in inputs.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _value(String name) => inputs[name]!.text.trim();
  double _number(String name) =>
      double.parse(_value(name).replaceAll(',', '.'));
  double? _optionalNumber(String name) =>
      _value(name).isEmpty ? null : _number(name);

  String _error(Object error) {
    if (error is ApiException)
      return error.details == null
          ? error.message
          : '${error.message} ${error.details}';
    if (error is ArgumentError && error.message != null)
      return error.message.toString();
    if (error is FormatException || error is ArgumentError)
      return 'Revisa los campos numéricos.';
    return 'No se pudo completar la operación.';
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => message = _error(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _load(int id) async {
    final loaded = await widget.commands.getProject(id);
    if (mounted)
      setState(() {
        project = loaded;
        inputs['projectId']!.text = '$id';
      });
  }

  Future<void> _createProject() => _run(() async {
    final name = _value('name');
    final location = _value('location');
    final stages = _value('stages')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (name.isEmpty || location.isEmpty || stages.isEmpty) {
      throw ArgumentError('Nombre, ubicación y etapas son obligatorios.');
    }
    final latitude = _optionalNumber('latitude');
    final longitude = _optionalNumber('longitude');
    if ((latitude == null) != (longitude == null)) {
      throw ArgumentError('Ingresa latitud y longitud juntas.');
    }
    final created = await widget.commands.createProject({
      'name': name,
      'location': location,
      'latitude': ?latitude,
      'longitude': ?longitude,
      if (_value('coverImageUrl').isNotEmpty)
        'coverImageUrl': _value('coverImageUrl'),
      'financingRules': {
        'minDownPaymentPercentage': _number('minDownPaymentPercentage'),
        'annualInterestRate': _number('annualInterestRate'),
        'maxTermMonths': int.parse(_value('maxTermMonths')),
        'lateFeeRate': _number('lateFeeRate'),
      },
      'stages': stages,
    });
    inputs['projectId']!.text = '${created.id}';
    if (mounted)
      setState(() {
        project = created;
        message = 'Proyecto ${created.id} creado como borrador.';
      });
  });

  Widget _field(String name, String label, {String? hint}) => TextField(
    controller: inputs[name],
    decoration: InputDecoration(labelText: label, hintText: hint),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar catálogo')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (busy) const LinearProgressIndicator(),
              if (message != null)
                Text(
                  message!,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              Text('Crear proyecto', style: theme.textTheme.titleLarge),
              _field('name', 'Nombre *'),
              _field('location', 'Ubicación *'),
              _field('latitude', 'Latitud', hint: '-12.0464'),
              _field('longitude', 'Longitud', hint: '-77.0428'),
              _field('coverImageUrl', 'URL de imagen de portada'),
              _field(
                'stages',
                'Etapas separadas por comas *',
                hint: 'Norte, Sur',
              ),
              _field('minDownPaymentPercentage', 'Cuota inicial mínima (%) *'),
              _field('annualInterestRate', 'Interés anual (%) *'),
              _field('maxTermMonths', 'Plazo máximo (meses) *'),
              _field('lateFeeRate', 'Mora (%) *'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: busy ? null : _createProject,
                child: const Text('Crear proyecto borrador'),
              ),
              const Divider(height: 40),
              Text(
                'Continuar con un proyecto',
                style: theme.textTheme.titleLarge,
              ),
              _field('projectId', 'ID del proyecto'),
              TextButton(
                onPressed: busy
                    ? null
                    : () => _run(() => _load(int.parse(_value('projectId')))),
                child: const Text('Cargar proyecto'),
              ),
              if (project != null)
                Text(
                  '${project!.name} · ${project!.status} · ID ${project!.id}',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
