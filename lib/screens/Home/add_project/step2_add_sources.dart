import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/add_project/presentation/cubit/add_project_cubit.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/project_enums.dart';
import 'package:requra/screens/Home/add_project/widgets/source_item_card.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

/// Step 2 of the Add Project wizard — "Add Requirement Sources".
class Step2AddSources extends StatefulWidget {
  const Step2AddSources({super.key});

  @override
  State<Step2AddSources> createState() => _Step2AddSourcesState();
}

class _Step2AddSourcesState extends State<Step2AddSources> {

  // ── Source management ────────────────────────────────────────────────────

  void _addSource(SourceItem source) {
    context.read<AddProjectCubit>().addSource(source);
  }

  void _removeSource(int index) {
    context.read<AddProjectCubit>().removeSource(index);
  }

  // ── File upload ──────────────────────────────────────────────────────────

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt', 'mp3', 'mp4'],
        withData: false, // Changed to false to prevent unknown_path exceptions for cloud files
      );

      if (result == null || result.files.isEmpty) return;

      for (final file in result.files) {
        if (file.path != null) {
          final ext = '.${file.extension ?? ''}';
          // Read bytes manually from the cached local path
          final bytes = await File(file.path!).readAsBytes();
          
          _addSource(
            SourceItem(
              fileName: file.name,
              fileSizeBytes: file.size,
              documentType: DocumentType.fromExtension(ext).value,
              fileBytes: bytes,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load file. Try downloading it to your device first.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Read the sources from the state
    final cubitState = context.watch<AddProjectCubit>().state;
    final List<SourceItem> sources = (cubitState is AddProjectStep2) ? cubitState.sources : [];
    final String? projectId = (cubitState is AddProjectStep2) ? cubitState.projectId : null;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        bottom: 400.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──
          Center(
            child: Column(
              children: [
                Text(
                  'Add Requirement Sources',
                  style: boldStyle(
                    fontSize: FontSize.font22,
                    color: AppColors.darkgrey,
                  ),
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'Choose one or more sources to help AI understand your project',
                    style: regularStyle(
                      fontSize: FontSize.font13,
                      color: AppColors.lightgrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          _buildDocumentsTab(),

          SizedBox(height: 24.h),

          // ── Uploaded Sources ──
          Text(
            'Uploaded Sources',
            style: semiBoldStyle(
              fontSize: FontSize.font14,
              color: AppColors.darkgrey,
            ),
          ),
          SizedBox(height: 12.h),
          if (sources.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFEEEEF0)),
              ),
              child: Center(
                child: Text(
                  'No sources added yet',
                  style: regularStyle(
                    fontSize: FontSize.font12,
                    color: AppColors.lightgrey,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 72.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sources.length,
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
                itemBuilder: (_, i) => SourceItemCard(
                  source: sources[i],
                  onRemove: () => _removeSource(i),
                ),
              ),
            ),
          SizedBox(height: 28.h),

          // ── Buttons ──
          Row(
            children: [
              // Back
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      context.read<AddProjectCubit>().goBackToStep1(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(color: AppColors.borderButton),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: semiBoldStyle(
                      fontSize: FontSize.font14,
                      color: AppColors.darkgrey,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Generate
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: LinearGradient(
                      colors: sources.isEmpty 
                          ? [AppColors.grey, AppColors.grey]
                          : [AppColors.lightPrimary, AppColors.primary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: sources.isEmpty || projectId == null ? null : () =>
                          context.read<AddProjectCubit>().uploadAndGenerate(projectId, sources),
                      borderRadius: BorderRadius.circular(14.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Generate',
                              style: boldStyle(
                                fontSize: FontSize.font14,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 18.r,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ── Documents Tab ────────────────────────────────────────────────────────

  Widget _buildDocumentsTab() {
    return GestureDetector(
      onTap: _pickFiles,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 32.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFD0D0D5),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFFD0D0D5),
            radius: 16.r,
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 40.r,
                color: AppColors.lightgrey,
              ),
              SizedBox(height: 12.h),
              Text(
                'Click or drag file to this area to upload',
                style: semiBoldStyle(
                  fontSize: FontSize.font13,
                  color: AppColors.darkgrey,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Supported formats: PDF, DOCX, TXT, MP3, MP4.',
                style: regularStyle(
                  fontSize: FontSize.font11,
                  color: AppColors.lightgrey,
                ),
              ),
              SizedBox(height: 20.h),
              OutlinedButton(
                onPressed: _pickFiles,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 12.h,
                  ),
                  side: BorderSide(color: AppColors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Upload Files',
                  style: semiBoldStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.darkgrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for dashed border effect on the Documents upload zone.
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    // The dashed effect is handled by the parent container's border.
    // This painter is a placeholder for visual enhancement if needed.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
