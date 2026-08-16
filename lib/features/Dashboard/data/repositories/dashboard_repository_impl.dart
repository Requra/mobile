import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/Dashboard/data/datasource/dashboard_remote_data_source.dart';
import 'package:requra/features/Dashboard/domain/repositories/dashboard_repository.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    try {
      final result = await remoteDataSource.getAllProjects();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }
}
