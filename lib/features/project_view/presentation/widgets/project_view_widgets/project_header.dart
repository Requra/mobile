import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class ProjectHeader extends StatelessWidget {
  final VoidCallback onAddProject;

  const ProjectHeader({super.key, required this.onAddProject});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('All Projects', style: boldStyle(fontSize: FontSize.font22, color: AppColors.black)),
          SizedBox(height: 6.h),
          Text(
            'Manage and organize your AI-generated requirement projects',
            textAlign: TextAlign.center,
            style: regularStyle(fontSize: FontSize.font14, color: AppColors.grey),
          ),
          SizedBox(height: 14.h),
          CustomButton(
            text: 'New Project',
            icon: Icons.add,
            onTap: onAddProject,
            color1: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
