import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/add_project/domain/repositories/add_project_repository.dart';
import 'package:requra/features/project/data/models/ai_run_status.dart';

class GetAiRunProgressUseCase {
  final AddProjectRepository repository;

  GetAiRunProgressUseCase(this.repository);

  Future<Either<Failure, AiRunStatus>> call(
      String projectId, String runId) async {
    return await repository.getAiRunProgress(projectId, runId);
  }
}
