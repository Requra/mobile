import 'package:requra/features/result_view/domain/entities/project_member.dart';

class ProjectMemberModel extends ProjectMember {
  const ProjectMemberModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.projectRole,
    super.avatarUrl,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      projectRole: json['projectRole'] ?? 'Member',
      avatarUrl: json['avatarUrl'],
    );
  }
}
