import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inmonode/core/network/api_constants.dart';
import 'package:inmonode/core/network/api_response.dart';
import 'package:inmonode/features/quotations/infrastructure/remote/quotation_dto.dart';

/// Financing simulations, for buyers only (`BUYER`). It needs the `AuthorizedClient`, which sends the
/// session's access token.
class QuotationApi {
  final http.Client client;

  QuotationApi({required this.client});

  Future<QuotationDto> simulate(int lotId, double initialPayment, int termMonths) async {
    final response = await guardRequest(
      client.post(
        Uri.parse('${ApiConstants.baseUrl}/lots/$lotId/quotations'),
        headers: ApiConstants.jsonHeaders,
        body: jsonEncode({'initialPayment': initialPayment, 'termMonths': termMonths}),
      ),
    );
    if (!response.isSuccessful) throw response.error;
    return QuotationDto.fromJson(response.json as Map<String, dynamic>);
  }
}
