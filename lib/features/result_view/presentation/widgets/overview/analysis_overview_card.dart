import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/presentation/widgets/overview/analysis_overview_metric_item.dart';

class AnalysisOverviewCard extends StatelessWidget {
  final int totalRequirements;

  const AnalysisOverviewCard({
    super.key,
    required this.totalRequirements,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate mock metrics based on totalRequirements
    final int approved = (totalRequirements * 0.7).round();
    final double accuracy =
        totalRequirements > 0 ? (approved / totalRequirements * 100) : 0;
    final double progress =
        totalRequirements > 0 ? (approved / totalRequirements) : 0;

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
          /// Title row
          Row(
            children: [
              Text(
                'Analysis Overview',
                style: boldStyle(
                  fontSize: FontSize.font16,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimaryBorder,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  'FINAL METRICS',
                  style: semiBoldStyle(
                    fontSize: FontSize.font10,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          /// Metrics grid (2x2)
          Row(
            children: [
              Expanded(
                child: AnalysisOverviewMetricItem(
                  icon: Icons.trending_up,
                  iconColor: AppColors.statusFinished,
                  label: 'Total Progress',
                  value: '${(progress * 100).toStringAsFixed(0)}%',
                  valueColor: AppColors.statusFinished,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AnalysisOverviewMetricItem(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.primary,
                  label: 'Total\nRequirements',
                  value: '$totalRequirements',
                  valueColor: AppColors.black,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: AnalysisOverviewMetricItem(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.statusInProgress,
                  label: 'Approved\nRequirements',
                  value: '$approved',
                  valueColor: AppColors.black,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AnalysisOverviewMetricItem(
                  icon: Icons.speed_outlined,
                  iconColor: AppColors.statusFinished,
                  label: 'Accuracy',
                  value: '${accuracy.toStringAsFixed(0)}%',
                  valueColor: AppColors.black,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          /// Overall Progress bar
          Row(
            children: [
              Text(
                'Overall Progress',
                style: semiBoldStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.grey,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: semiBoldStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.statusFinished,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.statusFinished),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }
}
