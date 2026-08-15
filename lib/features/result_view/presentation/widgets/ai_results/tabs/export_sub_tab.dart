import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
          _buildDownloadSection(context),

          SizedBox(height: 24.h),

          // Generate Export
          _buildGenerateExport(context),
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
        subtitle: 'Standard requirement and user story columns',
        isReady: dashboard.requirements.isNotEmpty,
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
  Widget _buildDownloadSection(BuildContext context) {
    final int jiraIssues = dashboard.userStories.length;

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

          // Jira-ready JSON
          _buildDownloadItem(
            icon: Icons.developer_board,
            iconColor: AppColors.primary,
            title: 'Jira-ready JSON',
            subtitle: '$jiraIssues issues ready',
            onTap: () {},
          ),
          SizedBox(height: 8.h),

          // Full result JSON
          _buildDownloadItem(
            icon: Icons.download_outlined,
            iconColor: AppColors.primary,
            title: 'Full result JSON',
            subtitle: 'Complete contract payload',
            onTap: () => _exportFullJson(context),
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
    required VoidCallback onTap,
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
            onPressed: onTap,
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
  Widget _buildGenerateExport(BuildContext context) {
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
              _buildExportButton(Icons.table_chart_outlined, 'XLSX', () => _exportRequirementsXlsx(context)),
              SizedBox(width: 12.w),
              _buildExportButton(Icons.description_outlined, 'CSV', () => _exportRequirementsCsv(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
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

  // ─── Export Logic ───
  Future<String?> _getDownloadPath() async {
    if (Platform.isAndroid) {
      // Direct path to Android's public Download folder
      return '/storage/emulated/0/Download';
    } else {
      // For iOS, the public download folder isn't directly accessible without user prompt,
      // so we use the application documents directory (visible in Files app if enabled in Info.plist)
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      // We don't block on denial because Android 11+ allows writing to Downloads without storage permission
    }
  }

  String _getUniqueFileName(String basePath, String filename) {
    File file = File('$basePath/$filename');
    if (!file.existsSync()) return file.path;

    final name = filename.substring(0, filename.lastIndexOf('.'));
    final ext = filename.substring(filename.lastIndexOf('.'));
    int counter = 1;
    
    while (File('$basePath/${name}_$counter$ext').existsSync()) {
      counter++;
    }
    return '$basePath/${name}_$counter$ext';
  }

  Future<void> _exportRequirementsCsv(BuildContext context) async {
    try {
      await _requestPermissions();
      final basePath = await _getDownloadPath();
      if (basePath == null) throw Exception("Could not get download path");

      List<List<dynamic>> rows = [];
      rows.add(["ID", "Title", "Description", "Type", "Priority", "Confidence Score"]);
      for (var req in dashboard.requirements) {
        rows.add([
          req.id,
          req.title,
          req.description,
          req.type,
          req.priority,
          req.confidenceScore
        ]);
      }
      String csv = const CsvEncoder().convert(rows);
      
      final filePath = _getUniqueFileName(basePath, 'requirements.csv');
      final file = File(filePath);
      await file.writeAsString(csv);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to $filePath'), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exporting CSV: $e')));
      }
    }
  }

  Future<void> _exportRequirementsXlsx(BuildContext context) async {
    try {
      await _requestPermissions();
      final basePath = await _getDownloadPath();
      if (basePath == null) throw Exception("Could not get download path");

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Requirements'];
      excel.setDefaultSheet('Requirements');
      
      sheetObject.appendRow([
        TextCellValue("ID"), 
        TextCellValue("Title"), 
        TextCellValue("Description"), 
        TextCellValue("Type"), 
        TextCellValue("Priority"), 
        TextCellValue("Confidence Score")
      ]);
      
      for (var req in dashboard.requirements) {
        sheetObject.appendRow([
          TextCellValue(req.id),
          TextCellValue(req.title),
          TextCellValue(req.description),
          TextCellValue(req.type),
          TextCellValue(req.priority),
          DoubleCellValue(req.confidenceScore),
        ]);
      }
      
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final filePath = _getUniqueFileName(basePath, 'requirements.xlsx');
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to $filePath'), backgroundColor: AppColors.primary),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exporting XLSX: $e')));
      }
    }
  }

  Future<void> _exportFullJson(BuildContext context) async {
    try {
      await _requestPermissions();
      final basePath = await _getDownloadPath();
      if (basePath == null) throw Exception("Could not get download path");

      final data = dashboard.rawJson ?? {};
      String jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      
      final filePath = _getUniqueFileName(basePath, 'full_result.json');
      final file = File(filePath);
      await file.writeAsString(jsonStr);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to $filePath'), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exporting JSON: $e')));
      }
    }
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
