import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/meeting/domain/entities/meeting_summary.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_finished_state.dart';

class MeetingFinishedCubit extends Cubit<MeetingFinishedState> {
  Timer? _mockTimer;

  MeetingFinishedCubit() : super(MeetingFinishedInitial());

  void init(MeetingSummary summary) {
    emit(MeetingFinishedLoaded(summary));

    // Simulate polling for AI extraction status
    if (summary.aiExtractionStatus == ProcessingStatus.processing) {
      _mockTimer?.cancel();
      _mockTimer = Timer(const Duration(seconds: 5), () {
        if (!isClosed && state is MeetingFinishedLoaded) {
          final currentState = state as MeetingFinishedLoaded;
          emit(
            MeetingFinishedLoaded(
              currentState.summary.copyWith(
                aiExtractionStatus: ProcessingStatus.ready,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Future<void> close() {
    _mockTimer?.cancel();
    return super.close();
  }
}
