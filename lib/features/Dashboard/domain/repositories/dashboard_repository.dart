import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<Project>>> getAllProjects();
}
