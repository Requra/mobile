import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool rememberMe = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = const AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) {
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
                  ),
                  SizedBox(height: 14.h),
                  CustomTextField(
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
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
                  const SocialAuthButtonsRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
