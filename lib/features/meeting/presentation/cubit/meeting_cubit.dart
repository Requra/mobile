import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/domain/usecases/create_meeting_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/get_project_meetings_usecase.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_state.dart';

class MeetingCubit extends Cubit<MeetingState> {
  final GetProjectMeetingsUseCase _getProjectMeetings;
  final CreateMeetingUseCase _createMeeting;

  MeetingCubit({
    required GetProjectMeetingsUseCase getProjectMeetingsUseCase,
    required CreateMeetingUseCase createMeetingUseCase,
  })  : _getProjectMeetings = getProjectMeetingsUseCase,
        _createMeeting = createMeetingUseCase,
        super(MeetingInitial());

  Future<void> fetchProjectMeetings(String projectId) async {
    emit(MeetingLoading());
    final result = await _getProjectMeetings(projectId);

    result.fold(
      (failure) => emit(MeetingError(failure.message)),
      (meetings) => emit(MeetingLoaded(meetings: meetings)),
    );
  }

  Future<String?> createMeeting({
    required String projectId,
    required String title,
    required String description,
    String? scheduledAt,
  }) async {
    final currentState = state;
    List<Meeting> currentMeetings = [];
    if (currentState is MeetingLoaded) {
      currentMeetings = currentState.meetings;
    }

    final result = await _createMeeting(
      projectId,
      {
        'title': title,
        'description': description,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
      },
    );

    return result.fold(
      (failure) => failure.message,
      (meeting) {
        final updatedMeetings = List<Meeting>.from(currentMeetings)..add(meeting);
        emit(MeetingLoaded(meetings: updatedMeetings));
        return null;
      },
    );
  }
}
