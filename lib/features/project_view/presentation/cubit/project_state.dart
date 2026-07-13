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

  const ProjectLoaded({
    required this.allProjects,
    this.searchQuery = '',
    this.sortBy = 'Name',
    this.isSubmitting = false,
  });

  ProjectLoaded copyWith({
    List<Project>? allProjects,
    String? searchQuery,
    String? sortBy,
    bool? isSubmitting,
  }) {
    return ProjectLoaded(
      allProjects: allProjects ?? this.allProjects,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      isSubmitting: isSubmitting ?? this.isSubmitting,
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

  List<Project> get processingProjects => filteredProjects.where((p) {
        final s = p.status.toLowerCase();
        return s.contains('process') ||
            s.contains('progress');
  }).toList();

  List<Project> get completedProjects => filteredProjects.where((p) {
        final s = p.status.toLowerCase();
        return s.contains('complet') || s.contains('finish');
  }).toList();

  List<Project> get draftProjects => filteredProjects.where((p) {
        return !processingProjects.contains(p) && !completedProjects.contains(p);
      }).toList();

  @override
  List<Object?> get props => [allProjects, searchQuery, sortBy, isSubmitting];
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
