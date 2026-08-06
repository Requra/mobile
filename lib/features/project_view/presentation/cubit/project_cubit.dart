import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/project_view/domain/usecases/project_usecases.dart';
import 'package:requra/features/project_view/presentation/cubit/project_state.dart';

/// Cached data for a single tab
class _TabCache {
  final List<Project> projects;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  const _TabCache({
    required this.projects,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });
}

class ProjectCubit extends Cubit<ProjectState> {
  final GetProjectsUseCase _getProjects;
  final DeleteProjectUseCase _deleteProject;
  final EditProjectUseCase _editProject;

  final GetProjectByIdUseCase _getProjectById;

  /// Cache keyed by status (null = "All Projects")
  final Map<String?, _TabCache> _cache = {};

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

  /// fetch projects from API (always hits network)
  Future<void> fetchProjects({String? status, int page = 1}) async {
    emit(ProjectLoading());

    final result = await _getProjects(status: status, pageNumber: page);
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (paginated) {
        // Update cache for this tab
        _cache[status] = _TabCache(
          projects: paginated.items,
          currentPage: paginated.currentPage,
          totalPages: paginated.totalPages,
          totalCount: paginated.totalCount,
        );
        emit(ProjectLoaded(
          allProjects: paginated.items,
          currentPage: paginated.currentPage,
          totalPages: paginated.totalPages,
          totalCount: paginated.totalCount,
          activeStatus: status,
        ));
      },
    );
  }

  /// Switch tab — uses cache if available, otherwise fetches from API
  Future<void> changeTab(String? status) async {
    final cached = _cache[status];
    if (cached != null) {
      // Show cached data instantly — no loading, no API call
      emit(ProjectLoaded(
        allProjects: cached.projects,
        currentPage: cached.currentPage,
        totalPages: cached.totalPages,
        totalCount: cached.totalCount,
        activeStatus: status,
      ));
    } else {
      await fetchProjects(status: status, page: 1);
    }
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
        
        // Update cache with the combined list
        _cache[currentState.activeStatus] = _TabCache(
          projects: updatedProjects,
          currentPage: paginated.currentPage,
          totalPages: paginated.totalPages,
          totalCount: paginated.totalCount,
        );
        
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

  /// Invalidate all cached tabs (after delete/edit)
  void _invalidateCache() {
    _cache.clear();
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
        _invalidateCache();
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
        _invalidateCache();
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
