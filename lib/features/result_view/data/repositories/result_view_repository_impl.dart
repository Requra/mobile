import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/result_view/data/datasource/result_view_remote_data_source.dart';
import 'package:requra/features/result_view/domain/entities/meeting.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/domain/repositories/result_view_repository.dart';

class ResultViewRepositoryImpl implements ResultViewRepository {
  final ResultViewRemoteDataSource remoteDataSource;

  ResultViewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProjectDetails>> getProjectDetails(String id) async {
    try {
      final result = await remoteDataSource.getProjectDetails(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, List<Meeting>>> getProjectMeetings(
      String projectId) async {
    try {
      final result = await remoteDataSource.getProjectMeetings(projectId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getProjectDocuments(
      String projectId) async {
    try {
      final result = await remoteDataSource.getProjectDocuments(projectId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Document>> uploadDocument({
    required File file,
    required String projectId,
    required String title,
    required int type,
    required int language,
    String? meetingId,
  }) async {
    try {
      final result = await remoteDataSource.uploadDocument(
        file: file,
        projectId: projectId,
        title: title,
        type: type,
        language: language,
        meetingId: meetingId,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }
}
