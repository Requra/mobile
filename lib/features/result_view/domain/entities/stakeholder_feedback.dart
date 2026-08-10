import 'package:equatable/equatable.dart';

class StakeholderFeedbackResponse extends Equatable {
  final List<StakeholderFeedbackItem> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int openCount;
  final int resolvedCount;
  final int unreadCount;

  const StakeholderFeedbackResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.openCount,
    required this.resolvedCount,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [
        items,
        totalCount,
        pageNumber,
        pageSize,
        openCount,
        resolvedCount,
        unreadCount,
      ];
}

class StakeholderFeedbackItem extends Equatable {
  final String id;
  final String projectId;
  final String targetType;
  final String? targetId;
  final String? targetTitle;
  final String content;
  final String status;
  final bool isRead;
  final FeedbackAuthor? author;
  final String? resolutionNote;
  final String? resolvedById;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StakeholderFeedbackItem({
    required this.id,
    required this.projectId,
    required this.targetType,
    this.targetId,
    this.targetTitle,
    required this.content,
    required this.status,
    required this.isRead,
    this.author,
    this.resolutionNote,
    this.resolvedById,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        targetType,
        targetId,
        targetTitle,
        content,
        status,
        isRead,
        author,
        resolutionNote,
        resolvedById,
        resolvedAt,
        createdAt,
        updatedAt,
      ];
}

class FeedbackAuthor extends Equatable {
  final String? displayName;
  final String? email;

  const FeedbackAuthor({
    this.displayName,
    this.email,
  });

  @override
  List<Object?> get props => [displayName, email];
}
