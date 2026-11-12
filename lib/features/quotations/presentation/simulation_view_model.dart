import 'package:flutter/foundation.dart';
import 'package:inmonode/core/formatting/formats.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/quotations/application/simulate_financing_use_case.dart';
import 'package:inmonode/features/quotations/domain/financing_rejection.dart';
import 'package:inmonode/features/quotations/domain/quotable_lot.dart';
import 'package:inmonode/features/quotations/domain/quotation.dart';

/// Simulator of one lot (US-17): the buyer enters a down payment and a term, and gets the schedule.
class SimulationViewModel extends ChangeNotifier {
  static const String unexpectedMessage =
      'No pudimos calcular la simulación. Inténtalo de nuevo en unos minutos.';

  final SimulateFinancingUseCase simulateFinancing;
  final QuotableLot lot;

  /// Starts at the smallest down payment and the longest term the project allows.
  SimulationViewModel({required this.simulateFinancing, required this.lot})
    : initialPayment = _plain(lot.minimumInitialPayment),
      termMonths = lot.maxTermMonths;

  /// The down payment as the buyer types it.
  String initialPayment;
  int termMonths;

  /// Rejection of the down payment, shown on its field.
  String? initialPaymentError;
  String? errorMessage;

  /// The lot was reserved or unpublished meanwhile: it can no longer be simulated.
  bool lotUnavailable = false;
  bool isSimulating = false;
  Quotation? quotation;

  bool _disposed = false;

  void updateInitialPayment(String text) {
    initialPayment = text;
    if (initialPaymentError != null) {
      initialPaymentError = null;
      notifyListeners();
    }
  }

  void updateTermMonths(int months) {
    termMonths = months.clamp(1, lot.maxTermMonths);
    notifyListeners();
  }

  Future<void> simulate() async {
    if (isSimulating || lotUnavailable) return;
    errorMessage = null;
    final amount = Formats.parseAmount(initialPayment);
    if (amount == null || amount <= 0) {
      initialPaymentError = 'Ingresa la cuota inicial en soles, por ejemplo 4500 o 4500.50.';
      notifyListeners();
      return;
    }
    // US-17, Scenario 2: below the minimum it is rejected here, without asking the Web Services.
    final rejection = lot.check(amount, termMonths);
    if (rejection != null) {
      _show(rejection);
      notifyListeners();
      return;
    }

    isSimulating = true;
    initialPaymentError = null;
    notifyListeners();
    try {
      quotation = await simulateFinancing.execute(
        lotId: lot.lotId,
        initialPayment: amount,
        termMonths: termMonths,
      );
    } on FinancingRejection catch (rejection) {
      // The project's rules changed since the lot was loaded; the Web Services have the last word.
      _show(rejection);
    } on ApiException catch (e) {
      _showApiError(e);
    } catch (_) {
      errorMessage = unexpectedMessage;
    } finally {
      isSimulating = false;
      notifyListeners();
    }
  }

  void _show(FinancingRejection rejection) {
    switch (rejection) {
      case InitialPaymentBelowMinimum(:final minimum):
        initialPaymentError =
            'La cuota inicial mínima es ${Formats.money(minimum, currency: lot.currency)} '
            '(${Formats.percent(lot.minInitialPercentage)} del precio).';
      case InitialPaymentCoversPrice():
        initialPaymentError =
            'La cuota inicial debe ser menor que el precio del lote '
            '(${Formats.money(lot.price, currency: lot.currency)}).';
      case TermOutOfRange(:final maxTermMonths):
        errorMessage = 'El plazo debe estar entre 1 y $maxTermMonths meses.';
    }
  }

  void _showApiError(ApiException error) {
    switch (error.code) {
      case 'LOT_CONFLICT':
        lotUnavailable = true;
        quotation = null;
        errorMessage = error.message;
      case 'LOT_NOT_FOUND':
        lotUnavailable = true;
        quotation = null;
        errorMessage = 'Este lote ya no está publicado. Elige otro lote.';
      default:
        errorMessage = error.message;
    }
  }

  static String _plain(double amount) {
    final cents = (amount * 100).round();
    return cents % 100 == 0 ? '${cents ~/ 100}' : (cents / 100).toStringAsFixed(2);
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
