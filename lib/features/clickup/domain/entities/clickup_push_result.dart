class ClickUpPushResult {
  final String projectId;
  final int createdCount;
  final int updatedCount;
  final int failedCount;
  final int skippedCount;
  final int totalCount;
  final String? message;
  final List<ClickUpPushDetail> details;

  const ClickUpPushResult({
    required this.projectId,
    required this.createdCount,
    required this.updatedCount,
    required this.failedCount,
    required this.skippedCount,
    required this.totalCount,
    this.message,
    required this.details,
  });
}

class ClickUpPushDetail {
  final String userStoryId;
  final String? clickUpTaskId;
  final String action; // "Created" | "Updated" | "Skipped" | "Failed"
  final bool success;
  final String? message; // error details if !success

  const ClickUpPushDetail({
    required this.userStoryId,
    this.clickUpTaskId,
    required this.action,
    required this.success,
    this.message,
  });
}
