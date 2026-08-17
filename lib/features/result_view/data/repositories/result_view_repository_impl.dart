import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/result_view/data/datasource/result_view_remote_data_source.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/domain/entities/stakeholder_feedback.dart';
import 'package:requra/features/result_view/domain/entities/review_invitation.dart';
import 'package:requra/features/result_view/domain/repositories/result_view_repository.dart';

class ResultViewRepositoryImpl implements ResultViewRepository {
  final ResultViewRemoteDataSource remoteDataSource;

  ResultViewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProjectDetails>> getProjectDetails(String id) async {
    try {
      final result = await remoteDataSource.getProjectDetails(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getProjectDocuments(
    String projectId,
  ) async {
    try {
      final result = await remoteDataSource.getProjectDocuments(projectId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Document>> uploadDocument({
    required File file,
    required String projectId,
    required String title,
    required String type,
    required String language,
    String? meetingId,
  }) async {
    try {
      final result = await remoteDataSource.uploadDocument(
        file: file,
        projectId: projectId,
        title: title,
        type: type,
        language: language,
        meetingId: meetingId,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, AiResultsDashboard>> getAiResultsDashboard(
    String projectId,
  ) async {
    try {
      final result = await remoteDataSource.getAiResultsDashboard(projectId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, List<AiUserStory>>> getUserStories(
    String projectId,
  ) async {
    try {
      final result = await remoteDataSource.getUserStories(projectId);
      return Right(result.items);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, List<AiRequirement>>> getRequirements(
    String projectId,
  ) async {
    try {
      final result = await remoteDataSource.getRequirements(projectId);
      return Right(result.items);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, StakeholderFeedbackResponse>> getStakeholderFeedback(
    String projectId,
  ) async {
    try {
      final result = await remoteDataSource.getStakeholderFeedback(projectId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> resolveFeedback(
    String projectId,
    String feedbackId,
    String? resolutionNote,
  ) async {
    try {
      await remoteDataSource.resolveFeedback(
        projectId,
        feedbackId,
        resolutionNote,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'A network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, ReviewInvitationResponse>> getReviewInvitations(
    String projectId,
  ) async {
    try {
      final response = await remoteDataSource.getReviewInvitations(projectId);
      return Right(response);
    } catch (e) {
      if (e is DioException) {
        String errorMessage = e.message ?? 'An error occurred';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
        return Left(ServerFailure(errorMessage));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendReviewInvitation(
    String projectId,
    String displayName,
    String email,
    String permission,
    String? expiresAt,
  ) async {
    try {
      await remoteDataSource.sendReviewInvitation(
        projectId,
        displayName,
        email,
        permission,
        expiresAt,
      );
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        String errorMessage = e.message ?? 'An error occurred';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
        return Left(ServerFailure(errorMessage));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendReviewInvitation(
    String projectId,
    String invitationId,
  ) async {
    try {
      await remoteDataSource.resendReviewInvitation(projectId, invitationId);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        String errorMessage = e.message ?? 'An error occurred';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
        return Left(ServerFailure(errorMessage));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> revokeReviewInvitation(
    String projectId,
    String invitationId,
  ) async {
    try {
      await remoteDataSource.revokeReviewInvitation(projectId, invitationId);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        String errorMessage = e.message ?? 'An error occurred';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
        return Left(ServerFailure(errorMessage));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateRequirementStatus(
    String projectId,
    String requirementId,
    int version,
    String workflowStatus, {
    String? reviewFeedback,
  }) async {
    try {
      final result = await remoteDataSource.updateRequirementStatus(
        projectId,
        requirementId,
        version,
        workflowStatus,
        reviewFeedback: reviewFeedback,
      );
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 412 || e.response?.statusCode == 409) {
          return const Left(ServerFailure('CONCURRENCY_ERROR'));
        }
        String errorMessage = e.message ?? 'An error occurred';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
        return Left(ServerFailure(errorMessage));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateRequirement(
    String projectId,
    String requirementId,
    int version, {
    required String title,
    required String description,
    required String type,
    required String priority,
  }) async {
    try {
      final result = await remoteDataSource.updateRequirement(
        projectId,
        requirementId,
        version,
        title: title,
        description: description,
        type: type,
        priority: priority,
      );
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 412 || e.response?.statusCode == 409) {
          return const Left(ServerFailure('CONCURRENCY_ERROR'));
        }
        String errorMessage = e.message ?? 'An error occurred';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
        return Left(ServerFailure(errorMessage));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateUserStoryStatus(
    String projectId,
    String storyId,
    int version,
    String workflowStatus, {
    String? reviewFeedback,
  }) async {
    try {
      final result = await remoteDataSource.updateUserStoryStatus(
        projectId,
        storyId,
        version,
        workflowStatus,
        reviewFeedback: reviewFeedback,
      );
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 412 || e.response?.statusCode == 409) {
          return const Left(ServerFailure('CONCURRENCY_ERROR'));
        }
        String errorMessage = e.message ?? 'An error occurred';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
        return Left(ServerFailure(errorMessage));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateUserStory(
    String projectId,
    String storyId,
    int version, {
    required String title,
    required String description,
    required List<String> acceptanceCriteria,
    required String priority,
  }) async {
    try {
      final result = await remoteDataSource.updateUserStory(
        projectId,
        storyId,
        version,
        title: title,
        description: description,
        acceptanceCriteria: acceptanceCriteria,
        priority: priority,
      );
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 412 || e.response?.statusCode == 409) {
          return const Left(ServerFailure('CONCURRENCY_ERROR'));
        }
        String errorMessage = e.message ?? 'An error occurred';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
        return Left(ServerFailure(errorMessage));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> regenerateUserStory(
    String projectId,
    String storyId,
    int version,
    String feedback,
  ) async {
    try {
      final result = await remoteDataSource.regenerateUserStory(
        projectId,
        storyId,
        version,
        feedback,
      );
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 412 || e.response?.statusCode == 409) {
          return const Left(ServerFailure('CONCURRENCY_ERROR'));
        }
        String errorMessage = e.message ?? 'An error occurred';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
        return Left(ServerFailure(errorMessage));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
