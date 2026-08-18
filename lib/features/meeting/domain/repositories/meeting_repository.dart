import 'package:dartz/dartz.dart';
import 'package:requra/core/errors/failures.dart';
import 'package:requra/features/meeting/data/models/meeting_models.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';

abstract class MeetingRepository {
  Future<Either<Failure, Meeting>> getMeetingDetails(String meetingId);
  Future<Either<Failure, List<Meeting>>> getProjectMeetings(String projectId);
  Future<Either<Failure, Meeting>> createMeeting(String projectId, Map<String, dynamic> data);
  Future<Either<Failure, Meeting>> updateMeeting(String meetingId, Map<String, dynamic> data);
  Future<Either<Failure, Meeting>> cancelMeeting(String meetingId);
  Future<Either<Failure, Meeting>> startMeeting(String meetingId);
  Future<Either<Failure, Meeting>> endMeeting(String meetingId);

  // Invite API
  Future<Either<Failure, List<ProjectMember>>> getProjectMembers(String projectId);
  Future<Either<Failure, List<MeetingInvitation>>> getMeetingInvitations(String meetingId);
  Future<Either<Failure, void>> inviteParticipants(String meetingId, List<Map<String, String>> members, {String platform = 'Mobile'});
  Future<Either<Failure, void>> inviteGuests(String meetingId, List<Map<String, String>> guests, {String platform = 'Mobile'});
  Future<Either<Failure, void>> resendInvitation(String meetingId, String invitationId, {String platform = 'Mobile'});
}
