import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_details_card.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_details_colors.dart';

/// "Live Meeting Room" card – currently shows a placeholder state.
class MeetingLiveRoomCard extends StatelessWidget {
  const MeetingLiveRoomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return MeetingDetailsCard(
      children: [
        const MeetingDetailsCardHeader(emoji: '📹', title: 'Live Meeting Room'),
        Text(
          'The immersive live meeting room features high-end video, screen sharing, and real-time collaboration.',
          style: TextStyle(
            fontSize: 13.sp,
            color: MeetingDetailsColors.inkSoft,
            height: 1.5,
            fontFamily: FontConstants.fontFamily,
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: MeetingDetailsColors.fieldBg,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: MeetingDetailsColors.border),
          ),
          child: Text(
            'Meeting not live',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: MeetingDetailsColors.inkSoft,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ),
      ],
    );
  }
}
