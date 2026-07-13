import 'package:requra/core/api/api_client.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/project_view/data/models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
  Future<bool> deleteProject(String id);
  Future<ProjectModel> editProject(String id, Map<String, dynamic> data);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final ApiClient apiClient;

  ProjectRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.projects);
      
      List<dynamic> data;
      //if status code == 200
      if (response.data['data']['items'] != null) {
        data = response.data['data']['items'];
      } else {
        data = [];
      }

      return data.map((json) => ProjectModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> deleteProject(String id) async {
    try {
      final response = await apiClient.dio.delete('${ApiConstants.projects}/$id');
      if (response.data is Map) {
        return response.data['isSuccess'] ?? true;
      }
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProjectModel> editProject(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.patch('${ApiConstants.projects}/$id', data: data);
      
      Map<String, dynamic> responseData;
      if (response.data is Map && response.data['data'] != null) {
        responseData = response.data['data'];
      } else {
        responseData = response.data;
      }
      
      return ProjectModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }
}
