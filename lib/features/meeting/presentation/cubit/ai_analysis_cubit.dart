import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/meeting/data/services/meeting_service.dart';
import 'package:requra/features/project/data/models/ai_run_status.dart';

abstract class AiAnalysisState {}

class AiAnalysisInitial extends AiAnalysisState {}

class AiAnalysisLoading extends AiAnalysisState {}

class AiAnalysisRunning extends AiAnalysisState {
  final AiRunStatus status;
  AiAnalysisRunning(this.status);
}

class AiAnalysisSuccess extends AiAnalysisState {
  final AiRunStatus status;
  AiAnalysisSuccess(this.status);
}

class AiAnalysisError extends AiAnalysisState {
  final String message;
  AiAnalysisError(this.message);
}

class AiAnalysisCubit extends Cubit<AiAnalysisState> {
  final MeetingService _meetingService;
  Timer? _pollingTimer;
  String? _runId;
  String? _projectId;

  AiAnalysisCubit(this._meetingService) : super(AiAnalysisInitial());

  Future<void> startAnalysis(String projectId, {String? meetingId}) async {
    if (state is AiAnalysisLoading || state is AiAnalysisRunning) return;

    _projectId = projectId;
    emit(AiAnalysisLoading());

    try {
      final response = await _meetingService.startAiRun(
        projectId: projectId,
        meetingId: meetingId,
      );

      if (response.isSuccess && response.data != null) {
        // The API returns the runId in data['aiJobId'] based on add_project_remote_data_source logic
        final data = response.data as Map<String, dynamic>;
        _runId = data['id']?.toString();

        if (_runId != null && _runId!.isNotEmpty) {
          _startPolling();
        } else {
          emit(AiAnalysisError('Failed to retrieve AI Run ID.'));
        }
      } else {
        emit(AiAnalysisError(response.message));
      }
    } catch (e) {
      emit(AiAnalysisError(e.toString()));
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_projectId == null || _runId == null || isClosed) {
        timer.cancel();
        return;
      }

      try {
        final response = await _meetingService.getAiRunProgress(
          projectId: _projectId!,
          runId: _runId!,
        );

        if (response.isSuccess && response.data != null) {
          final aiStatus = AiRunStatus.fromJson(
            response.data as Map<String, dynamic>,
          );

          if (aiStatus.status.toLowerCase() == 'completed' || aiStatus.progress >= 100) {
            timer.cancel();
            emit(AiAnalysisSuccess(aiStatus));
          } else if (aiStatus.status.toLowerCase() == 'failed') {
            timer.cancel();
            emit(
              AiAnalysisError(
                aiStatus.message.isNotEmpty
                    ? aiStatus.message
                    : 'AI Analysis failed.',
              ),
            );
          } else {
            emit(AiAnalysisRunning(aiStatus));
          }
        } else {
          // If polling fails briefly, don't kill the whole process immediately,
          // just log or maybe increment a failure counter. For now, we'll keep trying.
          print('Polling error: ${response.message}');
        }
      } catch (e) {
        print('Polling exception: $e');
      }
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
