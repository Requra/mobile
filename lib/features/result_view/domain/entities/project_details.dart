import 'package:equatable/equatable.dart';
import 'package:requra/features/result_view/domain/entities/project_member.dart';

class ProjectDetails extends Equatable {
  final String id;
  final String name;
  final String description;
  final String projectType;
  final String status;
  final String clientName;
  final String clientEmail;
  final List<ProjectMember> teamMembers;
  final DateTime? createdAt;

  const ProjectDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.projectType,
    required this.status,
    required this.clientName,
    required this.clientEmail,
    required this.teamMembers,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        projectType,
        status,
        clientName,
        clientEmail,
        teamMembers,
        createdAt,
      ];
}
