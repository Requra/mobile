import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';

/// Model for parsing user stories from the dedicated
/// GET /api/projects/{projectId}/results/user-stories endpoint.
///
/// The response uses camelCase keys (e.g. acceptanceCriteria, requirementId)
/// and has a different shape from the AI results dashboard user stories.
class UserStoryFromListModel extends AiUserStory {
  const UserStoryFromListModel({
    required super.id,
    required super.title,
    required super.description,
    required super.userStory,
    required super.acceptanceCriteria,
    required super.priority,
    super.type,
    required super.requirementId,
    super.quality,
    required super.sourceRefs,
    super.workflowStatus,
    super.version,
    super.qualityStatus,
    super.revisionNumber,
    super.revisionSource,
    super.sourceUserStoryId,
    super.sourceRequirementId,
  });

  factory UserStoryFromListModel.fromJson(Map<String, dynamic> json) {
    // Parse acceptance criteria – the API returns a list of strings
    List<String> parsedAC = [];
    if (json['acceptanceCriteria'] != null) {
      for (var item in json['acceptanceCriteria']) {
        if (item is String) {
          parsedAC.add(item);
        } else if (item is Map<String, dynamic> && item['text'] != null) {
          parsedAC.add(item['text'].toString());
        } else {
          parsedAC.add(item.toString());
        }
      }
    }

    // Map "status" field (e.g. "NeedReview") to workflowStatus format
    String? workflowStatus;
    final rawStatus = json['status']?.toString();
    if (rawStatus != null) {
      // Convert "NeedReview" → "NEEDS_REVIEW", etc.
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

    // Parse QualityInfo (camelCase)
    QualityInfo? quality;
    if (json['quality'] != null) {
      final qJson = json['quality'] as Map<String, dynamic>;
      quality = QualityInfo(
        score: qJson['score'] != null
            ? (qJson['score'] as num).toDouble()
            : null,
        level: qJson['level']?.toString(),
        issues: (qJson['issues'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        warnings: (qJson['warnings'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );
    }

    // Parse SourceRefs (camelCase)
    List<SourceRef> sourceRefs = [];
    if (json['sourceRefs'] != null) {
      sourceRefs = (json['sourceRefs'] as List<dynamic>).map((e) {
        final rJson = e as Map<String, dynamic>;
        return SourceRef(
          sourceId: rJson['sourceId']?.toString(),
          sourceType: rJson['sourceType']?.toString(),
          documentTitle:
              rJson['documentName']?.toString() ??
              rJson['documentTitle']?.toString(),
          chunkId: rJson['chunkId']?.toString(),
          quote: rJson['quote']?.toString(),
          confidenceScore: rJson['confidenceScore'] != null
              ? (rJson['confidenceScore'] as num).toDouble()
              : null,
          fileUrl: rJson['fileUrl']?.toString(),
          documentId: rJson['documentId']?.toString(),
        );
      }).toList();
    }

    return UserStoryFromListModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      userStory:
          json['userStory']?.toString() ??
          json['description']?.toString() ??
          '',
      acceptanceCriteria: parsedAC,
      priority: json['priority']?.toString() ?? '',
      type: json['type']?.toString(),
      requirementId: json['requirementId']?.toString() ?? '',
      workflowStatus: workflowStatus,
      version: json['version'] != null
          ? int.tryParse(json['version'].toString())
          : null,
      qualityStatus: json['qualityStatus']?.toString(),
      quality: quality,
      sourceRefs: sourceRefs,
      sourceUserStoryId: json['sourceUserStoryId']?.toString(),
      sourceRequirementId: json['sourceRequirementId']?.toString(),
    );
  }
}

/// Response wrapper for the user stories list API.
class UserStoryListResponse {
  final List<AiUserStory> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  const UserStoryListResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  factory UserStoryListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    final items = rawItems
        .map((e) => UserStoryFromListModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return UserStoryListResponse(
      items: items,
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 0,
    );
  }
}
