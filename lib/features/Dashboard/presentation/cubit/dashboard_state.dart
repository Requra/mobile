import 'package:equatable/equatable.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalProjects;
  final int inProgressCount;
  final int draftsCount;
  final int completedCount;
  final List<Project> focusProjects;
  final List<Project> recentProjects;
  final String userName;

  const DashboardLoaded({
    required this.totalProjects,
    required this.inProgressCount,
    required this.draftsCount,
    required this.completedCount,
    required this.focusProjects,
    required this.recentProjects,
    required this.userName,
  });

  @override
  List<Object?> get props => [
        totalProjects,
        inProgressCount,
        draftsCount,
        completedCount,
        focusProjects,
        recentProjects,
        userName,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
