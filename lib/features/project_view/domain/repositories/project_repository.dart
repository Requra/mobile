import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/project_view/data/models/paginated_projects.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, PaginatedProjects>> getProjects({String? status, int pageNumber = 1, int pageSize = 10});
  Future<Either<Failure, bool>> deleteProject(String id);
  Future<Either<Failure, Project>> editProject(String id, Map<String, dynamic> data);
  Future<Either<Failure, Project>> getProjectById(String id);
}
