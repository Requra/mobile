import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';

class InviteGuestsUseCase {
  final MeetingRepository repository;

  InviteGuestsUseCase(this.repository);

  Future<Either<Failure, void>> call(String meetingId, List<Map<String, String>> guests, {String platform = 'Mobile'}) {
    return repository.inviteGuests(meetingId, guests, platform: platform);
  }
}
