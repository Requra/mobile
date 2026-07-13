import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_text_field.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/project_view/presentation/helpers/project_helpers.dart';
import 'package:requra/routes/app_routes.dart';
import 'package:requra/core/global_widgets/custom_button.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onDeleted;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onDeleted,
  });

  ///Status helpers (delegated to project_helpers)
  String get _badge => projectStatusBadge(project.status);
  Color get _statusBg => statusBadgeBg(_badge);
  Color get _statusColor => statusBadgeColor(_badge);

  ///  Delete Dialog
  void _showDeleteDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: AppColors.white,
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: AppColors.lightPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.darkPrimary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Delete Project',
                  style: boldStyle(
                    fontSize: FontSize.font18,
                    color: AppColors.black,
                  ),
                ),
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
                  fontSize: FontSize.font14,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Type the project name to confirm:',
                style: semiBoldStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: project.name,
                onChanged: (_) => setD(() {}),
                controller: controller,
                borderRadius: 8,
              ),
            ],
          ),
          actionsPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child:
                  CustomButton(
                    text: 'Cancel',
                    color1: Colors.transparent,
                    color2: Colors.transparent,
                    transparent: true,
                    borderColor: AppColors.lightgrey,
                    textColor: AppColors.black,
                    isRegularStyle: true,
                    onTap: () => Navigator.pop(ctx),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.text.trim() == project.name.trim()
                        ? () {
                            Navigator.pop(ctx);
                            onDeleted();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Delete',
                      style: semiBoldStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openEditScreen(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.editProject,
      arguments: project,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
            ///status + Action buttons (Download and delete)
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 4.h,
                    horizontal: 10.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: _statusBg,
                  ),
                  child: Text(
                    _badge,
                    style: semiBoldStyle(
                      fontSize: FontSize.font12,
                      color: _statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.file_download_outlined,
                  size: 20.sp,
                  color: AppColors.lightgrey,
                ),
                SizedBox(width: 2.w),
                IconButton(
                  onPressed: () {
                    _showDeleteDialog(context);
                  },
                  icon: Icon(
                    Icons.delete_forever_outlined,
                    size: 20.sp,
                    color: AppColors.lightgrey,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            ///Title & description
            Text(
              project.name,
              style: boldStyle(
                fontSize: FontSize.font18,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: regularStyle(
                fontSize: FontSize.font14,
                color: AppColors.lightgrey,
              ),
            ),

            SizedBox(height: 8.h),

            ///stats
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.checklist_outlined,
                      size: 22.sp,
                      color: AppColors.lightgrey,
                    ),
                    title: Text(
                      'Generated',
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.lightgrey,
                      ),
                    ),
                    subtitle: Text(
                      '${project.totalRequirements} features',
                      overflow: TextOverflow.ellipsis,
                      style: boldStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.chat_bubble_outline,
                      size: 22.sp,
                      color: AppColors.lightgrey,
                    ),
                    title: Text(
                      'Comments',
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.lightgrey,
                      ),
                    ),
                    subtitle: Text(
                      '${project.totalComments} unsolved',
                      overflow: TextOverflow.ellipsis,
                      style: boldStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            ///client Email
            Row(
              children: [
                CircleAvatar(
                  radius: 14.r,
                  backgroundImage: const AssetImage(
                    'assets/images/RequraAvatar.png',
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    project.clientName,
                    overflow: TextOverflow.ellipsis,
                    style: regularStyle(
                      fontSize: FontSize.font14,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Edit',
                    color1: Colors.transparent,
                    color2: Colors.transparent,
                    borderColor: AppColors.lightgrey,
                    textColor: AppColors.black,
                    isRegularStyle: true,
                    onTap: () => _openEditScreen(context),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child:
                    CustomButton(
                      text: 'View Details',
                      color1: AppColors.primary,
                      isRegularStyle: true,
                      onTap: () {

                      },
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
