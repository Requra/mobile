import 'dart:io';
import 'package:requra/core/api/api_client.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/result_view/data/models/project_details_model.dart';
import 'package:dio/dio.dart';
import 'package:requra/features/result_view/data/models/document_model.dart';
import 'package:requra/features/result_view/data/models/ai_results_dashboard_model.dart';

abstract class ResultViewRemoteDataSource {
  Future<ProjectDetailsModel> getProjectDetails(String id);
  Future<List<DocumentModel>> getProjectDocuments(String projectId);
  Future<DocumentModel> uploadDocument({
    required File file,
    required String projectId,
    required String title,
    required String type,
    required String language,
    String? meetingId,
  });
  Future<AiResultsDashboardModel> getAiResultsDashboard(String projectId);
}

class ResultViewRemoteDataSourceImpl implements ResultViewRemoteDataSource {
  final ApiClient apiClient;

  ResultViewRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProjectDetailsModel> getProjectDetails(String id) async {
    try {
      final response =
          await apiClient.dio.get('${ApiConstants.projects}/$id');

      Map<String, dynamic> data;
      if (response.data['data'] != null) {
        data = response.data['data'];
      } else {
        data = response.data;
      }

      // teamMembers is already inside the project details JSON
      return ProjectDetailsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DocumentModel>> getProjectDocuments(String projectId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.documents,
        queryParameters: {'projectId': projectId},
      );

      // Handle 204 No Content or empty data
      if (response.statusCode == 204 || response.data == null || response.data == '') {
        return [];
      }

      List<dynamic> items = [];
      if (response.data['data'] is List) {
        items = response.data['data'];
      } else if (response.data['data'] != null &&
          response.data['data']['items'] != null) {
        items = response.data['data']['items'];
      } else if (response.data['items'] != null) {
        items = response.data['items'];
      } else if (response.data is List) {
        items = response.data;
      }

      return items.map((json) => DocumentModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DocumentModel> uploadDocument({
    required File file,
    required String projectId,
    required String title,
    required String type,
    required String language,
    String? meetingId,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      
      // Use PascalCase as required by the backend API
      final formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(file.path, filename: fileName),
        'ProjectId': projectId,
        'Title': title,
        'Type': type,
        'Language': language,
        if (meetingId != null) 'MeetingId': meetingId,
      });

      final response = await apiClient.dio.post(
        ApiConstants.documents,
        data: formData,
      );

      Map<String, dynamic> data;
      if (response.data['data'] != null) {
        data = response.data['data'];
      } else {
        data = response.data;
      }

      return DocumentModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AiResultsDashboardModel> getAiResultsDashboard(String projectId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.aiResultsDashboard(projectId),
      );

      Map<String, dynamic> data;
      if (response.data['data'] != null) {
        data = response.data['data'];
      } else {
        data = response.data;
      }

      return AiResultsDashboardModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
