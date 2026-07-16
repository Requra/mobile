import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/presentation/helpers/date_helper.dart';

class ProjectHeaderSection extends StatelessWidget {
  final ProjectDetails details;

  const ProjectHeaderSection({super.key, required this.details});

  String get _badge {
    final s = details.status.toLowerCase();
    if (s.contains('process') || s.contains('progress')) return 'IN PROGRESS';
    if (s.contains('complet') || s.contains('finish')) return 'FINISHED';
    return 'Draft';
  }

  Color get _statusBg {
    if (_badge == 'IN PROGRESS') return AppColors.statusInProgressLight;
    if (_badge == 'FINISHED') return AppColors.statusFinishedLight;
    return AppColors.lightgrey.withValues(alpha: 0.2);
  }

  Color get _statusColor {
    if (_badge == 'IN PROGRESS') return AppColors.statusInProgress;
    if (_badge == 'FINISHED') return AppColors.statusFinished;
    return AppColors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Project name
          Text(
            details.name,
            style: boldStyle(
              fontSize: FontSize.font22,
              color: AppColors.black,
            ),
          ),

          SizedBox(height: 8.h),

          /// Status badge + Created date
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 4.h,
                  horizontal: 10.w,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: _statusBg,
                ),
                child: Text(
                  _badge,
                  style: semiBoldStyle(
                    fontSize: FontSize.font12,
                    color: _statusColor,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.access_time_outlined,
                  size: 14.sp, color: AppColors.lightgrey),
              SizedBox(width: 4.w),
              Text(
                details.createdAt != null
                    ? 'Created ${formatDate(details.createdAt!)}'
                    : 'Created —',
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.lightgrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
