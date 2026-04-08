import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:requra/features/auth/data/models/projects_model.dart';

class ProjectService {
  static const String _baseUrl =
      'https://mock.apidog.com/m1/1212435-1208182-default/api';

  static const Map<String, String> _headers = {
    'Authorization': 'Bearer ANY_TOKEN',
    'Content-Type': 'application/json',
  };

  // ── GET /api/projects ─────────────────────────────────────────────────────
  /// Fetches the authenticated user's projects (paginated list).
  Future<List<Project>> getUserProjects() async {
    final uri = Uri.parse('$_baseUrl/projects');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ProjectResponse.fromJson(json).items;
    }

    throw Exception(
        'Failed to fetch projects (HTTP ${response.statusCode})');
  }

  // ── DELETE /api/projects/{id} ─────────────────────────────────────────────
  /// Deletes a project by ID. Returns true on success.
  Future<bool> deleteProject(String id) async {
    final uri = Uri.parse('$_baseUrl/projects/$id');
    final response = await http.delete(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['isSuccess'] == true && json['data'] == true;
    }

    throw Exception(
        'Failed to delete project (HTTP ${response.statusCode})');
  }
}
