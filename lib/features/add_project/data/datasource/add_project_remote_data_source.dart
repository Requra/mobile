import 'package:dio/dio.dart';
import 'package:requra/core/api/api_client.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/project_creation_result.dart';

import 'package:requra/features/project/data/models/ai_run_status.dart';

abstract class AddProjectRemoteDataSource {
  Future<ProjectCreationResult> createProject(ProjectDetails details);
  Future<String> uploadDocument(String projectId, SourceItem source);
  Future<String> startAiRun(String projectId, List<String> documentIds);
  Future<AiRunStatus> getAiRunProgress(String projectId, String runId);
}

class AddProjectRemoteDataSourceImpl implements AddProjectRemoteDataSource {
  final ApiClient apiClient;

  AddProjectRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProjectCreationResult> createProject(ProjectDetails details) async {
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
        responseData['data'] as Map<String, dynamic>,
      );
    }

    throw Exception(responseData?['message'] ?? 'Failed to create project');
  }

  @override
  Future<String> uploadDocument(String projectId, SourceItem source) async {
    final formData = FormData.fromMap({
      'projectId': projectId,
      'title': source.fileName,
      if (source.fileBytes != null)
        'file': MultipartFile.fromBytes(
          source.fileBytes!,
          filename: source.fileName,
        ),
    });

    final response = await apiClient.dio.post(
      ApiConstants.documents,
      data: formData,
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData['isSuccess'] == true &&
        responseData['data'] != null) {
      return responseData['data']['id'] ?? '';
    }

    throw Exception(responseData?['message'] ?? 'Failed to upload document');
  }

  @override
  Future<String> startAiRun(String projectId, List<String> documentIds) async {
    final payload = {
      "documentIds": documentIds,
      "meetingId": null,
      "analysisType": "project_results_dashboard",
      "language": "En",
    };

    final response = await apiClient.dio.post(
      'https://requra-ai.runasp.net/api/projects/$projectId/ai/runs',
      data: payload,
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData['isSuccess'] == true &&
        responseData['data'] != null) {
      return responseData['data']['aiJobId'] ?? '';
    }

    throw Exception(responseData?['message'] ?? 'Failed to start AI run');
  }

  @override
  Future<AiRunStatus> getAiRunProgress(String projectId, String runId) async {
    final response = await apiClient.dio.get(
      'https://requra-ai.runasp.net/api/projects/$projectId/ai/runs/$runId',
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData['isSuccess'] == true &&
        responseData['data'] != null) {
      return AiRunStatus.fromJson(responseData['data']);
    }

    throw Exception(
      responseData?['message'] ?? 'Failed to get AI run progress',
    );
  }
}
