import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class MetadataMemberTile extends StatelessWidget {
  final String email;

  const MetadataMemberTile({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final initials = email
        .split('@')
        .first
        .split(RegExp(r'[._]'))
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundHomeScreen,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14.r,
            backgroundColor: AppColors.darkPrimary,
            child: Text(
              initials,
              style: semiBoldStyle(
                fontSize: FontSize.font10,
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              email,
              style: regularStyle(
                fontSize: FontSize.font13,
                color: AppColors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
