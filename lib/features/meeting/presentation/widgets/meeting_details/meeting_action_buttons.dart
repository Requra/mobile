import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_colors.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/presentation/pages/pre_join_meeting_screen.dart';

/// The style of an action button.
enum MeetingActionStyle { primary, danger, dangerSolid, purple, outline }

/// Horizontally scrollable row of contextual action buttons.
/// The set of buttons shown varies by meeting status.
class MeetingActionButtons extends StatelessWidget {
  final Meeting meeting;

  const MeetingActionButtons({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    final s = meeting.status.toUpperCase();
    final buttons = <Widget>[];

    void joinMeeting() {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreJoinMeetingScreen(meeting: meeting),
        ),
      );
    }

    if (s == 'LIVE') {
      buttons.add(_ActionButton(
        emoji: '📹', 
        label: 'Join Now', 
        style: MeetingActionStyle.purple,
        onTap: joinMeeting,
      ));
    }

    buttons.add(_ActionButton(
      emoji: '👤', 
      label: 'Invite', 
      style: MeetingActionStyle.outline,
      onTap: () {},
    ));

    if (s == 'SCHEDULED') {
      buttons.addAll([
        _ActionButton(
          emoji: '✏️', 
          label: 'Edit Details', 
          style: MeetingActionStyle.outline,
          onTap: () {},
        ),
        _ActionButton(
          emoji: '▶', 
          label: 'Start Meeting', 
          style: MeetingActionStyle.primary,
          onTap: joinMeeting,
        ),
        _ActionButton(
          emoji: '⊗', 
          label: 'Cancel Meeting', 
          style: MeetingActionStyle.danger,
          onTap: () {},
        ),
      ]);
    } else if (s == 'CANCELLED') {
      buttons.add(_ActionButton(
        emoji: '▶', 
        label: 'Start Meeting', 
        style: MeetingActionStyle.primary,
        onTap: joinMeeting,
      ));
    } else if (s == 'LIVE') {
      buttons.addAll([
        _ActionButton(
          emoji: '■', 
          label: 'End Meeting', 
          style: MeetingActionStyle.dangerSolid,
          onTap: () {},
        ),
        _ActionButton(
          emoji: '⊗', 
          label: 'Cancel Meeting', 
          style: MeetingActionStyle.danger,
          onTap: () {},
        ),
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
  final VoidCallback onTap;

  const _ActionButton({
    required this.emoji,
    required this.label,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = _resolve(style);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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

