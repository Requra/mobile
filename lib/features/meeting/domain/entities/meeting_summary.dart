import 'package:equatable/equatable.dart';

enum ProcessingStatus {
  processing,
  ready,
  failed;
}

class MeetingSummary extends Equatable {
  final String meetingTitle;
  final String projectId;
  final String projectName;
  final ProcessingStatus transcriptStatus;
  final ProcessingStatus aiExtractionStatus;

  const MeetingSummary({
    required this.meetingTitle,
    required this.projectId,
    required this.projectName,
    this.transcriptStatus = ProcessingStatus.ready,
    this.aiExtractionStatus = ProcessingStatus.processing,
  });

  @override
  List<Object?> get props => [
        meetingTitle,
        projectId,
        projectName,
        transcriptStatus,
        aiExtractionStatus,
      ];

  MeetingSummary copyWith({
    String? meetingTitle,
    String? projectId,
    String? projectName,
    ProcessingStatus? transcriptStatus,
    ProcessingStatus? aiExtractionStatus,
  }) {
    return MeetingSummary(
      meetingTitle: meetingTitle ?? this.meetingTitle,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      transcriptStatus: transcriptStatus ?? this.transcriptStatus,
      aiExtractionStatus: aiExtractionStatus ?? this.aiExtractionStatus,
    );
  }
}
