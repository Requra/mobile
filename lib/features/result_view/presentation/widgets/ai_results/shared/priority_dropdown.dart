import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class PriorityDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final List<String> priorities;

  const PriorityDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.priorities = const ['Critical', 'High', 'Medium', 'Low'],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: semiBoldStyle(
            fontSize: FontSize.font13,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: priorities.contains(value) ? value : priorities.first,
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
          items: priorities.map((String priority) {
            return DropdownMenuItem<String>(
              value: priority,
              child: Text(
                priority,
                style: regularStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
