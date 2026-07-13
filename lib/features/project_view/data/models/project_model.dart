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
    super.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      clientName: json['clientName'] ?? json['clientEmail'] ?? '',
      // sometimes mock APIs return negative values due to randomization, so we use abs()
      totalRequirements: (json['totalRequirements'] ?? 0).abs(),
      totalUserStories: (json['totalUserStories'] ?? 0).abs(),
      totalComments: (json['totalComments'] ?? 0).abs(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
