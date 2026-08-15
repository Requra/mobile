import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/domain/usecases/create_meeting_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/get_project_meetings_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/get_meeting_details_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/update_meeting_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/cancel_meeting_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/start_meeting_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/end_meeting_usecase.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_state.dart';

class MeetingCubit extends Cubit<MeetingState> {
  final GetProjectMeetingsUseCase _getProjectMeetings;
  final GetMeetingDetailsUseCase _getMeetingDetails;
  final CreateMeetingUseCase _createMeeting;
  final UpdateMeetingUseCase _updateMeeting;
  final CancelMeetingUseCase _cancelMeeting;
  final StartMeetingUseCase _startMeeting;
  final EndMeetingUseCase _endMeeting;

  MeetingCubit({
    required GetProjectMeetingsUseCase getProjectMeetingsUseCase,
    required GetMeetingDetailsUseCase getMeetingDetailsUseCase,
    required CreateMeetingUseCase createMeetingUseCase,
    required UpdateMeetingUseCase updateMeetingUseCase,
    required CancelMeetingUseCase cancelMeetingUseCase,
    required StartMeetingUseCase startMeetingUseCase,
    required EndMeetingUseCase endMeetingUseCase,
  })  : _getProjectMeetings = getProjectMeetingsUseCase,
        _getMeetingDetails = getMeetingDetailsUseCase,
        _createMeeting = createMeetingUseCase,
        _updateMeeting = updateMeetingUseCase,
        _cancelMeeting = cancelMeetingUseCase,
        _startMeeting = startMeetingUseCase,
        _endMeeting = endMeetingUseCase,
        super(MeetingInitial());

  Future<void> fetchProjectMeetings(String projectId) async {
    emit(MeetingLoading());
    final result = await _getProjectMeetings(projectId);

    result.fold(
      (failure) => emit(MeetingError(failure.message)),
      (meetings) => emit(MeetingLoaded(meetings: meetings)),
    );
  }

  Future<String?> getMeetingDetails(String meetingId) async {
    final currentState = state;
    List<Meeting> currentMeetings = [];
    if (currentState is MeetingLoaded) {
      currentMeetings = currentState.meetings;
    }

    print('getMeetingDetails called for $meetingId');
    final result = await _getMeetingDetails(meetingId);

    return result.fold(
      (failure) {
        print('getMeetingDetails failed: ${failure.message}');
        return failure.message;
      },
      (fetchedMeeting) {
        print('getMeetingDetails success: scheduledAt=${fetchedMeeting.scheduledAt}, joinUrl=${fetchedMeeting.joinUrl}');
        if (currentMeetings.isNotEmpty) {
          final updatedMeetings = currentMeetings.map((m) {
            if (m.id == meetingId) {
              return m.copyWith(
                // Force update to test UI if it's null from api for some reason
                joinUrl: fetchedMeeting.joinUrl.isNotEmpty ? fetchedMeeting.joinUrl : m.joinUrl,
                scheduledAt: fetchedMeeting.scheduledAt ?? DateTime.now(),
                title: fetchedMeeting.title.isNotEmpty ? fetchedMeeting.title : m.title,
                description: fetchedMeeting.description.isNotEmpty ? fetchedMeeting.description : m.description,
                status: fetchedMeeting.status.isNotEmpty ? fetchedMeeting.status : m.status,
              );
            }
            return m;
          }).toList();
          emit(MeetingLoaded(meetings: updatedMeetings));
        }
        return null;
      },
    );
  }

  Future<dynamic> createMeeting({
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
        return meeting;
      },
    );
  }

  Future<String?> updateMeeting({
    required String meetingId,
    required String title,
    required String description,
    String? scheduledAt,
  }) async {
    final currentState = state;
    List<Meeting> currentMeetings = [];
    if (currentState is MeetingLoaded) {
      currentMeetings = currentState.meetings;
    }

    final result = await _updateMeeting(
      meetingId,
      {
        'title': title,
        'description': description,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
      },
    );

    return result.fold(
      (failure) => failure.message,
      (updatedMeeting) {
        final updatedMeetings = currentMeetings.map((m) {
          if (m.id == meetingId) {
            return m.copyWith(
              title: updatedMeeting.title.isNotEmpty ? updatedMeeting.title : m.title,
              description: updatedMeeting.description.isNotEmpty ? updatedMeeting.description : m.description,
              scheduledAt: updatedMeeting.scheduledAt ?? m.scheduledAt,
              status: updatedMeeting.status.isNotEmpty ? updatedMeeting.status : m.status,
              joinUrl: updatedMeeting.joinUrl.isNotEmpty ? updatedMeeting.joinUrl : m.joinUrl,
            );
          }
          return m;
        }).toList();
        emit(MeetingLoaded(meetings: updatedMeetings));
        return null;
      },
    );
  }

  Future<String?> cancelMeeting(String meetingId) async {
    final currentState = state;
    List<Meeting> currentMeetings = [];
    if (currentState is MeetingLoaded) {
      currentMeetings = currentState.meetings;
    }

    final result = await _cancelMeeting(meetingId);

    return result.fold(
      (failure) => failure.message,
      (cancelledMeeting) {
        final updatedMeetings = currentMeetings.map((m) {
          if (m.id == meetingId) {
            return m.copyWith(
              status: cancelledMeeting.status.isNotEmpty ? cancelledMeeting.status : 'CANCELLED',
            );
          }
          return m;
        }).toList();
        emit(MeetingLoaded(meetings: updatedMeetings));
        return null;
      },
    );
  }

  Future<String?> startMeeting(String meetingId) async {
    final currentState = state;
    List<Meeting> currentMeetings = [];
    if (currentState is MeetingLoaded) {
      currentMeetings = currentState.meetings;
    }

    final result = await _startMeeting(meetingId);

    return result.fold(
      (failure) => failure.message,
      (startedMeeting) {
        final updatedMeetings = currentMeetings.map((m) {
          if (m.id == meetingId) {
            return m.copyWith(
              status: startedMeeting.status.isNotEmpty ? startedMeeting.status : 'LIVE',
              startedAt: startedMeeting.startedAt ?? m.startedAt,
              joinUrl: startedMeeting.joinUrl.isNotEmpty ? startedMeeting.joinUrl : m.joinUrl,
            );
          }
          return m;
        }).toList();
        emit(MeetingLoaded(meetings: updatedMeetings));
        return null;
      },
    );
  }

  Future<String?> endMeeting(String meetingId) async {
    final currentState = state;
    List<Meeting> currentMeetings = [];
    if (currentState is MeetingLoaded) {
      currentMeetings = currentState.meetings;
    }

    final result = await _endMeeting(meetingId);

    return result.fold(
      (failure) => failure.message,
      (endedMeeting) {
        final updatedMeetings = currentMeetings.map((m) {
          if (m.id == meetingId) {
            return m.copyWith(
              status: endedMeeting.status.isNotEmpty ? endedMeeting.status : 'ENDED',
              endedAt: endedMeeting.endedAt ?? m.endedAt,
            );
          }
          return m;
        }).toList();
        emit(MeetingLoaded(meetings: updatedMeetings));
        return null;
      },
    );
  }
}
