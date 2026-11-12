import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/quotations/domain/financing_rejection.dart';
import 'package:inmonode/features/quotations/domain/quotable_lot.dart';

import '../../catalog/catalog_fakes.dart';
import '../quotation_fakes.dart';

void main() {
  test('takes the price from the lot and the rules from its project', () {
    final lot = QuotableLot.of(testProject(), testLot(id: 7, code: 'A-07'));

    expect(lot.lotId, 7);
    expect(lot.lotCode, 'A-07');
    expect(lot.price, 45000);
    expect(lot.projectName, 'Villa del Sol');
    expect(lot.minInitialPercentage, 10);
    expect(lot.annualInterestRate, 12.5);
    expect(lot.maxTermMonths, 60);
  });

  test('rounds the minimum down payment up to the cent, as the Web Services do', () {
    expect(testQuotableLot().minimumInitialPayment, 3500);
    // 15 % of 33,333.33 is 4,999.9995.
    final lot = QuotableLot(
      lotId: 1,
      lotCode: 'A-01',
      area: 120,
      price: 33333.33,
      currency: 'PEN',
      projectId: 1,
      projectName: 'Villa del Sol',
      minInitialPercentage: 15,
      annualInterestRate: 12,
      maxTermMonths: 60,
    );
    expect(lot.minimumInitialPayment, 5000);
  });

  test('accepts the minimum down payment and any term up to the maximum', () {
    final lot = testQuotableLot();

    expect(lot.check(3500, 1), isNull);
    expect(lot.check(34999.99, 60), isNull);
  });

  test('rejects a down payment under the minimum share of the price', () {
    final rejection = testQuotableLot().check(3499.99, 12);

    expect(rejection, isA<InitialPaymentBelowMinimum>());
    expect((rejection! as InitialPaymentBelowMinimum).minimum, 3500);
  });

  test('rejects a down payment that leaves nothing to finance', () {
    expect(testQuotableLot().check(35000, 12), isA<InitialPaymentCoversPrice>());
  });

  test('rejects a term longer than the project allows', () {
    final rejection = testQuotableLot().check(3500, 61);

    expect(rejection, isA<TermOutOfRange>());
    expect((rejection! as TermOutOfRange).maxTermMonths, 60);
  });
}
