import 'package:equatable/equatable.dart';

class ProjectDetails extends Equatable {
  final String id;
  final String name;
  final String description;
  final String projectType;
  final String status;
  final String clientName;
  final List<String> teamMembers;
  final DateTime? createdAt;

  const ProjectDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.projectType,
    required this.status,
    required this.clientName,
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
        teamMembers,
        createdAt,
      ];
}
