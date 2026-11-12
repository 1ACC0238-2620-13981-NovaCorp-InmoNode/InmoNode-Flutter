import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/domain/project.dart';
import 'package:inmonode/features/quotations/domain/financing_rejection.dart';

/// An available lot with what the simulator needs from its project: the price and the financing rules.
class QuotableLot {
  final int lotId;
  final String lotCode;
  final double area;
  final double price;
  final String currency;
  final int projectId;
  final String projectName;
  final double minInitialPercentage;
  final double annualInterestRate;
  final int maxTermMonths;

  const QuotableLot({
    required this.lotId,
    required this.lotCode,
    required this.area,
    required this.price,
    required this.currency,
    required this.projectId,
    required this.projectName,
    required this.minInitialPercentage,
    required this.annualInterestRate,
    required this.maxTermMonths,
  });

  factory QuotableLot.of(Project project, Lot lot) {
    final rules = project.financingRules;
    return QuotableLot(
      lotId: lot.id,
      lotCode: lot.code,
      area: lot.area,
      price: lot.price,
      currency: lot.currency,
      projectId: project.id,
      projectName: project.name,
      minInitialPercentage: rules.minDownPaymentPercentage,
      annualInterestRate: rules.annualInterestRate,
      maxTermMonths: rules.maxTermMonths,
    );
  }

  /// The smallest down payment the project accepts, rounded up to the cent as the Web Services do.
  double get minimumInitialPayment => _minimumCents / 100;

  /// Checks a simulation against the project's rules before asking the Web Services, which apply the same
  /// ones. Returns null when it can be simulated.
  FinancingRejection? check(double initialPayment, int termMonths) {
    final cents = (initialPayment * 100).round();
    if (cents < _minimumCents) return InitialPaymentBelowMinimum(minimumInitialPayment);
    if (cents >= (price * 100).round()) return const InitialPaymentCoversPrice();
    if (termMonths < 1 || termMonths > maxTermMonths) return TermOutOfRange(maxTermMonths);
    return null;
  }

  /// price × percentage / 100 in soles is price × percentage in cents. The small margin keeps a
  /// binary-float error such as 450000.0000001 from rounding up a whole cent.
  int get _minimumCents => (price * minInitialPercentage - 1e-6).ceil();
}
