import 'package:equatable/equatable.dart';

class ProjectMember extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String projectRole;
  final String? avatarUrl;

  const ProjectMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.projectRole,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        projectRole,
        avatarUrl,
      ];
}
