import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/ai_run_status.dart';
import 'package:requra/features/project/data/models/project_creation_result.dart';

abstract class AddProjectRepository {
  Future<Either<Failure, ProjectCreationResult>> createProject(
    ProjectDetails details,
  );

  Future<Either<Failure, String>> uploadAndGenerate(
    String projectId,
    List<SourceItem> sources,
  );

  Future<Either<Failure, AiRunStatus>> getAiRunProgress(
    String projectId,
    String runId,
  );
}
