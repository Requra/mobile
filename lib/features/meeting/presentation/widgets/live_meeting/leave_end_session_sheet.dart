import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

/// Result of the leave/end session dialog.
enum LeaveEndResult {
  /// The user chose to leave the meeting only.
  leaveOnly,

  /// The host chose to end for all participants.
  endForAll,
}

/// A dark-themed bottom sheet matching the "Leave or End Session?" design.
///
/// For hosts it shows three options: Cancel, Leave Only, End for All.
/// For non-hosts it shows two options: Cancel, Leave Only.
///
/// Returns a [LeaveEndResult] or `null` if cancelled.
class LeaveEndSessionSheet extends StatelessWidget {
  const LeaveEndSessionSheet({
    super.key,
    required this.isHost,
  });

  final bool isHost;

  /// Convenience helper to show this sheet and await the result.
  static Future<LeaveEndResult?> show(
    BuildContext context, {
    required bool isHost,
  }) {
    return showModalBottomSheet<LeaveEndResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LeaveEndSessionSheet(isHost: isHost),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle bar ──
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // ── Title row with close button ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHost ? 'Leave or End Session?' : 'Leave Session?',
                style: semiBoldStyle(
                  fontSize: FontSize.font18,
                  color: AppColors.white,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white60,
                    size: 18.r,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ── Subtitle ──
          Text(
            isHost
                ? 'As the host, you can end this meeting for all active participants or leave it yourself while keeping the session active.'
                : 'You can leave the meeting. The session will remain active for other participants.',
            style: regularStyle(
              fontSize: FontSize.font14,
              color: Colors.white60,
            ),
          ),
          SizedBox(height: 28.h),

          // ── Buttons row ──
          Row(
            children: [
              // Cancel
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 12.w,
                    top: 12.h,
                    bottom: 12.h,
                  ),
                  child: Text(
                    'Cancel',
                    style: semiBoldStyle(
                      fontSize: FontSize.font14,
                      color: Colors.white60,
                    ),
                  ),
                ),
              ),

              // Leave Only
              Expanded(
                child: SizedBox(
                  height: 44.h,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context, LeaveEndResult.leaveOnly),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.meetingCardBorder,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Leave Only',
                        style: semiBoldStyle(
                          fontSize: FontSize.font14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // End for All (host only)
              if (isHost) ...[
                SizedBox(width: 8.w),
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, LeaveEndResult.endForAll),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.liveRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'End for All',
                          style: semiBoldStyle(
                            fontSize: FontSize.font14,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
