import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/screens/resetPasswordSuccessfully_Screen.dart';
import 'package:requra/theme/color_manager.dart';

import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_auth_buttons_row.dart';

class CreateNewpasswordScreen extends StatefulWidget {
  const CreateNewpasswordScreen({super.key});

  @override
  State<CreateNewpasswordScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<CreateNewpasswordScreen> {
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
              title: 'Create a new password',
              subtitle: '',
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h,horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomTextField(
                    hintText: 'New Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  SizedBox(height: 14.h),
                  const CustomTextField(
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  SizedBox(height: 14.h),
                  CustomButton(
                    text: 'Update Password',
                    onTap: () {
                      // controller then check new == confirm PSWD
                      Navigator.pushNamed(context, "/resetPasswordSuccessfully");
                          },
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
