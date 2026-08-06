import 'package:requra/features/project_view/data/models/project_model.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';

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
    
    return PaginatedProjects(
      items: itemsList,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['pageNumber'] ?? 1,
    );
  }
}
