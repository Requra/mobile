class ProjectCreationResult {
  final int actorsCount;
  final String actorsSummary;
  final int requirementsCount;
  final String requirementsSummary;
  final int userStoriesCount;
  final String userStoriesSummary;
  final String projectId;
  final String? projectName;
  final String? projectType;
  final String? description;
  final String? status;
  final String? clientEmail;
  final String? createdAt;

  const ProjectCreationResult({
    required this.actorsCount,
    required this.actorsSummary,
    required this.requirementsCount,
    required this.requirementsSummary,
    required this.userStoriesCount,
    required this.userStoriesSummary,
    required this.projectId,
    this.projectName,
    this.projectType,
    this.description,
    this.status,
    this.clientEmail,
    this.createdAt,
  });

  factory ProjectCreationResult.fromJson(Map<String, dynamic> json) {
    return ProjectCreationResult(
      actorsCount: json['actorsCount'] ?? 0,
      actorsSummary: json['actorsSummary'] ?? '',
      requirementsCount: json['requirementsCount'] ?? 0,
      requirementsSummary: json['requirementsSummary'] ?? '',
      userStoriesCount: json['userStoriesCount'] ?? 0,
      userStoriesSummary: json['userStoriesSummary'] ?? '',
      projectId: json['id'] ?? json['projectId'] ?? '',
      projectName: json['name'],
      projectType: json['projectType'],
      description: json['description'],
      status: json['status'],
      clientEmail: json['clientEmail'],
      createdAt: json['createdAt'],
    );
  }
}
