import 'dart:io';
import 'package:requra/core/api/api_client.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/result_view/data/models/project_details_model.dart';
import 'package:dio/dio.dart';
import 'package:requra/features/result_view/data/models/document_model.dart';
import 'package:requra/features/result_view/data/models/ai_results_dashboard_model.dart';
import 'package:requra/features/result_view/data/models/stakeholder_feedback_model.dart';
import 'package:requra/features/result_view/data/models/review_invitation_model.dart';
import 'package:requra/features/result_view/data/models/user_story_list_model.dart';
import 'package:requra/features/result_view/data/models/requirement_list_model.dart';
import 'package:uuid/uuid.dart';

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
  Future<UserStoryListResponse> getUserStories(String projectId);
  Future<RequirementListResponse> getRequirements(String projectId);
  Future<StakeholderFeedbackResponseModel> getStakeholderFeedback(
    String projectId,
  );
  Future<void> resolveFeedback(
    String projectId,
    String feedbackId,
    String? resolutionNote,
  );
  Future<ReviewInvitationResponseModel> getReviewInvitations(String projectId);
  Future<void> sendReviewInvitation(
    String projectId,
    String displayName,
    String email,
    String permission,
    String? expiresAt,
  );
  Future<void> resendReviewInvitation(String projectId, String invitationId);
  Future<void> revokeReviewInvitation(String projectId, String invitationId);
  Future<Map<String, dynamic>> updateRequirementStatus(
    String projectId,
    String requirementId,
    int version,
    String workflowStatus, {
    String? reviewFeedback,
  });
  Future<Map<String, dynamic>> updateRequirement(
    String projectId,
    String requirementId,
    int version, {
    required String title,
    required String description,
    required String type,
    required String priority,
  });
  Future<Map<String, dynamic>> updateUserStoryStatus(
    String projectId,
    String storyId,
    int version,
    String workflowStatus, {
    String? reviewFeedback,
  });
  Future<Map<String, dynamic>> updateUserStory(
    String projectId,
    String storyId,
    int version, {
    required String title,
    required String description,
    required List<String> acceptanceCriteria,
    required String priority,
  });
  Future<Map<String, dynamic>> regenerateUserStory(
    String projectId,
    String storyId,
    int version,
    String feedback,
  );
}

class ResultViewRemoteDataSourceImpl implements ResultViewRemoteDataSource {
  final ApiClient apiClient;

  ResultViewRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProjectDetailsModel> getProjectDetails(String id) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.projects}/$id');

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
      if (response.statusCode == 204 ||
          response.data == null ||
          response.data == '') {
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
  Future<AiResultsDashboardModel> getAiResultsDashboard(
    String projectId,
  ) async {
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
  Future<UserStoryListResponse> getUserStories(String projectId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.userStoriesList(projectId),
      );

      Map<String, dynamic> data;
      if (response.data['data'] != null) {
        data = response.data['data'];
      } else {
        data = response.data;
      }

      return UserStoryListResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RequirementListResponse> getRequirements(String projectId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.requirementsList(projectId),
      );

      Map<String, dynamic> data;
      if (response.data['data'] != null) {
        data = response.data['data'];
      } else {
        data = response.data;
      }

      return RequirementListResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StakeholderFeedbackResponseModel> getStakeholderFeedback(
    String projectId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.feedback(projectId),
      );

      Map<String, dynamic> data;
      if (response.data['data'] != null) {
        data = response.data['data'];
      } else {
        data = response.data;
      }

      return StakeholderFeedbackResponseModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resolveFeedback(
    String projectId,
    String feedbackId,
    String? resolutionNote,
  ) async {
    try {
      await apiClient.dio.patch(
        ApiConstants.resolveFeedback(projectId, feedbackId),
        data: {
          "status": "RESOLVED",
          if (resolutionNote != null && resolutionNote.isNotEmpty)
            "resolutionNote": resolutionNote,
          "isRead": true,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ReviewInvitationResponseModel> getReviewInvitations(
    String projectId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.reviewInvitations(projectId),
      );
      return ReviewInvitationResponseModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendReviewInvitation(
    String projectId,
    String displayName,
    String email,
    String permission,
    String? expiresAt,
  ) async {
    try {
      await apiClient.dio.post(
        ApiConstants.reviewInvitations(projectId),
        data: {
          "stakeholders": [
            {"displayName": displayName, "email": email},
          ],
          "permission": permission,
          if (expiresAt != null) "expiresAt": expiresAt,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendReviewInvitation(
    String projectId,
    String invitationId,
  ) async {
    try {
      await apiClient.dio.post(
        ApiConstants.resendInvitation(projectId, invitationId),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> revokeReviewInvitation(
    String projectId,
    String invitationId,
  ) async {
    try {
      // It's a DELETE endpoint
      await apiClient.dio.delete(
        '${ApiConstants.reviewInvitations(projectId)}/$invitationId',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateRequirementStatus(
    String projectId,
    String requirementId,
    int version,
    String workflowStatus, {
    String? reviewFeedback,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        ApiConstants.requirementStatus(projectId, requirementId),
        options: Options(headers: {'If-Match': '"$version"'}),
        data: {
          "workflowStatus": workflowStatus,
          if (reviewFeedback != null && reviewFeedback.isNotEmpty)
            "reviewFeedback": reviewFeedback,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateRequirement(
    String projectId,
    String requirementId,
    int version, {
    required String title,
    required String description,
    required String type,
    required String priority,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        ApiConstants.requirementById(projectId, requirementId),
        options: Options(headers: {'If-Match': '"$version"'}),
        data: {
          "title": title,
          "description": description,
          "type": type,
          "priority": priority,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserStoryStatus(
    String projectId,
    String storyId,
    int version,
    String workflowStatus, {
    String? reviewFeedback,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        ApiConstants.userStoryStatus(projectId, storyId),
        options: Options(headers: {'If-Match': '"$version"'}),
        data: {
          "workflowStatus": workflowStatus,
          "feedback": (reviewFeedback != null && reviewFeedback.isNotEmpty) ? reviewFeedback : null,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserStory(
    String projectId,
    String storyId,
    int version, {
    required String title,
    required String description,
    required List<String> acceptanceCriteria,
    required String priority,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        ApiConstants.userStoryById(projectId, storyId),
        options: Options(headers: {'If-Match': '"$version"'}),
        data: {
          "title": title,
          "description": description,
          "acceptanceCriteria": acceptanceCriteria.map((ac) => {"text": ac}).toList(),
          "priority": priority,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> regenerateUserStory(
    String projectId,
    String storyId,
    int version,
    String feedback,
  ) async {
    try {
      final idempotencyKey = const Uuid().v4();
      final response = await apiClient.dio.post(
        ApiConstants.userStoryRegenerate(projectId, storyId),
        options: Options(headers: {
          'If-Match': '"$version"',
          'Idempotency-Key': idempotencyKey,
        }),
        data: {"feedback": feedback},
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
