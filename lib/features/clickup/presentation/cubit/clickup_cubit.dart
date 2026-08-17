import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/clickup/domain/usecases/clickup_usecases.dart';
import 'package:requra/features/clickup/presentation/cubit/clickup_state.dart';

class ClickUpCubit extends Cubit<ClickUpState> {
  final GetClickUpStatusUseCase getStatusUseCase;
  final GetClickUpAuthUrlUseCase getAuthUrlUseCase;
  final CompleteClickUpCallbackUseCase completeCallbackUseCase;
  final DisconnectClickUpUseCase disconnectUseCase;
  final PushApprovedToClickUpUseCase pushApprovedUseCase;

  ClickUpCubit({
    required this.getStatusUseCase,
    required this.getAuthUrlUseCase,
    required this.completeCallbackUseCase,
    required this.disconnectUseCase,
    required this.pushApprovedUseCase,
  }) : super(ClickUpInitial());

  /// Called on screen entry. Fetches status and emits the right state.
  Future<void> fetchStatus(String projectId) async {
    emit(ClickUpLoading());
    final result = await getStatusUseCase(projectId);
    result.fold(
      (failure) {
        final isExpired = failure.message == 'TOKEN_EXPIRED';
        emit(ClickUpError(message: failure.message, isTokenExpired: isExpired));
      },
      (status) {
        if (!status.isConnected) {
          emit(ClickUpDisconnected());
        } else if (status.tokenExpired) {
          emit(ClickUpTokenExpired(status: status));
        } else {
          emit(ClickUpConnected(status: status));
        }
      },
    );
  }

  /// Step 1 of OAuth: get the auth URL, then emit ClickUpConnecting
  Future<void> startConnect(String projectId) async {
    emit(ClickUpLoading());
    final result = await getAuthUrlUseCase(projectId);
    result.fold(
      (failure) => emit(ClickUpError(
          message: failure.message, isTokenExpired: false)),
      (authUrl) =>
          emit(ClickUpConnecting(authUrl: authUrl, projectId: projectId)),
    );
  }

  /// Step 2 of OAuth: called after WebView intercepts the callback URL
  Future<void> completeOAuth(String code, String projectId) async {
    emit(ClickUpExchangingCode());
    final result = await completeCallbackUseCase(code, projectId);
    result.fold(
      (failure) => emit(ClickUpError(
          message: failure.message, isTokenExpired: false)),
      (_) => fetchStatus(projectId), // refresh → should now be Connected
    );
  }

  /// Disconnect
  Future<void> disconnect(String projectId) async {
    emit(ClickUpLoading());
    final result = await disconnectUseCase(projectId);
    result.fold(
      (failure) => emit(ClickUpError(
          message: failure.message, isTokenExpired: false)),
      (_) => emit(ClickUpDisconnected()),
    );
  }

  /// Push approved user stories to ClickUp
  Future<void> pushApproved(String projectId) async {
    emit(ClickUpPushing());
    final result = await pushApprovedUseCase(projectId);
    result.fold(
      (failure) {
        final isExpired = failure.message == 'TOKEN_EXPIRED';
        emit(ClickUpError(message: failure.message, isTokenExpired: isExpired));
      },
      (pushResult) => emit(ClickUpPushComplete(result: pushResult)),
    );
  }
}
