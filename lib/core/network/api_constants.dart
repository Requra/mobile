class ApiConstants {
  ApiConstants._();

  //   static const String baseUrl = 'https://requra-ai.runasp.net';
  static const String baseUrl =
      'https://mock.apidog.com/m1/1212435-1208182-default';

  static const String login = 'https://requra-ai.runasp.net/api/Auth/login';
  static const String signup = 'https://requra-ai.runasp.net/api/Auth/register';
  static const String forgotPassword =
      'https://requra-ai.runasp.net/api/Auth/password/forgot';
  static const String verifyOtp =
      'https://requra-ai.runasp.net/api/Auth/password/verifyotp';
  static const String resetPassword =
      'https://requra-ai.runasp.net/api/Auth/password/reset';
  static const String changePassword =
      'https://requra-ai.runasp.net/api/profile/change-password';
  static const String uploadAvatar =
      'https://requra-ai.runasp.net/api/profile/avatar';
  static const String updateProfile =
      'https://requra-ai.runasp.net/api/profile';
  static const String deleteAccount =
      'https://requra-ai.runasp.net/api/profile';
  static const String refreshToken =
      'https://requra-ai.runasp.net/api/Auth/refresh-token';
  static const String googleLogin =
      'https://requra-ai.runasp.net/api/Auth/google-login';
  static const String confirmAccount =
      'https://requra-ai.runasp.net/api/Auth/confirm-account';
  static const String resendOtp =
      'https://requra-ai.runasp.net/api/Auth/otp/resend';
  static const String logout = 'https://requra-ai.runasp.net/api/Auth/logout';

  // ── Meeting (v1 mock API — kept for backward compatibility) ──
  static const String meetingsBase = 'https://requra-ai.runasp.net/api';

  // ── Meetings (real API base) ──
  static const String realMeetingsBase = 'https://requra-ai.runasp.net/api';

  static const String meetings = 'https://requra-ai.runasp.net/api/Meetings';

  // ── Meeting endpoint helpers (real API) ──

  /// GET /api/meetings/{meetingId}
  static String meetingDetails(String meetingId) =>
      '$realMeetingsBase/meetings/$meetingId';

  /// POST /api/meetings/{meetingId}/agora-token
  static String agoraToken(String meetingId) =>
      '$realMeetingsBase/meetings/$meetingId/agora-token';

  /// POST /api/meetings/{meetingId}/join
  static String joinMeeting(String meetingId) =>
      '$realMeetingsBase/meetings/$meetingId/join';

  /// POST /api/meetings/{meetingId}/leave
  static String leaveMeeting(String meetingId) =>
      '$realMeetingsBase/meetings/$meetingId/leave';

  /// POST /api/meetings/{meetingId}/end
  static String endMeeting(String meetingId) =>
      '$realMeetingsBase/meetings/$meetingId/end';

  /// GET /api/meetings/{meetingId}/participants
  static String meetingParticipants(String meetingId) =>
      '$realMeetingsBase/meetings/$meetingId/participants';

  /// POST /api/meetings/{meetingId}/participants/{participantId}/consent
  static String participantConsent(String meetingId, String participantId) =>
      '$realMeetingsBase/meetings/$meetingId/participants/$participantId/consent';

  /// POST /api/meetings/{meetingId}/recordings/start
  static String startRecording(String meetingId) =>
      '$realMeetingsBase/meetings/$meetingId/recordings/start';

  /// POST /api/recordings/{recordingId}/stop
  static String stopRecording(String recordingId) =>
      '$realMeetingsBase/recordings/$recordingId/stop';

  /// GET /api/recordings/{recordingId}
  static String getRecording(String recordingId) =>
      '$realMeetingsBase/recordings/$recordingId';

  /// POST /api/recordings/{recordingId}/chunks
  static String uploadChunk(String recordingId) =>
      '$realMeetingsBase/recordings/$recordingId/chunks';

  // ── Projects ──
  static const String projects = 'https://requra-ai.runasp.net/api/projects';

  static String projectById(String id) =>
      'https://requra-ai.runasp.net/api/Projects/$id';

  static String projectMembers(String id) =>
      'https://requra-ai.runasp.net/api/projects/$id/members';

  static const String documents = 'http://192.168.100.12:5099/api/Documents';

  static String aiResultsDashboard(String projectId) =>
      'http://192.168.100.12:5099/api/projects/$projectId/ai/results-dashboard';

  static String startAiRun(String projectId) =>
      'http://192.168.100.12:5099/api/projects/$projectId/ai/runs';

  static String getAiRunProgress(String projectId, String runId) =>
      'http://192.168.100.12:5099/api/projects/$projectId/ai/runs/$runId';

  static String feedback(String projectId) =>
      'https://requra-ai.runasp.net/api/project-review/$projectId/feedback';

  static String resolveFeedback(String projectId, String feedbackId) =>
      'https://requra-ai.runasp.net/api/project-review/$projectId/feedback/$feedbackId';

  // ── Review Invitations ──
  static String reviewInvitations(String projectId) =>
      '/api/projects/$projectId/review-invitations';

  static String resendInvitation(String projectId, String invitationId) =>
      '/api/projects/$projectId/review-invitations/$invitationId/resend';

  // ── Requirements ──
  static String requirementStatus(String projectId, String requirementId) =>
      '/api/projects/$projectId/requirements/$requirementId/status';

  static String requirementById(String projectId, String requirementId) =>
      '/api/projects/$projectId/requirements/$requirementId';

  // ── User Stories ──
  static String userStoryStatus(String projectId, String storyId) =>
      '/api/projects/$projectId/user-stories/$storyId/status';

  static String userStoryById(String projectId, String storyId) =>
      '/api/projects/$projectId/user-stories/$storyId';

  static String userStoryRegenerate(String projectId, String storyId) =>
      '/api/projects/$projectId/user-stories/$storyId/regenerate';
}
