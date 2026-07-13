class ProjectCreationResult {
  final int actorsCount;
  final String actorsSummary;
  final int requirementsCount;
  final String requirementsSummary;
  final int userStoriesCount;
  final String userStoriesSummary;
  final String projectId;

  const ProjectCreationResult({
    required this.actorsCount,
    required this.actorsSummary,
    required this.requirementsCount,
    required this.requirementsSummary,
    required this.userStoriesCount,
    required this.userStoriesSummary,
    required this.projectId,
  });

  factory ProjectCreationResult.fromJson(Map<String, dynamic> json) {
    return ProjectCreationResult(
      actorsCount: json['actorsCount'] ?? 0,
      actorsSummary: json['actorsSummary'] ?? '',
      requirementsCount: json['requirementsCount'] ?? 0,
      requirementsSummary: json['requirementsSummary'] ?? '',
      userStoriesCount: json['userStoriesCount'] ?? 0,
      userStoriesSummary: json['userStoriesSummary'] ?? '',
      projectId: json['projectId'] ?? '',
    );
  }
}
