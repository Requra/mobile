import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/profile/domain/entities/profile_entity.dart';
import 'package:requra/features/profile/domain/usecases/profile_usecases.dart';
import 'package:requra/features/profile/presentation/cubit/profile_state.dart';

export 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final LogoutUseCase _logoutUseCase;

  ProfileCubit({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UploadAvatarUseCase uploadAvatarUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _uploadAvatarUseCase = uploadAvatarUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _logoutUseCase = logoutUseCase,
        super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await _getProfileUseCase();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  void startEditing() {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(isEditing: true));
    }
  }

  void cancelEditing() {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(isEditing: false));
    }
  }

  Future<void> updateProfile(String name) async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    emit(currentState.copyWith(isUpdatingProfile: true));

    final result = await _updateProfileUseCase(name);

    result.fold(
      (failure) {
        // We emit a transient error, then revert back to Loaded
        emit(ProfileError(failure.message));
        emit(currentState.copyWith(isUpdatingProfile: false));
      },
      (updatedProfile) {
        emit(ProfileActionSuccess('Profile updated successfully'));
        emit(currentState.copyWith(
          profile: updatedProfile,
          isUpdatingProfile: false,
          isEditing: false,
        ));
      },
    );
  }

  Future<void> uploadAvatar(File file) async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    emit(currentState.copyWith(isUploadingAvatar: true, avatarFile: file));

    final result = await _uploadAvatarUseCase(file);

    result.fold(
      (failure) {
        emit(ProfileError(failure.message));
        emit(currentState.copyWith(
          isUploadingAvatar: false,
          clearAvatarFile: true, // Revert to old avatar
        ));
      },
      (newAvatarUrl) {
        final updatedProfile = ProfileEntity(
          name: currentState.profile.name,
          email: currentState.profile.email,
          jobTitle: currentState.profile.jobTitle,
          avatarUrl: newAvatarUrl,
        );
        
        emit(const ProfileActionSuccess('Avatar updated successfully'));
        emit(currentState.copyWith(
          profile: updatedProfile,
          isUploadingAvatar: false,
          clearAvatarFile: true,
        ));
      },
    );
  }

  Future<void> deleteAccount() async {
    emit(const ProfileLoading());
    final result = await _deleteAccountUseCase();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileDeleted()),
    );
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final previousState = state;
    emit(const ProfileLoading());
    final result = await _changePasswordUseCase(currentPassword, newPassword);

    result.fold(
      (failure) {
        emit(ProfileError(failure.message));
        if (previousState is ProfileLoaded) {
          emit(previousState);
        }
      },
      (_) {
        emit(const ProfileActionSuccess('Password changed successfully'));
        if (previousState is ProfileLoaded) {
          emit(previousState);
        }
      },
    );
  }

  Future<void> logout() async {
    emit(const ProfileLoading());
    final result = await _logoutUseCase();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileLoggedOut()),
    );
  }
}
