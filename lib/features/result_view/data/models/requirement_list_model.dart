import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';

/// Model for parsing requirements from the dedicated
/// GET /api/requirements/projects/{projectId}/requirements endpoint.
///
/// The response uses camelCase keys and has a different shape 
/// from the AI results dashboard requirements.
class RequirementFromListModel extends AiRequirement {
  const RequirementFromListModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    super.category,
    required super.priority,
    super.actor,
    required super.confidenceScore,
    super.quality,
    required super.sourceDocumentIds,
    required super.sourceRefs,
    super.workflowStatus,
    super.version,
    super.qualityStatus,
  });

  factory RequirementFromListModel.fromJson(Map<String, dynamic> json) {
    // Map "status" field (e.g. "Generated") to workflowStatus format
    String? workflowStatus;
    final rawStatus = json['status']?.toString();
    if (rawStatus != null) {
      // Convert "Generated" → "GENERATED", etc.
      switch (rawStatus) {
        case 'NeedReview':
          workflowStatus = 'NEEDS_REVIEW';
          break;
        case 'Approved':
          workflowStatus = 'APPROVED';
          break;
        case 'Rejected':
          workflowStatus = 'REJECTED';
          break;
        case 'Edited':
          workflowStatus = 'EDITED';
          break;
        default:
          workflowStatus = rawStatus.toUpperCase();
      }
    }

    // Map quality score
    QualityInfo? quality;
    if (json['qualityScore'] != null) {
      quality = QualityInfo(
        score: (json['qualityScore'] as num).toDouble(),
        issues: (json['qualityIssues'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        warnings: (json['qualityWarnings'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
    }

    // Extract source document IDs
    List<String> sourceDocumentIds = [];
    List<SourceRef> sourceRefs = [];
    
    if (json['sourceRefs'] != null) {
      for (var ref in json['sourceRefs']) {
        if (ref['documentName'] != null) {
          sourceDocumentIds.add(ref['documentName'].toString());
        } else if (ref['sourceId'] != null) {
          sourceDocumentIds.add(ref['sourceId'].toString());
        }
        
        sourceRefs.add(SourceRef(
          quote: ref['quote']?.toString(),
          documentTitle: ref['documentName']?.toString(),
          sourceId: ref['sourceId']?.toString(),
          chunkId: ref['chunkId']?.toString(),
          sourceType: ref['sourceType']?.toString(),
          confidenceScore: (ref['confidenceScore'] as num?)?.toDouble(),
        ));
      }
    }

    return RequirementFromListModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Functional',
      category: json['category']?.toString(),
      priority: json['priority']?.toString() ?? 'Medium',
      actor: json['actor']?.toString(),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      quality: quality,
      sourceDocumentIds: sourceDocumentIds,
      sourceRefs: sourceRefs,
      workflowStatus: workflowStatus,
      version: json['version'] as int?,
      qualityStatus: json['qualityStatus']?.toString(),
    );
  }
}

/// Response wrapper for the requirements list API.
class RequirementListResponse {
  final List<AiRequirement> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  const RequirementListResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  factory RequirementListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    final items = rawItems
        .map((e) => RequirementFromListModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return RequirementListResponse(
      items: items,
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 0,
    );
  }
}
