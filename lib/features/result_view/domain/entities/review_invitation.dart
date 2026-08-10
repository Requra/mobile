import 'package:equatable/equatable.dart';

class ReviewInvitationResponse extends Equatable {
  final List<ReviewInvitationItem> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int pendingCount;
  final int acceptedCount;
  final int revokedCount;

  const ReviewInvitationResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.pendingCount,
    required this.acceptedCount,
    required this.revokedCount,
  });

  @override
  List<Object?> get props => [
        items,
        totalCount,
        pageNumber,
        pageSize,
        pendingCount,
        acceptedCount,
        revokedCount,
      ];
}

class ReviewInvitationItem extends Equatable {
  final String id;
  final String projectId;
  final String stakeholderId;
  final String email;
  final String displayName;
  final String? company;
  final String? roleTitle;
  final String permission;
  final String status;
  final String? reviewUrl;
  final DateTime? expiresAt;
  final DateTime? acceptedAt;
  final DateTime? revokedAt;
  final String invitedById;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewInvitationItem({
    required this.id,
    required this.projectId,
    required this.stakeholderId,
    required this.email,
    required this.displayName,
    this.company,
    this.roleTitle,
    required this.permission,
    required this.status,
    this.reviewUrl,
    this.expiresAt,
    this.acceptedAt,
    this.revokedAt,
    required this.invitedById,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        stakeholderId,
        email,
        displayName,
        company,
        roleTitle,
        permission,
        status,
        reviewUrl,
        expiresAt,
        acceptedAt,
        revokedAt,
        invitedById,
        createdAt,
        updatedAt,
      ];
}
