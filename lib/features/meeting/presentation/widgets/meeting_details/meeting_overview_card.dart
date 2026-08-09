import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_card.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_colors.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_date_formatter.dart';

/// Scheduled date, host reference, role, access link, and meeting context.
class MeetingOverviewCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingOverviewCard({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    return MeetingDetailsCard(
      children: [
        const MeetingDetailsCardHeader(emoji: '⚙', title: 'Meeting Overview'),

        // Scheduled At
        const MeetingFieldLabel('📅 Scheduled At'),
        Text(
          meeting.scheduledAt != null
              ? MeetingDateFormatter.fullDate(meeting.scheduledAt!)
              : '—',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: MeetingDetailsColors.ink,
            fontFamily: FontConstants.fontFamily,
          ),
        ),
        SizedBox(height: 16.h),

        // Host Reference
        const MeetingFieldLabel('👤 Host Reference'),
        _pillBox('sim-part-host'),
        SizedBox(height: 16.h),

        // Your Role
        const MeetingFieldLabel('ⓘ Your Role'),
        _rolePill('HOST'),
        SizedBox(height: 16.h),

        // Access Link
        const MeetingFieldLabel('📹 Access Link'),
        GestureDetector(
          onTap: () {
            if (meeting.joinUrl.isNotEmpty) {
              Clipboard.setData(ClipboardData(text: meeting.joinUrl)).then((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invitation link copied!')),
                  );
                }
              });
            }
          },
          child: Text(
            'Copy Invitation Link ›',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: MeetingDetailsColors.purple,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ),

        // Divider
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Container(height: 1, color: MeetingDetailsColors.border),
        ),

        // Meeting Context & Agenda
        const MeetingFieldLabel('ⓘ Meeting Context & Agenda'),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(18.w, 14.h, 14.w, 14.h),
          decoration: BoxDecoration(
            color: MeetingDetailsColors.fieldBg,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: MeetingDetailsColors.border),
          ),
          child: Text(
            meeting.description,
            style: TextStyle(
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
              color: MeetingDetailsColors.inkSoft,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pillBox(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: MeetingDetailsColors.fieldBg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: MeetingDetailsColors.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: MeetingDetailsColors.ink,
          fontFamily: FontConstants.fontFamily,
        ),
      ),
    );
  }

  Widget _rolePill(String role) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: MeetingDetailsColors.purpleSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: MeetingDetailsColors.purple,
          fontFamily: FontConstants.fontFamily,
        ),
      ),
    );
  }
}

