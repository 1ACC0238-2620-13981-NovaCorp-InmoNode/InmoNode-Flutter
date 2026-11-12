import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/catalog_admin/domain/catalog_rejection.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_page.dart';

import '../catalog_admin_fakes.dart';

void main() {
  late FakeAdminCatalogRepository repository;

  setUp(() => repository = FakeAdminCatalogRepository());

  Future<void> pumpPage(WidgetTester tester) async {
    // Tall enough to build the whole page at once.
    tester.view.physicalSize = const Size(1280, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdminCatalogPage(createViewModel: () => adminCatalogViewModel(repository))),
      ),
    );
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  Future<void> type(WidgetTester tester, String label, String text) => tester.enterText(field(label), text);

  String textOf(WidgetTester tester, String label) => tester.widget<TextField>(field(label)).controller!.text;

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  MessageBanner banner(WidgetTester tester) => tester.widget<MessageBanner>(find.byType(MessageBanner));

  Future<void> fillProject(WidgetTester tester) async {
    await type(tester, 'Nombre *', 'Los Pinos');
    await type(tester, 'Ubicación *', 'Lurín, Lima');
    await type(tester, 'Etapas separadas por comas *', 'Norte, Sur');
    await type(tester, 'Cuota inicial mínima (%) *', '10');
    await type(tester, 'Interés anual (%) *', '12.5');
    await type(tester, 'Plazo máximo (meses) *', '60');
    await type(tester, 'Mora (%) *', '1.5');
  }

  Future<void> openProject(WidgetTester tester) async {
    await type(tester, 'ID del proyecto', '5');
    await tap(tester, 'Cargar proyecto');
  }

  Future<void> fillLot(
    WidgetTester tester, {
    String code = 'N-01',
    String polygon = '-77.0,-12.0\n-77.1,-12.0\n-77.1,-12.1',
  }) async {
    await type(tester, 'Código del lote *', code);
    await type(tester, 'Área (m²) *', '120');
    await type(tester, 'Precio (S/) *', '45,000.50');
    await type(tester, 'Polígono: longitud,latitud por línea *', polygon);
  }

  testWidgets('marks each field to correct, answers next to the button and sends nothing', (tester) async {
    await pumpPage(tester);

    await tap(tester, 'Crear proyecto borrador');

    expect(find.text('Completa este campo'), findsNWidgets(5));
    expect(find.text('Escribe al menos una etapa, por ejemplo: Norte, Sur'), findsOneWidget);
    expect(find.text('Ingresa un número entero de meses entre 1 y 360'), findsOneWidget);
    expect(banner(tester).message, 'Revisa los campos marcados.');
    expect(banner(tester).isError, isTrue);
    expect(repository.createdProjects, isEmpty);
  });

  testWidgets('US-51 creates a draft project and clears its form', (tester) async {
    await pumpPage(tester);
    await fillProject(tester);

    await tap(tester, 'Crear proyecto borrador');

    final sent = repository.createdProjects.single;
    expect(sent.name, 'Los Pinos');
    expect(sent.stages, ['Norte', 'Sur']);
    expect(sent.financingRules.annualInterestRate, 12.5);
    expect(sent.financingRules.maxTermMonths, 60);
    expect(sent.latitude, isNull);
    expect(
      banner(tester).message,
      'Proyecto «Los Pinos» creado como borrador con el ID 5. Registra sus lotes y luego publícalo.',
    );
    expect(banner(tester).isError, isFalse);
    expect(textOf(tester, 'Nombre *'), isEmpty);
    expect(textOf(tester, 'Etapas separadas por comas *'), isEmpty);
    expect(find.text('Los Pinos · Borrador · ID 5'), findsOneWidget);
  });

  testWidgets('checks the coordinates and the financing rules before sending them', (tester) async {
    await pumpPage(tester);
    await fillProject(tester);
    await type(tester, 'Latitud', '-12.2');
    await type(tester, 'Mora (%) *', '1,5');
    await type(tester, 'Etapas separadas por comas *', 'Norte, norte');

    await tap(tester, 'Crear proyecto borrador');

    expect(find.text('Ingresa también la longitud'), findsOneWidget);
    expect(find.text('Ingresa un número con punto decimal, por ejemplo 12.5'), findsOneWidget);
    expect(find.text('La etapa «norte» está repetida'), findsOneWidget);
    expect(repository.createdProjects, isEmpty);
  });

  testWidgets('creates the project once when the button is tapped twice', (tester) async {
    await pumpPage(tester);
    await fillProject(tester);
    repository.gate = Completer<void>();

    await tester.tap(find.text('Crear proyecto borrador'));
    await tester.tap(find.text('Crear proyecto borrador'));
    repository.gate!.complete();
    await tester.pumpAndSettle();

    expect(repository.createdProjects, hasLength(1));
  });

  testWidgets('US-52 registers a draft lot with its price and keeps the stage', (tester) async {
    await pumpPage(tester);
    await openProject(tester);
    await fillLot(tester, code: 'S-01');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sur').last);
    await tester.pumpAndSettle();

    await tap(tester, 'Registrar lote borrador');

    final sent = repository.registeredLots.single;
    expect(sent.stageName, 'Sur');
    expect(sent.price, 45000.5);
    expect(sent.front, isNull);
    expect(sent.boundary.ring, hasLength(4));
    expect(banner(tester).message, 'Lote S-01 registrado como borrador en la etapa Sur.');
    expect(textOf(tester, 'Código del lote *'), isEmpty);
    expect(
      find.descendant(of: find.byType(DropdownButtonFormField<String>), matching: find.text('Sur')),
      findsOneWidget,
    );
    expect(find.text('S-01 · Etapa Sur'), findsOneWidget);
    expect(find.text('Borrador · 120 m² · S/ 45,000.50'), findsOneWidget);
  });

  testWidgets('names the line of the polygon to correct', (tester) async {
    await pumpPage(tester);
    await openProject(tester);

    await fillLot(tester, polygon: '-77.0,-12.0\n-77.1 -12.0\n-77.1,-12.1');
    await tap(tester, 'Registrar lote borrador');

    expect(find.text('La línea 2 debe ser longitud,latitud, por ejemplo -77.0428,-12.0464'), findsOneWidget);
    expect(banner(tester).message, 'Revisa los campos marcados.');
    expect(repository.registeredLots, isEmpty);
  });

  testWidgets('says in Spanish that the lot code is already taken and keeps the form', (tester) async {
    await pumpPage(tester);
    await openProject(tester);
    repository.failure = const LotCodeTaken('N-01');

    await fillLot(tester);
    await tap(tester, 'Registrar lote borrador');

    expect(banner(tester).message, 'Ya existe un lote con el código N-01 en este proyecto.');
    expect(banner(tester).isError, isTrue);
    expect(textOf(tester, 'Código del lote *'), 'N-01');
  });

  testWidgets('asks for a lot before publishing the project', (tester) async {
    await pumpPage(tester);
    await openProject(tester);

    await tap(tester, 'Publicar proyecto');

    expect(banner(tester).message, 'Registra al menos un lote antes de publicar el proyecto.');
    expect(repository.publishedProjects, isEmpty);
  });

  testWidgets('US-53 publishes the project and then its lot, answering on the lot', (tester) async {
    repository.lots = [testAdminLot()];
    await pumpPage(tester);
    await openProject(tester);

    expect(find.text('Publica el proyecto para poder publicar sus lotes.'), findsOneWidget);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Publicar lote')).onPressed, isNull);

    await tap(tester, 'Publicar proyecto');
    expect(find.text('Los Pinos · Publicado · ID 5'), findsOneWidget);

    await tap(tester, 'Publicar lote');

    expect(repository.publishedLots, [9]);
    expect(find.text('Disponible · 120 m² · S/ 45,000.00'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Card),
        matching: find.widgetWithText(MessageBanner, 'Lote N-01 publicado: ya figura como disponible.'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('names the project that does not exist', (tester) async {
    await pumpPage(tester);
    repository.failure = const ProjectNotFound(99);

    await type(tester, 'ID del proyecto', '99');
    await tap(tester, 'Cargar proyecto');

    expect(banner(tester).message, 'No existe un proyecto con el ID 99.');
    expect(find.text('Registrar lote'), findsNothing);
  });
}
