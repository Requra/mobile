import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/add_project/domain/repositories/add_project_repository.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';

class UploadAndGenerateUseCase {
  final AddProjectRepository repository;

  UploadAndGenerateUseCase(this.repository);

  Future<Either<Failure, String>> call(
      String projectId, List<SourceItem> sources) async {
    return await repository.uploadAndGenerate(projectId, sources);
  }
}
