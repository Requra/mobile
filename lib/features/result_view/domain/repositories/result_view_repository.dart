import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/result_view/domain/entities/meeting.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';

abstract class ResultViewRepository {
  Future<Either<Failure, ProjectDetails>> getProjectDetails(String id);
  Future<Either<Failure, List<Meeting>>> getProjectMeetings(String projectId);
  Future<Either<Failure, List<Document>>> getProjectDocuments(String projectId);
  Future<Either<Failure, Document>> uploadDocument({
    required File file,
    required String projectId,
    required String title,
    required int type,
    required int language,
    String? meetingId,
  });
}
