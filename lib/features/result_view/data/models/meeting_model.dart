import 'package:requra/features/result_view/domain/entities/meeting.dart';

class MeetingModel extends Meeting {
  const MeetingModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.status,
    required super.joinUrl,
    super.scheduledAt,
    super.startedAt,
    super.endedAt,
    super.createdAt,
    required super.participantsCount,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      joinUrl: json['joinUrl'] ?? '',
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'])
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'])
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      // Mock API sometimes returns negative values
      participantsCount: (json['participantsCount'] ?? 0).abs(),
    );
  }
}
