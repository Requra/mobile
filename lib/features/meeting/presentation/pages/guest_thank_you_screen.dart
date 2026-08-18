import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class GuestThankYouScreen extends StatelessWidget {
  const GuestThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              
              // Icon
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                  size: 80.sp,
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Title
              Text(
                'Thank you for joining!',
                style: boldStyle(fontSize: FontSize.font24, color: AppColors.black),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16.h),
              
              // Subtitle
              Text(
                'You have successfully left the meeting.\nDid you enjoy the experience? Create an account to host your own meetings and manage projects.',
                style: regularStyle(fontSize: FontSize.font14, color: AppColors.darkgrey),
                textAlign: TextAlign.center,
              ),
              
              Spacer(),
              
              // Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to onboarding/login
                        Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Log In or Sign Up',
                        style: semiBoldStyle(fontSize: FontSize.font16, color: AppColors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Close the app
                        SystemNavigator.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Close App',
                        style: semiBoldStyle(fontSize: FontSize.font16, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
