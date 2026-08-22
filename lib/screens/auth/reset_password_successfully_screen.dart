import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

import '../../widgets/auth_header.dart';
import '../../core/global_widgets/custom_button.dart';
import '../../core/global_widgets/customAppBar.dart';

class ResetPasswordSuccessfullyScreen extends StatelessWidget {
  const ResetPasswordSuccessfullyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: '',
              subtitle: '',
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical:  20.h , horizontal: 20.w),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16.r)),
                  border: Border.all(
                    color: AppColors.lightgrey,
                    width: 1.5.w,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 12.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Password Reset Successfully", 
                        textAlign: TextAlign.center,
                        style: boldStyle(fontSize: FontSize.font18, color: AppColors.black),
                      ),
                      SizedBox(height: 8.h,),
                      Text(
                        "Your password has been updated. You can now sign in with your new password.", 
                        textAlign: TextAlign.center,
                        style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.darkgrey),
                      ),
                      SizedBox(height: 8.h,),
                      Image.asset(
                        'assets/images/RequraAvatar.png',
                        height: 250.h,
                        width: 300.w,
                        fit: BoxFit.contain,

                      ),
                      SizedBox(height: 16.h,),
                      CustomButton(
                        text: 'Back to Sign in',
                        onTap: () {
                          Navigator.pushNamed(context, "/login");
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
