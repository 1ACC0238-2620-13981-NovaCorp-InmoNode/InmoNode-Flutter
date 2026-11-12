import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/catalog_admin/application/catalog_commands.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_page.dart';

import '../catalog_admin_fakes.dart';

void main() {
  late FakeAdminCatalogRepository repository;

  setUp(() => repository = FakeAdminCatalogRepository());

  Future<void> pumpPage(WidgetTester tester) async {
    // Tall enough to build the whole form at once.
    tester.view.physicalSize = const Size(1280, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: AdminCatalogPage(commands: CatalogCommands(repository))));
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

  testWidgets('shows what to correct next to the create button and sends nothing', (tester) async {
    await pumpPage(tester);

    await tap(tester, 'Crear proyecto borrador');

    expect(banner(tester).message, 'Completa «Nombre».');
    expect(banner(tester).isError, isTrue);
    expect(repository.createdProjects, isEmpty);
  });

  testWidgets('US-51 creates a draft project and clears its form', (tester) async {
    await pumpPage(tester);
    await fillProject(tester);

    await tap(tester, 'Crear proyecto borrador');

    expect(repository.createdProjects.single, {
      'name': 'Los Pinos',
      'location': 'Lurín, Lima',
      'financingRules': {
        'minDownPaymentPercentage': 10.0,
        'annualInterestRate': 12.5,
        'maxTermMonths': 60,
        'lateFeeRate': 1.5,
      },
      'stages': ['Norte', 'Sur'],
    });
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
    await tap(tester, 'Crear proyecto borrador');
    expect(banner(tester).message, 'Ingresa la latitud y la longitud juntas.');

    await type(tester, 'Longitud', '-200');
    await tap(tester, 'Crear proyecto borrador');
    expect(banner(tester).message, '«Longitud» debe estar entre -180 y 180.');

    await type(tester, 'Longitud', '-76.9');
    await type(tester, 'Mora (%) *', '1,5');
    await tap(tester, 'Crear proyecto borrador');
    expect(banner(tester).message, 'Ingresa un número en «Mora», con punto decimal: por ejemplo 12.5.');

    await type(tester, 'Mora (%) *', '1.5');
    await type(tester, 'Etapas separadas por comas *', 'Norte, norte');
    await tap(tester, 'Crear proyecto borrador');
    expect(banner(tester).message, 'La etapa «norte» está repetida.');

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

  testWidgets('US-52 registers a draft lot with a closed polygon and keeps the stage', (tester) async {
    await pumpPage(tester);
    await openProject(tester);
    await fillLot(tester, code: 'S-01');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sur').last);
    await tester.pumpAndSettle();

    await tap(tester, 'Registrar lote borrador');

    final sent = repository.registeredLots.single;
    expect(sent['stageName'], 'Sur');
    expect(sent['price'], 45000.5);
    expect(sent.containsKey('front'), isFalse);
    expect(sent['polygon'], [
      [
        [-77.0, -12.0],
        [-77.1, -12.0],
        [-77.1, -12.1],
        [-77.0, -12.0],
      ],
    ]);
    expect(banner(tester).message, 'Lote S-01 registrado como borrador en la etapa Sur.');
    expect(textOf(tester, 'Código del lote *'), isEmpty);
    expect(
      find.descendant(of: find.byType(DropdownButtonFormField<String>), matching: find.text('Sur')),
      findsOneWidget,
    );
    expect(find.text('S-01 · Etapa Sur'), findsOneWidget);
    expect(find.text('Borrador · S/ 45,000.00'), findsOneWidget);
  });

  testWidgets('explains what is wrong with the polygon', (tester) async {
    await pumpPage(tester);
    await openProject(tester);

    await fillLot(tester, polygon: '-77.0,-12.0\n-77.1,-12.0');
    await tap(tester, 'Registrar lote borrador');
    expect(banner(tester).message, 'El polígono necesita al menos tres vértices, uno por línea.');

    await type(tester, 'Polígono: longitud,latitud por línea *', '-77.0,-12.0\n-77.1 -12.0\n-77.1,-12.1');
    await tap(tester, 'Registrar lote borrador');
    expect(banner(tester).message, 'La línea 2 del polígono debe ser longitud,latitud, por ejemplo -77.0428,-12.0464.');

    expect(repository.registeredLots, isEmpty);
  });

  testWidgets('says in Spanish that the lot code is already taken', (tester) async {
    await pumpPage(tester);
    await openProject(tester);
    repository.failure = const ApiException(
      statusCode: 409,
      code: 'LOT_CONFLICT',
      message: 'El lote ya no está disponible; elige otro lote',
      details: 'the code is already used in this project',
    );

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
    expect(repository.publishedProjects, 0);
  });

  testWidgets('US-53 publishes the project and then its lot, answering on the lot', (tester) async {
    repository.lots = [draftLot()];
    await pumpPage(tester);
    await openProject(tester);

    expect(find.text('Publica el proyecto para poder publicar sus lotes.'), findsOneWidget);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Publicar lote')).onPressed, isNull);

    await tap(tester, 'Publicar proyecto');
    expect(find.text('Los Pinos · Publicado · ID 5'), findsOneWidget);

    await tap(tester, 'Publicar lote');

    expect(repository.publishedLots, [9]);
    expect(find.text('Disponible · S/ 45,000.00'), findsOneWidget);
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
    repository.failure = const ApiException(statusCode: 404, code: 'PROJECT_NOT_FOUND', message: 'Recurso no encontrado');

    await type(tester, 'ID del proyecto', '99');
    await tap(tester, 'Cargar proyecto');

    expect(banner(tester).message, 'No existe un proyecto con el ID 99.');
  });
}
