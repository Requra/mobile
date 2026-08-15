import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';

class ApproveCircleButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final double size;

  const ApproveCircleButton({
    super.key,
    required this.isLoading,
    required this.onTap,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.h,
      width: size.h,
      child: isLoading
          ? Center(
              child: SizedBox(
                height: (size * 0.6).h,
                width: (size * 0.6).h,
                child: const CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular((size / 2).h),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: (size * 0.6).sp,
                  color: AppColors.statusFinished,
                ),
              ),
            ),
    );
  }
}
