import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_text_form_field.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class CoreInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController clientController;
  final String selectedStatus;
  final List<String> statusOptions;
  final ValueChanged<String> onStatusChanged;

  const CoreInfoSection({
    super.key,
    required this.nameController,
    required this.clientController,
    required this.selectedStatus,
    required this.statusOptions,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Section header
        Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'CORE INFORMATION',
              style: boldStyle(
                fontSize: FontSize.font14,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        /// Project Name
        CustomTextFormField(
          label: 'Project Name',
          hint: 'Enter project name',
          controller: nameController,
          validator: (v) => v!.trim().isEmpty ? 'Required' : null,
        ),
        SizedBox(height: 16.h),

        /// Client Email
        CustomTextFormField(
          label: 'Client Email',
          hint: 'Enter client email',
          controller: clientController,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v!.trim().isEmpty ? 'Required' : null,
        ),
        SizedBox(height: 16.h),

        /// Project Status
        Text(
          'Project Status',
          style: semiBoldStyle(
            fontSize: FontSize.font13,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          initialValue: selectedStatus,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey, size: 22.sp),
          dropdownColor: AppColors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          items: statusOptions
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      s,
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.black,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onStatusChanged(v);
          },
        ),
      ],
    );
  }
}
