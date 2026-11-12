import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:inmonode/core/network/api_constants.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/quotations/domain/financing_rejection.dart';
import 'package:inmonode/features/quotations/infrastructure/quotation_repository_impl.dart';
import 'package:inmonode/features/quotations/infrastructure/remote/quotation_api.dart';

import '../quotation_fakes.dart';

/// The Web Services answer UTF-8 JSON without a charset in the content type.
http.Response jsonResponse(Object body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

http.Response validationError(String details) {
  return jsonResponse({'code': 'VALIDATION_ERROR', 'message': 'Validación fallida', 'details': details}, 400);
}

void main() {
  late List<http.Request> requests;

  QuotationRepositoryImpl repositoryAnswering(http.Response Function(http.Request) answer) {
    requests = [];
    return QuotationRepositoryImpl(
      api: QuotationApi(
        client: MockClient((request) async {
          requests.add(request);
          return answer(request);
        }),
      ),
    );
  }

  test('asks the Web Services to simulate the lot with the down payment and the term', () async {
    final repository = repositoryAnswering((_) => jsonResponse(quotationJson, 201));

    await repository.simulate(lotId: 1, initialPayment: 3500.5, termMonths: 3);

    final request = requests.single;
    expect(request.method, 'POST');
    expect(request.url.toString(), '${ApiConstants.baseUrl}/lots/1/quotations');
    expect(request.headers['Content-Type'], startsWith('application/json'));
    expect(request.headers['Accept-Language'], 'es');
    expect(jsonDecode(request.body), {'initialPayment': 3500.5, 'termMonths': 3});
  });

  test('reads the totals and the schedule of the simulation', () async {
    final repository = repositoryAnswering((_) => jsonResponse(quotationJson, 201));

    final quotation = await repository.simulate(lotId: 1, initialPayment: 3500, termMonths: 3);

    expect(quotation.id, 1);
    expect(quotation.lotCode, 'A-01');
    expect(quotation.financedAmount, 31500);
    expect(quotation.annualInterestRate, 12.5);
    expect(quotation.monthlyInstallment, 10707.81);
    expect(quotation.totalInterest, 623.44);
    expect(quotation.totalToPay, 35623.44);
    expect(quotation.validUntil, DateTime.utc(2026, 11, 18, 23, 52, 17, 267, 656));
    expect(quotation.installments, hasLength(3));
    final first = quotation.installments.first;
    expect(first.dueDate, DateTime(2026, 12, 11));
    expect(first.principal, 10397.11);
    expect(first.interest, 310.70);
    expect(first.balance, 21102.89);
    expect(quotation.installments.last.balance, 0);
    expect(quotation.adjustedLastInstallment?.amount, 10707.82);
  });

  test('reads the minimum down payment from a rejected simulation', () async {
    final repository = repositoryAnswering(
      (_) => validationError('initialPayment must be at least 3500.00 PEN (10 % of the price 35000.00)'),
    );

    expect(
      repository.simulate(lotId: 1, initialPayment: 3000, termMonths: 12),
      throwsA(isA<InitialPaymentBelowMinimum>().having((r) => r.minimum, 'minimum', 3500)),
    );
  });

  test('tells when the down payment leaves nothing to finance', () async {
    final repository = repositoryAnswering(
      (_) => validationError('initialPayment must be less than the price 35000.00; nothing would be financed'),
    );

    expect(
      repository.simulate(lotId: 1, initialPayment: 35000, termMonths: 12),
      throwsA(isA<InitialPaymentCoversPrice>()),
    );
  });

  test('reads the longest term from a rejected simulation', () async {
    final repository = repositoryAnswering((_) => validationError('termMonths must be between 1 and 48'));

    expect(
      repository.simulate(lotId: 1, initialPayment: 3500, termMonths: 60),
      throwsA(isA<TermOutOfRange>().having((r) => r.maxTermMonths, 'maxTermMonths', 48)),
    );
  });

  test('passes on a lot that is no longer available', () async {
    final repository = repositoryAnswering(
      (_) => jsonResponse({
        'code': 'LOT_CONFLICT',
        'message': 'El lote ya no está disponible; elige otro lote',
        'details': 'lot A-02 is not available; choose another lot',
      }, 409),
    );

    expect(
      repository.simulate(lotId: 2, initialPayment: 3650, termMonths: 12),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', 'LOT_CONFLICT')
            .having((e) => e.message, 'message', 'El lote ya no está disponible; elige otro lote'),
      ),
    );
  });

  test('passes on a validation error it does not recognize', () async {
    final repository = repositoryAnswering((_) => validationError('Field initialPayment must be greater than 0'));

    expect(
      repository.simulate(lotId: 1, initialPayment: 0, termMonths: 12),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'VALIDATION_ERROR')),
    );
  });
}
