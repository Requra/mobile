import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/add_project/data/datasource/add_project_remote_data_source.dart';
import 'package:requra/features/add_project/domain/repositories/add_project_repository.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/project_creation_result.dart';

class AddProjectRepositoryImpl implements AddProjectRepository {
  final AddProjectRemoteDataSource remoteDataSource;

  AddProjectRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProjectCreationResult>> createProject(
      ProjectDetails details, List<SourceItem> sources) async {
    try {
      final result = await remoteDataSource.createProject(details, sources);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }
}
