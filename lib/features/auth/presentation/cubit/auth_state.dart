import 'package:equatable/equatable.dart';

/// Base class for all AuthCubit states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any token check has been performed.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A network call (login / signup / Google sign-in) is in flight.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// A valid access token exists — the user is signed in.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

/// No valid token found — the user must sign in.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Signup succeeded; the user must verify their email before proceeding.
class AuthVerificationRequired extends AuthState {
  const AuthVerificationRequired(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// An auth operation failed; [message] is shown to the user.
class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
