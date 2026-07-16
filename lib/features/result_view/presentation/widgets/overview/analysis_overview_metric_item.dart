import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class AnalysisOverviewMetricItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const AnalysisOverviewMetricItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.sp, color: iconColor),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                label,
                style: regularStyle(
                  fontSize: FontSize.font11,
                  color: AppColors.lightgrey,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.only(left: 22.w),
          child: Text(
            value,
            style: boldStyle(
              fontSize: FontSize.font20,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
