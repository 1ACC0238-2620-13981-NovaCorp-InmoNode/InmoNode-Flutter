import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inmonode/core/network/api_constants.dart';
import 'package:inmonode/core/network/api_response.dart';
import 'package:inmonode/features/catalog_admin/infrastructure/remote/admin_lot_dto.dart';
import 'package:inmonode/features/catalog_admin/infrastructure/remote/admin_project_dto.dart';

/// Catalog back-office (`/catalog`), for `CATALOG_ADMIN` only. It needs the `AuthorizedClient`, which sends
/// the session's access token; with it, `GET /projects/{id}` also answers draft projects.
class AdminCatalogApi {
  final http.Client client;

  AdminCatalogApi({required this.client});

  Future<AdminProjectDto> createProject(CreateProjectRequestDto request) async {
    return AdminProjectDto.fromJson(await _post('catalog/projects', request.toJson()) as Map<String, dynamic>);
  }

  Future<AdminProjectDto> getProject(int projectId) async {
    return AdminProjectDto.fromJson(await _get('projects/$projectId') as Map<String, dynamic>);
  }

  Future<List<AdminLotDto>> getLots(int projectId) async {
    final lots = await _get('catalog/projects/$projectId/lots') as List<dynamic>;
    return [for (final lot in lots) AdminLotDto.fromJson(lot as Map<String, dynamic>)];
  }

  Future<AdminLotDto> registerLot(int projectId, RegisterLotRequestDto request) async {
    final lot = await _post('catalog/projects/$projectId/lots', request.toJson());
    return AdminLotDto.fromJson(lot as Map<String, dynamic>);
  }

  Future<AdminProjectDto> publishProject(int projectId) async {
    return AdminProjectDto.fromJson(await _put('catalog/projects/$projectId/publish') as Map<String, dynamic>);
  }

  Future<AdminLotDto> publishLot(int lotId) async {
    return AdminLotDto.fromJson(await _put('catalog/lots/$lotId/publish') as Map<String, dynamic>);
  }

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}/$path');

  Future<dynamic> _get(String path) => _answer(client.get(_uri(path)));

  Future<dynamic> _post(String path, Map<String, dynamic> body) {
    return _answer(client.post(_uri(path), headers: ApiConstants.jsonHeaders, body: jsonEncode(body)));
  }

  Future<dynamic> _put(String path) => _answer(client.put(_uri(path), headers: ApiConstants.jsonHeaders));

  Future<dynamic> _answer(Future<http.Response> request) async {
    final response = await guardRequest(request);
    if (!response.isSuccessful) throw response.error;
    return response.json;
  }
}
