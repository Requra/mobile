import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/clickup/domain/entities/clickup_push_result.dart';
import 'package:requra/features/clickup/domain/entities/clickup_status.dart';
import 'package:requra/features/clickup/domain/repositories/clickup_repository.dart';

class GetClickUpAuthUrlUseCase {
  final ClickUpRepository repository;
  GetClickUpAuthUrlUseCase(this.repository);

  Future<Either<Failure, String>> call(String projectId) {
    return repository.getAuthorizeUrl(projectId);
  }
}

class CompleteClickUpCallbackUseCase {
  final ClickUpRepository repository;
  CompleteClickUpCallbackUseCase(this.repository);

  Future<Either<Failure, void>> call(String code, String projectId) {
    return repository.completeCallback(code, projectId);
  }
}

class GetClickUpStatusUseCase {
  final ClickUpRepository repository;
  GetClickUpStatusUseCase(this.repository);

  Future<Either<Failure, ClickUpStatus>> call(String projectId) {
    return repository.getStatus(projectId);
  }
}

class DisconnectClickUpUseCase {
  final ClickUpRepository repository;
  DisconnectClickUpUseCase(this.repository);

  Future<Either<Failure, void>> call(String projectId) {
    return repository.disconnect(projectId);
  }
}

class PushApprovedToClickUpUseCase {
  final ClickUpRepository repository;
  PushApprovedToClickUpUseCase(this.repository);

  Future<Either<Failure, ClickUpPushResult>> call(String projectId) {
    return repository.pushApproved(projectId);
  }
}
