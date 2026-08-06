import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/project_view/domain/usecases/project_usecases.dart';
import 'package:requra/features/project_view/presentation/cubit/project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final GetProjectsUseCase _getProjects;
  final DeleteProjectUseCase _deleteProject;
  final EditProjectUseCase _editProject;

  final GetProjectByIdUseCase _getProjectById;

  ProjectCubit({
    required GetProjectsUseCase getProjectsUseCase,
    required DeleteProjectUseCase deleteProjectUseCase,
    required EditProjectUseCase editProjectUseCase,
    required GetProjectByIdUseCase getProjectByIdUseCase,
  })  : _getProjects = getProjectsUseCase,
        _deleteProject = deleteProjectUseCase,
        _editProject = editProjectUseCase,
        _getProjectById = getProjectByIdUseCase,
        super(ProjectInitial());

  /// fetch projects from API
  Future<void> fetchProjects({String? status, int page = 1}) async {
    emit(ProjectLoading());

    final result = await _getProjects(status: status, pageNumber: page);
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (paginated) => emit(ProjectLoaded(
        allProjects: paginated.items,
        currentPage: paginated.currentPage,
        totalPages: paginated.totalPages,
        totalCount: paginated.totalCount,
        activeStatus: status,
      )),
    );
  }

  Future<void> changeTab(String? status) async {
    await fetchProjects(status: status, page: 1);
  }

  Future<void> loadMore() async {
    if (state is! ProjectLoaded) return;
    final currentState = state as ProjectLoaded;
    
    if (currentState.isLoadingMore || currentState.currentPage >= currentState.totalPages) return;
    
    emit(currentState.copyWith(isLoadingMore: true));
    
    final nextPage = currentState.currentPage + 1;
    final result = await _getProjects(status: currentState.activeStatus, pageNumber: nextPage);
    
    result.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
        emit(ProjectActionError(failure.message));
      },
      (paginated) {
        final updatedProjects = List<Project>.from(currentState.allProjects)..addAll(paginated.items);
        emit(currentState.copyWith(
          allProjects: updatedProjects,
          currentPage: paginated.currentPage,
          totalPages: paginated.totalPages,
          totalCount: paginated.totalCount,
          isLoadingMore: false,
        ));
      },
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
    if (id.isEmpty) {
      emit(const ProjectActionError('Cannot delete: project ID is missing.'));
      return;
    }
    final currentState = state as ProjectLoaded;

    final result = await _deleteProject(id);
    result.fold(
      (failure) {
        emit(ProjectActionError(failure.message));
        // Re-emit a fresh copy so Equatable doesn't suppress it
        emit(currentState.copyWith());
      },
      (_) async {
        emit(const ProjectActionSuccess('Project deleted successfully.'));
        await fetchProjects(status: currentState.activeStatus, page: 1);
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

  /// get project details by id
  Future<Project?> getProjectDetails(String id) async {
    final result = await _getProjectById(id);
    return result.fold(
      (failure) => null,
      (project) => project,
    );
  }
}
