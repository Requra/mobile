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
  final DateTime? createdAt;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.clientName,
    required this.totalRequirements,
    required this.totalUserStories,
    required this.totalComments,
    this.createdAt,
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
        createdAt,
      ];
}
