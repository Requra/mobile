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

class EditRequirementDialog extends StatefulWidget {
  final AiRequirement requirement;
  final String projectId;

  const EditRequirementDialog({
    super.key,
    required this.requirement,
    required this.projectId,
  });

  @override
  State<EditRequirementDialog> createState() => _EditRequirementDialogState();
}

class _EditRequirementDialogState extends State<EditRequirementDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedPriority;
  bool _isLoading = false;

  final List<String> _priorities = ['Critical', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.requirement.title);
    _descriptionController =
        TextEditingController(text: widget.requirement.description);
    
    // Ensure priority exists in the list, otherwise fallback to Medium
    _selectedPriority = widget.requirement.priority;
    if (!_priorities.contains(_selectedPriority)) {
      _selectedPriority = 'Medium';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description are required.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final cubit = context.read<ResultViewCubit>();

    // 1. Update content
    final error = await cubit.updateRequirement(
      widget.projectId,
      widget.requirement.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: widget.requirement.type,
      priority: _selectedPriority,
    );

    if (error != null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating content: $error')),
        );
      }
      return;
    }

    // 2. Update status to EDITED
    final statusError = await cubit.updateRequirementStatus(
      widget.projectId,
      widget.requirement.id,
      'EDITED',
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (statusError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $statusError')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Requirement updated successfully')),
        );
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
                  Text(
                    'Edit requirement',
                    style: boldStyle(
                        fontSize: FontSize.font20, color: AppColors.black),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Manual edits invalidate any previous approval and return the item to an explicit review decision.',
                style: regularStyle(
                    fontSize: FontSize.font14, color: AppColors.grey),
              ),
              SizedBox(height: 16.h),
              Divider(height: 1, color: const Color(0xFFE5E7EB)),
              SizedBox(height: 24.h),
              
              CustomTextFormField(
                label: 'Title *',
                controller: _titleController,
              ),
              SizedBox(height: 16.h),
              
              CustomTextFormField(
                label: 'Description *',
                controller: _descriptionController,
                maxLines: 4,
              ),
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      label: 'Type',
                      hint: widget.requirement.type,
                      enabled: false,
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
                    width: 140.w,
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
