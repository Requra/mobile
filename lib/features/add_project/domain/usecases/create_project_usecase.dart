import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/add_project/domain/repositories/add_project_repository.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/project_creation_result.dart';

class CreateProjectUseCase {
  final AddProjectRepository repository;

  CreateProjectUseCase(this.repository);

  Future<Either<Failure, ProjectCreationResult>> call(
      ProjectDetails details, List<SourceItem> sources) {
    return repository.createProject(details, sources);
  }
}
