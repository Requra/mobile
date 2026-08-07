import 'package:equatable/equatable.dart';

class Meeting extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String joinUrl;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime? createdAt;
  final int participantsCount;

  const Meeting({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.joinUrl,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.createdAt,
    required this.participantsCount,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        description,
        status,
        joinUrl,
        scheduledAt,
        startedAt,
        endedAt,
        createdAt,
        participantsCount,
      ];
}
