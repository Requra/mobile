import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_card.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_colors.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_date_formatter.dart';

/// Shows lifecycle status, and optionally started/ended timestamps.
class MeetingLifecycleCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingLifecycleCard({super.key, required this.meeting});

  String get _status => meeting.status.toUpperCase();
  bool get _isLive => _status == 'LIVE';
  bool get _isEnded => _status == 'ENDED';

  @override
  Widget build(BuildContext context) {
    return MeetingDetailsCard(
      children: [
        const MeetingDetailsCardHeader(icon: Icons.timer_outlined, title: 'Lifecycle'),
        const MeetingFieldLabel('Status'),
        _statusRow(_status, MeetingDetailsColors.dotColor(_status)),

        if (_isLive || _isEnded) ...[
          SizedBox(height: 16.h),
          const MeetingFieldLabel('Started At'),
          _valueRow(
            meeting.startedAt != null
                ? MeetingDateFormatter.time(meeting.startedAt!)
                : '—',
          ),
        ],

        if (_isEnded) ...[
          SizedBox(height: 16.h),
          const MeetingFieldLabel('Ended At'),
          _valueRow(
            meeting.endedAt != null
                ? MeetingDateFormatter.time(meeting.endedAt!)
                : '—',
          ),
        ],
      ],
    );
  }

  Widget _statusRow(String label, Color dotColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: MeetingDetailsColors.fieldBg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: MeetingDetailsColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: MeetingDetailsColors.ink,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueRow(String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: MeetingDetailsColors.fieldBg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: MeetingDetailsColors.border),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: MeetingDetailsColors.ink,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

