import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/data/datasource/meeting_remote_data_source.dart';
import 'package:requra/features/meeting/data/models/meeting_models.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  final MeetingRemoteDataSource remoteDataSource;

  MeetingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Meeting>> getMeetingDetails(String meetingId) async {
    try {
      final result = await remoteDataSource.getMeetingDetails(meetingId);
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

  @override
  Future<Either<Failure, Meeting>> updateMeeting(
      String meetingId, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.updateMeeting(meetingId, data);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Meeting>> cancelMeeting(String meetingId) async {
    try {
      final result = await remoteDataSource.cancelMeeting(meetingId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Meeting>> startMeeting(String meetingId) async {
    try {
      final result = await remoteDataSource.startMeeting(meetingId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }
  @override
  Future<Either<Failure, Meeting>> endMeeting(String meetingId) async {
    try {
      final result = await remoteDataSource.endMeeting(meetingId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  // ── Invite API ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ProjectMember>>> getProjectMembers(String projectId) async {
    try {
      final data = await remoteDataSource.getProjectMembers(projectId);
      final members = data.map((json) => ProjectMember.fromJson(json as Map<String, dynamic>)).toList();
      return Right(members);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MeetingInvitation>>> getMeetingInvitations(String meetingId) async {
    try {
      final data = await remoteDataSource.getMeetingInvitations(meetingId);
      final invitations = data.map((json) => MeetingInvitation.fromJson(json as Map<String, dynamic>)).toList();
      return Right(invitations);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> inviteParticipants(String meetingId, List<Map<String, String>> members, {String platform = 'Mobile'}) async {
    try {
      await remoteDataSource.inviteParticipants(meetingId, members, platform: platform);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> inviteGuests(String meetingId, List<Map<String, String>> guests, {String platform = 'Mobile'}) async {
    try {
      await remoteDataSource.inviteGuests(meetingId, guests, platform: platform);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendInvitation(String meetingId, String invitationId, {String platform = 'Mobile'}) async {
    try {
      await remoteDataSource.resendInvitation(meetingId, invitationId, platform: platform);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
