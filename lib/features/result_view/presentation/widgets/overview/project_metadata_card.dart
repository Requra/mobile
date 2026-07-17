import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/result_view/presentation/helpers/date_helper.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/presentation/widgets/overview/metadata_section_label.dart';
import 'package:requra/features/result_view/presentation/widgets/overview/metadata_client_tile.dart';
import 'package:requra/features/result_view/presentation/widgets/overview/metadata_member_tile.dart';

class ProjectMetadataCard extends StatelessWidget {
  final ProjectDetails details;

  const ProjectMetadataCard({super.key, required this.details});

  String get _badge {
    final s = details.status.toLowerCase();
    if (s.contains('process') || s.contains('progress')) return 'IN PROGRESS';
    if (s.contains('complet') || s.contains('finish')) return 'FINISHED';
    return 'Draft';
  }

  Color get _statusColor {
    if (_badge == 'IN PROGRESS') return AppColors.statusInProgress;
    if (_badge == 'FINISHED') return AppColors.statusFinished;
    return AppColors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            'Project Metadata',
            style: boldStyle(
              fontSize: FontSize.font16,
              color: AppColors.black,
            ),
          ),

          SizedBox(height: 16.h),

          /// Client section
          const MetadataSectionLabel(icon: Icons.person_outline, label: 'CLIENT'),
          SizedBox(height: 8.h),
          MetadataClientTile(name: details.clientName),

          SizedBox(height: 16.h),

          /// Team members section
          const MetadataSectionLabel(icon: Icons.groups_outlined, label: 'TEAM MEMBERS'),
          SizedBox(height: 8.h),
          ...details.teamMembers.map((email) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: MetadataMemberTile(email: email),
              )),

          SizedBox(height: 16.h),

          /// Created & Status row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MetadataSectionLabel(
                        icon: Icons.calendar_today_outlined, label: 'CREATED'),
                    SizedBox(height: 6.h),
                    Text(
                      details.createdAt != null
                          ? formatDate(details.createdAt!)
                          : '—',
                      style: boldStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MetadataSectionLabel(
                        icon: Icons.flag_outlined, label: 'STATUS'),
                    SizedBox(height: 6.h),
                    Text(
                      _badge,
                      style: boldStyle(
                        fontSize: FontSize.font14,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          /// Project type section
          const MetadataSectionLabel(icon: Icons.category_outlined, label: 'PROJECT TYPE'),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.lightPrimaryBorder,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              details.projectType,
              style: semiBoldStyle(
                fontSize: FontSize.font12,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

