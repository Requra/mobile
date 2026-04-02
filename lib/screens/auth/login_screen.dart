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

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.firstError)),
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
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      // User canceled Google sign-in.
      if (account == null) {
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

      if (idToken == null || idToken.trim().isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get Google id token.')),
        );
        return;
      }

      final response = await _authService.googleLogin(idToken: idToken);

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
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.firstError)),
      );
    } on PlatformException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      final String message = e.code == 'sign_in_failed'
          ? 'Google Sign-In configuration error (ApiException 10). Check SHA-1 and OAuth client setup.'
          : 'Google sign-in failed. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
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
