import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:requra/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final bool isEditing;
  final bool isUpdatingProfile;
  final bool isUploadingAvatar;
  final File? avatarFile;

  const ProfileLoaded({
    required this.profile,
    this.isEditing = false,
    this.isUpdatingProfile = false,
    this.isUploadingAvatar = false,
    this.avatarFile,
  });

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    bool? isEditing,
    bool? isUpdatingProfile,
    bool? isUploadingAvatar,
    File? avatarFile,
    bool clearAvatarFile = false,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isEditing: isEditing ?? this.isEditing,
      isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      avatarFile: clearAvatarFile ? null : (avatarFile ?? this.avatarFile),
    );
  }

  @override
  List<Object?> get props => [
        profile,
        isEditing,
        isUpdatingProfile,
        isUploadingAvatar,
        avatarFile,
      ];
}

class ProfileActionSuccess extends ProfileState {
  final String message;

  const ProfileActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileDeleted extends ProfileState {
  const ProfileDeleted();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
