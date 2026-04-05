class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://mock.apidog.com/m1/1212435-1208182-default';

  static const String login =
      '/api/Auth/login';
  static const String signup =
      '/api/Auth/register';
  static const String forgotPassword =
      '/api/Auth/password/forgot';
  static const String verifyOtp =
      '/api/Auth/password/verifyotp';
  static const String resetPassword =
      '/api/Auth/password/reset';
  static const String googleLogin = 'https://mock.apidog.com/m1/1240855-1237660-default/auth/google';
  static const String confirmAccount =
      '/api/Auth/confirm-account';
  static const String resendOtp =
      '/api/Auth/otp/resend';
}
