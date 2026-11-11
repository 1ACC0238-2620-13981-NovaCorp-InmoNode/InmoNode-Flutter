/// Financing conditions of a project, which the simulator (US-17) applies to its lots.
class FinancingRules {
  final double minDownPaymentPercentage;
  final double annualInterestRate;
  final int maxTermMonths;
  final double lateFeeRate;

  const FinancingRules({
    required this.minDownPaymentPercentage,
    required this.annualInterestRate,
    required this.maxTermMonths,
    required this.lateFeeRate,
  });
}
