import 'package:inmonode/features/quotations/domain/quotation.dart';

abstract class QuotationRepository {
  /// Simulates the financing of a lot as the signed-in buyer.
  ///
  /// Throws a `FinancingRejection` when the down payment or the term break the project's rules, and an
  /// `ApiException` otherwise, such as `LOT_CONFLICT` when the lot is no longer available.
  Future<Quotation> simulate({required int lotId, required double initialPayment, required int termMonths});
}
