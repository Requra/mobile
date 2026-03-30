import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';
import 'package:requra/widgets/project_Card.dart';

class UserstoriesTabview extends StatefulWidget {
  const UserstoriesTabview({super.key});

  @override
  State<UserstoriesTabview> createState() => _userstoriesTabviewState();
}

class _userstoriesTabviewState extends State<UserstoriesTabview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundHomeScreen,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Stories',
            style: semiBoldStyle(fontSize:FontSize.font22 , color: AppColors.black),
          ),
          SizedBox(height: 10.h),
          Text(
            'Structured requirements extracted by AI Requra. Review, verify, and refine the core value propositions for the upcoming sprint.',
            style: regularStyle(fontSize:FontSize.font14 , color: AppColors.grey),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 4.w),
                decoration: BoxDecoration(
                  color: AppColors.statusInProgressLight,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color:AppColors.statusInProgress, width: 1),
                ),
                child: Text(
                  'IN PROGRESS',
                  style: regularStyle(fontSize: FontSize.font12, color: AppColors.statusInProgress)
                ),
              ),
              Text(
                'Last updated 1m ago',
                style: TextStyle(fontSize: FontSize.font12, color: AppColors.grey),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryText,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: Icon(Icons.file_upload_outlined , color: AppColors.white,),
              label: Text(
            "Export",
            style: semiBoldStyle(
            fontSize: FontSize.font16,
            color: AppColors.white,
            ),
          ),
            ),
          ),

          SizedBox(height: 14.h,),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary.withOpacity(0.9),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: Icon(Icons.filter_alt_outlined , color: AppColors.white,),
              label: Text(
                "Filter",
                style: semiBoldStyle(
                  fontSize: FontSize.font16,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
