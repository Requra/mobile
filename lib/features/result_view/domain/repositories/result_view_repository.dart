import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/domain/entities/stakeholder_feedback.dart';
import 'package:requra/features/result_view/domain/entities/review_invitation.dart';

abstract class ResultViewRepository {
  Future<Either<Failure, ProjectDetails>> getProjectDetails(String id);
  Future<Either<Failure, List<Document>>> getProjectDocuments(String projectId);
  Future<Either<Failure, Document>> uploadDocument({
    required File file,
    required String projectId,
    required String title,
    required String type,
    required String language,
    String? meetingId,
  });
  Future<Either<Failure, AiResultsDashboard>> getAiResultsDashboard(String projectId);
  Future<Either<Failure, StakeholderFeedbackResponse>> getStakeholderFeedback(String projectId);
  Future<Either<Failure, void>> resolveFeedback(String projectId, String feedbackId, String? resolutionNote);
  Future<Either<Failure, ReviewInvitationResponse>> getReviewInvitations(String projectId);
  Future<Either<Failure, void>> sendReviewInvitation(String projectId, String displayName, String email, String permission, String? expiresAt);
  Future<Either<Failure, void>> resendReviewInvitation(String projectId, String invitationId);
  Future<Either<Failure, void>> revokeReviewInvitation(String projectId, String invitationId);
  Future<Either<Failure, Map<String, dynamic>>> updateRequirementStatus(
      String projectId, String requirementId, String workflowStatus,
      {String? reviewFeedback});
  Future<Either<Failure, Map<String, dynamic>>> updateRequirement(
    String projectId,
    String requirementId, {
    required String title,
    required String description,
    required String type,
    required String priority,
  });
  Future<Either<Failure, Map<String, dynamic>>> updateUserStoryStatus(
      String projectId, String storyId, String workflowStatus,
      {String? reviewFeedback});
  Future<Either<Failure, Map<String, dynamic>>> updateUserStory(
    String projectId,
    String storyId, {
    required String title,
    required String description,
    required List<String> acceptanceCriteria,
    required String priority,
  });
  Future<Either<Failure, Map<String, dynamic>>> regenerateUserStory(
      String projectId, String storyId, String feedback);
}
