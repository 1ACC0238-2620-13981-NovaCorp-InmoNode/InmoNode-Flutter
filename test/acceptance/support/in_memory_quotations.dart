import 'dart:math' as math;

import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/quotations/domain/financing_rejection.dart';
import 'package:inmonode/features/quotations/domain/quotation.dart';
import 'package:inmonode/features/quotations/domain/quotation_repository.dart';

import 'in_memory_catalog.dart';

/// `POST /quotations` kept in memory: the French schedule of the Web Services (`FinancingSimulationService`),
/// with the monthly rate equivalent to the annual effective rate and amounts rounded half to even.
class InMemoryQuotations implements QuotationRepository {
  static const Duration validity = Duration(days: 7);

  final InMemoryCatalog catalog;

  /// Every simulation the app asked for.
  final List<({int lotId, double initialPayment, int termMonths})> requests = [];

  int _nextId = 1;

  InMemoryQuotations(this.catalog);

  @override
  Future<Quotation> simulate({required int lotId, required double initialPayment, required int termMonths}) async {
    requests.add((lotId: lotId, initialPayment: initialPayment, termMonths: termMonths));
    final lot = catalog.lots.where((lot) => lot.id == lotId).firstOrNull;
    if (lot == null || lot.status != LotStatus.available) {
      throw const ApiException(statusCode: 409, code: 'LOT_CONFLICT', message: 'El lote ya no está disponible');
    }
    final rules = catalog.projects.firstWhere((project) => project.id == lot.projectId).rules;
    final priceCents = _cents(lot.price);
    final initialCents = _cents(initialPayment);
    final minimumCents = (priceCents * rules.minDownPaymentPercentage / 100 - 1e-6).ceil();
    if (initialCents < minimumCents) throw InitialPaymentBelowMinimum(minimumCents / 100);
    if (initialCents >= priceCents) throw const InitialPaymentCoversPrice();
    if (termMonths < 1 || termMonths > rules.maxTermMonths) throw TermOutOfRange(rules.maxTermMonths);

    final now = DateTime.now();
    final installments = frenchSchedule(
      financedCents: priceCents - initialCents,
      annualRatePercentage: rules.annualInterestRate,
      termMonths: termMonths,
      startDate: DateTime(now.year, now.month, now.day),
    );
    final interestCents = installments.fold<int>(0, (sum, installment) => sum + _cents(installment.interest));
    return Quotation(
      id: _nextId++,
      lotId: lot.id,
      projectId: lot.projectId,
      lotCode: lot.code,
      currency: InMemoryCatalog.currency,
      lotPrice: priceCents / 100,
      initialPayment: initialCents / 100,
      initialPercentage: (initialCents * 10000 / priceCents).round() / 100,
      financedAmount: (priceCents - initialCents) / 100,
      termMonths: termMonths,
      annualInterestRate: rules.annualInterestRate,
      monthlyInstallment: installments.first.amount,
      totalInterest: interestCents / 100,
      totalToPay: (priceCents + interestCents) / 100,
      generatedAt: now,
      validUntil: now.add(validity),
      installments: installments,
    );
  }

  static List<Installment> frenchSchedule({
    required int financedCents,
    required double annualRatePercentage,
    required int termMonths,
    required DateTime startDate,
  }) {
    final monthlyRate = math.pow(1 + annualRatePercentage / 100, 1 / 12) - 1;
    final growth = math.pow(1 + monthlyRate, termMonths);
    final fixedCents = monthlyRate == 0
        ? _halfEven(financedCents / termMonths)
        : _halfEven(financedCents * monthlyRate * growth / (growth - 1));
    var balance = financedCents;
    return [
      for (var number = 1; number <= termMonths; number++)
        () {
          final interest = _halfEven(balance * monthlyRate);
          final principal = number == termMonths ? balance : fixedCents - interest;
          balance -= principal;
          return Installment(
            number: number,
            dueDate: _plusMonths(startDate, number),
            amount: (principal + interest) / 100,
            principal: principal / 100,
            interest: interest / 100,
            balance: balance / 100,
          );
        }(),
    ];
  }

  static int _cents(double amount) => (amount * 100).round();

  static int _halfEven(num cents) {
    final floor = cents.floor();
    final fraction = cents - floor;
    if ((fraction - 0.5).abs() < 1e-9) return floor.isEven ? floor : floor + 1;
    return cents.round();
  }

  /// Same day [months] later, or the last day of a shorter month, as `LocalDate.plusMonths`.
  static DateTime _plusMonths(DateTime date, int months) {
    final firstOfMonth = DateTime(date.year, date.month + months);
    final lastDay = DateTime(firstOfMonth.year, firstOfMonth.month + 1, 0).day;
    return DateTime(firstOfMonth.year, firstOfMonth.month, math.min(date.day, lastDay));
  }
}
