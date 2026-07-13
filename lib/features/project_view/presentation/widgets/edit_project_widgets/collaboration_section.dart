import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_text_form_field.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

/// Collaboration & Scope section — Description textarea, team member
/// input with add-button, and member chips.
class CollaborationSection extends StatelessWidget {
  final TextEditingController descriptionController;
  final TextEditingController memberController;
  final List<String> teamMembers;
  final VoidCallback onAddMember;
  final ValueChanged<String> onRemoveMember;

  const CollaborationSection({
    super.key,
    required this.descriptionController,
    required this.memberController,
    required this.teamMembers,
    required this.onAddMember,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Section header
        Row(
          children: [
            Icon(Icons.people_outline, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'COLLABORATION & SCOPE',
              style: boldStyle(
                fontSize: FontSize.font14,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        /// Project Description
        CustomTextFormField(
          label: 'Project Description',
          hint: 'Describe your project goals and scope...',
          controller: descriptionController,
          maxLines: 5,
          validator: (v) => v!.trim().isEmpty ? 'Required' : null,
        ),
        SizedBox(height: 20.h),

        /// Team Members
        Text(
          'Team Members',
          style: semiBoldStyle(
            fontSize: FontSize.font13,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                hint: 'member@example.com',
                controller: memberController,
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (_) => onAddMember(),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: onAddMember,
              child: Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  color: AppColors.white,
                  size: 22.sp,
                ),
              ),
            ),
          ],
        ),

        /// Member chips
        if (teamMembers.isNotEmpty) ...[
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: teamMembers.map((email) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: AppColors.lightPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      email,
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () => onRemoveMember(email),
                      child: Icon(
                        Icons.close,
                        size: 14.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
