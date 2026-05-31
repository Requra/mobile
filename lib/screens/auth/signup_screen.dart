import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

import 'verification_screen.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_auth_buttons_row.dart';
import '../../widgets/password_rules_checklist.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = const AuthService();
  final RegExp _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _passwordTypingStarted = false;
  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String value) {
    if (value.trim().isEmpty) {
      return 'Full name is required';
    }
    return null;
  }

  String? _validateEmail(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Use format like: name@example.com';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }

    if (!PasswordRules.isValid(value)) {
      return 'Password must meet all requirements below';
    }

    return null;
  }

  String? _validateConfirmPassword(String confirmPassword, String password) {
    if (confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }

    if (confirmPassword != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _onFullNameChanged(String value) {
    setState(() {
      _fullNameError = _validateFullName(value);
    });
  }

  void _onEmailChanged(String value) {
    setState(() {
      _emailError = _validateEmail(value);
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      if (value.isNotEmpty) {
        _passwordTypingStarted = true;
      }

      _passwordError = _validatePassword(value);
      _confirmPasswordError = _validateConfirmPassword(
        _confirmPasswordController.text,
        value,
      );
    });
  }

  void _onConfirmPasswordChanged(String value) {
    setState(() {
      _confirmPasswordError = _validateConfirmPassword(
        value,
        _passwordController.text,
      );
    });
  }

  bool _validateForm() {
    final String? fullNameError = _validateFullName(_fullNameController.text);
    final String? emailError = _validateEmail(_emailController.text);
    final String? passwordError = _validatePassword(_passwordController.text);
    final String? confirmPasswordError = _validateConfirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
    );

    setState(() {
      _fullNameError = fullNameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return fullNameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    final List<String> parts = token.split('.');
    if (parts.length < 2) {
      return null;
    }

    try {
      final String payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final dynamic decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  void _logJwtClaims(String token) {
    if (!kDebugMode) {
      return;
    }

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

  Future<void> _handleSignup() async {
    if (_isLoading || _isGoogleLoading) {
      return;
    }

    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _authService.signup(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => VerificationScreen(
            source: VerificationSource.signup,
            email: _emailController.text.trim(),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );
  }

  Future<void> _handleGoogleSignup() async {
    if (_isGoogleLoading || _isLoading) {
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      // Force account picker on every tap by clearing the previous session.
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      debugPrint('Google account selected: ${account?.email ?? 'null'}');

      // User canceled Google sign-in.
      if (account == null) {
        debugPrint('Google sign-in canceled by user.');
        if (!mounted) {
          return;
        }

        setState(() {
          _isGoogleLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      // debugPrint('Google idToken : ${idToken}');
      // debugPrint('Google idToken length: ${idToken?.length ?? 0}');

      if (idToken == null || idToken.trim().isEmpty) {
        debugPrint('Google sign-in failed: idToken is null or empty.');
        if (!mounted) {
          return;
        }

        setState(() {
          _isGoogleLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in failed. Please try again.')),
        );
        return;
      }

      _logJwtClaims(idToken);

      // Use the same endpoint as login for Google auth.
      final response = await _authService.googleLogin(idToken: idToken);

      debugPrint(
        'Google login response: isSuccess=${response.isSuccess}, '
        'statusCode=${response.statusCode}, message=${response.message}, '
        'data=${response.data}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isGoogleLoading = false;
      });

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        return;
      }

      debugPrint('Google login failed: ${response.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed. Please try again.')),
      );
    } on PlatformException catch (e) {
      debugPrint('Google sign-in PlatformException: ${e.code} ${e.message}');
      if (!mounted) {
        return;
      }

      setState(() {
        _isGoogleLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed. Please try again.')),
      );
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      if (!mounted) {
        return;
      }

      setState(() {
        _isGoogleLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Create your Requra.ai account',
              subtitle: 'Start generating requirements from meetings and documents using AI.',
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    hintText: 'Full Name',
                    icon: Icons.person_outline,
                    controller: _fullNameController,
                    onChanged: _onFullNameChanged,
                    errorText: _fullNameError,
                  ),
                  SizedBox(height: 14.h),
                  CustomTextField(
                    hintText: 'Email Address',
                    icon: Icons.mail_outline,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: _onEmailChanged,
                    errorText: _emailError,
                  ),
                  SizedBox(height: 14.h),
                  CustomTextField(
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    onChanged: _onPasswordChanged,
                    errorText: _passwordTypingStarted ? _passwordError : null,
                  ),
                  if (_passwordTypingStarted) ...[
                    SizedBox(height: 8.h),
                    PasswordRulesChecklist(password: _passwordController.text),
                  ],
                  SizedBox(height: 14.h),
                  CustomTextField(
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _confirmPasswordController,
                    onChanged: _onConfirmPasswordChanged,
                    errorText: _confirmPasswordError,
                  ),
                  SizedBox(height: 22.h),
                  CustomButton(
                    text: _isLoading ? 'Creating...' : 'Create Account',
                    onTap: _handleSignup,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ' , style: regularStyle(fontSize: FontSize.font12, color: AppColors.black)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Back to Login' , style: regularStyle(fontSize: FontSize.font12, color: AppColors.primaryText)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SocialAuthButtonsRow(
                    onGoogleTap: _handleGoogleSignup,
                    isGoogleLoading: _isGoogleLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
