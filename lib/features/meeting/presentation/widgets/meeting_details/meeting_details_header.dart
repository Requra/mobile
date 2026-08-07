import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_colors.dart';

/// Title + status badge + description shown at the top of the meeting details screen.
class MeetingDetailsHeader extends StatelessWidget {
  final Meeting meeting;

  const MeetingDetailsHeader({super.key, required this.meeting});

  String get _status => meeting.status.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10.w,
            runSpacing: 6.h,
            children: [
              Text(
                meeting.title,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: MeetingDetailsColors.ink,
                  letterSpacing: -0.5,
                  fontFamily: FontConstants.fontFamily,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: MeetingDetailsColors.badgeBg(_status),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: MeetingDetailsColors.badgeFg(_status),
                    fontFamily: FontConstants.fontFamily,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            meeting.description,
            style: TextStyle(
              fontSize: 14.sp,
              color: MeetingDetailsColors.inkSoft,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

