/// `QuotationResource` of `POST /lots/{lotId}/quotations`. Amounts arrive as JSON numbers.
class QuotationDto {
  final int id;
  final int lotId;
  final int projectId;
  final String lotCode;
  final String currency;
  final double lotPrice;
  final double initialPayment;
  final double initialPercentage;
  final double financedAmount;
  final int termMonths;
  final double annualInterestRate;
  final double monthlyInstallment;
  final double totalInterest;
  final double totalToPay;
  final DateTime generatedAt;
  final DateTime validUntil;
  final List<InstallmentDto> installments;

  const QuotationDto({
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

  factory QuotationDto.fromJson(Map<String, dynamic> json) {
    return QuotationDto(
      id: json['id'] as int,
      lotId: json['lotId'] as int,
      projectId: json['projectId'] as int,
      lotCode: json['lotCode'] as String,
      currency: json['currency'] as String? ?? 'PEN',
      lotPrice: (json['lotPrice'] as num).toDouble(),
      initialPayment: (json['initialPayment'] as num).toDouble(),
      initialPercentage: (json['initialPercentage'] as num).toDouble(),
      financedAmount: (json['financedAmount'] as num).toDouble(),
      termMonths: json['termMonths'] as int,
      annualInterestRate: (json['annualInterestRate'] as num).toDouble(),
      monthlyInstallment: (json['monthlyInstallment'] as num).toDouble(),
      totalInterest: (json['totalInterest'] as num).toDouble(),
      totalToPay: (json['totalToPay'] as num).toDouble(),
      // Instants in UTC; the pages show them in the device's time.
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      installments: [
        for (final installment in json['installments'] as List<dynamic>)
          InstallmentDto.fromJson(installment as Map<String, dynamic>),
      ],
    );
  }
}

class InstallmentDto {
  final int number;

  /// A calendar date (`2026-12-11`), with no time zone.
  final DateTime dueDate;
  final double amount;
  final double principal;
  final double interest;
  final double balance;

  const InstallmentDto({
    required this.number,
    required this.dueDate,
    required this.amount,
    required this.principal,
    required this.interest,
    required this.balance,
  });

  factory InstallmentDto.fromJson(Map<String, dynamic> json) {
    return InstallmentDto(
      number: json['number'] as int,
      dueDate: DateTime.parse(json['dueDate'] as String),
      amount: (json['amount'] as num).toDouble(),
      principal: (json['principal'] as num).toDouble(),
      interest: (json['interest'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
