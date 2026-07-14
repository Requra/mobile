import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:requra/features/profile/data/models/profile_model.dart';
import 'package:requra/features/profile/domain/entities/profile_entity.dart';
import 'package:requra/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final response = await remoteDataSource.getProfile();
      if (response.isSuccess && response.data is Map<String, dynamic>) {
        return Right(
          ProfileModel.fromJson(response.data as Map<String, dynamic>),
        );
      } else {
        return Left(ServerFailure(response.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(String name) async {
    try {
      final response = await remoteDataSource.updateProfile(name);
      if (response.isSuccess && response.data is Map<String, dynamic>) {
        return Right(
          ProfileModel.fromJson(response.data as Map<String, dynamic>),
        );
      } else {
        return Left(ServerFailure(response.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(File file) async {
    try {
      final response = await remoteDataSource.uploadAvatar(file);
      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final newUrl = (response.data['avatarUrl'] ?? '').toString().trim();
        return Right(newUrl);
      } else {
        return Left(ServerFailure(response.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAccount() async {
    try {
      final response = await remoteDataSource.deleteAccount();
      if (response.isSuccess) {
        return const Right(true);
      } else {
        return Left(ServerFailure(response.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await remoteDataSource.changePassword(
        currentPassword,
        newPassword,
      );
      if (response.isSuccess) {
        return const Right(true);
      } else {
        return Left(ServerFailure(response.message));
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return Left(ServerFailure(msg));
    }
  }
}
