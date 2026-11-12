import 'package:flutter/material.dart';
import 'package:inmonode/core/formatting/formats.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/core/widgets/loading_button.dart';
import 'package:inmonode/core/widgets/message_banner.dart';

import '../application/catalog_commands.dart';
import '../domain/admin_catalog.dart';
import 'admin_catalog_labels.dart';

/// Where the answer to an action is shown: right above the button that asked for it, so the
/// administrator sees it without scrolling.
enum _Place {
  createProject,
  loadProject,
  publishProject,
  registerLot,
  publishLot,
}

class _Feedback {
  final _Place place;
  final String text;
  final bool isError;

  /// The lot whose card shows the answer, for [_Place.publishLot].
  final int? lotId;

  const _Feedback(this.place, this.text, {this.isError = false, this.lotId});
}

/// A value the administrator has to correct before anything is sent.
class _InvalidInput implements Exception {
  final String message;

  const _InvalidInput(this.message);
}

class AdminCatalogPage extends StatefulWidget {
  final CatalogCommands commands;
  const AdminCatalogPage({super.key, required this.commands});

  @override
  State<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends State<AdminCatalogPage> {
  static const _projectFields = [
    'name',
    'location',
    'latitude',
    'longitude',
    'coverImageUrl',
    'stages',
    'minDownPaymentPercentage',
    'annualInterestRate',
    'maxTermMonths',
    'lateFeeRate',
  ];
  static const _lotFields = [
    'code',
    'area',
    'front',
    'depth',
    'price',
    'polygon',
  ];

  final inputs = <String, TextEditingController>{
    for (final name in [..._projectFields, 'projectId', ..._lotFields])
      name: TextEditingController(),
  };
  AdminProject? project;
  List<AdminLot> lots = [];
  String? stage;
  _Feedback? feedback;
  _Place? running;

  bool get busy => running != null;

  @override
  void dispose() {
    for (final controller in inputs.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Runs [action] and shows its answer at [place]; a null answer shows nothing.
  Future<void> _run(
    _Place place,
    Future<String?> Function() action, {
    int? lotId,
    String? lotCode,
    int? projectId,
  }) async {
    if (busy) return;
    setState(() {
      running = place;
      feedback = null;
    });
    _Feedback? result;
    try {
      final text = await action();
      if (text != null) result = _Feedback(place, text, lotId: lotId);
    } catch (error) {
      result = _Feedback(
        place,
        _describe(error, lotCode: lotCode, projectId: projectId),
        isError: true,
        lotId: lotId,
      );
    }
    if (!mounted) return;
    setState(() {
      running = null;
      feedback = result;
    });
  }

  String _describe(Object error, {String? lotCode, int? projectId}) {
    if (error is _InvalidInput) return error.message;
    if (error is ApiException) {
      return AdminCatalogLabels.rejection(
        error,
        lotCode: lotCode,
        projectId: projectId,
      );
    }
    if (error is ArgumentError && error.message is String) {
      return error.message as String;
    }
    return 'No se pudo completar la operación. Inténtalo de nuevo.';
  }

  String _value(String name) => inputs[name]!.text.trim();

  String _text(String name, String label, {required int maxLength}) {
    final value = _value(name);
    if (value.isEmpty) throw _InvalidInput('Completa «$label».');
    if (value.length > maxLength) {
      throw _InvalidInput('«$label» admite hasta $maxLength caracteres.');
    }
    return value;
  }

  /// A decimal number written with a point, as `12.5`; null when the field is empty.
  double? _optionalNumber(
    String name,
    String label, {
    double? min,
    double? max,
    bool positive = false,
  }) {
    final text = _value(name);
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || !value.isFinite) {
      throw _InvalidInput(
        'Ingresa un número en «$label», con punto decimal: por ejemplo 12.5.',
      );
    }
    if (positive && value <= 0) {
      throw _InvalidInput('«$label» debe ser mayor que cero.');
    }
    if (min != null && max != null && (value < min || value > max)) {
      throw _InvalidInput(
        '«$label» debe estar entre ${_plain(min)} y ${_plain(max)}.',
      );
    }
    return value;
  }

  double _number(
    String name,
    String label, {
    double? min,
    double? max,
    bool positive = false,
  }) {
    final value = _optionalNumber(
      name,
      label,
      min: min,
      max: max,
      positive: positive,
    );
    if (value == null) throw _InvalidInput('Completa «$label».');
    return value;
  }

  static String _plain(double value) =>
      value == value.roundToDouble() ? '${value.toInt()}' : '$value';

  /// The body of `POST /catalog/projects`, checked against the limits of the Web Services.
  Map<String, dynamic> _projectValues() {
    final name = _text('name', 'Nombre', maxLength: 150);
    final location = _text('location', 'Ubicación', maxLength: 255);
    final latitude = _optionalNumber('latitude', 'Latitud', min: -90, max: 90);
    final longitude = _optionalNumber(
      'longitude',
      'Longitud',
      min: -180,
      max: 180,
    );
    if ((latitude == null) != (longitude == null)) {
      throw const _InvalidInput('Ingresa la latitud y la longitud juntas.');
    }
    final coverImageUrl = _value('coverImageUrl');
    if (coverImageUrl.length > 500) {
      throw const _InvalidInput(
        '«URL de imagen de portada» admite hasta 500 caracteres.',
      );
    }
    final stages = _stages();
    final maxTermMonths = int.tryParse(_value('maxTermMonths'));
    if (maxTermMonths == null || maxTermMonths < 1 || maxTermMonths > 360) {
      throw const _InvalidInput(
        'Ingresa en «Plazo máximo» un número entero de meses entre 1 y 360.',
      );
    }
    return {
      'name': name,
      'location': location,
      'latitude': ?latitude,
      'longitude': ?longitude,
      if (coverImageUrl.isNotEmpty) 'coverImageUrl': coverImageUrl,
      'financingRules': {
        'minDownPaymentPercentage': _number(
          'minDownPaymentPercentage',
          'Cuota inicial mínima',
          min: 0,
          max: 100,
        ),
        'annualInterestRate': _number(
          'annualInterestRate',
          'Interés anual',
          min: 0,
          max: 100,
        ),
        'maxTermMonths': maxTermMonths,
        'lateFeeRate': _number('lateFeeRate', 'Mora', min: 0, max: 100),
      },
      'stages': stages,
    };
  }

  List<String> _stages() {
    final stages = _value('stages')
        .split(',')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    if (stages.isEmpty) {
      throw const _InvalidInput(
        'Escribe al menos una etapa, por ejemplo: Norte, Sur.',
      );
    }
    if (stages.length > 50) {
      throw const _InvalidInput('Un proyecto admite hasta 50 etapas.');
    }
    final seen = <String>{};
    for (final name in stages) {
      if (name.length > 80) {
        throw _InvalidInput('La etapa «$name» supera los 80 caracteres.');
      }
      if (!seen.add(name.toLowerCase())) {
        throw _InvalidInput('La etapa «$name» está repetida.');
      }
    }
    return stages;
  }

  /// The body of `POST /catalog/projects/{id}/lots`.
  Map<String, dynamic> _lotValues() {
    final code = _text('code', 'Código del lote', maxLength: 30);
    final selectedStage = stage;
    if (selectedStage == null) {
      throw const _InvalidInput('Elige la etapa del lote.');
    }
    final area = _number('area', 'Área', positive: true);
    final front = _optionalNumber('front', 'Frente', positive: true);
    final depth = _optionalNumber('depth', 'Fondo', positive: true);
    final price = Formats.parseAmount(_value('price'));
    if (price == null || price <= 0) {
      throw const _InvalidInput(
        'Ingresa el precio en soles, por ejemplo 45000 o 45,000.50.',
      );
    }
    return {
      'code': code,
      'stageName': selectedStage,
      'area': area,
      'front': ?front,
      'depth': ?depth,
      'price': price,
      'polygon': _polygon(),
    };
  }

  /// A GeoJSON polygon ring from one `longitude,latitude` vertex per line, closed by the app.
  List<List<List<double>>> _polygon() {
    final lines = _value('polygon')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final points = <List<double>>[];
    for (final (index, line) in lines.indexed) {
      final parts = line.split(',');
      final longitude = parts.length == 2 ? _coordinate(parts[0]) : null;
      final latitude = parts.length == 2 ? _coordinate(parts[1]) : null;
      if (longitude == null || latitude == null) {
        throw _InvalidInput(
          'La línea ${index + 1} del polígono debe ser longitud,latitud, '
          'por ejemplo -77.0428,-12.0464.',
        );
      }
      if (longitude.abs() > 180 || latitude.abs() > 90) {
        throw _InvalidInput(
          'La línea ${index + 1} del polígono está fuera de rango: la longitud '
          'va de -180 a 180 y la latitud de -90 a 90.',
        );
      }
      points.add([longitude, latitude]);
    }
    // The ring may already be closed; the app closes it either way.
    if (points.length > 1 && _samePoint(points.first, points.last)) {
      points.removeLast();
    }
    if (points.length < 3) {
      throw const _InvalidInput(
        'El polígono necesita al menos tres vértices, uno por línea.',
      );
    }
    return [
      [...points, List<double>.of(points.first)],
    ];
  }

  static double? _coordinate(String text) {
    final value = double.tryParse(text.trim());
    return value != null && value.isFinite ? value : null;
  }

  static bool _samePoint(List<double> a, List<double> b) =>
      a[0] == b[0] && a[1] == b[1];

  Future<void> _load(int id) async {
    final loaded = await widget.commands.getProject(id);
    final loadedLots = await widget.commands.getLots(id);
    if (!mounted) return;
    setState(() {
      // Keep the chosen stage while the same project is reloaded.
      if (project?.id != loaded.id || !loaded.stages.contains(stage)) {
        stage = loaded.stages.firstOrNull;
      }
      project = loaded;
      lots = loadedLots;
      inputs['projectId']!.text = '$id';
    });
  }

  Future<void> _createProject() => _run(_Place.createProject, () async {
    final created = await widget.commands.createProject(_projectValues());
    for (final name in _projectFields) {
      inputs[name]!.clear();
    }
    if (mounted) {
      setState(() {
        project = created;
        lots = [];
        stage = created.stages.firstOrNull;
        inputs['projectId']!.text = '${created.id}';
      });
    }
    return 'Proyecto «${created.name}» creado como borrador con el ID '
        '${created.id}. Registra sus lotes y luego publícalo.';
  });

  Future<void> _loadProject() {
    final id = int.tryParse(_value('projectId'));
    return _run(_Place.loadProject, () async {
      if (id == null || id <= 0) {
        throw const _InvalidInput(
          'Ingresa el ID numérico del proyecto, por ejemplo 12.',
        );
      }
      await _load(id);
      return null;
    }, projectId: id);
  }

  Future<void> _publishProject(AdminProject selected) => _run(
    _Place.publishProject,
    () async {
      if (lots.isEmpty) {
        throw const _InvalidInput(
          'Registra al menos un lote antes de publicar el proyecto.',
        );
      }
      await widget.commands.publishProject(selected.id);
      await _load(selected.id);
      return 'Proyecto publicado. Ahora publica los lotes que quieras ofrecer.';
    },
  );

  Future<void> _registerLot(AdminProject selected) {
    final code = _value('code');
    return _run(_Place.registerLot, () async {
      final values = _lotValues();
      await widget.commands.registerLot(selected.id, values);
      for (final name in _lotFields) {
        inputs[name]!.clear();
      }
      await _load(selected.id);
      return 'Lote $code registrado como borrador en la etapa '
          '${values['stageName']}.';
    }, lotCode: code);
  }

  Future<void> _publishLot(AdminProject selected, AdminLot lot) =>
      _run(_Place.publishLot, () async {
        await widget.commands.publishLot(lot.id);
        await _load(selected.id);
        return 'Lote ${lot.code} publicado: ya figura como disponible.';
      }, lotId: lot.id);

  /// The answer shown at [place], if the last action was asked for there.
  List<Widget> _feedbackAt(_Place place, {int? lotId}) {
    final current = feedback;
    if (current == null || current.place != place || current.lotId != lotId) {
      return const [];
    }
    return [
      const SizedBox(height: 12),
      current.isError
          ? MessageBanner.error(current.text)
          : MessageBanner.info(current.text),
    ];
  }

  Widget _field(
    String name,
    String label, {
    String? hint,
    int lines = 1,
    TextInputType? keyboardType,
  }) => TextField(
    controller: inputs[name],
    maxLines: lines,
    keyboardType: keyboardType,
    decoration: InputDecoration(labelText: label, hintText: hint),
  );

  static const _decimal = TextInputType.numberWithOptions(decimal: true);
  static const _coordinates = TextInputType.numberWithOptions(
    decimal: true,
    signed: true,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = project;
    final published = selected?.status == 'PUBLISHED';
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar catálogo')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Crear proyecto', style: theme.textTheme.titleLarge),
              _field('name', 'Nombre *'),
              _field('location', 'Ubicación *'),
              _field(
                'latitude',
                'Latitud',
                hint: '-12.0464',
                keyboardType: _coordinates,
              ),
              _field(
                'longitude',
                'Longitud',
                hint: '-77.0428',
                keyboardType: _coordinates,
              ),
              _field(
                'coverImageUrl',
                'URL de imagen de portada',
                keyboardType: TextInputType.url,
              ),
              _field(
                'stages',
                'Etapas separadas por comas *',
                hint: 'Norte, Sur',
              ),
              _field(
                'minDownPaymentPercentage',
                'Cuota inicial mínima (%) *',
                hint: '10',
                keyboardType: _decimal,
              ),
              _field(
                'annualInterestRate',
                'Interés anual (%) *',
                hint: '12.5',
                keyboardType: _decimal,
              ),
              _field(
                'maxTermMonths',
                'Plazo máximo (meses) *',
                hint: '60',
                keyboardType: TextInputType.number,
              ),
              _field(
                'lateFeeRate',
                'Mora (%) *',
                hint: '1.5',
                keyboardType: _decimal,
              ),
              ..._feedbackAt(_Place.createProject),
              const SizedBox(height: 12),
              LoadingButton(
                label: 'Crear proyecto borrador',
                isLoading: running == _Place.createProject,
                onPressed: busy ? null : _createProject,
              ),
              const Divider(height: 40),
              Text(
                'Continuar con un proyecto',
                style: theme.textTheme.titleLarge,
              ),
              _field(
                'projectId',
                'ID del proyecto',
                keyboardType: TextInputType.number,
              ),
              ..._feedbackAt(_Place.loadProject),
              TextButton(
                onPressed: busy ? null : _loadProject,
                child: const Text('Cargar proyecto'),
              ),
              if (selected != null) ...[
                Text(
                  '${selected.name} · '
                  '${AdminCatalogLabels.projectStatus(selected.status)} · '
                  'ID ${selected.id}',
                ),
                ..._feedbackAt(_Place.publishProject),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: busy || published
                      ? null
                      : () => _publishProject(selected),
                  child: const Text('Publicar proyecto'),
                ),
                const SizedBox(height: 20),
                Text('Registrar lote', style: theme.textTheme.titleLarge),
                _field('code', 'Código del lote *', hint: 'N-01'),
                DropdownButtonFormField<String>(
                  key: ValueKey(selected.id),
                  initialValue: stage,
                  decoration: const InputDecoration(labelText: 'Etapa *'),
                  items: [
                    for (final item in selected.stages)
                      DropdownMenuItem(value: item, child: Text(item)),
                  ],
                  onChanged: busy
                      ? null
                      : (value) => setState(() => stage = value),
                ),
                _field('area', 'Área (m²) *', keyboardType: _decimal),
                _field(
                  'front',
                  'Frente (m), si aplica',
                  keyboardType: _decimal,
                ),
                _field('depth', 'Fondo (m), si aplica', keyboardType: _decimal),
                _field(
                  'price',
                  'Precio (S/) *',
                  hint: '45000',
                  keyboardType: _decimal,
                ),
                _field(
                  'polygon',
                  'Polígono: longitud,latitud por línea *',
                  hint:
                      '-77.0428,-12.0464\n-77.0427,-12.0464\n-77.0427,-12.0465',
                  lines: 5,
                  keyboardType: TextInputType.multiline,
                ),
                const Text(
                  'Ingresa al menos tres vértices; la app cerrará el polígono.',
                ),
                ..._feedbackAt(_Place.registerLot),
                const SizedBox(height: 12),
                LoadingButton(
                  label: 'Registrar lote borrador',
                  isLoading: running == _Place.registerLot,
                  onPressed: busy ? null : () => _registerLot(selected),
                ),
                const SizedBox(height: 20),
                Text('Lotes', style: theme.textTheme.titleLarge),
                if (lots.isEmpty) const Text('Aún no hay lotes registrados.'),
                if (!published && lots.any((lot) => lot.status == 'DRAFT'))
                  const Text(
                    'Publica el proyecto para poder publicar sus lotes.',
                  ),
                for (final item in lots)
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          title: Text('${item.code} · Etapa ${item.stageName}'),
                          subtitle: Text(
                            '${AdminCatalogLabels.lotStatus(item.status)} · '
                            '${Formats.money(item.price)}',
                          ),
                          trailing: item.status == 'DRAFT'
                              ? TextButton(
                                  onPressed: busy || !published
                                      ? null
                                      : () => _publishLot(selected, item),
                                  child: const Text('Publicar lote'),
                                )
                              : null,
                        ),
                        if (feedback?.lotId == item.id)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _feedbackAt(
                                _Place.publishLot,
                                lotId: item.id,
                              ),
                            ),
                          ),
                      ],
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
