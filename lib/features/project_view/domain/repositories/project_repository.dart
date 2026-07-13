import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<Project>>> getProjects();
  Future<Either<Failure, bool>> deleteProject(String id);
  Future<Either<Failure, Project>> editProject(String id, Map<String, dynamic> data);
}
