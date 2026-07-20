import 'package:requra/core/api/api_client.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/project_creation_result.dart';

abstract class AddProjectRemoteDataSource {
  Future<ProjectCreationResult> createProject(
      ProjectDetails details, List<SourceItem> sources);
}

class AddProjectRemoteDataSourceImpl implements AddProjectRemoteDataSource {
  final ApiClient apiClient;

  AddProjectRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProjectCreationResult> createProject(
      ProjectDetails details, List<SourceItem> sources) async {
    // Build the request body matching the API contract
    final requestBody = {
      'name': details.projectName,
      'description': details.description,
      'ProjectType': details.projectType.toString(),
      'clientEmail': details.clientEmail,
      'teamMembers': details.teamMembers
          .map((email) => {'email': email})
          .toList(),
    };

    final response = await apiClient.dio.post(
      ApiConstants.projects,
      data: requestBody,
    );

    final responseData = response.data;

    // The API wraps the project data inside a "data" key
    if (responseData is Map<String, dynamic> &&
        responseData['isSuccess'] == true &&
        responseData['data'] != null) {
      return ProjectCreationResult.fromJson(
          responseData['data'] as Map<String, dynamic>);
    }

    throw Exception(
        responseData?['message'] ?? 'Failed to create project');
  }
}
