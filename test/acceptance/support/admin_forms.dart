import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_driver.dart';

/// The four vertices the back-office form expects one per line, from a step that separates them with `;`.
String polygonLines(String vertices) => [
  for (final vertex in vertices.split(';'))
    if (vertex.trim().isNotEmpty) vertex.trim(),
].join('\n');

/// The square lot of the scenarios, as the administrator types it.
const String squarePolygon = '-77.0428,-12.0464; -77.0427,-12.0464; -77.0427,-12.0465; -77.0428,-12.0465';

/// Fills "Crear proyecto" with the standard financing rules and submits it. A null field is left empty.
Future<void> submitProjectForm(
  WidgetTester tester, {
  required String? name,
  required String? location,
  required String? stages,
}) async {
  final values = {
    'Nombre *': name,
    'Ubicación *': location,
    'Etapas separadas por comas *': stages,
    'Cuota inicial mínima (%) *': '10',
    'Interés anual (%) *': '12.5',
    'Plazo máximo (meses) *': '60',
    'Mora (%) *': '1.5',
  };
  for (final MapEntry(key: label, value: text) in values.entries) {
    if (text != null) await enterField(tester, label, text);
  }
  await tapButton(tester, find.widgetWithText(FilledButton, 'Crear proyecto borrador'));
}

/// Fills "Registrar lote" of the open project and submits it. An empty field is left empty.
Future<void> submitLotForm(
  WidgetTester tester, {
  required String code,
  String? stage,
  String area = '120',
  String front = '',
  String depth = '',
  String price = '45000',
  String polygon = squarePolygon,
}) async {
  await enterField(tester, 'Código del lote *', code);
  if (stage != null) await chooseStage(tester, stage);
  final values = {
    'Área (m²) *': area,
    'Frente (m), si aplica': front,
    'Fondo (m), si aplica': depth,
    'Precio (S/) *': price,
    'Polígono: longitud,latitud por línea *': polygonLines(polygon),
  };
  for (final MapEntry(key: label, value: text) in values.entries) {
    if (text.isNotEmpty) await enterField(tester, label, text);
  }
  await tapButton(tester, find.widgetWithText(FilledButton, 'Registrar lote borrador'));
}

/// Picks the stage of the new lot; the form starts with the first stage of the project.
Future<void> chooseStage(WidgetTester tester, String stage) async {
  final dropdown = find.byType(DropdownButtonFormField<String>);
  final current = tester.widget<DropdownButtonFormField<String>>(dropdown).initialValue;
  if (current == stage) return;
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(stage).last);
  await tester.pumpAndSettle();
}
