import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/profile/presentation/widgets/profile_info_row.dart';
import 'package:requra/widgets/action_button.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.nameController,
    required this.email,
    required this.role,
    required this.displayName,
    required this.isEditing,
    required this.avatarImage,
    required this.isUploadingAvatar,
    required this.onEditAvatar,
    required this.onStartEditing,
    required this.onCancelEditing,
    required this.onUpdateProfile,
    required this.isUpdatingProfile,
  });

  final TextEditingController nameController;
  final String email;
  final String role;
  final String displayName;
  final bool isEditing;
  final ImageProvider avatarImage;
  final bool isUploadingAvatar;
  final VoidCallback onEditAvatar;
  final VoidCallback onStartEditing;
  final VoidCallback onCancelEditing;
  final VoidCallback onUpdateProfile;
  final bool isUpdatingProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightPrimary, width: 1.1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 52.w,
                height: 52.w,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 52.w,
                      height: 52.w,
                      child: CircleAvatar(
                        radius: 24.r,
                        backgroundImage: avatarImage,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD8D8DE)),
                        ),
                        child: isUploadingAvatar
                            ? Padding(
                                padding: EdgeInsets.all(2.w),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryText,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.camera_alt),
                                iconSize: 10.sp,
                                color: AppColors.lightgrey,
                                padding: EdgeInsets.zero,
                                onPressed: onEditAvatar,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: semiBoldStyle(
                        fontSize: FontSize.font16,
                        color: AppColors.darkgrey,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.lightgrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: const Color(0xFFE5E5EA), height: 1.h),
          SizedBox(height: 10.h),
          ProfileInfoRow(
            label: 'Name',
            value: displayName,
            isEditable: true,
            isEditing: isEditing,
            controller: nameController,
          ),
          ProfileInfoRow(label: 'Email account', value: email),
          ProfileInfoRow(label: 'Role', value: role),
          SizedBox(height: 4.h),
          isEditing
              ? Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        label: 'Cancel',
                        isPrimary: false,
                        onTap: onCancelEditing,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ActionButton(
                        label: isUpdatingProfile ? 'Updating...' : 'Update',
                        isPrimary: true,
                        onTap: onUpdateProfile,
                      ),
                    ),
                  ],
                )
              : ActionButton(
                  label: 'Edit',
                  isPrimary: true,
                  onTap: onStartEditing,
                  fullWidth: true,
                ),
        ],
      ),
    );
  }
}
