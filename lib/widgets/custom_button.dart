import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

import '../theme/color_manager.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 15.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            gradient: const LinearGradient(
              colors: [AppColors.lightPrimary, AppColors.primary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: boldStyle(fontSize: FontSize.font16, color: AppColors.white)
          ),
        ),
      ),
    );
  }
}
