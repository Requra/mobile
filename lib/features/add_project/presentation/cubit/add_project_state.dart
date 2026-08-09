import 'package:equatable/equatable.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/project_creation_result.dart';

sealed class AddProjectState extends Equatable {
  const AddProjectState();

  @override
  List<Object?> get props => [];
}

class AddProjectStep1 extends AddProjectState {
  final ProjectDetails? details;

  const AddProjectStep1({this.details});

  @override
  List<Object?> get props => [details];
}

class AddProjectStep1Loading extends AddProjectState {
  final ProjectDetails details;

  const AddProjectStep1Loading({required this.details});

  @override
  List<Object?> get props => [details];
}

class AddProjectStep2 extends AddProjectState {
  final ProjectDetails details;
  final List<SourceItem> sources;
  final String projectId;

  const AddProjectStep2({
    required this.details,
    required this.sources,
    required this.projectId,
  });

  @override
  List<Object?> get props => [details, sources, projectId];
}

class AddProjectCreating extends AddProjectState {
  final ProjectDetails details;
  final List<SourceItem> sources;
  final String projectId;
  final int progress;
  final String statusMessage;
  final String? aiJobId;

  const AddProjectCreating({
    required this.details,
    required this.sources,
    required this.projectId,
    this.progress = 0,
    this.statusMessage = 'Starting AI...',
    this.aiJobId,
  });

  @override
  List<Object?> get props => [details, sources, projectId, progress, statusMessage, aiJobId];
}

class AddProjectSuccess extends AddProjectState {
  final ProjectDetails details;
  final List<SourceItem> sources;
  final String projectId;

  const AddProjectSuccess({
    required this.details,
    required this.sources,
    required this.projectId,
  });

  @override
  List<Object?> get props => [details, sources, projectId];
}

class AddProjectError extends AddProjectState {
  final String message;
  final ProjectDetails details;
  final List<SourceItem> sources;
  final String? projectId;

  const AddProjectError({
    required this.message,
    required this.details,
    required this.sources,
    this.projectId,
  });

  @override
  List<Object?> get props => [message, details, sources, projectId];
}
