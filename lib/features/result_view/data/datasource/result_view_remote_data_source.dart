import 'package:requra/core/api/api_client.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/result_view/data/models/meeting_model.dart';
import 'package:requra/features/result_view/data/models/project_details_model.dart';

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:requra/features/result_view/data/models/document_model.dart';
import 'package:requra/features/result_view/data/models/ai_results_dashboard_model.dart';

abstract class ResultViewRemoteDataSource {
  Future<ProjectDetailsModel> getProjectDetails(String id);
  Future<List<MeetingModel>> getProjectMeetings(String projectId);
  Future<List<DocumentModel>> getProjectDocuments(String projectId);
  Future<DocumentModel> uploadDocument({
    required File file,
    required String projectId,
    required String title,
    required int type,
    required int language,
    String? meetingId,
  });
  Future<AiResultsDashboardModel> getAiResultsDashboard(String projectId);
  Future<MeetingModel> createMeeting(String projectId, Map<String, dynamic> data);
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

      return ProjectDetailsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MeetingModel>> getProjectMeetings(String projectId) async {
    try {
      final response = await apiClient.dio
          .get('${ApiConstants.projects}/$projectId/meetings');

      List<dynamic> items;
      if (response.data['data'] != null &&
          response.data['data']['items'] != null) {
        items = response.data['data']['items'];
      } else {
        items = [];
      }

      return items.map((json) => MeetingModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DocumentModel>> getProjectDocuments(String projectId) async {
    try {
      final response = await apiClient.dio.get(
        '/api/documents',
        queryParameters: {'project_id': projectId},
      );

      List<dynamic> items;
      if (response.data['data'] != null &&
          response.data['data']['items'] != null) {
        items = response.data['data']['items'];
      } else {
        items = [];
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
    required int type,
    required int language,
    String? meetingId,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'projectId': projectId,
        'title': title,
        'type': type,
        'language': language,
        if (meetingId != null) 'meetingId': meetingId,
      });

      final response = await apiClient.dio.post(
        '/api/documents',
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
  @override
  Future<MeetingModel> createMeeting(String projectId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post(
        '${ApiConstants.projects}/$projectId/meetings',
        data: data,
      );

      Map<String, dynamic> responseData;
      if (response.data['data'] != null) {
        responseData = response.data['data'];
      } else {
        responseData = response.data;
      }

      return MeetingModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }
}
