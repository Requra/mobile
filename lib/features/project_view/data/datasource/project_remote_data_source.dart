import 'package:flutter/foundation.dart';
import 'package:requra/core/api/api_client.dart';
import 'package:requra/core/storage/secure_token_storage.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/project_view/data/models/paginated_projects.dart';
import 'package:requra/features/project_view/data/models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<PaginatedProjects> getProjects({String? status, int pageNumber = 1, int pageSize = 10});
  Future<bool> deleteProject(String id);
  Future<ProjectModel> editProject(String id, Map<String, dynamic> data);
  Future<ProjectModel> getProjectById(String id);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final ApiClient apiClient;

  ProjectRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedProjects> getProjects({String? status, int pageNumber = 1, int pageSize = 10}) async {
    try {
      final tokenStorage = const SecureTokenStorage();
      final userId = await tokenStorage.readUserId();
      
      final queryParams = <String, dynamic>{
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      };
      if (userId != null) {
        queryParams['UserId'] = userId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['Status'] = status;
      }
      
      final response = await apiClient.dio.get(
        ApiConstants.projects,
        queryParameters: queryParams,
      );
      if (response.statusCode == 204 || response.data == null || response.data == '') {
        return const PaginatedProjects(items: [], totalCount: 0, totalPages: 0, currentPage: 1);
      }
      
      // Debug: log the raw response to see item structure
      if (response.data is Map) {
        debugPrint('[getProjects] raw response keys: ${response.data.keys}');
        if (response.data['data'] != null) {
          final data = response.data['data'];
          if (data is Map && data['items'] is List) {
            for (final item in (data['items'] as List).take(2)) {
              debugPrint('[getProjects] item keys: ${(item as Map).keys}, id=${item['id']}');
            }
          }
          return PaginatedProjects.fromJson(data);
        }
      }
      return const PaginatedProjects(items: [], totalCount: 0, totalPages: 0, currentPage: 1);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> deleteProject(String id) async {
    try {
      debugPrint('[deleteProject] Deleting project with id: "$id"');
      debugPrint('[deleteProject] URL: ${ApiConstants.projectById(id)}');
      final response = await apiClient.dio.delete(ApiConstants.projectById(id));
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
      final response = await apiClient.dio.patch(ApiConstants.projectById(id), data: data);
      
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

  @override
  Future<ProjectModel> getProjectById(String id) async {
    try {
      final response = await apiClient.dio.get(ApiConstants.projectById(id));
      
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
