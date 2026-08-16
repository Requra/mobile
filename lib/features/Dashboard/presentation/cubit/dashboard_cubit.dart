import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/core/storage/secure_token_storage.dart';
import 'package:requra/features/Dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:requra/features/Dashboard/presentation/cubit/dashboard_state.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/project_view/presentation/helpers/project_helpers.dart';
import 'package:requra/features/profile/domain/usecases/profile_usecases.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardDataUseCase _getDashboardData;
  final GetProfileUseCase _getProfileUseCase;

  DashboardCubit({
    required GetDashboardDataUseCase getDashboardDataUseCase,
    required GetProfileUseCase getProfileUseCase,
  })  : _getDashboardData = getDashboardDataUseCase,
        _getProfileUseCase = getProfileUseCase,
        super(DashboardInitial());

  Future<void> loadDashboard() async {
    emit(DashboardLoading());

    try {
      final tokenStorage = const SecureTokenStorage();
      var userName = '';
      
      // Try to get name from Profile API first
      final profileResult = await _getProfileUseCase();
      profileResult.fold(
        (failure) {}, 
        (profile) => userName = profile.name
      );

      // Fallback to JWT display name if API fails or name is empty
      if (userName.isEmpty) {
        userName = await tokenStorage.readDisplayName() ?? '';
      }

      final result = await _getDashboardData();

      result.fold(
        (failure) => emit(DashboardError(failure.message)),
        (projects) {
          int totalProjects = projects.length;
          int inProgressCount = 0;
          int draftsCount = 0;
          int completedCount = 0;

          final inProgressProjects = <Project>[];

          for (final project in projects) {
            final statusLabelText = projectStatusBadge(project.status);
            
            if (statusLabelText == 'IN PROGRESS') {
              inProgressCount++;
              inProgressProjects.add(project);
            } else if (statusLabelText == 'DRAFTED') {
              draftsCount++;
            } else if (statusLabelText == 'FINISHED') {
              completedCount++;
            }
          }

          // Sort in-progress projects by updatedAt descending
          inProgressProjects.sort((a, b) {
            final dateA = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dateB = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dateB.compareTo(dateA);
          });
          
          final focusProjects = inProgressProjects.take(3).toList();

          // Sort all projects by createdAt descending for portfolio
          final allProjectsSorted = List<Project>.from(projects);
          allProjectsSorted.sort((a, b) {
            final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dateB.compareTo(dateA);
          });

          final recentProjects = allProjectsSorted.take(5).toList();

          emit(DashboardLoaded(
            totalProjects: totalProjects,
            inProgressCount: inProgressCount,
            draftsCount: draftsCount,
            completedCount: completedCount,
            focusProjects: focusProjects,
            recentProjects: recentProjects,
            userName: userName ?? '',
          ));
        },
      );
    } catch (e) {
      emit(DashboardError('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
