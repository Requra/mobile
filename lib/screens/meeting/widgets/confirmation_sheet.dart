import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

/// A generic dark-themed confirmation bottom sheet.
///
/// Returns `true` from [showModalBottomSheet] when the user confirms.
class ConfirmationSheet extends StatelessWidget {
  const ConfirmationSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.confirmLabel = 'Confirm',
    this.confirmColor,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final String confirmLabel;
  final Color? confirmColor;
  final IconData? icon;

  /// Convenience helper to show this sheet and await the result.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    String confirmLabel = 'Confirm',
    Color? confirmColor,
    IconData? icon,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ConfirmationSheet(
        title: title,
        subtitle: subtitle,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = confirmColor ?? AppColors.liveRed;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.meetingCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          top: BorderSide(color: AppColors.meetingCardBorder, width: 1),
          left: BorderSide(color: AppColors.meetingCardBorder, width: 1),
          right: BorderSide(color: AppColors.meetingCardBorder, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar ──
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),

          // ── Icon ──
          if (icon != null) ...[
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 28.r),
            ),
            SizedBox(height: 16.h),
          ],

          // ── Title ──
          Text(
            title,
            textAlign: TextAlign.center,
            style: semiBoldStyle(
              fontSize: FontSize.font18,
              color: AppColors.white,
            ),
          ),

          // ── Subtitle ──
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: regularStyle(
                fontSize: FontSize.font14,
                color: Colors.white60,
              ),
            ),
          ],

          SizedBox(height: 28.h),

          // ── Buttons ──
          Row(
            children: [
              // Cancel
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.meetingCardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: semiBoldStyle(
                        fontSize: FontSize.font14,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Confirm
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmLabel,
                      style: semiBoldStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
