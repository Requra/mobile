import 'package:equatable/equatable.dart';
import 'package:requra/features/result_view/domain/entities/meeting.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';

sealed class ResultViewState extends Equatable {
  const ResultViewState();

  @override
  List<Object?> get props => [];
}

class ResultViewInitial extends ResultViewState {}

class ResultViewLoading extends ResultViewState {}

class ResultViewLoaded extends ResultViewState {
  final ProjectDetails projectDetails;
  final List<Meeting> meetings;
  final List<Document> documents;
  final int totalRequirements;

  const ResultViewLoaded({
    required this.projectDetails,
    required this.meetings,
    required this.documents,
    required this.totalRequirements,
  });

  @override
  List<Object?> get props => [projectDetails, meetings, documents, totalRequirements];
}

class ResultViewError extends ResultViewState {
  final String message;
  const ResultViewError(this.message);

  @override
  List<Object?> get props => [message];
}
