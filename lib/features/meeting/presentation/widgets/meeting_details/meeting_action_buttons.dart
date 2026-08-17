import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_colors.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_invite_sheet.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/presentation/pages/pre_join_meeting_screen.dart';
import 'package:requra/features/meeting/presentation/pages/create_meeting_screen.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_cubit.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

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
    if (s == 'CANCELLED') {
      return const SizedBox.shrink();
    }
    
    final buttons = <Widget>[];

    void joinMeeting() {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<MeetingCubit>(),
            child: PreJoinMeetingScreen(meeting: meeting),
          ),
        ),
      );
    }

    void startAndJoinMeeting() async {
      if (!context.mounted) return;
      final cubit = context.read<MeetingCubit>();
      final error = await cubit.startMeeting(meeting.id);

      if (!context.mounted) return;

      if (error != null) {
        AppSnackbar.showError(context, error);
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: PreJoinMeetingScreen(meeting: meeting),
          ),
        ),
      );
    }

    void editDetails() {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<MeetingCubit>(),
            child: CreateMeetingScreen(
              projectId: meeting.projectId,
              meeting: meeting,
            ),
          ),
        ),
      ).then((result) {
        if (result == true && context.mounted) {
          // Pop back to the meetings list since the meeting was updated
          Navigator.of(context).pop();
        }
      });
    }

    void cancelMeeting() {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text('Cancel Meeting', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: MeetingDetailsColors.ink, fontFamily: FontConstants.fontFamily)),
          content: Text(
            'Are you sure you want to cancel this meeting? This action cannot be undone.',
            style: TextStyle(fontSize: 14.sp, color: MeetingDetailsColors.inkSoft, fontFamily: FontConstants.fontFamily),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('No, Keep It', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: MeetingDetailsColors.purple, fontFamily: FontConstants.fontFamily)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (!context.mounted) return;

                final cubit = context.read<MeetingCubit>();
                final error = await cubit.cancelMeeting(meeting.id);

                if (context.mounted) {
                  if (error == null) {
                    AppSnackbar.showSuccess(context, 'Meeting cancelled successfully');
                    Navigator.of(context).pop();
                  } else {
                    AppSnackbar.showError(context, error);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB3261E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                elevation: 0,
              ),
              child: Text('Yes, Cancel Meeting', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: FontConstants.fontFamily)),
            ),
          ],
        ),
      );
    }

    void endMeeting() {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text('End Meeting', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: MeetingDetailsColors.ink, fontFamily: FontConstants.fontFamily)),
          content: Text(
            'Are you sure you want to end this live meeting? This action cannot be undone.',
            style: TextStyle(fontSize: 14.sp, color: MeetingDetailsColors.inkSoft, fontFamily: FontConstants.fontFamily),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: MeetingDetailsColors.purple, fontFamily: FontConstants.fontFamily)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (!context.mounted) return;

                final cubit = context.read<MeetingCubit>();
                final error = await cubit.endMeeting(meeting.id);

                if (context.mounted) {
                  if (error == null) {
                    AppSnackbar.showSuccess(context, 'Meeting ended successfully');
                    Navigator.of(context).pop();
                  } else {
                    AppSnackbar.showError(context, error);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB3261E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                elevation: 0,
              ),
              child: Text('Yes, End Meeting', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: FontConstants.fontFamily)),
            ),
          ],
        ),
      );
    }

    if (s == 'LIVE') {
      buttons.add(_ActionButton(
        icon: Icons.videocam_outlined, 
        label: 'Join Now', 
        style: MeetingActionStyle.purple,
        onTap: joinMeeting,
      ));
    }

    buttons.add(_ActionButton(
      icon: Icons.person_add_alt, 
      label: 'Invite', 
      style: MeetingActionStyle.outline,
      onTap: () {
        MeetingInviteSheet.show(
          context,
          meetingId: meeting.id,
          projectId: meeting.projectId,
          joinUrl: meeting.joinUrl,
        );
      },
    ));

    if (s == 'SCHEDULED') {
      buttons.addAll([
        _ActionButton(
          icon: Icons.edit_outlined, 
          label: 'Edit Details', 
          style: MeetingActionStyle.outline,
          onTap: editDetails,
        ),
        _ActionButton(
          icon: Icons.play_arrow_outlined, 
          label: 'Start Meeting', 
          style: MeetingActionStyle.primary,
          onTap: startAndJoinMeeting,
        ),
        _ActionButton(
          icon: Icons.cancel_outlined, 
          label: 'Cancel Meeting', 
          style: MeetingActionStyle.danger,
          onTap: cancelMeeting,
        ),
      ]);
    } else if (s == 'CANCELLED') {
      // Handled above
    } else if (s == 'LIVE') {
      buttons.addAll([
        _ActionButton(
          icon: Icons.stop_outlined, 
          label: 'End Meeting', 
          style: MeetingActionStyle.dangerSolid,
          onTap: endMeeting,
        ),
        _ActionButton(
          icon: Icons.cancel_outlined, 
          label: 'Cancel Meeting', 
          style: MeetingActionStyle.danger,
          onTap: cancelMeeting,
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
  final IconData icon;
  final String label;
  final MeetingActionStyle style;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
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
            Icon(icon, size: 16.sp, color: fg),
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
