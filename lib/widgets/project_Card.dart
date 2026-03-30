import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

class Project {}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: AppColors.lightgrey,
          width: 1.5.w,
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                  EdgeInsets.symmetric(vertical: 4.h, horizontal: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.statusInProgress),
                    color: AppColors.statusInProgressLight,
                  ),
                  child: Text(
                    "IN PROGRESS",
                    style: regularStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.statusInProgress,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.file_download_outlined,
                    size: 20.sp, color: AppColors.lightgrey),
                SizedBox(width: 4.w),
                Icon(Icons.more_vert, size: 20.sp, color: AppColors.lightgrey),
              ],
            ),

            SizedBox(height: 12.h),

            Text(
              "CRM System Requirements",
              style: boldStyle(
                fontSize: FontSize.font18,
                color: AppColors.black,
              ),
            ),

            SizedBox(height: 4.h),

            Text(
              "Requirements extracted from sales stakeholder meeting.",
              style: regularStyle(
                fontSize: FontSize.font14,
                color: AppColors.lightgrey,
              ),
            ),

            SizedBox(height: 14.h),

            Text(
              "Requirements Generation",
              style: boldStyle(
                fontSize: FontSize.font14,
                color: AppColors.black,
              ),
            ),

            SizedBox(height: 8.h),

            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: LinearProgressIndicator(
                      value: 0.30,
                      minHeight: 8.h,
                      backgroundColor: AppColors.lightgrey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.statusInProgress),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  "30%",
                  style: regularStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.statusInProgress,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            Row(
              children: [
                Icon(Icons.checklist_outlined,
                    size: 22.sp, color: AppColors.lightgrey),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Generated",
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.lightgrey,
                      ),
                    ),
                    Text(
                      "18 features",
                      style: boldStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.chat_bubble_outline,
                    size: 22.sp, color: AppColors.lightgrey),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Client comments",
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.lightgrey,
                      ),
                    ),
                    Text(
                      "3 unsolved",
                      style: boldStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 14.h),

            Row(
              children: [
                CircleAvatar(
                  radius: 14.r,
                  backgroundImage:
                  AssetImage('assets/images/RequraAvatar.png'),
                ),
                SizedBox(width: 8.w),
                Text(
                  "User name",
                  style: regularStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.lightgrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      "Edit",
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusInProgress,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      "View Details",
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}