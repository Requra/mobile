import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/style_manager.dart';

import '../../theme/font_manager.dart';
import 'forgot_password_screen.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_auth_buttons_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );
  bool rememberMe = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = const AuthService();
  final RegExp _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    return null;
  }

  void _onEmailChanged(String value) {
    setState(() {
      _emailError = _validateEmail(value);
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordError = _validatePassword(value);
    });
  }

  bool _validateForm() {
    final String? emailError = _validateEmail(_emailController.text);
    final String? passwordError = _validatePassword(_passwordController.text);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    return emailError == null && passwordError == null;
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

  Future<void> _handleLogin() async {
    if (_isLoading) {
      return;
    }

    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
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

      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );
  }

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
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
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      debugPrint('Google idToken length: ${idToken?.length ?? 0}');

      if (idToken == null || idToken.trim().isEmpty) {
        debugPrint('Google sign-in failed: idToken is null or empty.');
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in failed. Please try again.')),
        );
        return;
      }

      _logJwtClaims(idToken);

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
        _isLoading = false;
      });

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
        return;
      }

      debugPrint('Google login failed: ${response.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kDebugMode && response.message.trim().isNotEmpty
                ? response.message
                : 'Google sign-in failed. Please try again.',
          ),
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Google sign-in PlatformException: ${e.code} ${e.message}');
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
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
        _isLoading = false;
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
              title: 'Welcome Back to Requra.ai',
              subtitle: 'Sign in to access your AI-powered requirements workspace.',
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h , horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    errorText: _passwordError,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        visualDensity: VisualDensity.compact,
                        activeColor: AppColors.primaryText,
                        onChanged: (value) {
                          // Handle remember me toggle
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      Text('Remember me' , style: regularStyle(fontSize: FontSize.font16, color: AppColors.black),),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot your password?',
                            style: regularStyle(fontSize: FontSize.font16, color: AppColors.primaryText).copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  CustomButton(
                    text: _isLoading ? 'Loading...' : 'Login',
                    onTap: _handleLogin,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('New here? ' , style: regularStyle(fontSize: FontSize.font14, color: AppColors.black)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/signup");
                              },
                        child:  Text(
                          'Create an account',
                            style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.primaryText).copyWith(decoration: TextDecoration.underline)
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SocialAuthButtonsRow(
                    onGoogleTap: _handleGoogleLogin,
                    isGoogleLoading: _isLoading,
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
