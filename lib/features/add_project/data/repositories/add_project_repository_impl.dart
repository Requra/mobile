import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/add_project/data/datasource/add_project_remote_data_source.dart';
import 'package:requra/features/add_project/domain/repositories/add_project_repository.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/ai_run_status.dart';
import 'package:requra/features/project/data/models/project_creation_result.dart';

class AddProjectRepositoryImpl implements AddProjectRepository {
  final AddProjectRemoteDataSource remoteDataSource;

  AddProjectRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProjectCreationResult>> createProject(
    ProjectDetails details,
  ) async {
    try {
      final result = await remoteDataSource.createProject(details);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAndGenerate(
    String projectId,
    List<SourceItem> sources,
  ) async {
    try {
      final List<String> documentIds = [];
      for (final source in sources) {
        final docId = await remoteDataSource.uploadDocument(projectId, source);
        if (docId.isNotEmpty) {
          documentIds.add(docId);
        }
      }

      final runId = await remoteDataSource.startAiRun(projectId, documentIds);
      return Right(runId);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiRunStatus>> getAiRunProgress(
    String projectId,
    String runId,
  ) async {
    try {
      final status = await remoteDataSource.getAiRunProgress(projectId, runId);
      return Right(status);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
