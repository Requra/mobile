import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';

class UpdateMeetingUseCase {
  final MeetingRepository repository;

  UpdateMeetingUseCase(this.repository);

  Future<Either<Failure, Meeting>> call(
      String meetingId, Map<String, dynamic> data) {
    return repository.updateMeeting(meetingId, data);
  }
}
