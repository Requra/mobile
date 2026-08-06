import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';

class EvidenceSubTab extends StatelessWidget {
  final AiResultsDashboard dashboard;

  const EvidenceSubTab({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Source Documents Card ───
          _buildSectionCard(
            icon: Icons.description_outlined,
            title: 'Source Documents',
            count: dashboard.sourceDocuments.length,
            subtitle: 'Documents analyzed in this run',
            child: Column(
              children: dashboard.sourceDocuments.map((doc) {
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundHomeScreen,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 20.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.title,
                              style: semiBoldStyle(
                                fontSize: FontSize.font14,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              doc.mimeType.isNotEmpty
                                  ? doc.mimeType
                                  : 'application/pdf',
                              style: regularStyle(
                                fontSize: FontSize.font12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 24.h),

          // ─── Requirement Coverage Card ───
          _buildSectionCard(
            icon: Icons.link,
            title: 'Requirement Coverage',
            subtitle: 'Traceability from requirements to user stories',
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: constraints.maxWidth > 700.w ? constraints.maxWidth : 700.w,
                    child: Column(
                      children: [
                        // Table header
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundHomeScreen,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.r),
                              topRight: Radius.circular(8.r),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'REQUIREMENT',
                                  style: boldStyle(
                                    fontSize: FontSize.font10,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'LINKED USER STORIES',
                                  style: boldStyle(
                                    fontSize: FontSize.font10,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'COVERAGE',
                                  style: boldStyle(
                                    fontSize: FontSize.font10,
                                    color: AppColors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'STATUS',
                                  style: boldStyle(
                                    fontSize: FontSize.font10,
                                    color: AppColors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Table rows
                        ...dashboard.requirementCoverages.map((cov) {
                          // Find the requirement title
                          final req = dashboard.requirements
                              .where((r) => r.id == cov.requirementId)
                              .firstOrNull;
                          final reqTitle = req?.title ?? cov.requirementId;

                          // Find linked user stories
                          final linkedStories = cov.userStoryIds
                              .map((sid) {
                                final us = dashboard.userStories
                                    .where((s) => s.id == sid)
                                    .firstOrNull;
                                return us?.title ?? sid;
                              })
                              .toList();

                          final isCovered =
                              cov.coverageStatus.toLowerCase() == 'covered';
                          final coveragePercent = isCovered ? '100%' : '0%';

                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: const Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Requirement
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cov.requirementId,
                                        style: regularStyle(
                                          fontSize: FontSize.font10,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        reqTitle,
                                        style: semiBoldStyle(
                                          fontSize: FontSize.font14,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Linked User Stories
                                Expanded(
                                  flex: 3,
                                  child: linkedStories.isEmpty
                                      ? Text(
                                          'No linked stories',
                                          style: regularStyle(
                                            fontSize: FontSize.font12,
                                            color: AppColors.grey,
                                          ).copyWith(fontStyle: FontStyle.italic),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: linkedStories
                                              .map(
                                                (title) => Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 2.h),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.link,
                                                        size: 14.sp,
                                                        color: AppColors.primary,
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Expanded(
                                                        child: Text(
                                                          title,
                                                          style: semiBoldStyle(
                                                            fontSize:
                                                                FontSize.font12,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                ),

                                // Coverage
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    coveragePercent,
                                    style: boldStyle(
                                      fontSize: FontSize.font14,
                                      color: AppColors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // Status
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: isCovered
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFFEE2E2),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isCovered
                                                ? Icons.check_circle_outline
                                                : Icons.error_outline,
                                            size: 14.sp,
                                            color: isCovered
                                                ? AppColors.statusFinished
                                                : AppColors.error,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            isCovered ? 'Covered' : 'Uncovered',
                                            style: semiBoldStyle(
                                              fontSize: FontSize.font10,
                                              color: isCovered
                                                  ? AppColors.statusFinished
                                                  : AppColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    int? count,
    required String subtitle,
    required Widget child,
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
                  color: AppColors.backgroundHomeScreen,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Icon(icon, size: 20.sp, color: AppColors.grey),
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
                            color: AppColors.black,
                          ),
                        ),
                        if (count != null) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.lightButton,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '$count',
                              style: semiBoldStyle(
                                fontSize: FontSize.font12,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}
