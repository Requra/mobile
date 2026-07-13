import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

/// Classification section with project type checkboxes displayed as
/// outlined containers with icons (matching the web design).
class ClassificationSection extends StatelessWidget {
  final List<String> selectedTypes;
  final ValueChanged<String> onToggleType;

  const ClassificationSection({
    super.key,
    required this.selectedTypes,
    required this.onToggleType,
  });

  static const _typeOptions = [
    _TypeOption('Financial', Icons.account_balance_outlined),
    _TypeOption('Medical', Icons.medical_services_outlined),
    _TypeOption('Educational', Icons.school_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Section header
        Row(
          children: [
            Icon(Icons.category_outlined, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'CLASSIFICATION',
              style: boldStyle(
                fontSize: FontSize.font14,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        /// Label
        Row(
          children: [
            Text(
              'Project Type',
              style: semiBoldStyle(
                fontSize: FontSize.font13,
                color: AppColors.black,
              ),
            ),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 13.sp)),
          ],
        ),
        SizedBox(height: 10.h),

        /// Type chips in a grid-like wrap
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: _typeOptions.map((opt) {
            final isSelected = selectedTypes.contains(opt.label);
            return GestureDetector(
              onTap: () => onToggleType(opt.label),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.lightPrimaryBorder
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Checkbox icon
                    Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.lightgrey,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 14.sp,
                              color: AppColors.white,
                            )
                          : null,
                    ),
                    SizedBox(width: 8.w),

                    /// Category icon
                    Icon(
                      opt.icon,
                      size: 18.sp,
                      color: isSelected ? AppColors.primary : AppColors.grey,
                    ),
                    SizedBox(width: 6.w),

                    /// Label
                    Text(
                      opt.label,
                      style: regularStyle(
                        fontSize: FontSize.font13,
                        color: isSelected ? AppColors.primary : AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TypeOption {
  final String label;
  final IconData icon;
  const _TypeOption(this.label, this.icon);
}
