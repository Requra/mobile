import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class ReviewActionPopupMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onReject;
  final VoidCallback? onRegenerate;
  final bool showRegenerate;
  final Color iconColor;

  const ReviewActionPopupMenu({
    super.key,
    required this.onEdit,
    required this.onReject,
    this.onRegenerate,
    this.showRegenerate = false,
    this.iconColor = AppColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_vert, color: iconColor, size: 20.sp),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'reject') {
          onReject();
        } else if (value == 'regenerate' && onRegenerate != null) {
          onRegenerate!();
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20.sp, color: AppColors.black),
              SizedBox(width: 8.w),
              Text(
                'Edit content',
                style: regularStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
        if (showRegenerate)
          PopupMenuItem<String>(
            value: 'regenerate',
            child: Row(
              children: [
                Icon(Icons.autorenew, size: 20.sp, color: AppColors.black),
                SizedBox(width: 8.w),
                Text(
                  'Regenerate with AI',
                  style: regularStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'reject',
          child: Row(
            children: [
              Icon(Icons.thumb_down_outlined,
                  size: 20.sp, color: AppColors.error),
              SizedBox(width: 8.w),
              Text(
                'Reject with feedback',
                style: regularStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
