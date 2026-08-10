import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/domain/usecases/result_view_usecases.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_state.dart';

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
  final UploadDocumentUseCase _uploadDocument;

  final GetStakeholderFeedbackUseCase _getStakeholderFeedback;
  final ResolveFeedbackUseCase _resolveFeedback;
  final GetReviewInvitationsUseCase _getReviewInvitations;
  final SendReviewInvitationUseCase _sendReviewInvitation;
  final ResendReviewInvitationUseCase _resendReviewInvitation;
  final RevokeReviewInvitationUseCase _revokeReviewInvitation;

  ResultViewCubit({
    required GetProjectDetailsUseCase getProjectDetailsUseCase,
    required GetProjectDocumentsUseCase getProjectDocumentsUseCase,
    required GetAiResultsDashboardUseCase getAiResultsDashboardUseCase,
    required UploadDocumentUseCase uploadDocumentUseCase,
    required GetStakeholderFeedbackUseCase getStakeholderFeedbackUseCase,
    required ResolveFeedbackUseCase resolveFeedbackUseCase,
    required GetReviewInvitationsUseCase getReviewInvitationsUseCase,
    required SendReviewInvitationUseCase sendReviewInvitationUseCase,
    required ResendReviewInvitationUseCase resendReviewInvitationUseCase,
    required RevokeReviewInvitationUseCase revokeReviewInvitationUseCase,
  }) : _getProjectDetails = getProjectDetailsUseCase,
       _getProjectDocuments = getProjectDocumentsUseCase,
       _getAiResultsDashboard = getAiResultsDashboardUseCase,
       _uploadDocument = uploadDocumentUseCase,
        _getStakeholderFeedback = getStakeholderFeedbackUseCase,
        _resolveFeedback = resolveFeedbackUseCase,
        _getReviewInvitations = getReviewInvitationsUseCase,
        _sendReviewInvitation = sendReviewInvitationUseCase,
        _resendReviewInvitation = resendReviewInvitationUseCase,
        _revokeReviewInvitation = revokeReviewInvitationUseCase,
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
        feedbackResponse: currentState.feedbackResponse,
        feedbackLoading: true,
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
              feedbackResponse: curr.feedbackResponse,
              feedbackLoading: false,
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
              feedbackResponse: feedbackResponse,
              feedbackLoading: false,
            ),
          );
        }
      },
    );
  }

  Future<String?> resolveFeedback(String projectId, String feedbackId, String? resolutionNote) async {
    final currentState = state;
    if (currentState is! ResultViewLoaded) return 'State not loaded';

    final result = await _resolveFeedback(projectId, feedbackId, resolutionNote);

    return result.fold(
      (failure) => failure.message,
      (_) {
        // Refetch feedback on success
        fetchStakeholderFeedback(projectId);
        return null; // Success
      },
    );
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
    final result = await _sendReviewInvitation(projectId, displayName, email, permission, expiresAt);
    return result.fold(
      (failure) => failure.message,
      (_) {
        fetchReviewInvitations(projectId);
        return null;
      },
    );
  }

  Future<String?> resendReviewInvitation({
    required String projectId,
    required String invitationId,
  }) async {
    final result = await _resendReviewInvitation(projectId, invitationId);
    return result.fold(
      (failure) => failure.message,
      (_) {
        fetchReviewInvitations(projectId);
        return null;
      },
    );
  }

  Future<String?> revokeReviewInvitation({
    required String projectId,
    required String invitationId,
  }) async {
    final result = await _revokeReviewInvitation(projectId, invitationId);
    return result.fold(
      (failure) => failure.message,
      (_) {
        fetchReviewInvitations(projectId);
        return null;
      },
    );
  }
}

