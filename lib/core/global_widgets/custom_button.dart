import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

import '../core/theme/color_manager.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    this.borderColor,
    this.isRegularStyle = false,
    this.transparent = false,
    this.textColor = AppColors.white,
    this.color1 = AppColors.lightPrimary,
    this.color2 = AppColors.primary,
  });

  final String text;
  final VoidCallback? onTap;
  final Color color1;
  final bool transparent;
  final bool isRegularStyle;
  final Color color2;
  final Color textColor;
  final Color? borderColor;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            border: borderColor != null
                ? Border.all(color: borderColor!) : null,
            borderRadius: BorderRadius.circular(8.r),
            gradient: LinearGradient(
              colors: transparent ? [Colors.transparent, Colors.transparent] :[color1, color2],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: isRegularStyle ? regularStyle(fontSize: FontSize.font14, color: textColor) :
            boldStyle(fontSize: FontSize.font16, color: textColor)
          ),
        ),
      ),
    );
  }
}
