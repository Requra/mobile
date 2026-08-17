import 'package:equatable/equatable.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/domain/entities/stakeholder_feedback.dart';
import 'package:requra/features/result_view/domain/entities/review_invitation.dart';

sealed class ResultViewState extends Equatable {
  const ResultViewState();

  @override
  List<Object?> get props => [];
}

class ResultViewInitial extends ResultViewState {}

class ResultViewLoading extends ResultViewState {}

class ResultViewLoaded extends ResultViewState {
  final ProjectDetails projectDetails;
  final List<Document> documents;
  final int totalRequirements;
  final AiResultsDashboard? aiDashboard;
  final List<AiUserStory>? userStories;
  final bool userStoriesLoading;
  final List<AiRequirement>? requirements;
  final bool requirementsLoading;
  final StakeholderFeedbackResponse? feedbackResponse;
  final bool feedbackLoading;
  final ReviewInvitationResponse? reviewInvitations;
  final bool invitationsLoading;

  const ResultViewLoaded({
    required this.projectDetails,
    required this.documents,
    required this.totalRequirements,
    this.aiDashboard,
    this.userStories,
    this.userStoriesLoading = false,
    this.requirements,
    this.requirementsLoading = false,
    this.feedbackResponse,
    this.feedbackLoading = false,
    this.reviewInvitations,
    this.invitationsLoading = false,
  });

  @override
  List<Object?> get props => [
        projectDetails,
        documents,
        totalRequirements,
        aiDashboard,
        userStories,
        userStoriesLoading,
        requirements,
        requirementsLoading,
        feedbackResponse,
        feedbackLoading,
        reviewInvitations,
        invitationsLoading,
      ];
}

class ResultViewError extends ResultViewState {
  final String message;
  const ResultViewError(this.message);

  @override
  List<Object?> get props => [message];
}
