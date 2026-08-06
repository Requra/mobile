import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class MetadataSectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const MetadataSectionLabel({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.lightgrey),
        SizedBox(width: 6.w),
        Text(
          label,
          style: semiBoldStyle(
            fontSize: FontSize.font11,
            color: AppColors.lightgrey,
          ),
        ),
      ],
    );
  }
}
