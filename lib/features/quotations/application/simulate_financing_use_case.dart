import 'package:inmonode/features/quotations/domain/quotation.dart';
import 'package:inmonode/features/quotations/domain/quotation_repository.dart';

class SimulateFinancingUseCase {
  final QuotationRepository repository;

  SimulateFinancingUseCase({required this.repository});

  Future<Quotation> execute({required int lotId, required double initialPayment, required int termMonths}) {
    return repository.simulate(lotId: lotId, initialPayment: initialPayment, termMonths: termMonths);
  }
}
