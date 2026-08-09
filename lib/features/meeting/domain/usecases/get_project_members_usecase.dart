import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/data/models/meeting_models.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';

class GetProjectMembersUseCase {
  final MeetingRepository repository;

  GetProjectMembersUseCase(this.repository);

  Future<Either<Failure, List<ProjectMember>>> call(String projectId) {
    return repository.getProjectMembers(projectId);
  }
}
