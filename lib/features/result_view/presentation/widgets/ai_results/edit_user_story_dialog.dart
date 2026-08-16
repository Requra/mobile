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
import 'package:requra/features/result_view/presentation/widgets/ai_results/shared/priority_dropdown.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

class EditUserStoryDialog extends StatefulWidget {
  final AiUserStory userStory;
  final String projectId;

  const EditUserStoryDialog({
    super.key,
    required this.userStory,
    required this.projectId,
  });

  @override
  State<EditUserStoryDialog> createState() => _EditUserStoryDialogState();
}

class _EditUserStoryDialogState extends State<EditUserStoryDialog> {
  late TextEditingController _titleController;
  late TextEditingController _storyController;
  late TextEditingController _acController;
  late String _selectedPriority;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.userStory.title);
    _storyController = TextEditingController(text: widget.userStory.userStory);
    _acController = TextEditingController(text: widget.userStory.acceptanceCriteria.join('\n'));
    _selectedPriority = widget.userStory.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    _acController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty || _storyController.text.trim().isEmpty) {
      AppSnackbar.showError(context, 'Title and story text are required.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final cubit = context.read<ResultViewCubit>();
    
    final acList = _acController.text.trim().split('\n').where((s) => s.trim().isNotEmpty).toList();

    final error = await cubit.updateUserStory(
      widget.projectId,
      widget.userStory.id,
      title: _titleController.text.trim(),
      description: widget.userStory.description, // Keeping existing description
      acceptanceCriteria: acList,
      priority: _selectedPriority,
    );

    if (error == null && mounted) {
      // Also automatically mark it as EDITED
      await cubit.updateUserStoryStatus(
        widget.projectId,
        widget.userStory.id,
        'EDITED',
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (error != null) {
        AppSnackbar.showError(context, 'Error updating user story: $error');
      } else {
        AppSnackbar.showSuccess(context, 'User story updated successfully');
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
                children: [
                  Expanded(
                    child: Text(
                      'Edit user story',
                      style: boldStyle(
                          fontSize: FontSize.font20, color: AppColors.black),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Divider(height: 1.h, color: const Color(0xFFE5E7EB)),
              SizedBox(height: 24.h),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextFormField(
                      label: 'Title *',
                      hint: 'Enter title',
                      controller: _titleController,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: PriorityDropdown(
                      value: _selectedPriority,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPriority = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              CustomTextFormField(
                label: 'User story *',
                hint: 'As a [role], I want [feature] so that [benefit]',
                controller: _storyController,
                maxLines: 4,
              ),
              SizedBox(height: 16.h),
              
              CustomTextFormField(
                label: 'Acceptance Criteria',
                hint: 'Enter criteria separated by new lines',
                controller: _acController,
                maxLines: 4,
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
                    width: 120.w,
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
                            text: 'Save changes',
                            onTap: _saveChanges,
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
