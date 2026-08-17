import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/clickup/data/datasource/clickup_remote_data_source.dart';
import 'package:requra/features/clickup/domain/entities/clickup_push_result.dart';
import 'package:requra/features/clickup/domain/entities/clickup_status.dart';
import 'package:requra/features/clickup/domain/repositories/clickup_repository.dart';

class ClickUpRepositoryImpl implements ClickUpRepository {
  final ClickUpRemoteDataSource remoteDataSource;

  ClickUpRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> getAuthorizeUrl(String projectId) async {
    try {
      final url = await remoteDataSource.getAuthorizeUrl(projectId);
      return Right(url);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> completeCallback(
      String code, String projectId) async {
    try {
      await remoteDataSource.completeCallback(code, projectId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ClickUpStatus>> getStatus(String projectId) async {
    try {
      final status = await remoteDataSource.getStatus(projectId);
      return Right(status);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> disconnect(String projectId) async {
    try {
      await remoteDataSource.disconnect(projectId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ClickUpPushResult>> pushApproved(
      String projectId) async {
    try {
      final result = await remoteDataSource.pushApproved(projectId);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) {
        return const ServerFailure('TOKEN_EXPIRED');
      }
      return ServerFailure(e.message ?? 'Server error occurred');
    }
    return ServerFailure(e.toString());
  }
}
