import 'package:requra/features/clickup/domain/entities/clickup_status.dart';

class ClickUpStatusModel extends ClickUpStatus {
  const ClickUpStatusModel({
    required super.isConnected,
    super.teamId,
    super.spaceId,
    super.listId,
    required super.tokenExpired,
    super.expiresAt,
  });

  factory ClickUpStatusModel.fromJson(Map<String, dynamic> json) {
    return ClickUpStatusModel(
      isConnected: json['isConnected'] ?? false,
      teamId: json['teamId']?.toString(),
      spaceId: json['spaceId']?.toString(),
      listId: json['listId']?.toString(),
      tokenExpired: json['tokenExpired'] ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
    );
  }
}
