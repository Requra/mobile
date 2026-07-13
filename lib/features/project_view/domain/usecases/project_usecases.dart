import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/project_view/domain/repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  Future<Either<Failure, List<Project>>> call() {
    return repository.getProjects();
  }
}

class DeleteProjectUseCase {
  final ProjectRepository repository;

  DeleteProjectUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id) {
    return repository.deleteProject(id);
  }
}

class EditProjectUseCase {
  final ProjectRepository repository;

  EditProjectUseCase(this.repository);

  Future<Either<Failure, Project>> call(String id, Map<String, dynamic> data) {
    return repository.editProject(id, data);
  }
}
