import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            color: Colors.white,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 26.h,
                    width: 26.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.smart_toy,
                        color: AppColors.primary,
                        size: 22.sp,
                      );
                    },
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 20.r,
                  onPressed: () {},
                  icon: const Icon(Icons.menu, color: AppColors.black),
                ),
              ],
            ),
          ),
        ),
        ClipPath(
          clipper: _HeaderCurveClipper(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 46.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.lightPrimary, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: boldStyle(fontSize: FontSize.font22, color: AppColors.white),
                ),
                SizedBox(height: 10.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: regularStyle(fontSize: FontSize.font14, color: AppColors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 22,
      size.width,
      size.height - 28,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
