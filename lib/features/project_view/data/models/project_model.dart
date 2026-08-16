import 'package:requra/features/project_view/domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.status,
    required super.clientName,
    required super.totalRequirements,
    required super.totalUserStories,
    required super.totalComments,
    super.projectType,
    super.clientEmail,
    super.language,
    super.teamMembers,
    super.createdAt,
    super.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTeamMembers = [];
    if (json['teamMembers'] != null && json['teamMembers'] is List) {
      parsedTeamMembers = (json['teamMembers'] as List)
          .map((m) => m['email']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return ProjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      clientName: json['clientEmail'] ?? json['clientName'] ?? '',
      // sometimes mock APIs return negative values due to randomization, so we use abs()
      totalRequirements: (json['totalRequirements'] ?? 0).abs(),
      totalUserStories: (json['totalUserStories'] ?? 0).abs(),
      totalComments: (json['totalComments'] ?? 0).abs(),
      projectType: json['projectType'],
      clientEmail: json['clientEmail'],
      language: json['language'],
      teamMembers: parsedTeamMembers,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}
