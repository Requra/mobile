import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:requra/core/storage/secure_token_storage.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';
import 'package:requra/features/auth/presentation/cubit/auth_state.dart';

export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthService authService,
    required GoogleSignIn googleSignIn,
  })  : _authService = authService,
        _googleSignIn = googleSignIn,
        super(const AuthInitial());

  final AuthService _authService;
  final GoogleSignIn _googleSignIn;
  static const SecureTokenStorage _tokenStorage = SecureTokenStorage();

  // ---------------------------------------------------------------------------
  // Token check — called by SplashScreen after its animation completes.
  // ---------------------------------------------------------------------------

  /// Checks whether a valid access token is stored and emits
  /// [AuthAuthenticated] or [AuthUnauthenticated] accordingly.
  Future<void> appStarted() async {
    final String? token = await _tokenStorage.readAccessToken();
    if (token != null && token.trim().isNotEmpty) {
      emit(const AuthAuthenticated());
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  // ---------------------------------------------------------------------------
  // Email / password login
  // ---------------------------------------------------------------------------

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());

    final response = await _authService.login(
      email: email.trim(),
      password: password,
    );

    if (response.isSuccess) {
      emit(const AuthAuthenticated());
    } else {
      emit(AuthError(response.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Registration
  // ---------------------------------------------------------------------------

  Future<void> signup({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());

    final response = await _authService.signup(
      fullName: fullName.trim(),
      email: email.trim(),
      password: password,
      confirmPassword: confirmPassword,
    );

    if (response.isSuccess) {
      emit(AuthVerificationRequired(email.trim()));
    } else {
      emit(AuthError(response.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Signup OTP confirmation
  // ---------------------------------------------------------------------------

  /// Confirms a newly registered account using the OTP sent to [email].
  /// On success emits [AuthUnauthenticated] so the screen navigates to Login.
  Future<void> confirmAccount({
    required String email,
    required String otpCode,
  }) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());

    final response = await _authService.confirmAccount(
      email: email.trim(),
      otpCode: otpCode.trim(),
    );

    if (response.isSuccess) {
      // Account confirmed — user should now log in.
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthError(response.message));
    }
  }

  /// Resends the signup confirmation OTP for [email].
  /// Does **not** emit a new cubit state — the cooldown countdown is purely
  /// a UI concern managed locally by VerificationScreen.
  /// Returns the server response message for the snackbar.
  Future<String> resendConfirmationOtp({required String email}) async {
    final response = await _authService.resendOtp(
      email: email.trim(),
      otpType: 0, // 0 = account confirmation
    );
    return response.message;
  }

  // ---------------------------------------------------------------------------
  // Google sign-in (shared by LoginScreen and SignupScreen)
  // ---------------------------------------------------------------------------

  Future<void> loginWithGoogle() async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());

    try {
      // Always show the account picker by clearing any cached session.
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      debugPrint('Google account selected: ${account?.email ?? 'null'}');

      // User tapped cancel — stay on the current screen.
      if (account == null) {
        debugPrint('Google sign-in canceled by user.');
        emit(const AuthUnauthenticated());
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      debugPrint('Google idToken length: ${idToken?.length ?? 0}');

      if (idToken == null || idToken.trim().isEmpty) {
        debugPrint('Google sign-in failed: idToken is null or empty.');
        emit(const AuthError('Google sign-in failed. Please try again.'));
        return;
      }

      // Debug-only JWT claims log — never exposed to the UI.
      _logJwtClaims(idToken);

      final response = await _authService.googleLogin(idToken: idToken);

      debugPrint(
        'Google login response: isSuccess=${response.isSuccess}, '
        'statusCode=${response.statusCode}, message=${response.message}',
      );

      if (response.isSuccess) {
        emit(const AuthAuthenticated());
      } else {
        final String errorMsg = kDebugMode && response.message.trim().isNotEmpty
            ? response.message
            : 'Google sign-in failed. Please try again.';
        emit(AuthError(errorMsg));
      }
    } on PlatformException catch (e) {
      debugPrint('Google sign-in PlatformException: ${e.code} ${e.message}');
      emit(const AuthError('Google sign-in failed. Please try again.'));
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      emit(const AuthError('Google sign-in failed. Please try again.'));
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    await _authService.clearSessionTokens();
    emit(const AuthUnauthenticated());
  }

  // ---------------------------------------------------------------------------
  // Private helpers — never called from any UI file.
  // ---------------------------------------------------------------------------

  /// Decodes a JWT payload segment for debug logging only.
  Map<String, dynamic>? _decodeJwtPayload(String token) {
    final List<String> parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final String payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final dynamic decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Prints Google ID-token claims in debug mode.
  void _logJwtClaims(String token) {
    if (!kDebugMode) return;
    final Map<String, dynamic>? payload = _decodeJwtPayload(token);
    if (payload == null) {
      debugPrint('Google idToken claims: <unreadable>');
      return;
    }
    debugPrint(
      'Google idToken claims: email=${payload['email']} '
      'sub=${payload['sub']} aud=${payload['aud']} azp=${payload['azp']}',
    );
  }
}
