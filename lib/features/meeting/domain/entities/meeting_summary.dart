import 'package:equatable/equatable.dart';

enum ProcessingStatus {
  processing,
  ready,
  failed;
}

class MeetingSummary extends Equatable {
  final String meetingId;
  final String meetingTitle;
  final String projectId;
  final String projectName;
  final ProcessingStatus transcriptStatus;
  final ProcessingStatus aiExtractionStatus;

  const MeetingSummary({
    required this.meetingId,
    required this.meetingTitle,
    required this.projectId,
    required this.projectName,
    this.transcriptStatus = ProcessingStatus.ready,
    this.aiExtractionStatus = ProcessingStatus.processing,
  });

  @override
  List<Object?> get props => [
        meetingId,
        meetingTitle,
        projectId,
        projectName,
        transcriptStatus,
        aiExtractionStatus,
      ];

  MeetingSummary copyWith({
    String? meetingId,
    String? meetingTitle,
    String? projectId,
    String? projectName,
    ProcessingStatus? transcriptStatus,
    ProcessingStatus? aiExtractionStatus,
  }) {
    return MeetingSummary(
      meetingId: meetingId ?? this.meetingId,
      meetingTitle: meetingTitle ?? this.meetingTitle,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      transcriptStatus: transcriptStatus ?? this.transcriptStatus,
      aiExtractionStatus: aiExtractionStatus ?? this.aiExtractionStatus,
    );
  }
}
