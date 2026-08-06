import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/presentation/helpers/date_helper.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/ai_results_metric_card.dart';

class AiResultsHeader extends StatelessWidget {
  final AiResultsDashboard dashboard;

  const AiResultsHeader({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title, Status & Buttons Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.lightButton,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),

              // Title and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'AI Results',
                          style: boldStyle(
                            fontSize: FontSize.font24,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.statusFinishedLight,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Text(
                            dashboard.status, // e.g. "Completed"
                            style: semiBoldStyle(
                              fontSize: FontSize.font12,
                              color: AppColors.statusFinished,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Structured requirements & insights extracted from your sources',
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Meta info chips
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _buildChip(
                          icon: Icons.percent,
                          label:
                              '${(dashboard.relevanceScore * 100).toInt()}% relevant',
                        ),
                        _buildChip(
                          icon: Icons.access_time,
                          label:
                              '${dashboard.processingTimeMs / 1000}s processing',
                        ),
                        if (dashboard.generatedAt != null)
                          _buildChip(
                            icon: Icons.calendar_today_outlined,
                            label: formatDate(dashboard.generatedAt!),
                          ),
                        _buildChip(
                          icon: Icons.insert_drive_file_outlined,
                          label:
                              '${dashboard.sourceDocuments.length} source${dashboard.sourceDocuments.length == 1 ? '' : 's'}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons (Stacking them for mobile if needed, but row for now)
              // In mobile, we might want to put this in a different place if space is tight,
              // but keeping it here for tablet/desktop view as per screenshot.
              if (MediaQuery.of(context).size.width > 600) ...[
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.person_add_alt,
                    size: 18.sp,
                    color: AppColors.white,
                  ),
                  label: Text(
                    'Share with Stakeholders',
                    style: semiBoldStyle(
                      fontSize: FontSize.font14,
                      color: AppColors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.refresh,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Regenerate',
                    style: semiBoldStyle(
                      fontSize: FontSize.font14,
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Action Buttons for Mobile
          if (MediaQuery.of(context).size.width <= 600) ...[
            SizedBox(height: 16.h),
            Column(
              children: [
                CustomButton(
                  onTap: () {},
                  icon: Icons.person_add_alt,
                  text: 'Share with Stakeholders',
                  iconColor: AppColors.white,
                  textColor: AppColors.white,
                  raduis: 8,
                  color1: AppColors.primary,
                  color2: AppColors.primary,
                ),

                SizedBox(height: 12.h),

                CustomButton(
                  text: 'Regenerate',
                  icon: Icons.refresh,
                  iconColor: AppColors.primary,
                  transparent: true,
                  borderColor: AppColors.primary,
                  textColor: AppColors.primary,
                  raduis: 8,
                  color1: AppColors.lightButton,
                ),
              ],
            ),
          ],

          SizedBox(height: 24.h),

          // Metrics Cards Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                AiResultsMetricCard(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.primary,
                  iconBgColor: AppColors.lightButton,
                  title: 'Requirements',
                  subtitle:
                      '${dashboard.metrics.functionalRequirements} functional · ${dashboard.metrics.nonFunctionalRequirements} non-func.',
                  value: '${dashboard.metrics.totalRequirements}',
                ),

                SizedBox(height: 16.h),
                AiResultsMetricCard(
                  icon: Icons.menu_book_outlined,
                  iconColor: const Color(0xFF0284C7),
                  iconBgColor: const Color(0xFFE0F2FE),
                  title: 'User Stories',
                  subtitle: 'Generated with acceptance criteria',
                  value: '${dashboard.metrics.userStories}',
                ),

                SizedBox(height: 16.h),
                AiResultsMetricCard(
                  icon: Icons.verified_user_outlined,
                  iconColor: AppColors.statusFinished,
                  iconBgColor: const Color(0xFFDCFCE7),
                  title: 'Coverage',
                  subtitle: 'Requirement → story coverage',
                  value: '60%', // This should be calculated or passed from API
                ),

                SizedBox(height: 16.h),
                AiResultsMetricCard(
                  icon: Icons.help_outline,
                  iconColor: const Color(0xFFD97706),
                  iconBgColor: const Color(0xFFFEF3C7),
                  title: 'Review Items',
                  subtitle: 'Risks + open questions',
                  value:
                      '${dashboard.metrics.risksCount + dashboard.metrics.openQuestionsCount}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundHomeScreen,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.grey),
          SizedBox(width: 6.w),
          Text(
            label,
            style: regularStyle(
              fontSize: FontSize.font12,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
