import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';

class InviteParticipantsUseCase {
  final MeetingRepository repository;

  InviteParticipantsUseCase(this.repository);

  Future<Either<Failure, void>> call(String meetingId, List<Map<String, String>> members) {
    return repository.inviteParticipants(meetingId, members);
  }
}
