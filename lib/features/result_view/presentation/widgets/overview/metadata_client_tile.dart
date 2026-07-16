import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class MetadataClientTile extends StatelessWidget {
  final String name;

  const MetadataClientTile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundHomeScreen,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.primary,
            child: Text(
              initials,
              style: semiBoldStyle(
                fontSize: FontSize.font11,
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
                  name,
                  style: semiBoldStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Project Client',
                  style: regularStyle(
                    fontSize: FontSize.font11,
                    color: AppColors.lightgrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
