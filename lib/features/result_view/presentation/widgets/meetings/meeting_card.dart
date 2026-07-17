import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/result_view/presentation/helpers/date_helper.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/meeting.dart';

class MeetingCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingCard({super.key, required this.meeting});

  String get _badge => meeting.status.toUpperCase();

  Color get _badgeBg {
    switch (_badge) {
      case 'LIVE':
        return AppColors.statusFinishedLight.withValues(alpha: 0.3);
      case 'ENDED':
        return AppColors.lightgrey.withValues(alpha: 0.2);
      case 'CANCELLED':
        return AppColors.error.withValues(alpha: 0.1);
      case 'SCHEDULED':
        return AppColors.statusInProgressLight;
      default:
        return AppColors.lightgrey.withValues(alpha: 0.2);
    }
  }

  Color get _badgeColor {
    switch (_badge) {
      case 'LIVE':
        return AppColors.statusFinished;
      case 'ENDED':
        return AppColors.grey;
      case 'CANCELLED':
        return AppColors.error;
      case 'SCHEDULED':
        return AppColors.statusInProgress;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  meeting.title,
                  style: boldStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: _badgeBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _badge,
                  style: semiBoldStyle(
                    fontSize: FontSize.font10,
                    color: _badgeColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          /// Date
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13.sp, color: AppColors.lightgrey),
              SizedBox(width: 4.w),
              Text(
                meeting.scheduledAt != null
                    ? formatDate(meeting.scheduledAt!)
                    : meeting.createdAt != null
                        ? formatDate(meeting.createdAt!)
                        : '—',
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.lightgrey,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          /// Description
          Text(
            meeting.description,
            style: regularStyle(
              fontSize: FontSize.font13,
              color: AppColors.grey,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 12.h),

          /// Bottom row: participants + details
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundHomeScreen,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.groups_outlined,
                        size: 14.sp, color: AppColors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      '${meeting.participantsCount} Participants',
                      style: semiBoldStyle(
                        fontSize: FontSize.font11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // TODO: navigate to meeting details
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Details',
                      style: semiBoldStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.chevron_right,
                        size: 16.sp, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
