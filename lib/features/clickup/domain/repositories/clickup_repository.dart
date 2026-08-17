import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/clickup/domain/entities/clickup_push_result.dart';
import 'package:requra/features/clickup/domain/entities/clickup_status.dart';

abstract class ClickUpRepository {
  Future<Either<Failure, String>> getAuthorizeUrl(String projectId);
  Future<Either<Failure, void>> completeCallback(String code, String projectId);
  Future<Either<Failure, ClickUpStatus>> getStatus(String projectId);
  Future<Either<Failure, void>> disconnect(String projectId);
  Future<Either<Failure, ClickUpPushResult>> pushApproved(String projectId);
}
