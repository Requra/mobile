import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_colors.dart';

/// Dark-themed session recording card shown only when the meeting has ended.
class MeetingRecordingCard extends StatelessWidget {
  const MeetingRecordingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14151A), Color(0xFF0C0D10)],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFF23252C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          SizedBox(height: 16.h),
          _metaRow(),
          SizedBox(height: 12.h),
          _playerRow(),
          SizedBox(height: 16.h),
          _downloadButton(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: MeetingDetailsColors.green,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'Session Recording',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: FontConstants.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _metaRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C22),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF26272F)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _metaLabel('FORMAT: SYNTHETIC-PREVIEW'),
          _metaLabel('DURATION: 69 MIN'),
        ],
      ),
    );
  }

  Widget _metaLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.5.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: const Color(0xFF9A9CA8),
        fontFamily: FontConstants.fontFamily,
      ),
    );
  }

  Widget _playerRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF26272F)),
      ),
      child: Row(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2B2C34),
            ),
            child: Center(
              child: Text('▶', style: TextStyle(fontSize: 11.sp, color: Colors.white)),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            '0:00 / 0:00',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD7D8DE),
              fontFamily: FontConstants.fontFamily,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3B44),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text('🔊', style: TextStyle(fontSize: 13.sp)),
          SizedBox(width: 8.w),
          Text('⋮', style: TextStyle(fontSize: 13.sp, color: const Color(0xFFB7B8C1))),
        ],
      ),
    );
  }

  Widget _downloadButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: MeetingDetailsColors.green,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        'DOWNLOAD AUDIO FILE (0.75 MB)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: const Color(0xFF04241A),
          fontFamily: FontConstants.fontFamily,
        ),
      ),
    );
  }
}

