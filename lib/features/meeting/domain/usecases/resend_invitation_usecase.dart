import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';

class ResendInvitationUseCase {
  final MeetingRepository repository;

  ResendInvitationUseCase(this.repository);

  Future<Either<Failure, void>> call(String meetingId, String invitationId) {
    return repository.resendInvitation(meetingId, invitationId);
  }
}
