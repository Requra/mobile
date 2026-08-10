import 'package:requra/features/result_view/domain/entities/review_invitation.dart';

class ReviewInvitationResponseModel extends ReviewInvitationResponse {
  const ReviewInvitationResponseModel({
    required super.items,
    required super.totalCount,
    required super.pageNumber,
    required super.pageSize,
    required super.pendingCount,
    required super.acceptedCount,
    required super.revokedCount,
  });

  factory ReviewInvitationResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewInvitationResponseModel(
      items: (json['items'] as List?)
              ?.map((item) => ReviewInvitationItemModel.fromJson(item))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      pendingCount: json['pendingCount'] ?? 0,
      acceptedCount: json['acceptedCount'] ?? 0,
      revokedCount: json['revokedCount'] ?? 0,
    );
  }
}

class ReviewInvitationItemModel extends ReviewInvitationItem {
  const ReviewInvitationItemModel({
    required super.id,
    required super.projectId,
    required super.stakeholderId,
    required super.email,
    required super.displayName,
    super.company,
    super.roleTitle,
    required super.permission,
    required super.status,
    super.reviewUrl,
    super.expiresAt,
    super.acceptedAt,
    super.revokedAt,
    required super.invitedById,
    super.createdAt,
    super.updatedAt,
  });

  factory ReviewInvitationItemModel.fromJson(Map<String, dynamic> json) {
    return ReviewInvitationItemModel(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      stakeholderId: json['stakeholderId'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      company: json['company'],
      roleTitle: json['roleTitle'],
      permission: json['permission'] ?? 'VIEWER',
      status: json['status'] ?? 'PENDING',
      reviewUrl: json['reviewUrl'],
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
      revokedAt: json['revokedAt'] != null ? DateTime.parse(json['revokedAt']) : null,
      invitedById: json['invitedById'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
