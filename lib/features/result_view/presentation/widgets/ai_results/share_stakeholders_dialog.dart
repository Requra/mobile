import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/meeting/presentation/helpers/date_helper.dart';
import 'package:requra/features/result_view/domain/entities/review_invitation.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_state.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

class ShareStakeholdersDialog extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ShareStakeholdersDialog({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ShareStakeholdersDialog> createState() =>
      _ShareStakeholdersDialogState();
}

class _ShareStakeholdersDialogState extends State<ShareStakeholdersDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedPermission = 'COMMENTER';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    context.read<ResultViewCubit>().fetchReviewInvitations(widget.projectId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendInvitation() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || email.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    final error = await context.read<ResultViewCubit>().sendReviewInvitation(
      projectId: widget.projectId,
      displayName: name,
      email: email,
      permission: _selectedPermission,
      // Let backend handle default expiration or we can pass one if required
      // expiresAt: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    );

    setState(() {
      _isSending = false;
    });

    if (error == null) {
      _nameController.clear();
      _emailController.clear();
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Invitation sent successfully');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        width: 600.w,
        constraints: BoxConstraints(maxHeight: 800.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.people_outline,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8.w,
                                runSpacing: 4.h,
                                children: [
                                  Text(
                                    'Share with stakeholders',
                                    style: boldStyle(
                                      fontSize: FontSize.font20,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: const Color(0xFFFDE68A),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.science_outlined,
                                          size: 12.sp,
                                          color: const Color(0xFFD97706),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'Simulation',
                                          style: semiBoldStyle(
                                            fontSize: FontSize.font10,
                                            color: const Color(0xFFD97706),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Invite stakeholders to review the generated results for ${widget.projectName}.',
                                style: regularStyle(
                                  fontSize: FontSize.font14,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            size: 20.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Form Section
                    _buildFormSection(),

                    SizedBox(height: 24.h),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: semiBoldStyle(
                              fontSize: FontSize.font14,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        ElevatedButton.icon(
                          onPressed: _isSending ? null : _handleSendInvitation,
                          icon: _isSending
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.send_outlined,
                                  size: 16.sp,
                                  color: AppColors.white,
                                ),
                          label: Text(
                            'Send invitation',
                            style: semiBoldStyle(
                              fontSize: FontSize.font14,
                              color: AppColors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                            ),
                            minimumSize: Size(0, 40.h),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Existing Invitations Section
              Container(
                color: const Color(0xFFF9FAFB),
                padding: EdgeInsets.all(24.w),
                child: BlocBuilder<ResultViewCubit, ResultViewState>(
                  builder: (context, state) {
                    if (state is! ResultViewLoaded) {
                      return const SizedBox.shrink();
                    }

                    if (state.invitationsLoading &&
                        state.reviewInvitations == null) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    final response = state.reviewInvitations;
                    if (response == null || response.items.isEmpty) {
                      return Center(
                        child: Text(
                          'No existing invitations',
                          style: regularStyle(
                            fontSize: FontSize.font14,
                            color: AppColors.grey,
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Existing invitations',
                                  style: boldStyle(
                                    fontSize: FontSize.font16,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Manage who has access to this review.',
                                  style: regularStyle(
                                    fontSize: FontSize.font12,
                                    color: AppColors.grey,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '${response.pendingCount} PENDING · ${response.acceptedCount} ACCEPTED',
                                  style: semiBoldStyle(
                                    fontSize: FontSize.font12,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: response.items.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            return _buildInvitationCard(
                              response.items[index],
                              context,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        Text(
          'Stakeholder display name *',
          style: semiBoldStyle(
            fontSize: FontSize.font14,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g. Client Manager',
            hintStyle: regularStyle(
              fontSize: FontSize.font14,
              color: AppColors.grey,
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Email
        Text(
          'Stakeholder email *',
          style: semiBoldStyle(
            fontSize: FontSize.font14,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'name@company.com',
            hintStyle: regularStyle(
              fontSize: FontSize.font14,
              color: AppColors.grey,
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Permission
        Text(
          'Permission',
          style: semiBoldStyle(
            fontSize: FontSize.font14,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Column(
          children: [
            _buildPermissionCard(
              title: 'Viewer',
              subtitle: 'Can read shared results only.',
              icon: Icons.remove_red_eye_outlined,
              value: 'VIEWER',
              isSelected: _selectedPermission == 'VIEWER',
            ),
            SizedBox(height: 12.h),
            _buildPermissionCard(
              title: 'Commenter',
              subtitle: 'Can read results and leave feedback.',
              icon: Icons.chat_bubble_outline,
              value: 'COMMENTER',
              isSelected: _selectedPermission == 'COMMENTER',
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Info Banner
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 16.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Stakeholders receive a unique, expiring review link. You can revoke access at any time.',
                  style: regularStyle(
                    fontSize: FontSize.font12,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPermission = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3E8FF) : AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                icon,
                size: 16.sp,
                color: isSelected ? AppColors.primary : AppColors.grey,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: semiBoldStyle(
                      fontSize: FontSize.font14,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: regularStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20.sp,
              color: isSelected ? AppColors.primary : AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationCard(ReviewInvitationItem item, BuildContext ctx) {
    final bool isAccepted = item.status == 'ACCEPTED';
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Name + Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 20.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + status + permission badges (wrapping)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: [
                        Text(
                          item.displayName,
                          style: boldStyle(
                            fontSize: FontSize.font14,
                            color: AppColors.black,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: isAccepted
                                ? AppColors.statusFinishedLight
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            item.status,
                            style: semiBoldStyle(
                              fontSize: FontSize.font10,
                              color: isAccepted
                                  ? AppColors.statusFinished
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            item.permission == 'COMMENTER'
                                ? 'Commenter'
                                : 'Viewer',
                            style: semiBoldStyle(
                              fontSize: FontSize.font10,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    // Email
                    Text(
                      item.email,
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12.sp,
                          color: AppColors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            'Invited ${item.createdAt != null ? formatDate(item.createdAt!) : ''}${item.expiresAt != null ? ' · Expires ${formatDate(item.expiresAt!)}' : ''}',
                            style: regularStyle(
                              fontSize: FontSize.font12,
                              color: AppColors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action buttons — right-aligned below content
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isAccepted)
                TextButton.icon(
                  onPressed: () async {
                    final error = await ctx
                        .read<ResultViewCubit>()
                        .resendReviewInvitation(
                          projectId: widget.projectId,
                          invitationId: item.id,
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(error ?? 'Invitation resent')),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.refresh,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Resend',
                    style: semiBoldStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              TextButton.icon(
                onPressed: () async {
                  final error = await ctx
                      .read<ResultViewCubit>()
                      .revokeReviewInvitation(
                        projectId: widget.projectId,
                        invitationId: item.id,
                      );
                  if (mounted && error != null) {
                    ScaffoldMessenger.of(
                      ctx,
                    ).showSnackBar(SnackBar(content: Text(error)));
                  }
                },
                icon: Icon(
                  Icons.delete_outline,
                  size: 16.sp,
                  color: const Color(0xFFDC2626),
                ),
                label: Text(
                  'Revoke',
                  style: semiBoldStyle(
                    fontSize: FontSize.font12,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),

          // Review URL
          if (item.reviewUrl != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 16.sp, color: AppColors.grey),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      item.reviewUrl!,
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.reviewUrl!));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard'),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy, size: 14.sp, color: AppColors.white),
                    label: Text(
                      'Copy link',
                      style: semiBoldStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
