import 'package:requra/features/clickup/domain/entities/clickup_push_result.dart';

class ClickUpPushResultModel extends ClickUpPushResult {
  const ClickUpPushResultModel({
    required super.projectId,
    required super.createdCount,
    required super.updatedCount,
    required super.failedCount,
    required super.skippedCount,
    required super.totalCount,
    super.message,
    required super.details,
  });

  factory ClickUpPushResultModel.fromJson(Map<String, dynamic> json) {
    final rawDetails = (json['details'] as List<dynamic>?) ?? [];
    final parsedDetails = rawDetails
        .map((e) => ClickUpPushDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ClickUpPushResultModel(
      projectId: json['projectId']?.toString() ?? '',
      createdCount: json['createdCount'] as int? ?? 0,
      updatedCount: json['updatedCount'] as int? ?? 0,
      failedCount: json['failedCount'] as int? ?? 0,
      skippedCount: json['skippedCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
      message: json['message']?.toString(),
      details: parsedDetails,
    );
  }
}

class ClickUpPushDetailModel extends ClickUpPushDetail {
  const ClickUpPushDetailModel({
    required super.userStoryId,
    super.clickUpTaskId,
    required super.action,
    required super.success,
    super.message,
  });

  factory ClickUpPushDetailModel.fromJson(Map<String, dynamic> json) {
    return ClickUpPushDetailModel(
      userStoryId: json['userStoryId']?.toString() ?? '',
      clickUpTaskId: json['clickUpTaskId']?.toString(),
      action: json['action']?.toString() ?? 'Unknown',
      success: json['success'] ?? false,
      message: json['message']?.toString(),
    );
  }
}
