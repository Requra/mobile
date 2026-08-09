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

  // ── Meeting (v1 API) ──
  static const String meetingsBase =
      'https://mock.apidog.com/m1/1212435-1208182-1270861/api';

  // ── Meetings (real API) ──
  static const String meetings =
      'https://requra-ai.runasp.net/api/Meetings';

  // ── Projects ──
  static const String projects = 'https://requra-ai.runasp.net/api/projects';

  static String projectById(String id) =>
      'https://requra-ai.runasp.net/api/Projects/$id';

  static String projectMembers(String id) =>
      'https://requra-ai.runasp.net/api/projects/$id/members';

  static const String documents = 'https://requra-ai.runasp.net/api/Documents';

  static String aiResultsDashboard(String projectId) =>
      '/api/projects/$projectId/ai/results-dashboard';
  //   'https://requra-ai.runasp.net/api/projects/$projectId/ai/results-dashboard';
}
