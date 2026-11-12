/// A simulated financing of a lot (US-17): fixed monthly installments under the project's rate, valid for a
/// limited time to back a separation request. Rates and shares are percentages (12.5 means 12.5 %).
class Quotation {
  final int id;
  final int lotId;
  final int projectId;
  final String lotCode;
  final String currency;
  final double lotPrice;
  final double initialPayment;

  /// Share of the lot price the down payment covers.
  final double initialPercentage;

  /// Lot price minus the down payment.
  final double financedAmount;
  final int termMonths;
  final double annualInterestRate;

  /// Fixed installment; only the last one may differ by a few cents of rounding.
  final double monthlyInstallment;
  final double totalInterest;

  /// Down payment plus every installment.
  final double totalToPay;
  final DateTime generatedAt;
  final DateTime validUntil;
  final List<Installment> installments;

  const Quotation({
    required this.id,
    required this.lotId,
    required this.projectId,
    required this.lotCode,
    required this.currency,
    required this.lotPrice,
    required this.initialPayment,
    required this.initialPercentage,
    required this.financedAmount,
    required this.termMonths,
    required this.annualInterestRate,
    required this.monthlyInstallment,
    required this.totalInterest,
    required this.totalToPay,
    required this.generatedAt,
    required this.validUntil,
    required this.installments,
  });

  /// The last installment when rounding made it differ from the others.
  Installment? get adjustedLastInstallment {
    if (installments.isEmpty) return null;
    final last = installments.last;
    return (last.amount - monthlyInstallment).abs() >= 0.005 ? last : null;
  }
}

/// One installment of the schedule.
class Installment {
  final int number;
  final DateTime dueDate;

  /// Principal plus interest.
  final double amount;
  final double principal;
  final double interest;

  /// Financed balance left after paying it.
  final double balance;

  const Installment({
    required this.number,
    required this.dueDate,
    required this.amount,
    required this.principal,
    required this.interest,
    required this.balance,
  });
}
