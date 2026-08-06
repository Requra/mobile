import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';
import 'package:requra/features/auth/presentation/cubit/forgot_password_state.dart';

export 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required AuthService authService})
      : _authService = authService,
        super(const ForgotPasswordInitial());

  final AuthService _authService;

  /// Email entered in the forgot-password step, carried forward across the flow.
  String _email = '';

  /// OTP code verified in step 2, forwarded to the reset-password call.
  String _code = '';

  // ---------------------------------------------------------------------------
  // Step 1 — Send reset-code email
  // ---------------------------------------------------------------------------

  /// Calls the forgot-password endpoint and emits [ForgotPasswordOtpSent]
  /// with the email so VerificationScreen can resend to the correct address.
  Future<void> sendResetCode({required String email}) async {
    if (state is ForgotPasswordLoading) return;
    emit(const ForgotPasswordLoading());

    _email = email.trim();
    final response = await _authService.forgotPassword(email: _email);

    if (response.isSuccess) {
      emit(ForgotPasswordOtpSent(_email));
    } else {
      emit(ForgotPasswordError(response.firstError.isNotEmpty
          ? response.firstError
          : response.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Step 2 — Verify OTP entered by the user
  // ---------------------------------------------------------------------------

  /// Calls the verify-OTP endpoint.  On success, emits [ForgotPasswordOtpVerified]
  /// so CreateNewPasswordScreen knows it may proceed.
  Future<void> verifyResetOtp({required String code}) async {
    if (state is ForgotPasswordLoading) return;
    emit(const ForgotPasswordLoading());

    final String trimmedCode = code.trim();
    final response = await _authService.verifyOtp(
      email: _email,
      code: trimmedCode,
    );

    if (response.isSuccess) {
      _code = trimmedCode;
      emit(ForgotPasswordOtpVerified(email: _email, code: trimmedCode));
    } else {
      emit(ForgotPasswordError(response.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Step 3 — Submit new password
  // ---------------------------------------------------------------------------

  /// Calls the reset-password endpoint.  On success emits [ForgotPasswordSuccess].
  Future<void> resetPassword({
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (state is ForgotPasswordLoading) return;
    emit(const ForgotPasswordLoading());

    final response = await _authService.resetPassword(
      email: _email,
      code: _code,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    if (response.isSuccess) {
      emit(const ForgotPasswordSuccess());
    } else {
      emit(ForgotPasswordError(response.firstError.isNotEmpty
          ? response.firstError
          : response.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Resend OTP (called from VerificationScreen — pure network, no state change)
  // ---------------------------------------------------------------------------

  /// Resends the password-reset OTP for [email].
  /// Does **not** emit a new cubit state — the cooldown timer is pure UI state
  /// managed locally by VerificationScreen.  Returns the response message.
  Future<String> resendResetOtp({required String email}) async {
    final response = await _authService.resendOtp(
      email: email.trim(),
      purpose: 'PasswordReset',
    );
    return response.message;
  }
}
