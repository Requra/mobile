import 'package:requra/features/result_view/domain/entities/project_details.dart';

class ProjectDetailsModel extends ProjectDetails {
  const ProjectDetailsModel({
    required super.id,
    required super.name,
    required super.description,
    required super.projectType,
    required super.status,
    required super.clientName,
    required super.teamMembers,
    super.createdAt,
  });

  factory ProjectDetailsModel.fromJson(Map<String, dynamic> json) {
    // Parse team members from list of objects with 'email' key
    final List<String> members = [];
    if (json['teamMembers'] is List) {
      for (final member in json['teamMembers']) {
        if (member is Map<String, dynamic> && member['email'] != null) {
          members.add(member['email']);
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
      teamMembers: members,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
