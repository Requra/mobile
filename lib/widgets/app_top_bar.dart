import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: const Color(0xFFEDE7FF),
          ),
          child: Image(
            image: const AssetImage('assets/images/logo.png'),
            height: 16.h,
            width: 16.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.smart_toy,
                color: const Color(0xFF7B5DD4),
                size: 14.sp,
              );
            },
          ),
        ),
        const Spacer(),
        const AppActionIcon(icon: Icons.notifications_none),
        SizedBox(width: 10.w),
        const AppActionIcon(icon: Icons.menu),
      ],
    );
  }
}

class AppActionIcon extends StatelessWidget {
  const AppActionIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFE4E4E8)),
      ),
      child: Icon(icon, color: AppColors.grey, size: 17.sp),
    );
  }
}
