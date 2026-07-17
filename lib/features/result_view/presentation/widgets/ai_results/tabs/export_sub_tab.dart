import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';

class ExportSubTab extends StatelessWidget {
  final AiResultsDashboard dashboard;

  const ExportSubTab({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width <= 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Export Readiness + Export Preview
          isMobile
              ? Column(
                  children: [
                    _buildExportReadiness(),
                    SizedBox(height: 16.h),
                    _buildExportPreview(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _buildExportReadiness()),
                    SizedBox(width: 16.w),
                    Expanded(flex: 2, child: _buildExportPreview()),
                  ],
                ),

          SizedBox(height: 24.h),

          // Download from this run
          _buildDownloadSection(),

          SizedBox(height: 24.h),

          // Generate Export
          _buildGenerateExport(),
        ],
      ),
    );
  }

  // ─── Export Readiness ───
  Widget _buildExportReadiness() {
    final checks = <_ReadinessCheck>[
      _ReadinessCheck(
        icon: Icons.check_circle_outline,
        title: 'Requirements extracted',
        subtitle: '${dashboard.metrics.totalRequirements} requirements available',
        isReady: dashboard.metrics.totalRequirements > 0,
      ),
      _ReadinessCheck(
        icon: Icons.check_circle_outline,
        title: 'User stories generated',
        subtitle: '${dashboard.metrics.userStories} stories available',
        isReady: dashboard.metrics.userStories > 0,
      ),
      _ReadinessCheck(
        icon: Icons.check_circle_outline,
        title: 'XLSX export supported',
        subtitle: dashboard.exports.excel.available && dashboard.exports.excel.columns != null
            ? '${dashboard.exports.excel.columns!.length} columns: ${dashboard.exports.excel.columns!.take(4).join(', ')}…'
            : 'Not available',
        isReady: dashboard.exports.excel.available,
      ),
      _ReadinessCheck(
        icon: Icons.check_circle_outline,
        title: 'Run has a valid ID',
        subtitle: 'Run: ${dashboard.analysisRunId.length > 12 ? '${dashboard.analysisRunId.substring(0, 12)}…' : dashboard.analysisRunId}',
        isReady: dashboard.analysisRunId.isNotEmpty,
      ),
    ];

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
              Icon(Icons.verified_outlined,
                  size: 20.sp, color: AppColors.grey),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Readiness',
                    style: boldStyle(
                      fontSize: FontSize.font16,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    'Pre-flight checks before export',
                    style: regularStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...checks.map((c) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Icon(
                      c.isReady
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      size: 20.sp,
                      color: c.isReady
                          ? AppColors.statusFinished
                          : AppColors.error,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.title,
                            style: semiBoldStyle(
                              fontSize: FontSize.font14,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            c.subtitle,
                            style: regularStyle(
                              fontSize: FontSize.font12,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: c.isReady
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        c.isReady ? 'Ready' : 'N/A',
                        style: boldStyle(
                          fontSize: FontSize.font10,
                          color: c.isReady
                              ? AppColors.statusFinished
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ─── Export Preview ───
  Widget _buildExportPreview() {
    // Build rows from requirements
    final previewRows = dashboard.requirements.take(5).toList();

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
              Icon(Icons.table_chart_outlined,
                  size: 20.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Preview',
                    style: boldStyle(
                      fontSize: FontSize.font16,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    'Showing first ${previewRows.length} of ${dashboard.requirements.length} requirements',
                    style: regularStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),

          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: constraints.maxWidth > 600.w ? constraints.maxWidth : 600.w,
                  child: Column(
                    children: [
                      // Table header
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundHomeScreen,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.r),
                            topRight: Radius.circular(8.r),
                          ),
                        ),
                        child: Row(
                          children: [
                            _headerCell('ID', flex: 2),
                            _headerCell('TITLE', flex: 3),
                            _headerCell('TYPE', flex: 2),
                            _headerCell('PRIORITY', flex: 2),
                            _headerCell('CONFIDENCE', flex: 2),
                          ],
                        ),
                      ),

                      // Table rows
                      ...previewRows.map((req) {
                        return Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
                              _dataCell(req.id, flex: 2, color: AppColors.grey),
                              _dataCell(req.title, flex: 3),
                              _dataCell(req.type, flex: 2),
                              _dataCell(req.priority, flex: 2),
                              _dataCell('${(req.confidenceScore * 100).toInt()}%',
                                  flex: 2),
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
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: boldStyle(fontSize: FontSize.font10, color: AppColors.primary),
      ),
    );
  }

  Widget _dataCell(String text, {required int flex, Color? color}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: regularStyle(
          fontSize: FontSize.font12,
          color: color ?? AppColors.black,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ─── Download from this run ───
  Widget _buildDownloadSection() {
    final int excelRows = dashboard.exports.excel.rows?.length ?? 0;
    final int jiraIssues = dashboard.exports.jira.rows?.length ?? 0;

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
              Icon(Icons.file_copy_outlined,
                  size: 20.sp, color: AppColors.grey),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download from this run',
                    style: boldStyle(
                      fontSize: FontSize.font16,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    'Generated in your browser — no server needed',
                    style: regularStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Requirements CSV
          _buildDownloadItem(
            icon: Icons.description_outlined,
            iconColor: AppColors.primary,
            title: 'Requirements CSV',
            subtitle: '$excelRows rows ready',
          ),
          SizedBox(height: 8.h),

          // Jira-ready JSON
          _buildDownloadItem(
            icon: Icons.developer_board,
            iconColor: AppColors.primary,
            title: 'Jira-ready JSON',
            subtitle: '$jiraIssues issues ready',
          ),
          SizedBox(height: 8.h),

          // Full result JSON
          _buildDownloadItem(
            icon: Icons.download_outlined,
            iconColor: AppColors.primary,
            title: 'Full result JSON',
            subtitle: 'Complete contract payload (admin / d…',
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundHomeScreen,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, size: 16.sp, color: iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: semiBoldStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.black,
                  ),
                ),
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
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.download, size: 16.sp, color: AppColors.primary),
            label: Text(
              'Download',
              style: semiBoldStyle(
                fontSize: FontSize.font12,
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: const Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Generate Export ───
  Widget _buildGenerateExport() {
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
              Icon(Icons.cloud_download_outlined,
                  size: 20.sp, color: AppColors.grey),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate Export',
                    style: boldStyle(
                      fontSize: FontSize.font16,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    'Download on demand via backend',
                    style: regularStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildExportButton(Icons.table_chart_outlined, 'XLSX'),
              SizedBox(width: 12.w),
              _buildExportButton(Icons.description_outlined, 'CSV'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18.sp, color: AppColors.black),
      label: Text(
        label,
        style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.black),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: const Color(0xFFE5E7EB)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
      ),
    );
  }
}

class _ReadinessCheck {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isReady;

  const _ReadinessCheck({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isReady,
  });
}
