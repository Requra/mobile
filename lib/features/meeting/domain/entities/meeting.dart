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

  Meeting copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? status,
    String? joinUrl,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
    int? participantsCount,
  }) {
    return Meeting(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      joinUrl: joinUrl ?? this.joinUrl,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      participantsCount: participantsCount ?? this.participantsCount,
    );
  }
}
