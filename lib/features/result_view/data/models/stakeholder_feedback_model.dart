import 'package:requra/features/result_view/domain/entities/stakeholder_feedback.dart';

class StakeholderFeedbackResponseModel extends StakeholderFeedbackResponse {
  const StakeholderFeedbackResponseModel({
    required super.items,
    required super.totalCount,
    required super.pageNumber,
    required super.pageSize,
    required super.openCount,
    required super.resolvedCount,
    required super.unreadCount,
  });

  factory StakeholderFeedbackResponseModel.fromJson(Map<String, dynamic> json) {
    return StakeholderFeedbackResponseModel(
      items: (json['items'] as List?)
              ?.map((e) => StakeholderFeedbackItemModel.fromJson(e))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      openCount: json['openCount'] ?? 0,
      resolvedCount: json['resolvedCount'] ?? 0,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

class StakeholderFeedbackItemModel extends StakeholderFeedbackItem {
  const StakeholderFeedbackItemModel({
    required super.id,
    required super.projectId,
    required super.targetType,
    super.targetId,
    super.targetTitle,
    required super.content,
    required super.status,
    required super.isRead,
    super.author,
    super.resolutionNote,
    super.resolvedById,
    super.resolvedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory StakeholderFeedbackItemModel.fromJson(Map<String, dynamic> json) {
    return StakeholderFeedbackItemModel(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      targetType: json['targetType'] ?? '',
      targetId: json['targetId'],
      targetTitle: json['targetTitle'],
      content: json['content'] ?? '',
      status: json['status'] ?? 'OPEN',
      isRead: json['isRead'] ?? false,
      author: json['author'] != null
          ? FeedbackAuthorModel.fromJson(json['author'])
          : null,
      resolutionNote: json['resolutionNote'],
      resolvedById: json['resolvedById'],
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}

class FeedbackAuthorModel extends FeedbackAuthor {
  const FeedbackAuthorModel({
    super.displayName,
    super.email,
  });

  factory FeedbackAuthorModel.fromJson(Map<String, dynamic> json) {
    return FeedbackAuthorModel(
      displayName: json['displayName'],
      email: json['email'],
    );
  }
}
