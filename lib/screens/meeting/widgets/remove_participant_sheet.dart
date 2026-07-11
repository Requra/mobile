import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/meeting/data/models/meeting_models.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

/// Bottom sheet for confirming removal of a participant from the meeting.
class RemoveParticipantSheet extends StatelessWidget {
  const RemoveParticipantSheet({
    super.key,
    required this.participant,
    required this.onConfirm,
  });

  final Participant participant;
  final VoidCallback onConfirm;

  /// Convenience helper to show this sheet.
  static Future<void> show(
    BuildContext context, {
    required Participant participant,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RemoveParticipantSheet(
        participant: participant,
        onConfirm: onConfirm,
      ),
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

          // ── Warning icon ──
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: AppColors.liveRed.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_remove_rounded,
              color: AppColors.liveRed,
              size: 28.r,
            ),
          ),
          SizedBox(height: 16.h),

          // ── Title ──
          Text(
            'Remove participant?',
            style: semiBoldStyle(
              fontSize: FontSize.font18,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 8.h),

          // ── Subtitle ──
          Text(
            'Remove ${participant.displayName} from this meeting?',
            textAlign: TextAlign.center,
            style: regularStyle(
              fontSize: FontSize.font14,
              color: Colors.white60,
            ),
          ),
          SizedBox(height: 28.h),

          // ── Buttons ──
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.liveRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Remove',
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
