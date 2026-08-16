import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final String status;
  final String clientName;
  final int totalRequirements;
  final int totalUserStories;
  final int totalComments;
  final String? projectType;
  final String? clientEmail;
  final String? language;
  final List<String>? teamMembers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.clientName,
    required this.totalRequirements,
    required this.totalUserStories,
    required this.totalComments,
    this.projectType,
    this.clientEmail,
    this.language,
    this.teamMembers,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    status,
    clientName,
    totalRequirements,
    totalUserStories,
    totalComments,
    projectType,
    clientEmail,
    language,
    teamMembers,
    createdAt,
    updatedAt,
  ];
}
