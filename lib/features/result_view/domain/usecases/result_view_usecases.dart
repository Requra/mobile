import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/result_view/domain/entities/meeting.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/domain/repositories/result_view_repository.dart';

class GetProjectDetailsUseCase {
  final ResultViewRepository repository;

  GetProjectDetailsUseCase(this.repository);

  Future<Either<Failure, ProjectDetails>> call(String id) {
    return repository.getProjectDetails(id);
  }
}

class GetProjectMeetingsUseCase {
  final ResultViewRepository repository;

  GetProjectMeetingsUseCase(this.repository);

  Future<Either<Failure, List<Meeting>>> call(String projectId) {
    return repository.getProjectMeetings(projectId);
  }
}

class GetProjectDocumentsUseCase {
  final ResultViewRepository repository;

  GetProjectDocumentsUseCase(this.repository);

  Future<Either<Failure, List<Document>>> call(String projectId) {
    return repository.getProjectDocuments(projectId);
  }
}

class UploadDocumentUseCase {
  final ResultViewRepository repository;

  UploadDocumentUseCase(this.repository);

  Future<Either<Failure, Document>> call({
    required File file,
    required String projectId,
    required String title,
    required int type,
    required int language,
    String? meetingId,
  }) {
    return repository.uploadDocument(
      file: file,
      projectId: projectId,
      title: title,
      type: type,
      language: language,
      meetingId: meetingId,
    );
  }
}

class GetAiResultsDashboardUseCase {
  final ResultViewRepository repository;

  GetAiResultsDashboardUseCase(this.repository);

  Future<Either<Failure, AiResultsDashboard>> call(String projectId) {
    return repository.getAiResultsDashboard(projectId);
  }
}

class CreateMeetingUseCase {
  final ResultViewRepository repository;

  CreateMeetingUseCase(this.repository);

  Future<Either<Failure, Meeting>> call(
      String projectId, Map<String, dynamic> data) {
    return repository.createMeeting(projectId, data);
  }
}
