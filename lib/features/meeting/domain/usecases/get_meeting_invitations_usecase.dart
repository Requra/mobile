import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/data/models/meeting_models.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';

class GetMeetingInvitationsUseCase {
  final MeetingRepository repository;

  GetMeetingInvitationsUseCase(this.repository);

  Future<Either<Failure, List<MeetingInvitation>>> call(String meetingId) {
    return repository.getMeetingInvitations(meetingId);
  }
}
