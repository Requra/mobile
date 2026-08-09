import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/meeting/domain/entities/meeting_summary.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_finished/status_badge.dart';

class SessionRecordingCard extends StatelessWidget {
  final ProcessingStatus transcriptStatus;
  final ProcessingStatus aiExtractionStatus;

  const SessionRecordingCard({
    super.key,
    required this.transcriptStatus,
    required this.aiExtractionStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.video_camera_front_rounded,
                color: const Color(0xFF4A4E69), // Dark icon color
                size: 24.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'Session Recording',
                style: boldStyle(
                  fontSize: FontSize.font16,
                  color: const Color(0xFF1E2022), // Dark text color
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Audio Transcript Row
          _buildRow(
            iconData: Icons.description_rounded,
            iconColor: const Color(0xFFE8F5E9), // Light green icon bg
            iconIconColor: const Color(0xFF81C784), // Green icon color
            title: 'Audio Transcript',
            subtitle: 'Transcript generated and secured.',
            status: transcriptStatus,
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Divider(color: Colors.grey.shade200, height: 1),
          ),
          
          // AI Requirement Extraction Row
          _buildRow(
            iconData: Icons.auto_awesome_rounded,
            iconColor: const Color(0xFFF3E5F5), // Light purple icon bg
            iconIconColor: const Color(0xFFCE93D8), // Purple icon color
            title: 'AI Requirement\nExtraction',
            subtitle: 'Processing transcript for user\nstories and requirements...',
            status: aiExtractionStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData iconData,
    required Color iconColor,
    required Color iconIconColor,
    required String title,
    required String subtitle,
    required ProcessingStatus status,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            iconData,
            color: iconIconColor,
            size: 24.r,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: boldStyle(
                  fontSize: FontSize.font14,
                  color: const Color(0xFF1E2022),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: const Color(0xFF7B8794),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        StatusBadge(status: status),
      ],
    );
  }
}
