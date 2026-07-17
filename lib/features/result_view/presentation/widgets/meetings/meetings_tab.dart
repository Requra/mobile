import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/meeting.dart';
import 'package:requra/features/result_view/presentation/widgets/meetings/meeting_card.dart';
import 'package:requra/features/result_view/presentation/widgets/meetings/meetings_empty_state.dart';

class MeetingsTab extends StatelessWidget {
  final List<Meeting> meetings;

  const MeetingsTab({super.key, required this.meetings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Header card
        Container(
          margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Meetings',
                style: boldStyle(
                  fontSize: FontSize.font16,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Manage and join live sync sessions for requirement gathering.',
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.lightgrey,
                ),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'Create Meeting',
                icon: Icons.add,
                color1: AppColors.primary,
                onTap: () {
                  // TODO: navigate to create meeting
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        /// Meetings list or empty state
        Expanded(
          child: meetings.isEmpty
              ? const MeetingsEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 4.h),
                  itemCount: meetings.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return MeetingCard(meeting: meetings[index]);
                  },
                ),
        ),
      ],
    );
  }
}
