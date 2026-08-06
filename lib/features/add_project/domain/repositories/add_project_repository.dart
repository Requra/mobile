import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/project_creation_result.dart';

abstract class AddProjectRepository {
  Future<Either<Failure, ProjectCreationResult>> createProject(
      ProjectDetails details, List<SourceItem> sources);
}
