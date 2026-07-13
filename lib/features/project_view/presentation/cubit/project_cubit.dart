import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/project_view/domain/usecases/project_usecases.dart';
import 'package:requra/features/project_view/presentation/cubit/project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final GetProjectsUseCase _getProjects;
  final DeleteProjectUseCase _deleteProject;
  final EditProjectUseCase _editProject;

  ProjectCubit({
    required GetProjectsUseCase getProjectsUseCase,
    required DeleteProjectUseCase deleteProjectUseCase,
    required EditProjectUseCase editProjectUseCase,
  })  : _getProjects = getProjectsUseCase,
        _deleteProject = deleteProjectUseCase,
        _editProject = editProjectUseCase,
        super(ProjectInitial());

  /// fetch projects from API
  Future<void> fetchProjects() async {
    emit(ProjectLoading());

    final result = await _getProjects();
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (projects) => emit(ProjectLoaded(allProjects: projects)),
    );
  }

  /// sort & search projects functions
  void searchProjects(String query) {
    if (state is ProjectLoaded) {
      emit((state as ProjectLoaded).copyWith(searchQuery: query));
    }
  }

  void sortProjects(String sortBy) {
    if (state is ProjectLoaded) {
      emit((state as ProjectLoaded).copyWith(sortBy: sortBy));
    }
  }

  ///delete project by id
  Future<void> deleteProject(String id) async {
    if (state is! ProjectLoaded) {
      return;
    }
    final currentState = state as ProjectLoaded;


    //⚠️⚠️⚠️ should remove after success
    final currentProjects = currentState.allProjects.where((p) => p.id != id).toList();
    emit(currentState.copyWith(allProjects: currentProjects));

    final result = await _deleteProject(id);
    result.fold(
      (failure) {
        emit(ProjectActionError(failure.message));
        emit(currentState);
      },
      (_) {
        emit(const ProjectActionSuccess('Project deleted successfully.'));
        emit(currentState.copyWith(allProjects: currentProjects));
      },
    );
  }

  /// edit project by id
  Future<bool> editProject(String id, Map<String, dynamic> data) async {
    if (state is! ProjectLoaded) {
      return false;
    }
    final currentState = state as ProjectLoaded;
    emit(currentState.copyWith(isSubmitting: true));
    final result = await _editProject(id, data);
    return result.fold(
      (failure) {
        emit(ProjectActionError(failure.message));
        emit(currentState.copyWith(isSubmitting: false));
        return false;
      },
      (updated) {
        final updatedList = currentState.allProjects.map((p) {
          return p.id == id ? updated : p;
        }).toList();
        
        emit(const ProjectActionSuccess('Project updated successfully.'));
        emit(currentState.copyWith(
          isSubmitting: false,
          allProjects: updatedList,
        ));
        return true;
      },
    );
  }
}
