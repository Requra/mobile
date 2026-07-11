import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;

  const CustomAppBar({
    super.key,
    this.onNotificationTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Image.asset('assets/images/logo.png', height: 35.h),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: onNotificationTap ?? () {},
          icon: Icon(Icons.notifications_none, color: AppColors.black),
        ),
        IconButton(
          onPressed: onMenuTap ?? () {},
          icon: Icon(Icons.menu, color: AppColors.black),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}