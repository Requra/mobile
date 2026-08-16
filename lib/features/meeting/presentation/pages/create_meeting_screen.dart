import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_cubit.dart';
import 'package:requra/features/meeting/presentation/pages/meeting_details_screen.dart' as requra_meeting_details;
import 'package:requra/core/global_widgets/app_snackbar.dart';

class CreateMeetingScreen extends StatefulWidget {
  final String projectId;

  /// When non-null the screen works in **edit mode**: fields are pre-filled and
  /// the submit button reads "UPDATE" instead of "CREATE MEETING".
  final Meeting? meeting;
  
  const CreateMeetingScreen({
    super.key,
    required this.projectId,
    this.meeting,
  });

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  bool get _isEditMode => widget.meeting != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController.text = widget.meeting!.title;
      _descriptionController.text = widget.meeting!.description;
      _selectedDateTime = widget.meeting!.scheduledAt;
    }
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour < 12 ? 'AM' : 'PM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final monthStr = dt.month.toString().padLeft(2, '0');
    final dayStr = dt.day.toString().padLeft(2, '0');
    return '$monthStr/$dayStr/${dt.year} $hour:$minuteStr $period';
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedDateTime != null
            ? TimeOfDay.fromDateTime(_selectedDateTime!)
            : TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      AppSnackbar.showError(context, 'Meeting title is required');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final cubit = context.read<MeetingCubit>();
    String? formattedDate;
    if (_selectedDateTime != null) {
      formattedDate = _selectedDateTime!.toUtc().toIso8601String();
    }

    String? error;

    if (_isEditMode) {
      error = await cubit.updateMeeting(
        meetingId: widget.meeting!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        scheduledAt: formattedDate,
      );
    } else {
      final result = await cubit.createMeeting(
        projectId: widget.projectId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        scheduledAt: formattedDate,
      );
      if (result is String) {
        error = result;
      } else {
        // It's a Meeting object
        if (mounted) {
          setState(() => _isLoading = false);
          AppSnackbar.showSuccess(context, 'Meeting created successfully');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => BlocProvider.value(
                value: context.read<MeetingCubit>(),
                child: requra_meeting_details.MeetingDetailsScreen(meeting: result),
              ),
            ),
          );
          return;
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (error == null) {
        AppSnackbar.showSuccess(context, 'Meeting updated successfully');
        Navigator.of(context).pop(true);
      } else {
        AppSnackbar.showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.black),
        title: Text(
          _isEditMode ? 'Edit Sync Session' : 'Create Sync Session',
          style: boldStyle(fontSize: FontSize.font18, color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            _isEditMode ? Icons.edit_outlined : Icons.videocam_outlined,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          _isEditMode ? 'Edit Meeting Details' : 'Schedule New Meeting',
                          style: boldStyle(
                            fontSize: FontSize.font16,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _isEditMode
                          ? 'Update your meeting information.'
                          : 'Create a new sync space for your team. You can start it immediately or schedule for later.',
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('MEETING TITLE', icon: Icons.text_fields, required: true),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Sprint Planning - Week 4',
                        hintStyle: regularStyle(color: AppColors.grey, fontSize: FontSize.font14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    _buildLabel('AGENDA & DESCRIPTION', icon: Icons.notes),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Outline the main topics and objectives...',
                        hintStyle: regularStyle(color: AppColors.grey, fontSize: FontSize.font14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Scheduled Time
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('SCHEDULED TIME', icon: Icons.calendar_today_outlined),
                          SizedBox(height: 12.h),
                          InkWell(
                            onTap: _pickDateTime,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedDateTime == null
                                        ? 'mm/dd/yyyy --:-- --'
                                        : _formatDateTime(_selectedDateTime!),
                                    style: regularStyle(
                                      color: _selectedDateTime == null ? AppColors.grey : AppColors.black,
                                      fontSize: FontSize.font14,
                                    ),
                                  ),
                                  Icon(Icons.calendar_today, size: 18.sp, color: AppColors.black),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Pro Tip: Leave this blank to create an instant meeting room.',
                            style: regularStyle(
                              fontSize: FontSize.font12,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    const Divider(color: Color(0xFFE5E7EB)),
                    SizedBox(height: 16.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'CANCEL',
                            style: boldStyle(color: AppColors.black, fontSize: FontSize.font14),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        SizedBox(
                          width: 160.w,
                          child: CustomButton(
                            text: _isLoading
                                ? (_isEditMode ? 'UPDATING...' : 'CREATING...')
                                : (_isEditMode ? 'UPDATE' : 'CREATE MEETING'),
                            color1: AppColors.primary,
                            onTap: _isLoading ? null : _submit,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {required IconData icon, bool required = false}) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          text,
          style: boldStyle(fontSize: FontSize.font12, color: AppColors.black),
        ),
        if (required) ...[
          SizedBox(width: 4.w),
          Text('*', style: boldStyle(fontSize: FontSize.font12, color: Colors.red)),
        ],
      ],
    );
  }
}
