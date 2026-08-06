import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class ProjectDescriptionCard extends StatelessWidget {
  final String description;

  const ProjectDescriptionCard({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header with icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimaryBorder,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROJECT DESCRIPTION',
                    style: boldStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    'Overview',
                    style: regularStyle(
                      fontSize: FontSize.font11,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          /// Description text
          Text(
            description,
            style: regularStyle(
              fontSize: FontSize.font14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
