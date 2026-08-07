import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';

class GetProjectMeetingsUseCase {
  final MeetingRepository repository;

  GetProjectMeetingsUseCase(this.repository);

  Future<Either<Failure, List<Meeting>>> call(String projectId) {
    return repository.getProjectMeetings(projectId);
  }
}
