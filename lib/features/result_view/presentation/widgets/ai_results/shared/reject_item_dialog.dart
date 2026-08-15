import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/global_widgets/custom_text_form_field.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class RejectItemDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<String?> Function(String feedback) onReject;
  final String successMessage;
  final String label;
  final String hint;

  const RejectItemDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onReject,
    required this.successMessage,
    this.label = 'Decision reason *',
    this.hint = 'Explain what changed or what needs correction.',
  });

  @override
  State<RejectItemDialog> createState() => _RejectItemDialogState();
}

class _RejectItemDialogState extends State<RejectItemDialog> {
  late TextEditingController _reasonController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleReject() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.label.replaceAll(' *', '')} is required.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final error = await widget.onReject(_reasonController.text.trim());

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.successMessage)),
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
                    widget.title,
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
                widget.subtitle,
                style: regularStyle(
                    fontSize: FontSize.font14, color: AppColors.grey),
              ),
              SizedBox(height: 16.h),
              Divider(height: 1, color: const Color(0xFFE5E7EB)),
              SizedBox(height: 24.h),
              
              CustomTextFormField(
                label: widget.label,
                hint: widget.hint,
                controller: _reasonController,
                maxLines: 5,
                onFieldSubmitted: (_) => _handleReject(),
              ),
              SizedBox(height: 8.h),
              
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _reasonController,
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
                            text: 'Reject',
                            onTap: _handleReject,
                            color1: AppColors.error,
                            color2: AppColors.error,
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
