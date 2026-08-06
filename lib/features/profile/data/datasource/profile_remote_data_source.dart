import 'dart:io';
import 'package:requra/features/auth/data/models/auth_response.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';

abstract class ProfileRemoteDataSource {
  Future<AuthResponse> getProfile();
  Future<AuthResponse> updateProfile(String name);
  Future<AuthResponse> uploadAvatar(File file);
  Future<AuthResponse> deleteAccount();
  Future<AuthResponse> changePassword(String currentPassword, String newPassword);
  Future<AuthResponse> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final AuthService authService;

  ProfileRemoteDataSourceImpl({required this.authService});

  @override
  Future<AuthResponse> getProfile() {
    return authService.getProfile();
  }

  @override
  Future<AuthResponse> updateProfile(String name) {
    return authService.updateProfile(name: name);
  }

  @override
  Future<AuthResponse> uploadAvatar(File file) {
    return authService.uploadAvatar(file: file);
  }

  @override
  Future<AuthResponse> deleteAccount() {
    return authService.deleteAccount();
  }

  @override
  Future<AuthResponse> changePassword(String currentPassword, String newPassword) {
    return authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<AuthResponse> logout() {
    return authService.logout();
  }
}
