import 'package:requra/core/api/api_client.dart';
import 'package:requra/core/storage/secure_token_storage.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/project_view/data/models/project_model.dart';

abstract class DashboardRemoteDataSource {
  Future<List<ProjectModel>> getAllProjects();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final tokenStorage = const SecureTokenStorage();
      final userId = await tokenStorage.readUserId();

      final queryParams = <String, dynamic>{
        'PageNumber': 1,
        'PageSize': 100, // Large page size to get all projects for the dashboard
      };
      
      if (userId != null) {
        queryParams['UserId'] = userId;
      }

      final response = await apiClient.dio.get(
        ApiConstants.projects,
        queryParameters: queryParams,
      );

      if (response.data['data'] != null) {
        final data = response.data['data'];
        if (data is Map && data['items'] is List) {
          return (data['items'] as List)
              .map((item) => ProjectModel.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
