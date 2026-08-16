import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/Dashboard/domain/repositories/dashboard_repository.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';

class GetDashboardDataUseCase {
  final DashboardRepository repository;

  GetDashboardDataUseCase(this.repository);

  Future<Either<Failure, List<Project>>> call() {
    return repository.getAllProjects();
  }
}
