import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_auth_buttons_row.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
                  const CustomTextField(
                    hintText: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 14.h),
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
                  SizedBox(height: 14.h),
                  const CustomTextField(
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  SizedBox(height: 22.h),
                  CustomButton(
                    text: 'Create Account',
                    onTap: () {},
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
