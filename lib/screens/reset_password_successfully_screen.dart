import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';

class ResetPasswordSuccessfullyScreen extends StatelessWidget {
  const ResetPasswordSuccessfullyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                height: 500.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16.r)),
                  border: Border.all(
                    color: AppColors.lightgrey,
                    width: 1.5.w,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical:  12.h , horizontal: 12.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Password Reset Successfully" , style: boldStyle(fontSize: FontSize.font20, color: AppColors.black),),
                      SizedBox(height: 8.h,),
                      Text("Your password has been updated. You can now sign in with your new password.", style: boldStyle(fontSize: FontSize.font16, color: AppColors.grey),),
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
