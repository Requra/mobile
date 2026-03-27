import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/style_manager.dart';

import '../theme/font_manager.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_auth_buttons_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = true;

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
                  const CustomTextField(
                    hintText: 'Email Address',
                    icon: Icons.mail_outline,
                  ),
                  SizedBox(height: 14.h),
                  const CustomTextField(
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
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
                    text: 'Login',
                    onTap: () {},
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
