import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';

abstract class MeetingRepository {
  Future<Either<Failure, List<Meeting>>> getProjectMeetings(String projectId);
  Future<Either<Failure, Meeting>> createMeeting(String projectId, Map<String, dynamic> data);
}
