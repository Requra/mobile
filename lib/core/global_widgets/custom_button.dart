import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

import '../theme/color_manager.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    this.borderColor,
    this.isRegularStyle = false,
    this.transparent = false,
    this.icon,
    this.iconColor = AppColors.white,
    this.textColor = AppColors.white,
    this.color1 = AppColors.lightPrimary,
    this.color2 = AppColors.primary,
    this.raduis = 8.0,
  });

  final String text;
  final VoidCallback? onTap;
  final Color color1;
  final bool transparent;
  final bool isRegularStyle;
  final Color color2;
  final Color textColor;
  final Color? borderColor;
  final Color iconColor;
  final IconData? icon;
  final double raduis;


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: borderColor != null
            ? Border.all(color: borderColor!) : null,
        borderRadius: BorderRadius.circular(raduis.r),
        gradient: LinearGradient(
          colors: transparent ? [Colors.transparent, Colors.transparent] :[color1, color2],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(raduis.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: icon == null ? Text(
              text,
              textAlign: TextAlign.center,
              style: isRegularStyle ? regularStyle(fontSize: FontSize.font14, color: transparent ? AppColors.black : textColor) :
              boldStyle(fontSize: FontSize.font14, color: transparent ? AppColors.black :textColor)
            ) :
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                    text,
                    textAlign: TextAlign.center,
                    style: isRegularStyle ? regularStyle(fontSize: FontSize.font14, color: textColor) :
                    boldStyle(fontSize: FontSize.font14, color: textColor)
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
