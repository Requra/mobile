import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/global_widgets/custom_text_form_field.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

class RegenerateUserStoryDialog extends StatefulWidget {
  final AiUserStory userStory;
  final String projectId;

  const RegenerateUserStoryDialog({
    super.key,
    required this.userStory,
    required this.projectId,
  });

  @override
  State<RegenerateUserStoryDialog> createState() => _RegenerateUserStoryDialogState();
}

class _RegenerateUserStoryDialogState extends State<RegenerateUserStoryDialog> {
  late TextEditingController _instructionsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _instructionsController = TextEditingController();
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _regenerate() async {
    if (_instructionsController.text.trim().isEmpty) {
      AppSnackbar.showError(context, 'Regeneration instructions are required.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final cubit = context.read<ResultViewCubit>();

    final error = await cubit.regenerateUserStory(
      widget.projectId,
      widget.userStory.id,
      _instructionsController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (error != null) {
        AppSnackbar.showError(context, 'Error regenerating user story: $error');
      } else {
        AppSnackbar.showSuccess(context, 'User story regenerated successfully');
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.primary, size: 24.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Regenerate with AI',
                            style: boldStyle(
                                fontSize: FontSize.font20, color: AppColors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Give precise instructions. The new revision will be saved as Needs review and never auto-approved.',
                style: regularStyle(
                    fontSize: FontSize.font14, color: AppColors.grey),
              ),
              SizedBox(height: 16.h),
              Divider(height: 1, color: const Color(0xFFE5E7EB)),
              SizedBox(height: 24.h),
              
              CustomTextFormField(
                label: 'Regeneration instructions *',
                hint: 'e.g. Include specific metrics for performance requirements',
                controller: _instructionsController,
                maxLines: 5,
              ),
              SizedBox(height: 8.h),
              
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _instructionsController,
                builder: (context, value, child) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${value.text.length} / 4,000',
                      style: regularStyle(
                          fontSize: FontSize.font12, color: AppColors.grey),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 32.h),
              Divider(height: 1, color: const Color(0xFFE5E7EB)),
              SizedBox(height: 24.h),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: semiBoldStyle(
                          fontSize: FontSize.font14, color: AppColors.black),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  SizedBox(
                    width: 160.w,
                    child: _isLoading
                        ? Center(
                            child: SizedBox(
                              height: 24.h,
                              width: 24.h,
                              child: const CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          )
                        : CustomButton(
                            text: 'Regenerate story',
                            icon: Icons.autorenew,
                            onTap: _regenerate,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
