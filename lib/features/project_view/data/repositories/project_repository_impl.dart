import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/project_view/data/datasource/project_remote_data_source.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/project_view/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    try {
      final result = await remoteDataSource.getProjects();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProject(String id) async {
    try {
      final result = await remoteDataSource.deleteProject(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Project>> editProject(String id, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.editProject(id, data);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }
}
