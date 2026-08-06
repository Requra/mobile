import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';

class UserStoriesSubTab extends StatelessWidget {
  final AiResultsDashboard dashboard;

  const UserStoriesSubTab({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Count
          Text(
            '${dashboard.userStories.length} user stories',
            style: semiBoldStyle(
              fontSize: FontSize.font14,
              color: AppColors.grey,
            ),
          ),

          SizedBox(height: 12.h),

          // List of user stories
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashboard.userStories.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              return _buildUserStoryCard(dashboard.userStories[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserStoryCard(AiUserStory story) {
    Color priorityColor;
    Color priorityBg;
    if (story.priority.toLowerCase() == 'critical') {
      priorityColor = AppColors.error;
      priorityBg = const Color(0xFFFEE2E2);
    } else if (story.priority.toLowerCase() == 'high') {
      priorityColor = const Color(0xFFD97706);
      priorityBg = const Color(0xFFFEF3C7);
    } else {
      priorityColor = AppColors.statusFinished;
      priorityBg = const Color(0xFFDCFCE7);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                story.id,
                style: semiBoldStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.grey,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: priorityBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  story.priority,
                  style: semiBoldStyle(
                    fontSize: FontSize.font10,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Title
          Text(
            story.title,
            style: boldStyle(fontSize: FontSize.font16, color: AppColors.black),
          ),
          SizedBox(height: 8.h),
          // User Story Text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundHomeScreen,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              story.userStory,
              style: regularStyle(
                fontSize: FontSize.font14,
                color: AppColors.black,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Acceptance Criteria
          Text(
            'Acceptance Criteria',
            style: semiBoldStyle(
              fontSize: FontSize.font14,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
          ...story.acceptanceCriteria.map(
            (ac) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 6.h, right: 8.w),
                    child: CircleAvatar(
                      radius: 3.r,
                      backgroundColor: AppColors.grey,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      ac.text,
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: const Color(0xFFE5E7EB)),
          SizedBox(height: 12.h),
          // Footer
          Row(
            children: [
              Icon(Icons.link, size: 16.sp, color: AppColors.grey),
              SizedBox(width: 4.w),
              Text(
                'Linked to: ${story.requirementId}',
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
