import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class ProjectEmptyState extends StatelessWidget {
  final int tabIndex;
  final VoidCallback onAddProject;

  const ProjectEmptyState({super.key, required this.tabIndex, required this.onAddProject});

  @override
  Widget build(BuildContext context) {
    const labels = ['processing', 'completed', 'draft'];
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty.png',
              width: 180.w,
              height: 180.h,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(Icons.folder_open, size: 100, color: Colors.grey),
            ),
            SizedBox(height: 20.h),
            Text(
              'No ${labels[tabIndex]} found',
              style: boldStyle(fontSize: FontSize.font18, color: AppColors.black),
            ),
            SizedBox(height: 8.h),
            Text(
              "You haven't started any projects in this category yet.\nLet's create your first AI-generated requirement project!",
              textAlign: TextAlign.center,
              style: regularStyle(fontSize: FontSize.font14, color: AppColors.grey),
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Start New Project',
              icon: Icons.add,
              onTap: onAddProject,
              color1: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
