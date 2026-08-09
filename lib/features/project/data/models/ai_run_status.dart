class AiRunStatus {
  final String id;
  final String status;
  final int progress;
  final String currentNode;
  final String currentNodeLabel;
  final String message;

  AiRunStatus({
    required this.id,
    required this.status,
    required this.progress,
    required this.currentNode,
    required this.currentNodeLabel,
    required this.message,
  });

  factory AiRunStatus.fromJson(Map<String, dynamic> json) {
    return AiRunStatus(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      progress: json['progress'] ?? 0,
      currentNode: json['currentNode'] ?? '',
      currentNodeLabel: json['currentNodeLabel'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
