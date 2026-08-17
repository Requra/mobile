class ClickUpStatus {
  final bool isConnected;
  final String? teamId;
  final String? spaceId;
  final String? listId;
  final bool tokenExpired;
  final DateTime? expiresAt;

  // Extensibility: add teamName/spaceName/listName here when backend provides them
  // final String? teamName;
  // final String? spaceName;
  // final String? listName;

  const ClickUpStatus({
    required this.isConnected,
    this.teamId,
    this.spaceId,
    this.listId,
    required this.tokenExpired,
    this.expiresAt,
  });
}
