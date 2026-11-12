// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@Tags(['acceptance', 'US-17'])
import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_published_project_asks_for_a_minimum_down_payment_of_charges_an_annual_rate_of_and_finances_up_to_months.dart';
import './step/its_lot_is_available_at.dart';
import './step/a_buyer_is_signed_in.dart';
import './step/the_buyer_chooses_the_lot_of_to_simulate.dart';
import './step/the_buyer_enters_a_down_payment_of_and_a_term_of_months.dart';
import './step/the_buyer_runs_the_simulation.dart';
import './step/the_monthly_installment_is.dart';
import './step/the_term_is_summarized_as.dart';
import './step/the_breakdown_shows.dart';
import './step/the_schedule_lists_monthly_installments.dart';
import './step/the_down_payment_is_rejected_with.dart';
import './step/no_quotation_is_requested.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Self-service financing simulation''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await thePublishedProjectAsksForAMinimumDownPaymentOfChargesAnAnnualRateOfAndFinancesUpToMonths(
          tester, 'Los Pinos', 10, 12.5, 60);
      await itsLotIsAvailableAt(tester, 'N-01', 45000);
      await aBuyerIsSignedIn(tester);
      await theBuyerChoosesTheLotOfToSimulate(tester, 'N-01', 'Los Pinos');
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''Calculation with the standard rate''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Calculation with the standard rate''');
        await bddSetUp(tester);
        await theBuyerEntersADownPaymentOfAndATermOfMonths(tester, '4500', 60);
        await theBuyerRunsTheSimulation(tester);
        await theMonthlyInstallmentIs(tester, 'S/ 897.55');
        await theTermIsSummarizedAs(
            tester, '60 cuotas, la última de S/ 897.84 por redondeo');
        await theBreakdownShows(
            tester,
            const bdd.DataTable([
              ['concept', 'value'],
              ['Precio del lote', 'S/ 45,000.00'],
              ['Cuota inicial (10 %)', 'S/ 4,500.00'],
              ['Monto financiado', 'S/ 40,500.00'],
              ['Tasa de interés anual', '12.5 %'],
              ['Intereses', 'S/ 13,353.29'],
              ['Total a pagar', 'S/ 58,353.29']
            ]));
        await theScheduleListsMonthlyInstallments(tester, 60);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Calculation with the standard rate''',
          success,
        );
      }
    });
    testWidgets('''Minimum down payment validation''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Minimum down payment validation''');
        await bddSetUp(tester);
        await theBuyerEntersADownPaymentOfAndATermOfMonths(tester, '4000', 60);
        await theBuyerRunsTheSimulation(tester);
        await theDownPaymentIsRejectedWith(tester,
            'La cuota inicial mínima es S/ 4,500.00 (10 % del precio).');
        await noQuotationIsRequested(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Minimum down payment validation''',
          success,
        );
      }
    });
  });
}
