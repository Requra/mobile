import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
class CircularIcon extends StatelessWidget {
  const CircularIcon({
    super.key,
    required this.icon,
    this.color1 = AppColors.primary,
    this.color2 = AppColors.lightPrimary,
    this.iconColor = AppColors.white,
    this.borderColor,
    this.size,
  });

  final IconData icon;
  final Color color1;
  final Color color2;
  final Color? borderColor;
  final Color iconColor;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      width: 100.w,
      decoration: BoxDecoration(
        border: borderColor != null ? Border.all(color: borderColor! , width: 4.r) : null,
        gradient: LinearGradient(colors: [color1 , color2] , begin: Alignment.bottomLeft , end: Alignment.topRight),
        borderRadius: BorderRadius.all(Radius.circular(50.r)),
      ),
      child: Icon(
        icon, color: iconColor,
        size: size ?? 20.r,
      ),
    );
  }
}

