import 'package:equatable/equatable.dart';
import 'package:requra/features/clickup/domain/entities/clickup_push_result.dart';
import 'package:requra/features/clickup/domain/entities/clickup_status.dart';

abstract class ClickUpState extends Equatable {
  const ClickUpState();

  @override
  List<Object?> get props => [];
}

class ClickUpInitial extends ClickUpState {}

class ClickUpLoading extends ClickUpState {}

class ClickUpDisconnected extends ClickUpState {}

class ClickUpConnecting extends ClickUpState {
  final String authUrl;
  final String projectId;

  const ClickUpConnecting({required this.authUrl, required this.projectId});

  @override
  List<Object?> get props => [authUrl, projectId];
}

class ClickUpExchangingCode extends ClickUpState {}

class ClickUpConnected extends ClickUpState {
  final ClickUpStatus status;

  const ClickUpConnected({required this.status});

  @override
  List<Object?> get props => [status];
}

class ClickUpTokenExpired extends ClickUpState {
  final ClickUpStatus status;

  const ClickUpTokenExpired({required this.status});

  @override
  List<Object?> get props => [status];
}

class ClickUpPushing extends ClickUpState {}

class ClickUpPushComplete extends ClickUpState {
  final ClickUpPushResult result;

  const ClickUpPushComplete({required this.result});

  @override
  List<Object?> get props => [result];
}

class ClickUpError extends ClickUpState {
  final String message;
  final bool isTokenExpired;

  const ClickUpError({required this.message, required this.isTokenExpired});

  @override
  List<Object?> get props => [message, isTokenExpired];
}
