import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/core/storage/secure_token_storage.dart';
import 'package:requra/features/meeting/domain/usecases/get_meeting_invitations_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/get_project_members_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/invite_guests_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/invite_participants_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/resend_invitation_usecase.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_invite_state.dart';

class MeetingInviteCubit extends Cubit<MeetingInviteState> {
  final GetProjectMembersUseCase _getProjectMembers;
  final GetMeetingInvitationsUseCase _getMeetingInvitations;
  final InviteParticipantsUseCase _inviteParticipants;
  final InviteGuestsUseCase _inviteGuests;
  final ResendInvitationUseCase _resendInvitation;

  MeetingInviteCubit({
    required GetProjectMembersUseCase getProjectMembersUseCase,
    required GetMeetingInvitationsUseCase getMeetingInvitationsUseCase,
    required InviteParticipantsUseCase inviteParticipantsUseCase,
    required InviteGuestsUseCase inviteGuestsUseCase,
    required ResendInvitationUseCase resendInvitationUseCase,
  })  : _getProjectMembers = getProjectMembersUseCase,
        _getMeetingInvitations = getMeetingInvitationsUseCase,
        _inviteParticipants = inviteParticipantsUseCase,
        _inviteGuests = inviteGuestsUseCase,
        _resendInvitation = resendInvitationUseCase,
        super(const MeetingInviteState());

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
  
  void markNeedsRefresh(bool needsRefresh) {
    emit(state.copyWith(needsRefresh: needsRefresh));
  }

  Future<void> loadMembers(String projectId) async {
    emit(state.copyWith(loadingMembers: true, clearError: true, clearSuccess: true));
    final result = await _getProjectMembers(projectId);
    final tokenStorage = const SecureTokenStorage();
    final currentUserId = await tokenStorage.readUserId();

    result.fold(
      (failure) => emit(state.copyWith(loadingMembers: false, errorMessage: failure.message)),
      (members) {
        final filteredMembers = members.where((m) => m.id != currentUserId).toList();
        emit(state.copyWith(loadingMembers: false, members: filteredMembers));
      },
    );
  }

  Future<void> loadInvitations(String meetingId) async {
    emit(state.copyWith(loadingInvitations: true, clearError: true, clearSuccess: true));
    final result = await _getMeetingInvitations(meetingId);

    result.fold(
      (failure) => emit(state.copyWith(loadingInvitations: false, errorMessage: failure.message)),
      (invitations) => emit(state.copyWith(loadingInvitations: false, invitations: invitations)),
    );
  }

  Future<void> inviteParticipant(String meetingId, String memberId, String role) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    
    final membersList = [
      {'memberId': memberId, 'role': role}
    ];
    
    final result = await _inviteParticipants(meetingId, membersList);

    result.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        isSubmitting: false, 
        successMessage: 'Invitation sent!', 
        needsRefresh: true
      )),
    );
  }

  Future<void> inviteGuest(String meetingId, String name, String email) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    
    final guestsList = [
      {'displayName': name, 'email': email}
    ];

    final result = await _inviteGuests(meetingId, guestsList);

    result.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        isSubmitting: false, 
        successMessage: 'Guest invited successfully!', 
        needsRefresh: true
      )),
    );
  }

  Future<void> resendInvitation(String meetingId, String invitationId, String displayName) async {
    final newResendingIds = Set<String>.from(state.resendingIds)..add(invitationId);
    emit(state.copyWith(resendingIds: newResendingIds, clearError: true, clearSuccess: true));
    
    final result = await _resendInvitation(meetingId, invitationId);

    final updatedResendingIds = Set<String>.from(state.resendingIds)..remove(invitationId);
    
    result.fold(
      (failure) => emit(state.copyWith(resendingIds: updatedResendingIds, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        resendingIds: updatedResendingIds, 
        successMessage: 'Invitation resent to $displayName',
      )),
    );
  }
}
