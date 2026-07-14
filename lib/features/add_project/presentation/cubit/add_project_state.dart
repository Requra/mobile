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

class AddProjectStep2 extends AddProjectState {
  final ProjectDetails details;
  final List<SourceItem> sources;

  const AddProjectStep2({
    required this.details,
    required this.sources,
  });

  @override
  List<Object?> get props => [details, sources];
}

class AddProjectCreating extends AddProjectState {
  final ProjectDetails details;
  final List<SourceItem> sources;

  const AddProjectCreating({
    required this.details,
    required this.sources,
  });

  @override
  List<Object?> get props => [details, sources];
}

class AddProjectSuccess extends AddProjectState {
  final ProjectCreationResult result;
  final ProjectDetails details;
  final List<SourceItem> sources;

  const AddProjectSuccess({
    required this.result,
    required this.details,
    required this.sources,
  });

  @override
  List<Object?> get props => [result, details, sources];
}

class AddProjectError extends AddProjectState {
  final String message;
  final ProjectDetails details;
  final List<SourceItem> sources;

  const AddProjectError({
    required this.message,
    required this.details,
    required this.sources,
  });

  @override
  List<Object?> get props => [message, details, sources];
}
