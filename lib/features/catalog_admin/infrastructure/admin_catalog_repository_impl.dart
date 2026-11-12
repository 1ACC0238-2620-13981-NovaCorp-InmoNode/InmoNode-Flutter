import 'dart:convert';

import 'package:inmonode/core/network/api_constants.dart';
import 'package:inmonode/core/network/api_response.dart';
import 'package:inmonode/core/network/authorized_client.dart';

import '../domain/admin_catalog.dart';

class AdminCatalogRepositoryImpl implements AdminCatalogRepository {
  final AuthorizedClient client;
  const AdminCatalogRepositoryImpl(this.client);

  AdminProject _project(Map<String, dynamic> data) => AdminProject(
    (data['id'] as num).toInt(),
    data['name'] as String,
    data['status'] as String,
    (data['stages'] as List<dynamic>).cast<String>(),
  );

  @override
  Future<AdminProject> createProject(Map<String, dynamic> values) async {
    final response = await guardRequest(
      client.post(
        Uri.parse('${ApiConstants.baseUrl}/catalog/projects'),
        headers: ApiConstants.jsonHeaders,
        body: jsonEncode(values),
      ),
    );
    if (!response.isSuccessful) throw response.error;
    return _project(response.json as Map<String, dynamic>);
  }

  @override
  Future<AdminProject> getProject(int id) async {
    final response = await guardRequest(
      client.get(Uri.parse('${ApiConstants.baseUrl}/projects/$id')),
    );
    if (!response.isSuccessful) throw response.error;
    return _project(response.json as Map<String, dynamic>);
  }
}
