class ApiConstants {
  ApiConstants._();

  //   static const String baseUrl = 'https://requra-ai.runasp.net';
  static const String baseUrl =
      'https://mock.apidog.com/m1/1212435-1208182-default';

  static const String login = '/api/Auth/login';
  static const String signup = '/api/Auth/register';
  static const String forgotPassword = '/api/Auth/password/forgot';
  static const String verifyOtp = '/api/Auth/password/verifyotp';
  static const String resetPassword = '/api/Auth/password/reset';
  static const String changePassword = '/api/profile/change-password';
  static const String uploadAvatar = '/api/profile/avatar';
  static const String updateProfile = '/api/profile';
  static const String deleteAccount = '/api/account';
  static const String refreshToken = '/api/Auth/refresh-token';
  static const String googleLogin = '/api/Auth/google-login';
  static const String confirmAccount = '/api/Auth/confirm-account';
  static const String resendOtp = '/api/Auth/otp/resend';

  // ── Meeting (v1 API) ──
  static const String meetingsBase =
      'https://mock.apidog.com/m1/1212435-1208182-1270861/api';
}
