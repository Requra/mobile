import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';

class SummarySubTab extends StatelessWidget {
  final AiResultsDashboard dashboard;

  const SummarySubTab({
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
                _buildExecutiveSummary(),
                SizedBox(height: 16.h),
                _buildStakeholders(),
                SizedBox(height: 16.h),
                _buildKeyDecisions(),
                SizedBox(height: 16.h),
                _buildInScope(),
                SizedBox(height: 16.h),
                _buildAssumptions(),
                SizedBox(height: 16.h),
                _buildOutOfScope(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildExecutiveSummary(),
                      SizedBox(height: 16.h),
                      _buildKeyDecisions(),
                      SizedBox(height: 16.h),
                      _buildAssumptions(),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildStakeholders(),
                      SizedBox(height: 16.h),
                      _buildInScope(),
                      SizedBox(height: 16.h),
                      _buildOutOfScope(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    int? count,
    required Widget content,
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
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: boldStyle(
                              fontSize: FontSize.font16,
                              color: AppColors.black),
                        ),
                        if (count != null) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '$count',
                              style: semiBoldStyle(
                                  fontSize: FontSize.font12,
                                  color: AppColors.grey),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: regularStyle(
                            fontSize: FontSize.font12, color: AppColors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(height: 1, color: const Color(0xFFE5E7EB)),
          SizedBox(height: 16.h),
          content,
        ],
      ),
    );
  }

  Widget _buildExecutiveSummary() {
    return _buildCard(
      icon: Icons.auto_awesome,
      iconColor: AppColors.primary,
      iconBgColor: AppColors.lightButton,
      title: 'Executive Summary',
      subtitle: 'What Requra understood about this project',
      content: Text(
        dashboard.summary.executiveSummary,
        style: regularStyle(fontSize: FontSize.font14, color: AppColors.black),
      ),
    );
  }

  Widget _buildKeyDecisions() {
    return _buildCard(
      icon: Icons.account_tree_outlined,
      iconColor: AppColors.primary,
      iconBgColor: AppColors.lightButton,
      title: 'Key Decisions',
      subtitle: 'Architectural and product decisions captured',
      count: dashboard.summary.keyDecisions.length,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dashboard.summary.keyDecisions
            .map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, right: 8.w),
                        child: CircleAvatar(
                          radius: 3.r,
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e,
                          style: regularStyle(
                              fontSize: FontSize.font14,
                              color: AppColors.black),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildAssumptions() {
    return _buildCard(
      icon: Icons.shield_outlined,
      iconColor: const Color(0xFF0D9488),
      iconBgColor: const Color(0xFFCCFBF1),
      title: 'Assumptions',
      subtitle: 'Inferred from source context',
      count: dashboard.summary.assumptions.length,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dashboard.summary.assumptions
            .map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, right: 8.w),
                        child: CircleAvatar(
                          radius: 3.r,
                          backgroundColor: const Color(0xFF0D9488),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e,
                          style: regularStyle(
                              fontSize: FontSize.font14,
                              color: AppColors.black),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStakeholders() {
    return _buildCard(
      icon: Icons.people_outline,
      iconColor: AppColors.grey,
      iconBgColor: const Color(0xFFF3F4F6),
      title: 'Stakeholders',
      subtitle: '',
      content: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: dashboard.summary.stakeholders
            .map((e) => Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.lightButton,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.lightPrimary),
                  ),
                  child: Text(
                    e,
                    style: semiBoldStyle(
                        fontSize: FontSize.font12, color: AppColors.primary),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInScope() {
    return _buildCard(
      icon: Icons.adjust,
      iconColor: AppColors.statusFinished,
      iconBgColor: const Color(0xFFDCFCE7),
      title: 'In Scope',
      subtitle: '',
      count: dashboard.summary.scope.length,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dashboard.summary.scope
            .map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, right: 8.w),
                        child: CircleAvatar(
                          radius: 3.r,
                          backgroundColor: AppColors.statusFinished,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e,
                          style: regularStyle(
                              fontSize: FontSize.font14,
                              color: AppColors.black),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildOutOfScope() {
    return _buildCard(
      icon: Icons.block,
      iconColor: AppColors.grey,
      iconBgColor: const Color(0xFFF3F4F6),
      title: 'Out of Scope',
      subtitle: '',
      count: dashboard.summary.outOfScope.length,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dashboard.summary.outOfScope
            .map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, right: 8.w),
                        child: CircleAvatar(
                          radius: 3.r,
                          backgroundColor: AppColors.grey,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e,
                          style: regularStyle(
                              fontSize: FontSize.font14,
                              color: AppColors.black),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
