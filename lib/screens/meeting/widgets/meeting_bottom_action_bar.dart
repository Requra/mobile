import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/meeting/data/models/meeting_models.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

/// Bottom action bar with 5 circular buttons:
/// Mute | People | Record/Stop (center, larger) | Invite | Leave/End
class MeetingBottomActionBar extends StatelessWidget {
  const MeetingBottomActionBar({
    super.key,
    required this.isMuted,
    required this.isHost,
    required this.recordingStatus,
    required this.onMuteToggle,
    required this.onPeopleTap,
    required this.onRecordTap,
    required this.onInviteTap,
    required this.onLeaveOrEndTap,
    this.isRecordingLoading = false,
  });

  final bool isMuted;
  final bool isHost;
  final RecordingStatus? recordingStatus;
  final VoidCallback onMuteToggle;
  final VoidCallback onPeopleTap;
  final VoidCallback onRecordTap;
  final VoidCallback onInviteTap;
  final VoidCallback onLeaveOrEndTap;
  final bool isRecordingLoading;

  bool get _isRecordingActive => recordingStatus == RecordingStatus.active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.meetingCard,
        border: Border(
          top: BorderSide(color: AppColors.meetingCardBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ── Mute ──
                _ActionBtn(
                  icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  label: isMuted ? 'Unmute' : 'Mute',
                  bgColor: isMuted
                      ? AppColors.liveRed.withOpacity(0.15)
                      : AppColors.meetingBg,
                  iconColor: isMuted ? AppColors.liveRed : Colors.white70,
                  borderColor: isMuted
                      ? AppColors.liveRed.withOpacity(0.4)
                      : AppColors.meetingCardBorder,
                  onTap: onMuteToggle,
                ),

                // ── People ──
                _ActionBtn(
                  icon: Icons.people_outline_rounded,
                  label: 'People',
                  bgColor: AppColors.meetingBg,
                  iconColor: Colors.white70,
                  borderColor: AppColors.meetingCardBorder,
                  onTap: onPeopleTap,
                ),

                // ── Record / Stop (center, larger) ──
                _CenterRecordBtn(
                  isActive: _isRecordingActive,
                  isLoading: isRecordingLoading,
                  onTap: onRecordTap,
                ),

                // ── Invite ──
                _ActionBtn(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'Invite',
                  bgColor: AppColors.meetingBg,
                  iconColor: Colors.white70,
                  borderColor: AppColors.meetingCardBorder,
                  onTap: onInviteTap,
                ),

                // ── Leave / End ──
                _ActionBtn(
                  icon: Icons.call_end_rounded,
                  label: isHost ? 'End' : 'Leave',
                  bgColor: AppColors.liveRed.withOpacity(0.15),
                  iconColor: AppColors.liveRed,
                  borderColor: AppColors.liveRed.withOpacity(0.4),
                  onTap: onLeaveOrEndTap,
                ),
              ],
            ),

            // ── Home indicator (cosmetic) ──
            SizedBox(height: 12.h),
            Container(
              width: 134.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}

// ── Small action button ─────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Icon(icon, color: iconColor, size: 22.r),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: regularStyle(
              fontSize: FontSize.font10,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Center record / stop button ─────────────────────────────────────────────

class _CenterRecordBtn extends StatefulWidget {
  const _CenterRecordBtn({
    required this.isActive,
    required this.isLoading,
    required this.onTap,
  });

  final bool isActive;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<_CenterRecordBtn> createState() => _CenterRecordBtnState();
}

class _CenterRecordBtnState extends State<_CenterRecordBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isActive) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _CenterRecordBtn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isActive && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) {
              final double scale =
                  widget.isActive ? 1.0 + (_pulse.value * 0.08) : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: widget.isActive
                    ? AppColors.liveRed.withOpacity(0.2)
                    : AppColors.meetingBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isActive
                      ? AppColors.liveRed
                      : AppColors.meetingCardBorder,
                  width: 2,
                ),
              ),
              child: widget.isLoading
                  ? Padding(
                      padding: EdgeInsets.all(14.r),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: widget.isActive
                            ? AppColors.liveRed
                            : Colors.white70,
                      ),
                    )
                  : Icon(
                      widget.isActive
                          ? Icons.stop_rounded
                          : Icons.fiber_manual_record_rounded,
                      color: widget.isActive
                          ? AppColors.liveRed
                          : AppColors.recordingRed,
                      size: 26.r,
                    ),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            widget.isActive ? 'Stop Rec' : 'Start Rec',
            style: regularStyle(
              fontSize: FontSize.font10,
              color: widget.isActive ? AppColors.liveRed : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
