// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';
import 'package:http/http.dart' as http;

class ProjectCard extends StatefulWidget {
  final String id;
  final String title;
  final String clientName;
  final String status;
  final String description;
  final String comments;
  final VoidCallback? onDeleted;

  const ProjectCard({
    super.key,
    required this.id,
    required this.title,
    required this.clientName,
    required this.status,
    required this.description,
    required this.comments,
    this.onDeleted,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isDeleting = false;

  // ── Status helpers ────────────────────────────────────────────────────────

  String get _statusLabel {
    switch (widget.status.trim()) {
      case 'InProgress':
        return 'IN PROGRESS';
      case 'Completed':
        return 'FINISHED';
      case 'Drafted':
        return 'Draft';
      default:
        return widget.status;
    }
  }

  Color get _statusBg {
    switch (widget.status.trim()) {
      case 'InProgress':
        return AppColors.statusInProgressLight;
      case 'Completed':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color get _statusColor {
    switch (widget.status.trim()) {
      case 'InProgress':
        return AppColors.statusInProgress;
      case 'Completed':
        return AppColors.statusFinished;
      default:
        return AppColors.lightgrey;
    }
  }

  Color get _progressColor {
    switch (widget.status.trim()) {
      case 'InProgress':
        return AppColors.statusInProgress;
      case 'Completed':
        return AppColors.statusFinished;
      default:
        return AppColors.lightgrey;
    }
  }

  Color get _viewBtnColor {
    switch (widget.status.trim()) {
      case 'InProgress':
        return AppColors.statusInProgress;
      default:
        return AppColors.primary;
    }
  }

  // ── Delete API ────────────────────────────────────────────────────────────

  Future<void> _deleteProject() async {
    setState(() => _isDeleting = true);
    try {
      final uri = Uri.parse(
        'https://mock.apidog.com/m1/1212435-1208182-default/api/projects/${widget.id}',
      );
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer ANY_TOKEN',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Project deleted successfully',
              style: semiBoldStyle(
                  fontSize: FontSize.font14, color: AppColors.white),
            ),
            backgroundColor: AppColors.statusFinished,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ),
        );
        widget.onDeleted?.call();
      } else {
        _showErrorSnack('Failed to delete. Please try again.');
      }
    } catch (_) {
      if (mounted) _showErrorSnack('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: semiBoldStyle(
                fontSize: FontSize.font14, color: AppColors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  // ── Delete Confirmation Dialog ────────────────────────────────────────────

  void _showDeleteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                child: Icon(Icons.delete_outline,
                    color: Colors.red, size: 22.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text('Delete Project',
                    style: boldStyle(
                        fontSize: FontSize.font18, color: AppColors.black)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this project?\nThis action cannot be undone.',
                style: regularStyle(
                    fontSize: FontSize.font14, color: AppColors.grey),
              ),
              SizedBox(height: 16.h),
              Text('Type the project name to confirm:',
                  style: semiBoldStyle(
                      fontSize: FontSize.font12, color: AppColors.black)),
              SizedBox(height: 8.h),
              TextField(
                controller: controller,
                onChanged: (_) => setD(() {}),
                decoration: InputDecoration(
                  hintText: widget.title,
                  hintStyle: regularStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.lightgrey),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide:
                          BorderSide(color: AppColors.lightgrey)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.primary)),
                ),
              ),
            ],
          ),
          actionsPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          actions: [
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.lightgrey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('Cancel',
                      style: semiBoldStyle(
                          fontSize: FontSize.font14,
                          color: AppColors.black)),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      controller.text.trim() == widget.title.trim()
                          ? () {
                              Navigator.pop(ctx);
                              _deleteProject();
                            }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor:
                        Colors.red.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('Delete Project',
                      style: semiBoldStyle(
                          fontSize: FontSize.font14,
                          color: AppColors.white)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isDeleting ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Card(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: const Color(0xFFE5E7EB), width: 1.w),
        ),
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status row ────────────────────────────────────────────────
              Row(children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 4.h, horizontal: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: _statusBg,
                  ),
                  child: Text(_statusLabel,
                      style: semiBoldStyle(
                          fontSize: FontSize.font12, color: _statusColor)),
                ),
                const Spacer(),
                Icon(Icons.file_download_outlined,
                    size: 20.sp, color: AppColors.lightgrey),
                SizedBox(width: 2.w),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert,
                      size: 20.sp, color: AppColors.lightgrey),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  onSelected: (v) {
                    if (v == 'delete') _showDeleteDialog();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            color: Colors.red, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text('Delete',
                            style: regularStyle(
                                fontSize: FontSize.font14,
                                color: Colors.red)),
                      ]),
                    ),
                  ],
                ),
              ]),

              SizedBox(height: 12.h),

              // ── Title ─────────────────────────────────────────────────────
              Text(widget.title,
                  style: boldStyle(
                      fontSize: FontSize.font18, color: AppColors.black)),

              SizedBox(height: 4.h),

              Text(widget.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: regularStyle(
                      fontSize: FontSize.font14, color: AppColors.lightgrey)),

              SizedBox(height: 14.h),

              Text('Requirements Generation',
                  style: boldStyle(
                      fontSize: FontSize.font14, color: AppColors.black)),

              SizedBox(height: 8.h),

              // ── Progress bar ──────────────────────────────────────────────
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: LinearProgressIndicator(
                      value: 0.30,
                      minHeight: 8.h,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_progressColor),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text('30%',
                    style: regularStyle(
                        fontSize: FontSize.font14, color: _progressColor)),
              ]),

              SizedBox(height: 14.h),

              // ── Generated / Comments ──────────────────────────────────────
              Row(children: [
                Icon(Icons.checklist_outlined,
                    size: 22.sp, color: AppColors.lightgrey),
                SizedBox(width: 8.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Generated',
                      style: regularStyle(
                          fontSize: FontSize.font12,
                          color: AppColors.lightgrey)),
                  Text('18 features',
                      style: boldStyle(
                          fontSize: FontSize.font14, color: AppColors.black)),
                ]),
                const Spacer(),
                Icon(Icons.chat_bubble_outline,
                    size: 22.sp, color: AppColors.lightgrey),
                SizedBox(width: 8.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Client comments',
                      style: regularStyle(
                          fontSize: FontSize.font12,
                          color: AppColors.lightgrey)),
                  Text('${widget.comments} unsolved',
                      style: boldStyle(
                          fontSize: FontSize.font14, color: AppColors.black)),
                ]),
              ]),

              SizedBox(height: 14.h),

              // ── Client ────────────────────────────────────────────────────
              Row(children: [
                CircleAvatar(
                  radius: 14.r,
                  backgroundImage:
                      const AssetImage('assets/images/RequraAvatar.png'),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(widget.clientName,
                      overflow: TextOverflow.ellipsis,
                      style: regularStyle(
                          fontSize: FontSize.font14, color: AppColors.black)),
                ),
              ]),

              SizedBox(height: 14.h),

              // ── Buttons ───────────────────────────────────────────────────
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.lightgrey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text('Edit',
                        style: regularStyle(
                            fontSize: FontSize.font14,
                            color: AppColors.black)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _viewBtnColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text('View Details',
                        style: regularStyle(
                            fontSize: FontSize.font14, color: AppColors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}