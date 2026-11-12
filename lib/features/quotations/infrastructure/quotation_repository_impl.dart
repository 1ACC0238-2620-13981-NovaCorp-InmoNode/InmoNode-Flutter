import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/quotations/domain/financing_rejection.dart';
import 'package:inmonode/features/quotations/domain/quotation.dart';
import 'package:inmonode/features/quotations/domain/quotation_repository.dart';
import 'package:inmonode/features/quotations/infrastructure/remote/quotation_api.dart';
import 'package:inmonode/features/quotations/infrastructure/remote/quotation_dto.dart';

class QuotationRepositoryImpl implements QuotationRepository {
  // The Web Services answer every broken rule as VALIDATION_ERROR, with the rule in `details` (in English).
  static final RegExp _belowMinimum = RegExp(r'initialPayment must be at least ([\d.]+)');
  static final RegExp _termOutOfRange = RegExp(r'termMonths must be between 1 and (\d+)');
  static const String _coversPrice = 'nothing would be financed';

  final QuotationApi api;

  const QuotationRepositoryImpl({required this.api});

  @override
  Future<Quotation> simulate({required int lotId, required double initialPayment, required int termMonths}) async {
    try {
      return _toQuotation(await api.simulate(lotId, initialPayment, termMonths));
    } on ApiException catch (e) {
      final rejection = _toRejection(e);
      if (rejection == null) rethrow;
      throw rejection;
    }
  }

  FinancingRejection? _toRejection(ApiException error) {
    final details = error.details;
    if (error.code != 'VALIDATION_ERROR' || details == null) return null;
    final minimum = _belowMinimum.firstMatch(details);
    if (minimum != null) return InitialPaymentBelowMinimum(double.parse(minimum.group(1)!));
    if (details.contains(_coversPrice)) return const InitialPaymentCoversPrice();
    final term = _termOutOfRange.firstMatch(details);
    if (term != null) return TermOutOfRange(int.parse(term.group(1)!));
    return null;
  }

  Quotation _toQuotation(QuotationDto dto) {
    return Quotation(
      id: dto.id,
      lotId: dto.lotId,
      projectId: dto.projectId,
      lotCode: dto.lotCode,
      currency: dto.currency,
      lotPrice: dto.lotPrice,
      initialPayment: dto.initialPayment,
      initialPercentage: dto.initialPercentage,
      financedAmount: dto.financedAmount,
      termMonths: dto.termMonths,
      annualInterestRate: dto.annualInterestRate,
      monthlyInstallment: dto.monthlyInstallment,
      totalInterest: dto.totalInterest,
      totalToPay: dto.totalToPay,
      generatedAt: dto.generatedAt,
      validUntil: dto.validUntil,
      installments: [
        for (final installment in dto.installments)
          Installment(
            number: installment.number,
            dueDate: installment.dueDate,
            amount: installment.amount,
            principal: installment.principal,
            interest: installment.interest,
            balance: installment.balance,
          ),
      ],
    );
  }
}
