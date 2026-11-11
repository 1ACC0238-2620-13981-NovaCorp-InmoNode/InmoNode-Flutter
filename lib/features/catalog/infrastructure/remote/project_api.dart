import 'package:http/http.dart' as http;
import 'package:inmonode/core/network/api_constants.dart';
import 'package:inmonode/core/network/api_response.dart';
import 'package:inmonode/features/catalog/infrastructure/remote/lot_dto.dart';
import 'package:inmonode/features/catalog/infrastructure/remote/project_dto.dart';
import 'package:inmonode/features/catalog/infrastructure/remote/project_summary_dto.dart';

/// Public catalog of `/projects`. It needs no session, so it uses a plain client.
class ProjectApi {
  /// Without a `Content-Type`, Web browsers send these GETs without a CORS preflight.
  static const Map<String, String> _headers = {'Accept-Language': 'es'};

  final http.Client client;

  ProjectApi({http.Client? client}) : client = client ?? http.Client();

  Future<List<ProjectSummaryDto>> getPublished() async {
    final projects = await _get('projects') as List<dynamic>;
    return [
      for (final project in projects) ProjectSummaryDto.fromJson(project as Map<String, dynamic>),
    ];
  }

  Future<ProjectDto> getById(int projectId) async {
    return ProjectDto.fromJson(await _get('projects/$projectId') as Map<String, dynamic>);
  }

  Future<List<LotDto>> getLots(int projectId) async {
    final collection = await _get('projects/$projectId/lots') as Map<String, dynamic>;
    return [
      for (final feature in collection['features'] as List<dynamic>)
        LotDto.fromFeature(feature as Map<String, dynamic>),
    ];
  }

  Future<dynamic> _get(String path) async {
    final response = await guardRequest(
      client.get(Uri.parse('${ApiConstants.baseUrl}/$path'), headers: _headers),
    );
    if (!response.isSuccessful) throw response.error;
    return response.json;
  }
}
