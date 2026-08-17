import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
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
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 35.h,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 8.w),
          Text(
            'Requra.ai',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6B46C1),
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ],
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(2.h),
        child: Container(
          color: const Color(0xFF6B46C1),
          height: 2.h,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 2.h);
}