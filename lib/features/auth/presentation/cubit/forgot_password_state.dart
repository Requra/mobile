import 'package:equatable/equatable.dart';

/// Base class for all ForgotPasswordCubit states.
abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

/// No operation has been started yet.
class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

/// A network call is in flight.
class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

/// Reset code was sent successfully; the user must enter the OTP.
/// [email] is passed forward so VerificationScreen can resend to the same address.
class ForgotPasswordOtpSent extends ForgotPasswordState {
  const ForgotPasswordOtpSent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// OTP was verified successfully; the user may now set a new password.
/// [email] and [code] are kept so the reset-password endpoint can use them.
class ForgotPasswordOtpVerified extends ForgotPasswordState {
  const ForgotPasswordOtpVerified({required this.email, required this.code});

  final String email;
  final String code;

  @override
  List<Object?> get props => [email, code];
}

/// Password was reset successfully.
class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess();
}

/// An operation failed; [message] is shown to the user.
class ForgotPasswordError extends ForgotPasswordState {
  const ForgotPasswordError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
