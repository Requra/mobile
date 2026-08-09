import 'package:equatable/equatable.dart';
import 'package:requra/features/meeting/domain/entities/meeting_summary.dart';

sealed class MeetingFinishedState extends Equatable {
  const MeetingFinishedState();

  @override
  List<Object?> get props => [];
}

class MeetingFinishedInitial extends MeetingFinishedState {}

class MeetingFinishedLoaded extends MeetingFinishedState {
  final MeetingSummary summary;

  const MeetingFinishedLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}
