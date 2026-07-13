import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';

class ProjectErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const ProjectErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.lightgrey),
          SizedBox(height: 12.h),
          Text('Could not load projects.', style: TextStyle(color: AppColors.grey)),
          SizedBox(height: 12.h),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.30,
            child: CustomButton(
              text: "Retry",
              onTap: onRetry,
              color1: AppColors.primary,
              raduis: 30,
            ),
          ),
        ],
      ),
    );
  }
}
