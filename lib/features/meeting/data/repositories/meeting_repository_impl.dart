import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/data/datasource/meeting_remote_data_source.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  final MeetingRemoteDataSource remoteDataSource;

  MeetingRepositoryImpl({required this.remoteDataSource});

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
  Future<Either<Failure, Meeting>> createMeeting(
      String projectId, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createMeeting(projectId, data);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }
}
