import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/add_project/domain/usecases/create_project_usecase.dart';
import 'package:requra/features/add_project/presentation/cubit/add_project_state.dart';
import 'package:requra/features/add_project/domain/usecases/get_ai_run_progress_usecase.dart';
import 'package:requra/features/add_project/domain/usecases/upload_and_generate_usecase.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';

export 'add_project_state.dart';

class AddProjectCubit extends Cubit<AddProjectState> {
  final CreateProjectUseCase _createProjectUseCase;
  final UploadAndGenerateUseCase _uploadAndGenerateUseCase;
  final GetAiRunProgressUseCase _getAiRunProgressUseCase;

  AddProjectCubit({
    required CreateProjectUseCase createProjectUseCase,
    required UploadAndGenerateUseCase uploadAndGenerateUseCase,
    required GetAiRunProgressUseCase getAiRunProgressUseCase,
  })  : _createProjectUseCase = createProjectUseCase,
        _uploadAndGenerateUseCase = uploadAndGenerateUseCase,
        _getAiRunProgressUseCase = getAiRunProgressUseCase,
        super(const AddProjectStep1());

  /// Update details without API call (legacy)
  void setProjectDetails(ProjectDetails details) {
    if (state is AddProjectStep1) {
      emit(AddProjectStep1(details: details));
    }
  }

  /// Add a source (Step 2)
  void addSource(SourceItem source) {
    if (state is AddProjectStep2) {
      final currentState = state as AddProjectStep2;
      final updatedSources = List<SourceItem>.from(currentState.sources)..add(source);
      emit(AddProjectStep2(details: currentState.details, sources: updatedSources, projectId: currentState.projectId));
    }
  }

  /// Remove a source (Step 2)
  void removeSource(int index) {
    if (state is AddProjectStep2) {
      final currentState = state as AddProjectStep2;
      final updatedSources = List<SourceItem>.from(currentState.sources)..removeAt(index);
      emit(AddProjectStep2(details: currentState.details, sources: updatedSources, projectId: currentState.projectId));
    }
  }

  /// Go back to Step 1
  void goBackToStep1() {
    if (state is AddProjectStep2) {
      final currentState = state as AddProjectStep2;
      emit(AddProjectStep1(details: currentState.details));
    } else if (state is AddProjectCreating) {
      final currentState = state as AddProjectCreating;
      emit(AddProjectStep1(details: currentState.details));
    } else if (state is AddProjectError) {
       final currentState = state as AddProjectError;
       emit(AddProjectStep1(details: currentState.details));
    }
  }

  /// Go back to Step 2 from generating/success/error state
  void goBackToStep2() {
    if (state is AddProjectCreating) {
      final currentState = state as AddProjectCreating;
      emit(AddProjectStep2(details: currentState.details, sources: currentState.sources, projectId: currentState.projectId));
    } else if (state is AddProjectSuccess) {
      final currentState = state as AddProjectSuccess;
      emit(AddProjectStep2(details: currentState.details, sources: currentState.sources, projectId: currentState.projectId));
    } else if (state is AddProjectError) {
      final currentState = state as AddProjectError;
      emit(AddProjectStep2(details: currentState.details, sources: currentState.sources, projectId: currentState.projectId ?? ''));
    }
  }

  /// Reset the wizard to the initial state (Step 1)
  void reset() {
    emit(const AddProjectStep1());
  }

  /// Create Project (Step 1)
  Future<void> createProject(ProjectDetails details) async {
    emit(AddProjectStep1Loading(details: details));

    final result = await _createProjectUseCase(details);

    result.fold(
      (failure) {
        // Stay on step 1 on error, just pass error via a Snackbar in UI (handled by AddProjectError for simplicity, but wait, AddProjectError requires sources. Let's just emit Step1 again or AddProjectError with empty sources).
        emit(AddProjectError(
          message: failure.message,
          details: details,
          sources: const [],
        ));
      },
      (successResult) {
        emit(AddProjectStep2(
          details: details,
          sources: const [],
          projectId: successResult.projectId,
        ));
      },
    );
  }

  /// Upload documents and generate (Step 2)
  Future<void> uploadAndGenerate(String projectId, List<SourceItem> sources) async {
    if (state is! AddProjectStep2) return;
    final currentState = state as AddProjectStep2;
    
    emit(AddProjectCreating(
      details: currentState.details,
      sources: sources,
      projectId: projectId,
    ));

    final result = await _uploadAndGenerateUseCase(projectId, sources);
    
    result.fold(
      (failure) => emit(AddProjectError(
        message: failure.message,
        details: currentState.details,
        sources: sources,
        projectId: projectId,
      )),
      (runId) {
        emit(AddProjectCreating(
          details: currentState.details,
          sources: sources,
          projectId: projectId,
          aiJobId: runId,
          progress: 0,
          statusMessage: 'Queued for AI analysis',
        ));
        _startPollingAiProgress(projectId, runId, currentState.details, sources);
      },
    );
  }

  Future<void> _startPollingAiProgress(String projectId, String runId, ProjectDetails details, List<SourceItem> sources) async {
    const pollInterval = Duration(seconds: 3);
    
    while (state is AddProjectCreating && (state as AddProjectCreating).aiJobId == runId) {
      await Future.delayed(pollInterval);
      
      // Stop if state changed while waiting (e.g., user went back)
      if (state is! AddProjectCreating) return;
      
      final result = await _getAiRunProgressUseCase(projectId, runId);
      
      result.fold(
        (failure) {
          emit(AddProjectError(
            message: failure.message,
            details: details,
            sources: sources,
            projectId: projectId,
          ));
        },
        (status) {
          if (status.status.toUpperCase() == 'COMPLETED') {
            emit(AddProjectSuccess(
              details: details,
              sources: sources,
              projectId: projectId,
            ));
          } else if (status.status.toUpperCase() == 'FAILED' || status.status.toUpperCase() == 'ERROR') {
            emit(AddProjectError(
              message: status.message.isNotEmpty ? status.message : 'AI generation failed',
              details: details,
              sources: sources,
              projectId: projectId,
            ));
          } else {
            // Processing or Queued
            emit(AddProjectCreating(
              details: details,
              sources: sources,
              projectId: projectId,
              aiJobId: runId,
              progress: status.progress,
              statusMessage: status.currentNodeLabel.isNotEmpty ? status.currentNodeLabel : status.message,
            ));
          }
        }
      );
      
      if (state is AddProjectSuccess || state is AddProjectError) {
        break;
      }
    }
  }
}
