import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/result_view/domain/entities/meeting.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/domain/usecases/result_view_usecases.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_state.dart';

class ResultViewCubit extends Cubit<ResultViewState> {
  final GetProjectDetailsUseCase _getProjectDetails;
  final GetProjectMeetingsUseCase _getProjectMeetings;
  final GetProjectDocumentsUseCase _getProjectDocuments;
  final GetAiResultsDashboardUseCase _getAiResultsDashboard;
  final UploadDocumentUseCase _uploadDocument;

  ResultViewCubit({
    required GetProjectDetailsUseCase getProjectDetailsUseCase,
    required GetProjectMeetingsUseCase getProjectMeetingsUseCase,
    required GetProjectDocumentsUseCase getProjectDocumentsUseCase,
    required GetAiResultsDashboardUseCase getAiResultsDashboardUseCase,
    required UploadDocumentUseCase uploadDocumentUseCase,
  })  : _getProjectDetails = getProjectDetailsUseCase,
        _getProjectMeetings = getProjectMeetingsUseCase,
        _getProjectDocuments = getProjectDocumentsUseCase,
        _getAiResultsDashboard = getAiResultsDashboardUseCase,
        _uploadDocument = uploadDocumentUseCase,
        super(ResultViewInitial());

  /// Fetches project details and meetings in parallel.
  /// [totalRequirements] comes from the Project entity already available
  /// on the project card (from the projects list API).
  Future<void> fetchResultView(String projectId,
      {int totalRequirements = 0}) async {
    emit(ResultViewLoading());

    // Fetch all in parallel
    final results = await Future.wait([
      _getProjectDetails(projectId),
      _getProjectMeetings(projectId),
      _getProjectDocuments(projectId),
      _getAiResultsDashboard(projectId),
    ]);

    final detailsResult = results[0];
    final meetingsResult = results[1];
    final documentsResult = results[2];
    final aiResult = results[3];

    // Check details result
    ProjectDetails? details;
    detailsResult.fold(
      (failure) => emit(ResultViewError(failure.message)),
      (data) => details = data as ProjectDetails,
    );
    if (details == null) return;

    // Check meetings result
    List<Meeting> meetings = [];
    meetingsResult.fold(
      (_) => meetings = [],
      (data) => meetings = data as List<Meeting>,
    );
    
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

    emit(ResultViewLoaded(
      projectDetails: details!,
      meetings: meetings,
      documents: documents,
      totalRequirements: totalRequirements,
      aiDashboard: aiDashboard,
    ));
  }

  Future<String?> uploadDocument({
    required File file,
    required String projectId,
    required String title,
    required int type,
    required int language,
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
    emit(ResultViewLoaded(
      projectDetails: currentState.projectDetails,
      meetings: currentState.meetings,
      documents: List.from(currentState.documents)..add(tempDoc),
      totalRequirements: currentState.totalRequirements,
      aiDashboard: currentState.aiDashboard,
    ));

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
          emit(ResultViewLoaded(
            projectDetails: currentState.projectDetails,
            meetings: currentState.meetings,
            documents: currentState.documents,
            totalRequirements: currentState.totalRequirements,
            aiDashboard: currentState.aiDashboard,
          ));
          return failure.message; // Return error string
        },
        (document) {
          // Append the real document on success
          final updatedDocuments = List<Document>.from(currentState.documents)
            ..add(document);
            
          emit(ResultViewLoaded(
            projectDetails: currentState.projectDetails,
            meetings: currentState.meetings,
            documents: updatedDocuments,
            totalRequirements: currentState.totalRequirements,
            aiDashboard: currentState.aiDashboard,
          ));
          return null; // Return null on success
        },
      );
    } catch (e) {
      // Fallback in case of unexpected exceptions (e.g. from hot reload missing DI)
      emit(ResultViewLoaded(
        projectDetails: currentState.projectDetails,
        meetings: currentState.meetings,
        documents: currentState.documents,
        totalRequirements: currentState.totalRequirements,
        aiDashboard: currentState.aiDashboard,
      ));
      return e.toString();
    }
  }
}
