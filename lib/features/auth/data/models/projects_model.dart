class Project {
  final String id;
  final String name;
  final String description;
  final String status;
  final String clientName;
  final int totalComments;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.clientName,
    required this.totalComments,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      clientName: json['clientName'] ?? '',
      totalComments: json['totalComments'] ?? 0,
    );
  }
}

class ProjectResponse {
  final bool isSuccess;
  final List<Project> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final String message;
  final int statusCode;

  ProjectResponse({
    required this.isSuccess,
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.message,
    required this.statusCode,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return ProjectResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,

      items: (data['items'] as List)
          .map((e) => Project.fromJson(e))
          .toList(),

      totalCount: data['totalCount'] ?? 0,
      pageNumber: data['pageNumber'] ?? 1,
      pageSize: data['pageSize'] ?? 10,
    );
  }
}