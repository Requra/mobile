import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/add_project/domain/usecases/create_project_usecase.dart';
import 'package:requra/features/add_project/presentation/cubit/add_project_state.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';

export 'add_project_state.dart';

class AddProjectCubit extends Cubit<AddProjectState> {
  final CreateProjectUseCase _createProjectUseCase;

  AddProjectCubit({required CreateProjectUseCase createProjectUseCase})
      : _createProjectUseCase = createProjectUseCase,
        super(const AddProjectStep1());

  /// Move to Step 2
  void setProjectDetails(ProjectDetails details) {
    if (state is AddProjectStep1) {
      emit(AddProjectStep2(details: details, sources: const []));
    } else if (state is AddProjectStep2) {
      final currentState = state as AddProjectStep2;
      emit(AddProjectStep2(details: details, sources: currentState.sources));
    } else if (state is AddProjectError) {
       final currentState = state as AddProjectError;
       emit(AddProjectStep2(details: details, sources: currentState.sources));
    }
  }

  /// Add a source (Step 2)
  void addSource(SourceItem source) {
    if (state is AddProjectStep2) {
      final currentState = state as AddProjectStep2;
      final updatedSources = List<SourceItem>.from(currentState.sources)..add(source);
      emit(AddProjectStep2(details: currentState.details, sources: updatedSources));
    }
  }

  /// Remove a source (Step 2)
  void removeSource(int index) {
    if (state is AddProjectStep2) {
      final currentState = state as AddProjectStep2;
      final updatedSources = List<SourceItem>.from(currentState.sources)..removeAt(index);
      emit(AddProjectStep2(details: currentState.details, sources: updatedSources));
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
      emit(AddProjectStep2(details: currentState.details, sources: currentState.sources));
    } else if (state is AddProjectSuccess) {
      final currentState = state as AddProjectSuccess;
      emit(AddProjectStep2(details: currentState.details, sources: currentState.sources));
    } else if (state is AddProjectError) {
      final currentState = state as AddProjectError;
      emit(AddProjectStep2(details: currentState.details, sources: currentState.sources));
    }
  }

  /// Reset the wizard to the initial state (Step 1)
  void reset() {
    emit(const AddProjectStep1());
  }

  /// Start AI generation (Step 3)
  Future<void> createProject() async {
    if (state is! AddProjectStep2) return;
    
    final currentState = state as AddProjectStep2;
    emit(AddProjectCreating(details: currentState.details, sources: currentState.sources));

    final result = await _createProjectUseCase(currentState.details, currentState.sources);

    result.fold(
      (failure) => emit(AddProjectError(
        message: failure.message,
        details: currentState.details,
        sources: currentState.sources,
      )),
      (successResult) => emit(AddProjectSuccess(
        result: successResult,
        details: currentState.details,
        sources: currentState.sources,
      )),
    );
  }
}
