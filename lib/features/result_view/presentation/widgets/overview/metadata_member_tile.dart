import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/project_member.dart';

class MetadataMemberTile extends StatelessWidget {
  final ProjectMember member;

  const MetadataMemberTile({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    String initials = '';
    if (member.name.isNotEmpty) {
      initials = member.name.substring(0, 1).toUpperCase();
    } else {
      initials = member.email
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (member.name.isNotEmpty)
                  Text(
                    member.name,
                    style: semiBoldStyle(
                      fontSize: FontSize.font13,
                      color: AppColors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  member.email,
                  style: regularStyle(
                    fontSize: FontSize.font11,
                    color: AppColors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              member.projectRole,
              style: semiBoldStyle(
                fontSize: FontSize.font10,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
