import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

import '../theme/color_manager.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    this.borderColor,
    this.textColor = AppColors.white,
    this.color1 = AppColors.lightPrimary,
    this.color2 = AppColors.primary,
  });

  final String text;
  final VoidCallback? onTap;
  final Color color1;
  final Color color2;
  final Color textColor;
  final Color? borderColor;


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
            border: borderColor != null
                ? Border.all(color: borderColor!) : null,
            borderRadius: BorderRadius.circular(14.r),
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: boldStyle(fontSize: FontSize.font16, color: textColor)
          ),
        ),
      ),
    );
  }
}
