import 'package:equatable/equatable.dart';
import 'package:requra/features/meeting/data/models/meeting_models.dart';

class MeetingInviteState extends Equatable {
  final List<ProjectMember> members;
  final bool loadingMembers;
  final List<MeetingInvitation> invitations;
  final bool loadingInvitations;
  final bool isSubmitting;
  final Set<String> resendingIds;
  final String? errorMessage;
  final String? successMessage;
  final bool needsRefresh;

  const MeetingInviteState({
    this.members = const [],
    this.loadingMembers = false,
    this.invitations = const [],
    this.loadingInvitations = false,
    this.isSubmitting = false,
    this.resendingIds = const {},
    this.errorMessage,
    this.successMessage,
    this.needsRefresh = false,
  });

  MeetingInviteState copyWith({
    List<ProjectMember>? members,
    bool? loadingMembers,
    List<MeetingInvitation>? invitations,
    bool? loadingInvitations,
    bool? isSubmitting,
    Set<String>? resendingIds,
    String? errorMessage,
    String? successMessage,
    bool? needsRefresh,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return MeetingInviteState(
      members: members ?? this.members,
      loadingMembers: loadingMembers ?? this.loadingMembers,
      invitations: invitations ?? this.invitations,
      loadingInvitations: loadingInvitations ?? this.loadingInvitations,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      resendingIds: resendingIds ?? this.resendingIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      needsRefresh: needsRefresh ?? this.needsRefresh,
    );
  }

  @override
  List<Object?> get props => [
        members,
        loadingMembers,
        invitations,
        loadingInvitations,
        isSubmitting,
        resendingIds,
        errorMessage,
        successMessage,
        needsRefresh,
      ];
}
