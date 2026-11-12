import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/quotations/application/simulate_financing_use_case.dart';
import 'package:inmonode/features/quotations/presentation/simulation_panel.dart';
import 'package:inmonode/features/quotations/presentation/simulation_view_model.dart';

import '../quotation_fakes.dart';

void main() {
  late FakeQuotationRepository repository;

  setUp(() {
    repository = FakeQuotationRepository()..onSimulate = (_) async => testQuotation();
  });

  Future<void> pumpPanel(WidgetTester tester, {Size size = const Size(1280, 900)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final viewModel = SimulationViewModel(
      simulateFinancing: SimulateFinancingUseCase(repository: repository),
      lot: testQuotableLot(),
    );
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(padding: const EdgeInsets.all(16), children: [SimulationPanel(viewModel: viewModel)]),
        ),
      ),
    );
  }

  Future<void> simulate(WidgetTester tester) async {
    await tester.tap(find.text('Simular financiamiento'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the lot, its conditions and the minimum down payment', (tester) async {
    await pumpPanel(tester);

    expect(find.text('Lote A-01'), findsOneWidget);
    expect(find.text('S/ 35,000.00'), findsOneWidget);
    expect(
      find.text('Cuota inicial mínima 10 % · Tasa de interés anual 12.5 % · Hasta 60 meses'),
      findsOneWidget,
    );
    expect(find.text('Mínimo S/ 3,500.00 (10 % del precio)'), findsOneWidget);
    expect(find.text('60 meses'), findsOneWidget);
  });

  testWidgets('Scenario 1: shows the installment, the totals, the validity and the schedule', (tester) async {
    await pumpPanel(tester);

    await simulate(tester);

    expect(find.text('Cuota mensual'), findsOneWidget);
    expect(find.text('S/ 10,707.81'), findsWidgets);
    expect(find.text('3 cuotas, la última de S/ 10,707.82 por redondeo'), findsOneWidget);
    expect(find.text('12.5 %'), findsOneWidget);
    expect(find.text('S/ 623.44'), findsOneWidget);
    expect(find.text('S/ 35,623.44'), findsOneWidget);
    expect(find.textContaining('Esta simulación es válida hasta el'), findsOneWidget);
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('11/12/2026'), findsOneWidget);
    expect(find.text('S/ 21,102.89'), findsOneWidget);
    expect(find.text('Volver a simular'), findsOneWidget);
  });

  testWidgets('lists the schedule instead of a table on a phone', (tester) async {
    await pumpPanel(tester, size: const Size(360, 740));

    await simulate(tester);
    // The first scrollable is the page; the text field has its own.
    await tester.scrollUntilVisible(find.text('Cuota 3'), 300, scrollable: find.byType(Scrollable).first);

    expect(find.byType(DataTable), findsNothing);
    expect(find.text('Cuota 1'), findsOneWidget);
    expect(find.textContaining('Vence el 11/02/2027'), findsOneWidget);
  });

  testWidgets('Scenario 2: asks for at least the minimum down payment', (tester) async {
    await pumpPanel(tester);

    await tester.enterText(find.byType(TextField), '3000');
    await simulate(tester);

    expect(find.text('La cuota inicial mínima es S/ 3,500.00 (10 % del precio).'), findsOneWidget);
    expect(find.text('Cuota mensual'), findsNothing);
    expect(repository.calls, isEmpty);
  });

  testWidgets('disables the simulator when the lot is no longer available', (tester) async {
    repository.onSimulate = (_) async => throw const ApiException(
      statusCode: 409,
      code: 'LOT_CONFLICT',
      message: 'El lote ya no está disponible; elige otro lote',
    );
    await pumpPanel(tester);

    await simulate(tester);

    expect(find.text('El lote ya no está disponible; elige otro lote'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Simular financiamiento'));
    expect(button.onPressed, isNull);
  });
}
