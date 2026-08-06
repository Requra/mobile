import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_details_card.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_details_colors.dart';

/// Participants summary + empty-state invite CTA.
class MeetingParticipantsCard extends StatelessWidget {
  final int participantsCount;

  const MeetingParticipantsCard({
    super.key,
    required this.participantsCount,
  });

  @override
  Widget build(BuildContext context) {
    return MeetingDetailsCard(
      children: [
        const MeetingDetailsCardHeader(emoji: '👥', title: 'Participants & Roster'),

        // Summary strip
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF6F4FF), Color(0xFFF7F7FA)],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text('👥',
                      style: TextStyle(fontSize: 18.sp, color: MeetingDetailsColors.purple)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$participantsCount Expected Participants',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: MeetingDetailsColors.ink,
                        fontFamily: FontConstants.fontFamily,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Real-time status of session invitees and participant connections.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: MeetingDetailsColors.inkSoft,
                        height: 1.4,
                        fontFamily: FontConstants.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Empty state
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: MeetingDetailsColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: MeetingDetailsColors.purpleSoft,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(child: Text('✉', style: TextStyle(fontSize: 20.sp))),
              ),
              SizedBox(height: 14.h),
              Text(
                'No Invitations Found',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: MeetingDetailsColors.ink,
                  fontFamily: FontConstants.fontFamily,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Invite teammates, stakeholders, or external guests to join this session and collaborate in real-time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: MeetingDetailsColors.inkSoft,
                  height: 1.5,
                  fontFamily: FontConstants.fontFamily,
                ),
              ),
              SizedBox(height: 18.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: MeetingDetailsColors.border, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('👤', style: TextStyle(fontSize: 14.sp)),
                    SizedBox(width: 6.w),
                    Text(
                      'Send First Invite',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: MeetingDetailsColors.ink,
                        fontFamily: FontConstants.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
