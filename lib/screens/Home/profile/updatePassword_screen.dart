// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';
import 'package:requra/widgets/circular_icon.dart';
import 'package:requra/widgets/custom_button.dart';


class UpdatepasswordScreen extends StatelessWidget {
  const UpdatepasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                    padding: EdgeInsets.symmetric(vertical:  40.h , horizontal: 20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularIcon(icon: Icons.check_circle_outline_outlined , size: 35.r,),
                        SizedBox(height: 16.h,),
                        Text("Set New Password" , style: boldStyle(fontSize: FontSize.font20, color: AppColors.black),textAlign: TextAlign.center,),
                        SizedBox(height: 16.h,),
                        Text("Your password has been successfully changed. You can now use your new password to log in." , style: regularStyle(fontSize: FontSize.font14, color: AppColors.lightgrey),textAlign: TextAlign.center,),
                        SizedBox(height: 16.h,),
                        CircularIcon(icon: Icons.check , size: 35.r , borderColor: AppColors.lightPrimaryBorder, iconColor: AppColors.primary, color1: Colors.white, color2: Colors.white,),
                        SizedBox(height: 16.h,),
                        CustomButton(
                          text: "Back to Profile",
                          onTap: () {
                            Navigator.pushReplacementNamed(context, "/profile");
                          },
                          color1: AppColors.primaryText,
                          color2: AppColors.primaryText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




