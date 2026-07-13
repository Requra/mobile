import 'dart:async';
import 'package:requra/core/api/api_client.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/project_creation_result.dart';

class ProjectCreationService {
  final ApiClient apiClient;

  ProjectCreationService({required this.apiClient});

  Future<ProjectCreationResult> createProject(
      ProjectDetails details, List<SourceItem> sources) async {
    // Here we would typically use apiClient.dio.post(...) to send multipart form data
    // For now, we simulate a network delay and return mock data to match the UI requirements
    
    await Future.delayed(const Duration(seconds: 4));

    // Simulate successful response with mock data
    return const ProjectCreationResult(
      actorsCount: 5,
      actorsSummary: 'Customer, Admin, Delivery Agent...',
      requirementsCount: 24,
      requirementsSummary: 'Functional + Non-functional',
      userStoriesCount: 18,
      userStoriesSummary: 'Ready for development',
      projectId: 'proj-mock-123',
    );
  }
}
