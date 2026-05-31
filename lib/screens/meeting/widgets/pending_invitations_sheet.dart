import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/meeting/data/models/meeting_models.dart';
import 'package:requra/features/meeting/data/services/meeting_service.dart';
import 'package:requra/screens/meeting/widgets/confirmation_sheet.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

/// Bottom sheet listing pending invitations with Resend / Revoke actions.
class PendingInvitationsSheet extends StatefulWidget {
  const PendingInvitationsSheet({
    super.key,
    required this.meetingId,
    required this.invitations,
    required this.onRefresh,
  });

  final String meetingId;
  final List<Invitation> invitations;
  final VoidCallback onRefresh;

  /// Convenience helper to show this sheet.
  static Future<void> show(
    BuildContext context, {
    required String meetingId,
    required List<Invitation> invitations,
    required VoidCallback onRefresh,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PendingInvitationsSheet(
        meetingId: meetingId,
        invitations: invitations,
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  State<PendingInvitationsSheet> createState() =>
      _PendingInvitationsSheetState();
}

class _PendingInvitationsSheetState extends State<PendingInvitationsSheet> {
  final MeetingService _service = const MeetingService();
  final Set<String> _loadingIds = {};

  List<Invitation> get _pending =>
      widget.invitations
          .where((i) => i.status == InvitationStatus.pending)
          .toList();

  Future<void> _resend(Invitation inv) async {
    setState(() => _loadingIds.add('resend_${inv.id}'));
    final response = await _service.resendInvitation(
      widget.meetingId,
      inv.id,
    );
    if (!mounted) return;
    setState(() => _loadingIds.remove('resend_${inv.id}'));

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation resent to ${inv.displayName}'),
          backgroundColor: AppColors.timerGreen,
        ),
      );
    } else {
      _showError(response.message);
    }
  }

  Future<void> _revoke(Invitation inv) async {
    final confirmed = await ConfirmationSheet.show(
      context,
      title: 'Revoke invitation?',
      subtitle: 'Revoke the invitation sent to ${inv.displayName}?',
      confirmLabel: 'Revoke',
      confirmColor: AppColors.liveRed,
      icon: Icons.link_off_rounded,
    );
    if (!confirmed || !mounted) return;

    setState(() => _loadingIds.add('revoke_${inv.id}'));
    final response = await _service.revokeInvitation(
      widget.meetingId,
      inv.id,
    );
    if (!mounted) return;
    setState(() => _loadingIds.remove('revoke_${inv.id}'));

    if (response.isSuccess) {
      widget.onRefresh();
      if (mounted) Navigator.pop(context);
    } else {
      _showError(response.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.liveRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Invitation> pending = _pending;

    return Container(
      constraints: BoxConstraints(maxHeight: 0.7.sh),
      decoration: BoxDecoration(
        color: AppColors.meetingCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          top: BorderSide(color: AppColors.meetingCardBorder, width: 1),
          left: BorderSide(color: AppColors.meetingCardBorder, width: 1),
          right: BorderSide(color: AppColors.meetingCardBorder, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Icon(Icons.mail_outline_rounded,
                        color: AppColors.consentAmber, size: 22.r),
                    SizedBox(width: 10.w),
                    Text(
                      'Pending Invitations',
                      style: semiBoldStyle(
                        fontSize: FontSize.font18,
                        color: AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.consentAmber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${pending.length}',
                        style: semiBoldStyle(
                          fontSize: FontSize.font12,
                          color: AppColors.consentAmber,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Divider(color: AppColors.meetingCardBorder, height: 1),
              ],
            ),
          ),

          // ── List ──
          Flexible(
            child: pending.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      'No pending invitations',
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: Colors.white38,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
                    itemCount: pending.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: AppColors.meetingCardBorder, height: 24.h),
                    itemBuilder: (_, index) =>
                        _InvitationRow(
                          invitation: pending[index],
                          isResending:
                              _loadingIds.contains('resend_${pending[index].id}'),
                          isRevoking:
                              _loadingIds.contains('revoke_${pending[index].id}'),
                          onResend: () => _resend(pending[index]),
                          onRevoke: () => _revoke(pending[index]),
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InvitationRow extends StatelessWidget {
  const _InvitationRow({
    required this.invitation,
    required this.isResending,
    required this.isRevoking,
    required this.onResend,
    required this.onRevoke,
  });

  final Invitation invitation;
  final bool isResending;
  final bool isRevoking;
  final VoidCallback onResend;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Avatar ──
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: AppColors.consentAmber.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _initials(invitation.displayName),
            style: semiBoldStyle(
              fontSize: FontSize.font12,
              color: AppColors.consentAmber,
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // ── Name + Email ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invitation.displayName,
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                invitation.email,
                style: regularStyle(
                  fontSize: FontSize.font11,
                  color: Colors.white38,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // ── Actions ──
        _ActionButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Resend',
          isLoading: isResending,
          color: AppColors.roleMember,
          onTap: onResend,
        ),
        SizedBox(width: 6.w),
        _ActionButton(
          icon: Icons.close_rounded,
          tooltip: 'Revoke',
          isLoading: isRevoking,
          color: AppColors.liveRed,
          onTap: onRevoke,
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.isLoading,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isLoading;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 34.r,
          height: 34.r,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: isLoading
              ? Padding(
                  padding: EdgeInsets.all(8.r),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Icon(icon, color: color, size: 18.r),
        ),
      ),
    );
  }
}
