import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

/// A horizontal 3-step progress indicator for the Add Project wizard.
///
/// Steps: "Project Details" → "Add Sources" → "AI Generate"
///
/// [currentStep] is 0-indexed:
///   0 = Project Details (active)
///   1 = Add Sources (active)
///   2 = AI Generate (active)
class ProjectStepper extends StatelessWidget {
  const ProjectStepper({super.key, required this.currentStep});

  final int currentStep;

  static const _labels = ['Project Details', 'Add Sources', 'AI Generate'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (index) {
          // Even indices = step circles, odd indices = connecting lines
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            return _StepCircle(
              stepNumber: stepIndex + 1,
              label: _labels[stepIndex],
              isCompleted: stepIndex < currentStep,
              isActive: stepIndex == currentStep,
            );
          } else {
            final lineIndex = index ~/ 2;
            return _ConnectingLine(isCompleted: lineIndex < currentStep);
          }
        }),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.stepNumber,
    required this.label,
    required this.isCompleted,
    required this.isActive,
  });

  final int stepNumber;
  final String label;
  final bool isCompleted;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.primary
                : (isActive ? Colors.transparent : Colors.transparent),
            border: Border.all(
              color: isCompleted || isActive
                  ? AppColors.primary
                  : const Color(0xFFD0D0D5),
              width: 2.r,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 16.r)
                : Text(
                    '$stepNumber',
                    style: semiBoldStyle(
                      fontSize: FontSize.font12,
                      color: isActive
                          ? AppColors.primary
                          : const Color(0xFFD0D0D5),
                    ),
                  ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: regularStyle(
            fontSize: FontSize.font10,
            color: isCompleted || isActive
                ? AppColors.primary
                : AppColors.lightgrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ConnectingLine extends StatelessWidget {
  const _ConnectingLine({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Container(
          height: 2.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primary : const Color(0xFFD0D0D5),
            borderRadius: BorderRadius.circular(1.r),
          ),
        ),
      ),
    );
  }
}
