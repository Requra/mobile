import 'package:requra/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.name,
    required super.email,
    required super.jobTitle,
    required super.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: (json['name'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      jobTitle: (json['jobTitle'] ?? '').toString().trim(),
      avatarUrl: (json['avatarUrl'] ?? '').toString().trim(),
    );
  }
}
