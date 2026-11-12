import 'package:flutter/material.dart';
import 'package:inmonode/core/formatting/formats.dart';
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
      'code',
      'area',
      'front',
      'depth',
      'price',
      'polygon',
    ])
      name: TextEditingController(),
  };
  AdminProject? project;
  List<AdminLot> lots = [];
  String? stage;
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
    final loadedLots = await widget.commands.getLots(id);
    if (mounted)
      setState(() {
        project = loaded;
        lots = loadedLots;
        stage = loaded.stages.firstOrNull;
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
        lots = [];
        stage = created.stages.firstOrNull;
        message = 'Proyecto ${created.id} creado como borrador.';
      });
  });

  List<List<List<double>>> _polygon() {
    final points = _value('polygon')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) {
          final parts = line.trim().split(',');
          if (parts.length != 2)
            throw const FormatException('Se esperan longitud,latitud');
          return [double.parse(parts[0].trim()), double.parse(parts[1].trim())];
        })
        .toList();
    if (points.length < 3)
      throw const FormatException('Se requieren tres vértices');
    if (points.first[0] != points.last[0] ||
        points.first[1] != points.last[1]) {
      points.add(List<double>.from(points.first));
    }
    return [points];
  }

  Future<void> _registerLot() => _run(() async {
    final selected = project;
    if (selected == null || stage == null || _value('code').isEmpty) {
      throw ArgumentError('Selecciona un proyecto y completa lote y etapa.');
    }
    await widget.commands.registerLot(selected.id, {
      'code': _value('code'),
      'stageName': stage,
      'area': _number('area'),
      if (_optionalNumber('front') != null) 'front': _number('front'),
      if (_optionalNumber('depth') != null) 'depth': _number('depth'),
      'price': _number('price'),
      'polygon': _polygon(),
    });
    await _load(selected.id);
    if (mounted) setState(() => message = 'Lote registrado como borrador.');
  });

  Widget _field(String name, String label, {String? hint, int lines = 1}) =>
      TextField(
        controller: inputs[name],
        maxLines: lines,
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
              if (project != null) ...[
                const SizedBox(height: 20),
                Text('Registrar lote', style: theme.textTheme.titleLarge),
                _field('code', 'Código del lote *', hint: 'N-01'),
                DropdownButtonFormField<String>(
                  key: ValueKey(project!.id),
                  initialValue: stage,
                  decoration: const InputDecoration(labelText: 'Etapa *'),
                  items: [
                    for (final item in project!.stages)
                      DropdownMenuItem(value: item, child: Text(item)),
                  ],
                  onChanged: busy
                      ? null
                      : (value) => setState(() => stage = value),
                ),
                _field('area', 'Área (m²) *'),
                _field('front', 'Frente (m), si aplica'),
                _field('depth', 'Fondo (m), si aplica'),
                _field('price', 'Precio (S/) *'),
                _field(
                  'polygon',
                  'Polígono: longitud,latitud por línea *',
                  hint:
                      '-77.0428,-12.0464\n-77.0427,-12.0464\n-77.0427,-12.0465',
                  lines: 5,
                ),
                const Text(
                  'Ingresa al menos tres vértices; la app cerrará el polígono.',
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: busy ? null : _registerLot,
                  child: const Text('Registrar lote borrador'),
                ),
                const SizedBox(height: 20),
                Text('Lotes', style: theme.textTheme.titleLarge),
                if (lots.isEmpty) const Text('Aún no hay lotes registrados.'),
                for (final item in lots)
                  Card(
                    child: ListTile(
                      title: Text('${item.code} · ${item.stageName}'),
                      subtitle: Text(
                        '${item.status} · ${Formats.money(item.price)}',
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
