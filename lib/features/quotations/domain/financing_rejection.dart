/// Why a financing simulation was not accepted under the project's rules (US-17, Scenario 2).
sealed class FinancingRejection implements Exception {
  const FinancingRejection();
}

/// The down payment is under the project's minimum share of the price.
class InitialPaymentBelowMinimum extends FinancingRejection {
  /// The smallest down payment accepted, in the currency of the lot.
  final double minimum;

  const InitialPaymentBelowMinimum(this.minimum);
}

/// The down payment covers the whole price, so nothing would be financed.
class InitialPaymentCoversPrice extends FinancingRejection {
  const InitialPaymentCoversPrice();
}

/// The term is outside 1 to the project's maximum.
class TermOutOfRange extends FinancingRejection {
  final int maxTermMonths;

  const TermOutOfRange(this.maxTermMonths);
}
