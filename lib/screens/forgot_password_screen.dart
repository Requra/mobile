import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/screens/verification_screen.dart';
import 'package:requra/theme/color_manager.dart';

import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Forgot Your Password?',
              subtitle: 'Enter your email and we’ll send you a verification code to reset your password.',
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical:20.h , horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8.h),
                  const CustomTextField(
                    hintText: 'Email Address',
                    icon: Icons.mail_outline,
                  ),
                  SizedBox(height: 24.h),
                  CustomButton(
                    text: 'Send Code',
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => const VerificationScreen(),
                    ),),
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context , "/login"),
                      child: const Text('Back to Login'),
                    ),
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
