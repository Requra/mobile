import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_details_colors.dart';

/// The style of an action button.
enum MeetingActionStyle { primary, danger, dangerSolid, purple, outline }

/// Horizontally scrollable row of contextual action buttons.
/// The set of buttons shown varies by meeting status.
class MeetingActionButtons extends StatelessWidget {
  final String status;

  const MeetingActionButtons({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
    final buttons = <Widget>[];

    if (s == 'LIVE') {
      buttons.add(_ActionButton(emoji: '📹', label: 'Join Now', style: MeetingActionStyle.purple));
    }

    buttons.add(const _ActionButton(emoji: '👤', label: 'Invite', style: MeetingActionStyle.outline));

    if (s == 'SCHEDULED') {
      buttons.addAll([
        const _ActionButton(emoji: '✏️', label: 'Edit Details', style: MeetingActionStyle.outline),
        const _ActionButton(emoji: '▶', label: 'Start Meeting', style: MeetingActionStyle.primary),
        const _ActionButton(emoji: '⊗', label: 'Cancel Meeting', style: MeetingActionStyle.danger),
      ]);
    } else if (s == 'CANCELLED') {
      buttons.add(const _ActionButton(emoji: '▶', label: 'Start Meeting', style: MeetingActionStyle.primary));
    } else if (s == 'LIVE') {
      buttons.addAll([
        const _ActionButton(emoji: '■', label: 'End Meeting', style: MeetingActionStyle.dangerSolid),
        const _ActionButton(emoji: '⊗', label: 'Cancel Meeting', style: MeetingActionStyle.danger),
      ]);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
      child: Row(
        children: buttons
            .map((b) => Padding(padding: EdgeInsets.only(right: 8.w), child: b))
            .toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final MeetingActionStyle style;

  const _ActionButton({
    required this.emoji,
    required this.label,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = _resolve(style);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: fg,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  static (Color, Color, Color) _resolve(MeetingActionStyle s) {
    switch (s) {
      case MeetingActionStyle.primary:
        return (MeetingDetailsColors.green, Colors.white, MeetingDetailsColors.green);
      case MeetingActionStyle.danger:
        return (MeetingDetailsColors.redSoft, MeetingDetailsColors.red, const Color(0xFFF6C9CA));
      case MeetingActionStyle.dangerSolid:
        return (const Color(0xFFB3261E), Colors.white, const Color(0xFFB3261E));
      case MeetingActionStyle.purple:
        return (MeetingDetailsColors.purple, Colors.white, MeetingDetailsColors.purple);
      case MeetingActionStyle.outline:
        return (Colors.white, MeetingDetailsColors.ink, MeetingDetailsColors.border);
    }
  }
}
