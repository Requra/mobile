import 'package:requra/features/project_view/data/models/project_model.dart';

class PaginatedProjects {
  final List<ProjectModel> items;
  final int totalCount;
  final int totalPages;
  final int currentPage;

  const PaginatedProjects({
    required this.items,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginatedProjects.fromJson(Map<String, dynamic> json) {
    var itemsList = <ProjectModel>[];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => ProjectModel.fromJson(item))
          .toList();
    }
    
    int totalCount = json['totalCount'] ?? 0;
    int parsedTotalPages = json['totalPages'] ?? 0;
    int totalPages = parsedTotalPages > 0 ? parsedTotalPages : (totalCount > 0 ? (totalCount / 10).ceil() : 0);
    
    return PaginatedProjects(
      items: itemsList,
      totalCount: totalCount,
      totalPages: totalPages,
      currentPage: json['pageNumber'] ?? json['currentPage'] ?? 1,
    );
  }
}

