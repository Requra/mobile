import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/profile/domain/entities/profile_entity.dart';
import 'package:requra/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call() async {
    return await repository.getProfile();
  }
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(String name) async {
    return await repository.updateProfile(name);
  }
}

class UploadAvatarUseCase {
  final ProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<Either<Failure, String>> call(File file) async {
    return await repository.uploadAvatar(file);
  }
}

class DeleteAccountUseCase {
  final ProfileRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.deleteAccount();
  }
}

class ChangePasswordUseCase {
  final ProfileRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, bool>> call(String currentPassword, String newPassword) async {
    return await repository.changePassword(currentPassword, newPassword);
  }
}

class LogoutUseCase {
  final ProfileRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.logout();
  }
}
