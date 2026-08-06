import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_details_colors.dart';

/// Reusable card wrapper with standard border + radius used across the
/// meeting details screen.
class MeetingDetailsCard extends StatelessWidget {
  final List<Widget> children;

  const MeetingDetailsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: MeetingDetailsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// Section header used inside [MeetingDetailsCard] (emoji icon + title).
class MeetingDetailsCardHeader extends StatelessWidget {
  final String emoji;
  final String title;

  const MeetingDetailsCardHeader({
    super.key,
    required this.emoji,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: MeetingDetailsColors.purpleSoft,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(child: Text(emoji, style: TextStyle(fontSize: 16.sp))),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: MeetingDetailsColors.ink,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small uppercase label used before field values.
class MeetingFieldLabel extends StatelessWidget {
  final String text;

  const MeetingFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: MeetingDetailsColors.inkSoft,
          fontFamily: FontConstants.fontFamily,
        ),
      ),
    );
  }
}
