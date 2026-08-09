import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';

class ReviewQueueSubTab extends StatelessWidget {
  final AiResultsDashboard dashboard;

  const ReviewQueueSubTab({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width <= 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRisks(),
                SizedBox(height: 16.h),
                _buildOpenQuestions(),
                SizedBox(height: 16.h),
                _buildActionItems(),
                SizedBox(height: 16.h),
                _buildQualityReport(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildRisks(),
                      SizedBox(height: 16.h),
                      _buildActionItems(),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    children: [
                      _buildOpenQuestions(),
                      SizedBox(height: 16.h),
                      _buildQualityReport(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionContainer({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required int count,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: boldStyle(fontSize: FontSize.font16, color: AppColors.black),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$count',
                  style: semiBoldStyle(fontSize: FontSize.font12, color: AppColors.grey),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRisks() {
    return _buildSectionContainer(
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      iconBgColor: const Color(0xFFFEE2E2),
      title: 'Risks',
      count: dashboard.summary.risks.length,
      children: dashboard.summary.risks.map((risk) {
        Color severityColor;
        Color severityBg;
        if (risk.severity.toLowerCase() == 'high') {
          severityColor = AppColors.error;
          severityBg = const Color(0xFFFEE2E2);
        } else if (risk.severity.toLowerCase() == 'medium') {
          severityColor = const Color(0xFFD97706);
          severityBg = const Color(0xFFFEF3C7);
        } else {
          severityColor = AppColors.statusFinished;
          severityBg = const Color(0xFFDCFCE7);
        }

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: severityBg.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: severityBg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(risk.title, style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.black))),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: severityBg,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(risk.severity, style: semiBoldStyle(fontSize: FontSize.font10, color: severityColor)),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(risk.description, style: regularStyle(fontSize: FontSize.font12, color: AppColors.grey)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOpenQuestions() {
    return _buildSectionContainer(
      icon: Icons.help_outline,
      iconColor: AppColors.primary,
      iconBgColor: AppColors.lightButton,
      title: 'Open Questions',
      count: dashboard.summary.openQuestions.length,
      children: dashboard.summary.openQuestions.map((q) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q.question, style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.black)),
              SizedBox(height: 4.h),
              Text('Question ID: ${q.id}. Resolve before final sign-off.', style: regularStyle(fontSize: FontSize.font12, color: AppColors.grey)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionItems() {
    return _buildSectionContainer(
      icon: Icons.check_box_outlined,
      iconColor: AppColors.primary,
      iconBgColor: AppColors.lightButton,
      title: 'Action Items',
      count: dashboard.summary.actionItems.length,
      children: dashboard.summary.actionItems.map((item) {
        Color priorityColor;
        Color priorityBg;
        if (item.priority.toLowerCase() == 'high') {
          priorityColor = const Color(0xFFD97706);
          priorityBg = const Color(0xFFFEF3C7);
        } else if (item.priority.toLowerCase() == 'medium') {
          priorityColor = const Color(0xFF0EA5E9);
          priorityBg = const Color(0xFFE0F2FE);
        } else {
          priorityColor = AppColors.grey;
          priorityBg = const Color(0xFFF3F4F6);
        }

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.black)),
                    if (item.owner != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14.sp, color: AppColors.grey),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              item.owner!,
                              style: regularStyle(fontSize: FontSize.font12, color: AppColors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: priorityBg,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(item.priority, style: semiBoldStyle(fontSize: FontSize.font10, color: priorityColor)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQualityReport() {
    final report = dashboard.qualityReport;
    if (report == null) return const SizedBox();

    return _buildSectionContainer(
      icon: Icons.high_quality,
      iconColor: const Color(0xFFD97706),
      iconBgColor: const Color(0xFFFEF3C7),
      title: 'Quality Report',
      count: report.highSeverityIssueCount ?? 0,
      children: [
        _buildQualityMetric(
            'Overall Score', report.overallScore, Icons.score),
        _buildQualityMetric('Traceability Coverage',
            report.traceabilityCoverage, Icons.verified_user),
        _buildQualityMetric('Groundedness Score', report.groundednessScore,
            Icons.library_books),
        _buildQualityMetric('Story Completeness', report.storyCompleteness,
            Icons.done_all),
        _buildQualityMetric('Acceptance Criteria Quality',
            report.acceptanceCriteriaQuality, Icons.rule),
        _buildQualityMetric(
            'Duplicate Risk', report.duplicateRisk, Icons.copy,
            invertColor: true),
      ],
    );
  }

  Widget _buildQualityMetric(String title, double? value, IconData icon,
      {bool invertColor = false}) {
    if (value == null) return const SizedBox();
    
    // For duplicate risk, lower is better. For others, higher is better.
    Color valueColor;
    if (invertColor) {
      valueColor = value > 0.1 ? AppColors.error : AppColors.statusFinished;
    } else {
      valueColor = value >= 0.8
          ? AppColors.statusFinished
          : (value >= 0.6 ? const Color(0xFFD97706) : AppColors.error);
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 16.sp, color: AppColors.grey),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: regularStyle(fontSize: FontSize.font14, color: AppColors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${(value * 100).toInt()}%',
            style: semiBoldStyle(fontSize: FontSize.font14, color: valueColor),
          ),
        ],
      ),
    );
  }
}

