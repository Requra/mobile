import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class MetadataClientTile extends StatelessWidget {
  final String email;
  final String name;
  final String role;

  const MetadataClientTile({
    super.key,
    required this.email,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    String initials = '';
    if (name.isNotEmpty) {
      initials = name.substring(0, 1).toUpperCase();
    } else if (email.isNotEmpty) {
      initials = email
          .split('@')
          .first
          .split(RegExp(r'[._]'))
          .take(2)
          .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
          .join();
    }

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
            backgroundColor: AppColors.primary,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email.isNotEmpty ? email : name,
                  style: semiBoldStyle(
                    fontSize: FontSize.font13,
                    color: AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Project Client',
                  style: regularStyle(
                    fontSize: FontSize.font11,
                    color: AppColors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (role.isNotEmpty) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                role,
                style: semiBoldStyle(
                  fontSize: FontSize.font10,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
