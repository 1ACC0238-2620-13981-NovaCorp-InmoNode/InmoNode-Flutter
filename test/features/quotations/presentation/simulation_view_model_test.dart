import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/quotations/application/simulate_financing_use_case.dart';
import 'package:inmonode/features/quotations/domain/financing_rejection.dart';
import 'package:inmonode/features/quotations/presentation/simulation_view_model.dart';

import '../quotation_fakes.dart';

void main() {
  late FakeQuotationRepository repository;
  late SimulationViewModel viewModel;

  setUp(() {
    repository = FakeQuotationRepository()..onSimulate = (_) async => testQuotation();
    viewModel = SimulationViewModel(
      simulateFinancing: SimulateFinancingUseCase(repository: repository),
      lot: testQuotableLot(),
    );
  });

  test('starts at the minimum down payment and the longest term of the project', () {
    expect(viewModel.initialPayment, '3500');
    expect(viewModel.termMonths, 60);
  });

  test('Scenario 1: simulates the lot with the down payment and the chosen term', () async {
    viewModel
      ..updateInitialPayment('5,000.50')
      ..updateTermMonths(36);

    await viewModel.simulate();

    expect(repository.calls.single, (lotId: 1, initialPayment: 5000.5, termMonths: 36));
    expect(viewModel.quotation?.monthlyInstallment, 10707.81);
    expect(viewModel.quotation?.annualInterestRate, testQuotableLot().annualInterestRate);
    expect(viewModel.initialPaymentError, isNull);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isSimulating, isFalse);
  });

  test('Scenario 2: rejects a down payment under the minimum without asking the Web Services', () async {
    viewModel.updateInitialPayment('3499.99');

    await viewModel.simulate();

    expect(repository.calls, isEmpty);
    expect(viewModel.quotation, isNull);
    expect(viewModel.initialPaymentError, 'La cuota inicial mínima es S/ 3,500.00 (10 % del precio).');
  });

  test('clears the rejection once the buyer edits the down payment', () async {
    viewModel.updateInitialPayment('3000');
    await viewModel.simulate();

    viewModel.updateInitialPayment('3500');

    expect(viewModel.initialPaymentError, isNull);
  });

  test('rejects a down payment that covers the whole price', () async {
    viewModel.updateInitialPayment('35000');

    await viewModel.simulate();

    expect(repository.calls, isEmpty);
    expect(viewModel.initialPaymentError, 'La cuota inicial debe ser menor que el precio del lote (S/ 35,000.00).');
  });

  test('asks for an amount it can read', () async {
    viewModel.updateInitialPayment('3.500,00');

    await viewModel.simulate();

    expect(repository.calls, isEmpty);
    expect(viewModel.initialPaymentError, contains('Ingresa la cuota inicial'));
  });

  test('keeps the term within the project limits', () {
    viewModel.updateTermMonths(0);
    expect(viewModel.termMonths, 1);

    viewModel.updateTermMonths(120);
    expect(viewModel.termMonths, 60);
  });

  test('shows the minimum of the Web Services when the project rules changed', () async {
    repository.onSimulate = (_) async => throw const InitialPaymentBelowMinimum(4200);

    await viewModel.simulate();

    expect(viewModel.initialPaymentError, 'La cuota inicial mínima es S/ 4,200.00 (10 % del precio).');
    expect(viewModel.quotation, isNull);
  });

  test('stops simulating a lot that someone else reserved meanwhile', () async {
    await viewModel.simulate();
    repository.onSimulate = (_) async => throw const ApiException(
      statusCode: 409,
      code: 'LOT_CONFLICT',
      message: 'El lote ya no está disponible; elige otro lote',
    );

    await viewModel.simulate();
    await viewModel.simulate();

    expect(repository.calls, hasLength(2));
    expect(viewModel.lotUnavailable, isTrue);
    expect(viewModel.quotation, isNull);
    expect(viewModel.errorMessage, 'El lote ya no está disponible; elige otro lote');
  });

  test('stops simulating a lot that is no longer published', () async {
    repository.onSimulate = (_) async => throw const ApiException(
      statusCode: 404,
      code: 'LOT_NOT_FOUND',
      message: 'Recurso no encontrado',
    );

    await viewModel.simulate();

    expect(viewModel.lotUnavailable, isTrue);
    expect(viewModel.errorMessage, 'Este lote ya no está publicado. Elige otro lote.');
  });

  test('lets the buyer retry after a connection failure', () async {
    repository.onSimulate = (_) async => throw const ApiException.network();

    await viewModel.simulate();

    expect(viewModel.errorMessage, const ApiException.network().message);
    expect(viewModel.lotUnavailable, isFalse);
  });
}
