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
  }) : _authService = authService,
       _googleSignIn = googleSignIn,
       super(const AuthInitial());

  final AuthService _authService;
  final GoogleSignIn _googleSignIn;
  static const SecureTokenStorage _tokenStorage = SecureTokenStorage();

  /// Stored credentials for auto-login after email confirmation.
  String? _pendingEmail;
  String? _pendingPassword;

  // ---------------------------------------------------------------------------
  // Token check — called by SplashScreen after its animation completes.
  // ---------------------------------------------------------------------------

  /// Checks whether a valid access token is stored and validates it
  /// by attempting a token refresh. Emits [AuthAuthenticated] if valid,
  /// or [AuthUnauthenticated] if missing / expired / invalid.
  Future<void> appStarted() async {
    final String? token = await _tokenStorage.readAccessToken();
    if (token == null || token.trim().isEmpty) {
      emit(const AuthUnauthenticated());
      return;
    }

    final String? refreshToken = await _tokenStorage.readRefreshToken();

    // If there is no refresh token (e.g., from Google Login), try validating
    // the session with a profile request instead.
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      final profileResponse = await _authService.getProfile();
      // If unauthorized, the token is dead. Otherwise (success or offline), keep them logged in.
      if (profileResponse.statusCode == 401) {
        await _tokenStorage.clearTokens();
        emit(const AuthUnauthenticated());
      } else {
        emit(const AuthAuthenticated());
      }
      return;
    }

    // Validate the session by refreshing the token.
    final refreshResponse = await _authService.refreshAuthToken();
    
    if (refreshResponse.isSuccess) {
      emit(const AuthAuthenticated());
    } else if (refreshResponse.statusCode == 401 || refreshResponse.statusCode == 400) {
      // Token is stale or invalid — clear and go to login.
      await _tokenStorage.clearTokens();
      emit(const AuthUnauthenticated());
    } else {
      // Network error or 500 server error — assume valid to allow offline access/retry.
      emit(const AuthAuthenticated());
    }
  }

  // ---------------------------------------------------------------------------
  // Email / password login
  // ---------------------------------------------------------------------------

  Future<void> login({required String email, required String password}) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());

    final response = await _authService.login(
      email: email.trim(),
      password: password,
    );

    if (response.isSuccess) {
      _pendingEmail = null;
      _pendingPassword = null;
      emit(const AuthAuthenticated());
    } else {
      // If the server says the account is unconfirmed, redirect to OTP.
      final String msg = response.message.toLowerCase();
      if (msg.contains('confirm') && msg.contains('email')) {
        _pendingEmail = email.trim();
        _pendingPassword = password;

        // Send a fresh confirmation OTP so the user gets a code immediately.
        await _authService.resendOtp(
          email: email.trim(),
          purpose: 'EmailConfirmation',
        );

        emit(AuthVerificationRequired(email.trim()));
      } else {
        emit(AuthError(response.message));
      }
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
    required String role,
  }) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());

    final response = await _authService.signup(
      fullName: fullName.trim(),
      email: email.trim(),
      password: password,
      confirmPassword: confirmPassword,
      role: role,
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
    required String code,
  }) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());

    final response = await _authService.confirmAccount(
      email: email.trim(),
      code: code.trim(),
    );

    if (response.isSuccess) {
      // If we have stored login credentials (user came from login flow),
      // auto-login instead of going back to the login screen.
      if (_pendingEmail != null && _pendingPassword != null) {
        final loginResponse = await _authService.login(
          email: _pendingEmail!,
          password: _pendingPassword!,
        );
        _pendingEmail = null;
        _pendingPassword = null;
        if (loginResponse.isSuccess) {
          emit(const AuthAuthenticated());
        } else {
          // Login failed after confirmation — send to login screen.
          emit(const AuthUnauthenticated());
        }
      } else {
        // Came from signup flow — user should log in manually.
        emit(const AuthUnauthenticated());
      }
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
      purpose: 'EmailConfirmation',
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
        emit(const AuthError('Google sign-in failed: idToken is missing.'));
        return;
      }

      // Debug-only JWT claims log — never exposed to the UI.
      _logJwtClaims(idToken);

      final response = await _authService.googleLogin(idToken: idToken);

      final userData = response.userData;
      if (userData != null) {
        debugPrint('Google login isNewUser: ${userData.isNewUser}');
        debugPrint(
          'Google login refreshToken length: ${userData.refreshToken}',
        );
        debugPrint('Google login tokenExpiry: ${userData.tokenExpiry}');
      } else {
        debugPrint('Google login raw data: ${response.data}');
      }

      if (response.isSuccess) {
        if (userData != null && userData.isNewUser) {
          emit(const AuthNewUserRoleSelectionRequired());
        } else {
          emit(const AuthAuthenticated());
        }
      } else {
        final String errorMsg = response.message.trim().isNotEmpty
            ? 'Backend error: ${response.message}'
            : 'Google sign-in failed: Backend returned false without message.';
        emit(AuthError(errorMsg));
      }
    } on PlatformException catch (e) {
      debugPrint('Google sign-in PlatformException: ${e.code} ${e.message}');
      emit(
        AuthError(
          'Google sign-in PlatformException: ${e.code}. Check SHA-1/Google-Services.',
        ),
      );
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      emit(AuthError('Google sign-in Error: $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // Change Role (For new Google users)
  // ---------------------------------------------------------------------------

  Future<void> changeRole(String role) async {
    if (state is AuthLoading) return;
    // We don't emit AuthLoading to keep the UI simple if needed, 
    // but usually it's good to emit it.
    emit(const AuthLoading());

    final response = await _authService.changeRole(role: role);
    if (response.isSuccess) {
      // Role successfully updated, user can now enter the app
      emit(const AuthAuthenticated());
    } else {
      emit(AuthError(response.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    // Always clear local tokens and navigate to login, regardless of
    // whether the server-side logout succeeds (avoids "user not found").
    try {
      await _authService.logout();
    } catch (_) {
      // Ignore server errors — the important thing is clearing local state.
    }
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
