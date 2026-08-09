import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';

class EndMeetingUseCase {
  final MeetingRepository repository;

  EndMeetingUseCase(this.repository);

  Future<Either<Failure, Meeting>> call(String meetingId) {
    return repository.endMeeting(meetingId);
  }
}
