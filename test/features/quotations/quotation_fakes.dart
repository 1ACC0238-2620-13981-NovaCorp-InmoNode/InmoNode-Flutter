import 'package:inmonode/features/quotations/domain/quotable_lot.dart';
import 'package:inmonode/features/quotations/domain/quotation.dart';
import 'package:inmonode/features/quotations/domain/quotation_repository.dart';

/// Lot A-01 of Villa del Sol: S/ 35,000.00, at least 10 % down, 12.5 % a year, up to 60 months.
QuotableLot testQuotableLot({int lotId = 1, String code = 'A-01', double price = 35000}) {
  return QuotableLot(
    lotId: lotId,
    lotCode: code,
    area: 120,
    price: price,
    currency: 'PEN',
    projectId: 1,
    projectName: 'Villa del Sol',
    minInitialPercentage: 10,
    annualInterestRate: 12.5,
    maxTermMonths: 60,
  );
}

/// `POST /lots/1/quotations` with S/ 3,500.00 down over 3 months, as the backend answered it.
const Map<String, Object> quotationJson = {
  'id': 1,
  'lotId': 1,
  'projectId': 1,
  'lotCode': 'A-01',
  'currency': 'PEN',
  'lotPrice': 35000.00,
  'initialPayment': 3500.00,
  'initialPercentage': 10.00,
  'financedAmount': 31500.00,
  'termMonths': 3,
  'annualInterestRate': 12.5000,
  'monthlyInstallment': 10707.81,
  'totalInterest': 623.44,
  'totalToPay': 35623.44,
  'generatedAt': '2026-11-11T23:52:17.267656Z',
  'validUntil': '2026-11-18T23:52:17.267656Z',
  'installments': [
    {
      'number': 1,
      'dueDate': '2026-12-11',
      'amount': 10707.81,
      'principal': 10397.11,
      'interest': 310.70,
      'balance': 21102.89,
    },
    {
      'number': 2,
      'dueDate': '2027-01-11',
      'amount': 10707.81,
      'principal': 10499.66,
      'interest': 208.15,
      'balance': 10603.23,
    },
    {
      'number': 3,
      'dueDate': '2027-02-11',
      'amount': 10707.82,
      'principal': 10603.23,
      'interest': 104.59,
      'balance': 0.00,
    },
  ],
};

/// The same simulation as [quotationJson], as the domain sees it.
Quotation testQuotation() {
  return Quotation(
    id: 1,
    lotId: 1,
    projectId: 1,
    lotCode: 'A-01',
    currency: 'PEN',
    lotPrice: 35000,
    initialPayment: 3500,
    initialPercentage: 10,
    financedAmount: 31500,
    termMonths: 3,
    annualInterestRate: 12.5,
    monthlyInstallment: 10707.81,
    totalInterest: 623.44,
    totalToPay: 35623.44,
    generatedAt: DateTime.utc(2026, 11, 11, 23, 52, 17),
    validUntil: DateTime.utc(2026, 11, 18, 23, 52, 17),
    installments: [
      Installment(
        number: 1,
        dueDate: DateTime(2026, 12, 11),
        amount: 10707.81,
        principal: 10397.11,
        interest: 310.70,
        balance: 21102.89,
      ),
      Installment(
        number: 2,
        dueDate: DateTime(2027, 1, 11),
        amount: 10707.81,
        principal: 10499.66,
        interest: 208.15,
        balance: 10603.23,
      ),
      Installment(
        number: 3,
        dueDate: DateTime(2027, 2, 11),
        amount: 10707.82,
        principal: 10603.23,
        interest: 104.59,
        balance: 0,
      ),
    ],
  );
}

typedef SimulateCall = ({int lotId, double initialPayment, int termMonths});

class FakeQuotationRepository implements QuotationRepository {
  Future<Quotation> Function(SimulateCall call)? onSimulate;

  final List<SimulateCall> calls = [];

  @override
  Future<Quotation> simulate({required int lotId, required double initialPayment, required int termMonths}) {
    final call = (lotId: lotId, initialPayment: initialPayment, termMonths: termMonths);
    calls.add(call);
    return onSimulate!(call);
  }
}
