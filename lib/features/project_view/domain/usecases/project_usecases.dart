import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/project_view/data/models/paginated_projects.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/project_view/domain/repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  Future<Either<Failure, PaginatedProjects>> call({String? status, int pageNumber = 1, int pageSize = 10}) {
    return repository.getProjects(status: status, pageNumber: pageNumber, pageSize: pageSize);
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

class GetProjectByIdUseCase {
  final ProjectRepository repository;

  GetProjectByIdUseCase(this.repository);

  Future<Either<Failure, Project>> call(String id) {
    return repository.getProjectById(id);
  }
}
