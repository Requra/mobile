import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.isPrimary,
    required this.onTap,
    this.fullWidth = false,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final Widget button = SizedBox(
      height: 40.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppColors.primaryText
              : const Color(0xFFF2F2F7),
          foregroundColor: isPrimary ? AppColors.white : AppColors.primaryText,
          elevation: 0,
          side: BorderSide(
            color: isPrimary ? AppColors.primaryText : const Color(0xFFC8C8D0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          label,
          style: semiBoldStyle(
            fontSize: FontSize.font14,
            color: isPrimary ? AppColors.white : AppColors.primaryText,
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
