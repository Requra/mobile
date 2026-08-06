import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/data/models/project_member_model.dart';

class ProjectDetailsModel extends ProjectDetails {
  const ProjectDetailsModel({
    required super.id,
    required super.name,
    required super.description,
    required super.projectType,
    required super.status,
    required super.clientName,
    required super.clientEmail,
    required super.teamMembers,
    super.createdAt,
  });

  factory ProjectDetailsModel.fromJson(Map<String, dynamic> json) {
    final String clientEmail = json['clientEmail'] ?? '';

    // Parse team members from list of objects
    final List<ProjectMemberModel> members = [];
    if (json['teamMembers'] is List) {
      for (final member in json['teamMembers']) {
        if (member is Map<String, dynamic>) {
          members.add(ProjectMemberModel.fromJson(member));
        }
      }
    }

    return ProjectDetailsModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      projectType: json['projectType'] ?? '',
      status: json['status'] ?? '',
      clientName: json['clientName'] ?? '',
      clientEmail: clientEmail,
      teamMembers: members,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
