import 'package:equatable/equatable.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';

sealed class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Project> allProjects;
  final String searchQuery;
  final String sortBy;
  final bool isSubmitting;
  
  // Pagination and filtering fields
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String? activeStatus;
  final bool isLoadingMore;

  const ProjectLoaded({
    required this.allProjects,
    this.searchQuery = '',
    this.sortBy = 'Name',
    this.isSubmitting = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.activeStatus,
    this.isLoadingMore = false,
  });

  ProjectLoaded copyWith({
    List<Project>? allProjects,
    String? searchQuery,
    String? sortBy,
    bool? isSubmitting,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    String? activeStatus,
    bool? isLoadingMore,
    bool clearStatus = false,
  }) {
    return ProjectLoaded(
      allProjects: allProjects ?? this.allProjects,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      activeStatus: clearStatus ? null : (activeStatus ?? this.activeStatus),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  List<Project> get filteredProjects {
    var list = allProjects.where((p) {
      final q = searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.clientName.toLowerCase().contains(q);
    }).toList();

    switch (sortBy) {
      case 'Features':
        list.sort((a, b) => b.totalRequirements.compareTo(a.totalRequirements));
      case 'Comments':
        list.sort((a, b) => b.totalComments.compareTo(a.totalComments));
      default:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  @override
  List<Object?> get props => [
        allProjects,
        searchQuery,
        sortBy,
        isSubmitting,
        currentPage,
        totalPages,
        totalCount,
        activeStatus,
        isLoadingMore,
      ];
}

class ProjectError extends ProjectState {
  final String message;
  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectActionSuccess extends ProjectState {
  final String message;
  const ProjectActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectActionError extends ProjectState {
  final String message;
  const ProjectActionError(this.message);

  @override
  List<Object?> get props => [message];
}
