import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

import '../theme/color_manager.dart';

class SocialAuthButtonsRow extends StatelessWidget {
  const SocialAuthButtonsRow({
    super.key,
    this.onGoogleTap,
    this.isGoogleLoading = false,
  });

  final VoidCallback? onGoogleTap;
  final bool isGoogleLoading;

  @override
  Widget build(BuildContext context) {
    final borderStyle = OutlinedButton.styleFrom(
      side: BorderSide(color: AppColors.lightgrey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h),
    );

    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text('or continue with' , style: boldStyle(fontSize: FontSize.font12, color: AppColors.black),),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: borderStyle,
                onPressed: isGoogleLoading ? null : onGoogleTap,
                child: isGoogleLoading
                    ? SizedBox(
                        width: 18.sp,
                        height: 18.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const SweepGradient(
                          colors: [
                            Color(0xFF4285F4),
                            Color(0xFFEA4335),
                            Color(0xFFFBBC05),
                            Color(0xFF34A853),
                            Color(0xFF4285F4),
                          ],
                          stops: [0.0, 0.28, 0.52, 0.78, 1.0],
                        ).createShader(bounds),
                        child: FaIcon(
                          FontAwesomeIcons.google,
                          color: AppColors.white,
                          size: 20.sp,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: OutlinedButton(
                style: borderStyle,
                onPressed: () {},
                child: FaIcon(
                  FontAwesomeIcons.github,
                  color: AppColors.black,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
