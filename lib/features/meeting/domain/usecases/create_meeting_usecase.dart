import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';

class CreateMeetingUseCase {
  final MeetingRepository repository;

  CreateMeetingUseCase(this.repository);

  Future<Either<Failure, Meeting>> call(
      String projectId, Map<String, dynamic> data) {
    return repository.createMeeting(projectId, data);
  }
}
