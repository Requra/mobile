import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, ProfileEntity>> updateProfile(String name);
  Future<Either<Failure, String>> uploadAvatar(File file);
  Future<Either<Failure, bool>> deleteAccount();
  Future<Either<Failure, bool>> changePassword(String currentPassword, String newPassword);
  Future<Either<Failure, bool>> logout();
}
