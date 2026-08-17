import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/domain/usecases/result_view_usecases.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_state.dart';

class ResultViewCubit extends Cubit<ResultViewState> {
  final GetProjectDetailsUseCase _getProjectDetails;
  final GetProjectDocumentsUseCase _getProjectDocuments;
  final GetAiResultsDashboardUseCase _getAiResultsDashboard;
  final GetUserStoriesUseCase _getUserStories;
  final GetRequirementsUseCase _getRequirements;
  final UploadDocumentUseCase _uploadDocument;

  final GetStakeholderFeedbackUseCase _getStakeholderFeedback;
  final ResolveFeedbackUseCase _resolveFeedback;
  final GetReviewInvitationsUseCase _getReviewInvitations;
  final SendReviewInvitationUseCase _sendReviewInvitation;
  final ResendReviewInvitationUseCase _resendReviewInvitation;
  final RevokeReviewInvitationUseCase _revokeReviewInvitation;
  final UpdateRequirementStatusUseCase _updateRequirementStatus;
  final UpdateRequirementUseCase _updateRequirement;
  final UpdateUserStoryStatusUseCase _updateUserStoryStatus;
  final UpdateUserStoryUseCase _updateUserStory;
  final RegenerateUserStoryUseCase _regenerateUserStory;

  ResultViewCubit({
    required GetProjectDetailsUseCase getProjectDetailsUseCase,
    required GetProjectDocumentsUseCase getProjectDocumentsUseCase,
    required GetAiResultsDashboardUseCase getAiResultsDashboardUseCase,
    required GetUserStoriesUseCase getUserStoriesUseCase,
    required GetRequirementsUseCase getRequirementsUseCase,
    required UploadDocumentUseCase uploadDocumentUseCase,
    required GetStakeholderFeedbackUseCase getStakeholderFeedbackUseCase,
    required ResolveFeedbackUseCase resolveFeedbackUseCase,
    required GetReviewInvitationsUseCase getReviewInvitationsUseCase,
    required SendReviewInvitationUseCase sendReviewInvitationUseCase,
    required ResendReviewInvitationUseCase resendReviewInvitationUseCase,
    required RevokeReviewInvitationUseCase revokeReviewInvitationUseCase,
    required UpdateRequirementStatusUseCase updateRequirementStatusUseCase,
    required UpdateRequirementUseCase updateRequirementUseCase,
    required UpdateUserStoryStatusUseCase updateUserStoryStatusUseCase,
    required UpdateUserStoryUseCase updateUserStoryUseCase,
    required RegenerateUserStoryUseCase regenerateUserStoryUseCase,
  }) : _getProjectDetails = getProjectDetailsUseCase,
       _getProjectDocuments = getProjectDocumentsUseCase,
       _getAiResultsDashboard = getAiResultsDashboardUseCase,
       _getUserStories = getUserStoriesUseCase,
       _getRequirements = getRequirementsUseCase,
       _uploadDocument = uploadDocumentUseCase,
       _getStakeholderFeedback = getStakeholderFeedbackUseCase,
       _resolveFeedback = resolveFeedbackUseCase,
       _getReviewInvitations = getReviewInvitationsUseCase,
       _sendReviewInvitation = sendReviewInvitationUseCase,
       _resendReviewInvitation = resendReviewInvitationUseCase,
       _revokeReviewInvitation = revokeReviewInvitationUseCase,
       _updateRequirementStatus = updateRequirementStatusUseCase,
       _updateRequirement = updateRequirementUseCase,
       _updateUserStoryStatus = updateUserStoryStatusUseCase,
       _updateUserStory = updateUserStoryUseCase,
       _regenerateUserStory = regenerateUserStoryUseCase,
       super(ResultViewInitial());

  /// Fetches project details and meetings in parallel.
  /// [totalRequirements] comes from the Project entity already available
  /// on the project card (from the projects list API).
  Future<void> fetchResultView(
    String projectId, {
    int totalRequirements = 0,
  }) async {
    emit(ResultViewLoading());

    // Fetch all in parallel
    final results = await Future.wait([
      _getProjectDetails(projectId),
      _getProjectDocuments(projectId),
      _getAiResultsDashboard(projectId),
    ]);

    final detailsResult = results[0];
    final documentsResult = results[1];
    final aiResult = results[2];

    // Check details result
    ProjectDetails? details;
    detailsResult.fold(
      (failure) => emit(ResultViewError(failure.message)),
      (data) => details = data as ProjectDetails,
    );
    if (details == null) return;

    // Check documents result
    List<Document> documents = [];
    documentsResult.fold(
      (_) => documents = [],
      (data) => documents = data as List<Document>,
    );

    // Check AI results
    AiResultsDashboard? aiDashboard;
    aiResult.fold(
      (_) => aiDashboard = null,
      (data) => aiDashboard = data as AiResultsDashboard,
    );

    emit(
      ResultViewLoaded(
        projectDetails: details!,
        documents: documents,
        totalRequirements: totalRequirements,
        aiDashboard: aiDashboard,
      ),
    );
  }

  /// Fetches user stories from the dedicated user-stories endpoint.
  Future<void> fetchUserStories(String projectId) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) return;

    emit(
      ResultViewLoaded(
        projectDetails: currentState.projectDetails,
        documents: currentState.documents,
        totalRequirements: currentState.totalRequirements,
        aiDashboard: currentState.aiDashboard,
        userStories: currentState.userStories,
        userStoriesLoading: true,
        requirements: currentState.requirements,
        requirementsLoading: currentState.requirementsLoading,
        feedbackResponse: currentState.feedbackResponse,
        feedbackLoading: currentState.feedbackLoading,
        reviewInvitations: currentState.reviewInvitations,
        invitationsLoading: currentState.invitationsLoading,
      ),
    );

    final result = await _getUserStories(projectId);

    result.fold(
      (failure) {
        if (state is ResultViewLoaded) {
          final curr = state as ResultViewLoaded;
          emit(
            ResultViewLoaded(
              projectDetails: curr.projectDetails,
              documents: curr.documents,
              totalRequirements: curr.totalRequirements,
              aiDashboard: curr.aiDashboard,
              userStories: curr.userStories,
              userStoriesLoading: false,
              requirements: curr.requirements,
              requirementsLoading: curr.requirementsLoading,
              feedbackResponse: curr.feedbackResponse,
              feedbackLoading: curr.feedbackLoading,
              reviewInvitations: curr.reviewInvitations,
              invitationsLoading: curr.invitationsLoading,
            ),
          );
        }
      },
      (userStories) {
        if (state is ResultViewLoaded) {
          final curr = state as ResultViewLoaded;
          emit(
            ResultViewLoaded(
              projectDetails: curr.projectDetails,
              documents: curr.documents,
              totalRequirements: curr.totalRequirements,
              aiDashboard: curr.aiDashboard,
              userStories: userStories,
              userStoriesLoading: false,
              requirements: curr.requirements,
              requirementsLoading: curr.requirementsLoading,
              feedbackResponse: curr.feedbackResponse,
              feedbackLoading: curr.feedbackLoading,
              reviewInvitations: curr.reviewInvitations,
              invitationsLoading: curr.invitationsLoading,
            ),
          );
        }
      },
    );
  }

  /// Fetches requirements from the dedicated requirements endpoint.
  Future<void> fetchRequirements(String projectId) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) return;

    emit(
      ResultViewLoaded(
        projectDetails: currentState.projectDetails,
        documents: currentState.documents,
        totalRequirements: currentState.totalRequirements,
        aiDashboard: currentState.aiDashboard,
        userStories: currentState.userStories,
        userStoriesLoading: currentState.userStoriesLoading,
        requirements: currentState.requirements,
        requirementsLoading: true,
        feedbackResponse: currentState.feedbackResponse,
        feedbackLoading: currentState.feedbackLoading,
        reviewInvitations: currentState.reviewInvitations,
        invitationsLoading: currentState.invitationsLoading,
      ),
    );

    final result = await _getRequirements(projectId);

    result.fold(
      (failure) {
        if (state is ResultViewLoaded) {
          final curr = state as ResultViewLoaded;
          emit(
            ResultViewLoaded(
              projectDetails: curr.projectDetails,
              documents: curr.documents,
              totalRequirements: curr.totalRequirements,
              aiDashboard: curr.aiDashboard,
              userStories: curr.userStories,
              userStoriesLoading: curr.userStoriesLoading,
              requirements: curr.requirements,
              requirementsLoading: false,
              feedbackResponse: curr.feedbackResponse,
              feedbackLoading: curr.feedbackLoading,
              reviewInvitations: curr.reviewInvitations,
              invitationsLoading: curr.invitationsLoading,
            ),
          );
        }
      },
      (requirements) {
        if (state is ResultViewLoaded) {
          final curr = state as ResultViewLoaded;
          emit(
            ResultViewLoaded(
              projectDetails: curr.projectDetails,
              documents: curr.documents,
              totalRequirements: curr.totalRequirements,
              aiDashboard: curr.aiDashboard,
              userStories: curr.userStories,
              userStoriesLoading: curr.userStoriesLoading,
              requirements: requirements,
              requirementsLoading: false,
              feedbackResponse: curr.feedbackResponse,
              feedbackLoading: curr.feedbackLoading,
              reviewInvitations: curr.reviewInvitations,
              invitationsLoading: curr.invitationsLoading,
            ),
          );
        }
      },
    );
  }

  Future<String?> uploadDocument({
    required File file,
    required String projectId,
    required String title,
    required String type,
    required String language,
  }) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) return 'State not loaded';

    // Create a placeholder document to show loading UI
    final tempDoc = Document(
      id: 'uploading_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      status: 999, // 999 indicates uploading state
      fileSize: file.lengthSync().toDouble(),
      createdAt: DateTime.now(),
    );

    // Emit state with placeholder document
    emit(
      ResultViewLoaded(
        projectDetails: currentState.projectDetails,
        documents: List.from(currentState.documents)..add(tempDoc),
        totalRequirements: currentState.totalRequirements,
        aiDashboard: currentState.aiDashboard,
        userStories: currentState.userStories,
        userStoriesLoading: currentState.userStoriesLoading,
        requirements: currentState.requirements,
        requirementsLoading: currentState.requirementsLoading,
        feedbackResponse: currentState.feedbackResponse,
        feedbackLoading: currentState.feedbackLoading,
        reviewInvitations: currentState.reviewInvitations,
        invitationsLoading: currentState.invitationsLoading,
      ),
    );

    try {
      final result = await _uploadDocument(
        file: file,
        projectId: projectId,
        title: title,
        type: type,
        language: language,
      );

      return result.fold(
        (failure) {
          // Revert back to original state on failure
          emit(
            ResultViewLoaded(
              projectDetails: currentState.projectDetails,
              documents: currentState.documents,
              totalRequirements: currentState.totalRequirements,
              aiDashboard: currentState.aiDashboard,
              userStories: currentState.userStories,
              userStoriesLoading: currentState.userStoriesLoading,
              requirements: currentState.requirements,
              requirementsLoading: currentState.requirementsLoading,
              feedbackResponse: currentState.feedbackResponse,
              feedbackLoading: currentState.feedbackLoading,
              reviewInvitations: currentState.reviewInvitations,
              invitationsLoading: currentState.invitationsLoading,
            ),
          );
          return failure.message; // Return error string
        },
        (document) {
          // Append the real document on success
          final updatedDocuments = List<Document>.from(currentState.documents)
            ..add(document);

          emit(
            ResultViewLoaded(
              projectDetails: currentState.projectDetails,
              documents: updatedDocuments,
              totalRequirements: currentState.totalRequirements,
              aiDashboard: currentState.aiDashboard,
              userStories: currentState.userStories,
              userStoriesLoading: currentState.userStoriesLoading,
              requirements: currentState.requirements,
              requirementsLoading: currentState.requirementsLoading,
              feedbackResponse: currentState.feedbackResponse,
              feedbackLoading: currentState.feedbackLoading,
              reviewInvitations: currentState.reviewInvitations,
              invitationsLoading: currentState.invitationsLoading,
            ),
          );
          return null; // Return null on success
        },
      );
    } catch (e) {
      // Fallback in case of unexpected exceptions (e.g. from hot reload missing DI)
      emit(
        ResultViewLoaded(
          projectDetails: currentState.projectDetails,
          documents: currentState.documents,
          totalRequirements: currentState.totalRequirements,
          aiDashboard: currentState.aiDashboard,
          userStories: currentState.userStories,
          userStoriesLoading: currentState.userStoriesLoading,
          requirements: currentState.requirements,
          requirementsLoading: currentState.requirementsLoading,
          feedbackResponse: currentState.feedbackResponse,
          feedbackLoading: currentState.feedbackLoading,
          reviewInvitations: currentState.reviewInvitations,
          invitationsLoading: currentState.invitationsLoading,
        ),
      );
      return e.toString();
    }
  }

  Future<String?> downloadDocument({required Document document}) async {
    try {
      if (document.storageUrl == null || document.storageUrl!.isEmpty) {
        return 'No download URL available';
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) return 'Could not access storage';

      final savedPath = '${directory.path}/${document.title}';

      final dio = Dio();
      await dio.download(document.storageUrl!, savedPath);

      return 'Downloaded to: $savedPath';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> fetchStakeholderFeedback(String projectId) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) return;

    emit(
      ResultViewLoaded(
        projectDetails: currentState.projectDetails,
        documents: currentState.documents,
        totalRequirements: currentState.totalRequirements,
        aiDashboard: currentState.aiDashboard,
        userStories: currentState.userStories,
        userStoriesLoading: currentState.userStoriesLoading,
        requirements: currentState.requirements,
        requirementsLoading: currentState.requirementsLoading,
        feedbackResponse: currentState.feedbackResponse,
        feedbackLoading: true,
        reviewInvitations: currentState.reviewInvitations,
        invitationsLoading: currentState.invitationsLoading,
      ),
    );

    final result = await _getStakeholderFeedback(projectId);

    result.fold(
      (failure) {
        // Just stop loading on error for now
        if (state is ResultViewLoaded) {
          final curr = state as ResultViewLoaded;
          emit(
            ResultViewLoaded(
              projectDetails: curr.projectDetails,
              documents: curr.documents,
              totalRequirements: curr.totalRequirements,
              aiDashboard: curr.aiDashboard,
              userStories: curr.userStories,
              userStoriesLoading: curr.userStoriesLoading,
              requirements: curr.requirements,
              requirementsLoading: curr.requirementsLoading,
              feedbackResponse: curr.feedbackResponse,
              feedbackLoading: false,
              reviewInvitations: curr.reviewInvitations,
              invitationsLoading: curr.invitationsLoading,
            ),
          );
        }
      },
      (feedbackResponse) {
        if (state is ResultViewLoaded) {
          final curr = state as ResultViewLoaded;
          emit(
            ResultViewLoaded(
              projectDetails: curr.projectDetails,
              documents: curr.documents,
              totalRequirements: curr.totalRequirements,
              aiDashboard: curr.aiDashboard,
              userStories: curr.userStories,
              userStoriesLoading: curr.userStoriesLoading,
              requirements: curr.requirements,
              requirementsLoading: curr.requirementsLoading,
              feedbackResponse: feedbackResponse,
              feedbackLoading: false,
              reviewInvitations: curr.reviewInvitations,
              invitationsLoading: curr.invitationsLoading,
            ),
          );
        }
      },
    );
  }

  Future<String?> resolveFeedback(
    String projectId,
    String feedbackId,
    String? resolutionNote,
  ) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) return 'State not loaded';

    final result = await _resolveFeedback(
      projectId,
      feedbackId,
      resolutionNote,
    );

    return result.fold((failure) => failure.message, (_) {
      // Refetch feedback on success
      fetchStakeholderFeedback(projectId);
      return null; // Success
    });
  }

  Future<void> fetchReviewInvitations(String projectId) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) return;

    emit(
      ResultViewLoaded(
        projectDetails: currentState.projectDetails,
        documents: currentState.documents,
        totalRequirements: currentState.totalRequirements,
        aiDashboard: currentState.aiDashboard,
        userStories: currentState.userStories,
        userStoriesLoading: currentState.userStoriesLoading,
        requirements: currentState.requirements,
        requirementsLoading: currentState.requirementsLoading,
        feedbackResponse: currentState.feedbackResponse,
        feedbackLoading: currentState.feedbackLoading,
        reviewInvitations: currentState.reviewInvitations,
        invitationsLoading: true,
      ),
    );

    final result = await _getReviewInvitations(projectId);

    result.fold(
      (failure) {
        if (state is ResultViewLoaded) {
          final curr = state as ResultViewLoaded;
          emit(
            ResultViewLoaded(
              projectDetails: curr.projectDetails,
              documents: curr.documents,
              totalRequirements: curr.totalRequirements,
              aiDashboard: curr.aiDashboard,
              userStories: curr.userStories,
              userStoriesLoading: curr.userStoriesLoading,
              requirements: curr.requirements,
              requirementsLoading: curr.requirementsLoading,
              feedbackResponse: curr.feedbackResponse,
              feedbackLoading: curr.feedbackLoading,
              reviewInvitations: curr.reviewInvitations,
              invitationsLoading: false,
            ),
          );
        }
      },
      (reviewInvitations) {
        if (state is ResultViewLoaded) {
          final curr = state as ResultViewLoaded;
          emit(
            ResultViewLoaded(
              projectDetails: curr.projectDetails,
              documents: curr.documents,
              totalRequirements: curr.totalRequirements,
              aiDashboard: curr.aiDashboard,
              userStories: curr.userStories,
              userStoriesLoading: curr.userStoriesLoading,
              requirements: curr.requirements,
              requirementsLoading: curr.requirementsLoading,
              feedbackResponse: curr.feedbackResponse,
              feedbackLoading: curr.feedbackLoading,
              reviewInvitations: reviewInvitations,
              invitationsLoading: false,
            ),
          );
        }
      },
    );
  }

  Future<String?> sendReviewInvitation({
    required String projectId,
    required String displayName,
    required String email,
    required String permission,
    String? expiresAt,
  }) async {
    final result = await _sendReviewInvitation(
      projectId,
      displayName,
      email,
      permission,
      expiresAt,
    );
    return result.fold((failure) => failure.message, (_) {
      fetchReviewInvitations(projectId);
      return null;
    });
  }

  Future<String?> resendReviewInvitation({
    required String projectId,
    required String invitationId,
  }) async {
    final result = await _resendReviewInvitation(projectId, invitationId);
    return result.fold((failure) => failure.message, (_) {
      fetchReviewInvitations(projectId);
      return null;
    });
  }

  Future<String?> revokeReviewInvitation({
    required String projectId,
    required String invitationId,
  }) async {
    final result = await _revokeReviewInvitation(projectId, invitationId);
    return result.fold((failure) => failure.message, (_) {
      fetchReviewInvitations(projectId);
      return null;
    });
  }

  Future<String?> updateRequirementStatus(
    String projectId,
    String requirementId,
    String status, {
    String? reviewFeedback,
  }) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) {
      return 'State not loaded';
    }

    final req = currentState.requirements?.firstWhere(
      (r) => r.id == requirementId,
      orElse: () => throw Exception('Requirement not found'),
    );
    final int version = req?.version ?? 0;

    final result = await _updateRequirementStatus(
      projectId,
      requirementId,
      version,
      status,
      reviewFeedback: reviewFeedback,
    );

    return result.fold(
      (failure) {
        if (failure.message == 'CONCURRENCY_ERROR') {
          fetchRequirements(projectId);
          return 'This item was modified by someone else. The list has been refreshed. Please review the new version and try again.';
        }
        return failure.message;
      },
      (response) {
        final int? newVersion =
            response['data']?['version'] ?? response['version'];
        // Update the separately fetched requirements list
        final updatedRequirements = currentState.requirements?.map((r) {
          if (r.id == requirementId) {
            return r.copyWith(workflowStatus: status, version: newVersion);
          }
          return r;
        }).toList();

        emit(
          ResultViewLoaded(
            projectDetails: currentState.projectDetails,
            documents: currentState.documents,
            totalRequirements: currentState.totalRequirements,
            aiDashboard: currentState.aiDashboard,
            userStories: currentState.userStories,
            userStoriesLoading: currentState.userStoriesLoading,
            requirements: updatedRequirements ?? currentState.requirements,
            requirementsLoading: currentState.requirementsLoading,
            feedbackResponse: currentState.feedbackResponse,
            feedbackLoading: currentState.feedbackLoading,
            reviewInvitations: currentState.reviewInvitations,
            invitationsLoading: currentState.invitationsLoading,
          ),
        );
        return null; // Success
      },
    );
  }

  Future<String?> updateRequirement(
    String projectId,
    String requirementId, {
    required String title,
    required String description,
    required String type,
    required String priority,
  }) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) {
      return 'State not loaded';
    }

    final req = currentState.requirements?.firstWhere(
      (r) => r.id == requirementId,
      orElse: () => throw Exception('Requirement not found'),
    );
    final int version = req?.version ?? 0;

    final result = await _updateRequirement(
      projectId,
      requirementId,
      version,
      title: title,
      description: description,
      type: type,
      priority: priority,
    );

    return result.fold(
      (failure) {
        if (failure.message == 'CONCURRENCY_ERROR') {
          fetchRequirements(projectId);
          return 'This item was modified by someone else. The list has been refreshed. Please review the new version and try again.';
        }
        return failure.message;
      },
      (response) {
        final int? newVersion =
            response['data']?['version'] ?? response['version'];
        // Update the separately fetched requirements list
        final updatedRequirements = currentState.requirements?.map((r) {
          if (r.id == requirementId) {
            return r.copyWith(
              title: title,
              description: description,
              type: type,
              priority: priority,
              version: newVersion,
            );
          }
          return r;
        }).toList();

        emit(
          ResultViewLoaded(
            projectDetails: currentState.projectDetails,
            documents: currentState.documents,
            totalRequirements: currentState.totalRequirements,
            aiDashboard: currentState.aiDashboard,
            userStories: currentState.userStories,
            userStoriesLoading: currentState.userStoriesLoading,
            requirements: updatedRequirements ?? currentState.requirements,
            requirementsLoading: currentState.requirementsLoading,
            feedbackResponse: currentState.feedbackResponse,
            feedbackLoading: currentState.feedbackLoading,
            reviewInvitations: currentState.reviewInvitations,
            invitationsLoading: currentState.invitationsLoading,
          ),
        );
        return null; // Success
      },
    );
  }

  Future<String?> updateUserStoryStatus(
    String projectId,
    String storyId,
    String status, {
    String? reviewFeedback,
  }) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) {
      return 'State not loaded';
    }

    final story = currentState.userStories?.firstWhere(
      (s) => s.id == storyId,
      orElse: () => throw Exception('User story not found'),
    );
    final int version = story?.version ?? 0;

    final result = await _updateUserStoryStatus(
      projectId,
      storyId,
      version,
      status,
      reviewFeedback: reviewFeedback,
    );

    return result.fold(
      (failure) {
        if (failure.message == 'CONCURRENCY_ERROR') {
          fetchUserStories(projectId);
          return 'This item was modified by someone else. The list has been refreshed. Please review the new version and try again.';
        }
        return failure.message;
      },
      (response) {
        final int? newVersion =
            response['data']?['version'] ?? response['version'];
        // Update the separately fetched user stories list
        final updatedStories = currentState.userStories?.map((s) {
          if (s.id == storyId) {
            return s.copyWith(workflowStatus: status, version: newVersion);
          }
          return s;
        }).toList();

        emit(
          ResultViewLoaded(
            projectDetails: currentState.projectDetails,
            documents: currentState.documents,
            totalRequirements: currentState.totalRequirements,
            aiDashboard: currentState.aiDashboard,
            userStories: updatedStories ?? currentState.userStories,
            userStoriesLoading: currentState.userStoriesLoading,
            requirements: currentState.requirements,
            requirementsLoading: currentState.requirementsLoading,
            feedbackResponse: currentState.feedbackResponse,
            feedbackLoading: currentState.feedbackLoading,
            reviewInvitations: currentState.reviewInvitations,
            invitationsLoading: currentState.invitationsLoading,
          ),
        );
        return null; // Success
      },
    );
  }

  Future<String?> updateUserStory(
    String projectId,
    String storyId, {
    required String title,
    required String description,
    required List<String> acceptanceCriteria,
    required String priority,
  }) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) {
      return 'State not loaded';
    }

    final story = currentState.userStories?.firstWhere(
      (s) => s.id == storyId,
      orElse: () => throw Exception('User story not found'),
    );
    final int version = story?.version ?? 0;

    final result = await _updateUserStory(
      projectId,
      storyId,
      version,
      title: title,
      description: description,
      acceptanceCriteria: acceptanceCriteria,
      priority: priority,
    );

    return result.fold(
      (failure) {
        if (failure.message == 'CONCURRENCY_ERROR') {
          fetchUserStories(projectId);
          return 'This item was modified by someone else. The list has been refreshed. Please review the new version and try again.';
        }
        return failure.message;
      },
      (response) {
        final int? newVersion =
            response['data']?['version'] ?? response['version'];
        // Update the separately fetched user stories list
        final updatedStories = currentState.userStories?.map((s) {
          if (s.id == storyId) {
            return s.copyWith(
              title: title,
              description: description,
              acceptanceCriteria: acceptanceCriteria,
              priority: priority,
              version: newVersion,
            );
          }
          return s;
        }).toList();

        emit(
          ResultViewLoaded(
            projectDetails: currentState.projectDetails,
            documents: currentState.documents,
            totalRequirements: currentState.totalRequirements,
            aiDashboard: currentState.aiDashboard,
            userStories: updatedStories ?? currentState.userStories,
            userStoriesLoading: currentState.userStoriesLoading,
            requirements: currentState.requirements,
            requirementsLoading: currentState.requirementsLoading,
            feedbackResponse: currentState.feedbackResponse,
            feedbackLoading: currentState.feedbackLoading,
            reviewInvitations: currentState.reviewInvitations,
            invitationsLoading: currentState.invitationsLoading,
          ),
        );
        return null; // Success
      },
    );
  }

  Future<String?> regenerateUserStory(
    String projectId,
    String storyId,
    String feedback,
  ) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) {
      return 'State not loaded';
    }

    final story = currentState.userStories?.firstWhere(
      (s) => s.id == storyId,
      orElse: () => throw Exception('User story not found'),
    );
    final int version = story?.version ?? 0;

    final result = await _regenerateUserStory(
      projectId,
      storyId,
      version,
      feedback,
    );

    return result.fold(
      (failure) {
        if (failure.message == 'CONCURRENCY_ERROR') {
          fetchUserStories(projectId);
          return 'This item was modified by someone else. The list has been refreshed. Please review the new version and try again.';
        }
        return failure.message;
      },
      (response) {
        final int? newVersion =
            response['data']?['version'] ?? response['version'];
        final updatedStories = currentState.userStories?.map((s) {
          if (s.id == storyId) {
            return s.copyWith(
              workflowStatus: 'GENERATED',
              version: newVersion,
            ); // Usually resets status
          }
          return s;
        }).toList();

        emit(
          ResultViewLoaded(
            projectDetails: currentState.projectDetails,
            documents: currentState.documents,
            totalRequirements: currentState.totalRequirements,
            aiDashboard: currentState.aiDashboard,
            userStories: updatedStories ?? currentState.userStories,
            userStoriesLoading: currentState.userStoriesLoading,
            requirements: currentState.requirements,
            requirementsLoading: currentState.requirementsLoading,
            feedbackResponse: currentState.feedbackResponse,
            feedbackLoading: currentState.feedbackLoading,
            reviewInvitations: currentState.reviewInvitations,
            invitationsLoading: currentState.invitationsLoading,
          ),
        );
        return null;
      },
    );
  }
}
