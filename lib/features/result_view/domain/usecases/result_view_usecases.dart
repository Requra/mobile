import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/domain/entities/stakeholder_feedback.dart';
import 'package:requra/features/result_view/domain/entities/review_invitation.dart';
import 'package:requra/features/result_view/domain/repositories/result_view_repository.dart';

class GetProjectDetailsUseCase {
  final ResultViewRepository repository;

  GetProjectDetailsUseCase(this.repository);

  Future<Either<Failure, ProjectDetails>> call(String id) {
    return repository.getProjectDetails(id);
  }
}

class GetProjectDocumentsUseCase {
  final ResultViewRepository repository;

  GetProjectDocumentsUseCase(this.repository);

  Future<Either<Failure, List<Document>>> call(String projectId) {
    return repository.getProjectDocuments(projectId);
  }
}

class UploadDocumentUseCase {
  final ResultViewRepository repository;

  UploadDocumentUseCase(this.repository);

  Future<Either<Failure, Document>> call({
    required File file,
    required String projectId,
    required String title,
    required String type,
    required String language,
    String? meetingId,
  }) {
    return repository.uploadDocument(
      file: file,
      projectId: projectId,
      title: title,
      type: type,
      language: language,
      meetingId: meetingId,
    );
  }
}

class GetAiResultsDashboardUseCase {
  final ResultViewRepository repository;

  GetAiResultsDashboardUseCase(this.repository);

  Future<Either<Failure, AiResultsDashboard>> call(String projectId) {
    return repository.getAiResultsDashboard(projectId);
  }
}

class GetStakeholderFeedbackUseCase {
  final ResultViewRepository repository;

  GetStakeholderFeedbackUseCase(this.repository);

  Future<Either<Failure, StakeholderFeedbackResponse>> call(String projectId) {
    return repository.getStakeholderFeedback(projectId);
  }
}

class ResolveFeedbackUseCase {
  final ResultViewRepository repository;

  ResolveFeedbackUseCase(this.repository);

  Future<Either<Failure, void>> call(String projectId, String feedbackId, String? resolutionNote) async {
    return await repository.resolveFeedback(projectId, feedbackId, resolutionNote);
  }
}

class GetReviewInvitationsUseCase {
  final ResultViewRepository repository;

  GetReviewInvitationsUseCase(this.repository);

  Future<Either<Failure, ReviewInvitationResponse>> call(String projectId) async {
    return await repository.getReviewInvitations(projectId);
  }
}

class SendReviewInvitationUseCase {
  final ResultViewRepository repository;

  SendReviewInvitationUseCase(this.repository);

  Future<Either<Failure, void>> call(String projectId, String displayName, String email, String permission, String? expiresAt) async {
    return await repository.sendReviewInvitation(projectId, displayName, email, permission, expiresAt);
  }
}

class ResendReviewInvitationUseCase {
  final ResultViewRepository repository;

  ResendReviewInvitationUseCase(this.repository);

  Future<Either<Failure, void>> call(String projectId, String invitationId) async {
    return await repository.resendReviewInvitation(projectId, invitationId);
  }
}

class RevokeReviewInvitationUseCase {
  final ResultViewRepository repository;

  RevokeReviewInvitationUseCase(this.repository);

  Future<Either<Failure, void>> call(String projectId, String invitationId) async {
    return await repository.revokeReviewInvitation(projectId, invitationId);
  }
}
