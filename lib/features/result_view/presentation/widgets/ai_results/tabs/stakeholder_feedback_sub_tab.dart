import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/domain/entities/stakeholder_feedback.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_state.dart';

class StakeholderFeedbackSubTab extends StatefulWidget {
  final AiResultsDashboard dashboard;
  final String projectId;

  const StakeholderFeedbackSubTab({
    super.key,
    required this.dashboard,
    required this.projectId,
  });

  @override
  State<StakeholderFeedbackSubTab> createState() =>
      _StakeholderFeedbackSubTabState();
}

class _StakeholderFeedbackSubTabState extends State<StakeholderFeedbackSubTab> {
  int _selectedFilter = 0; // 0=All, 1=Open, 2=Resolved
  String _selectedTarget = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResultViewCubit>().fetchStakeholderFeedback(
        widget.projectId,
      );
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy · hh:mm a').format(date);
  }

  void _showResolveDialog(StakeholderFeedbackItem item) {
    final noteController = TextEditingController();
    bool isSubmitting = false;
    final cubit = context.read<ResultViewCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              backgroundColor: AppColors.white,
              child: Container(
                width: 500.w,
                padding: EdgeInsets.all(24.w),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mark feedback resolved',
                          style: boldStyle(
                            fontSize: FontSize.font18,
                            color: AppColors.black,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: Icon(
                            Icons.close,
                            size: 20.sp,
                            color: AppColors.grey,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Optionally leave a short note about how this feedback was addressed.',
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        item.content,
                        style: regularStyle(
                          fontSize: FontSize.font14,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Resolution note (optional)',
                      style: semiBoldStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'What changed in response to this feedback?',
                        hintStyle: regularStyle(
                          fontSize: FontSize.font14,
                          color: AppColors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(dialogContext),
                          child: Text(
                            'Cancel',
                            style: semiBoldStyle(
                              fontSize: FontSize.font14,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setDialogState(() => isSubmitting = true);
                                  final error = await cubit.resolveFeedback(
                                    widget.projectId,
                                    item.id,
                                    noteController.text,
                                  );
                                  setDialogState(() => isSubmitting = false);
                                  if (error == null && builderContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  } else if (error != null && builderContext.mounted) {
                                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                                      SnackBar(content: Text(error)),
                                    );
                                  }
                                },
                          icon: isSubmitting
                              ? SizedBox(
                                  width: 16.sp,
                                  height: 16.sp,
                                  child: const CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.check_circle_outline,
                                  size: 16.sp,
                                  color: AppColors.white,
                                ),
                          label: Text(
                            'Mark resolved',
                            style: semiBoldStyle(
                              fontSize: FontSize.font14,
                              color: AppColors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResultViewCubit, ResultViewState>(
      builder: (context, state) {
        if (state is! ResultViewLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final response = state.feedbackResponse;

        if (state.feedbackLoading && response == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (response == null) {
          return const Center(child: Text('No feedback available.'));
        }

        List<StakeholderFeedbackItem> filtered = response.items;
        if (_selectedFilter == 1) {
          filtered = filtered.where((e) => e.status == 'OPEN').toList();
        } else if (_selectedFilter == 2) {
          filtered = filtered.where((e) => e.status == 'RESOLVED').toList();
        }

        if (_selectedTarget.isNotEmpty) {
          filtered = filtered
              .where((e) => e.targetType == _selectedTarget)
              .toList();
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 24.sp,
                          color: AppColors.black,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stakeholder feedback',
                                style: boldStyle(
                                  fontSize: FontSize.font18,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Comments shared by stakeholders reviewing this project. The AI Review Queue is unchanged — this is the human feedback inbox.',
                                style: regularStyle(
                                  fontSize: FontSize.font12,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Badges
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _buildCountBadge(
                          '${response.openCount} OPEN',
                          const Color(0xFFD97706),
                        ),
                        _buildCountBadge(
                          '${response.resolvedCount} RESOLVED',
                          AppColors.statusFinished,
                        ),
                        _buildCountBadge(
                          '${response.unreadCount} UNREAD',
                          AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Filters
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // All / Open / Resolved tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterTab('All', 0),
                        SizedBox(width: 4.w),
                        _buildFilterTab('Open', 1),
                        SizedBox(width: 4.w),
                        _buildFilterTab('Resolved', 2),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Target chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 14.sp,
                          color: AppColors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'TARGET',
                          style: semiBoldStyle(
                            fontSize: FontSize.font10,
                            color: AppColors.grey,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _buildTargetChip('SUMMARY'),
                        SizedBox(width: 4.w),
                        _buildTargetChip('REQUIREMENT'),
                        SizedBox(width: 4.w),
                        _buildTargetChip('USER STORY'),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Feedback cards
              if (state.feedbackLoading && response.items.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ...filtered.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _buildFeedbackCard(item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: boldStyle(fontSize: FontSize.font10, color: color),
      ),
    );
  }

  Widget _buildFilterTab(String label, int index) {
    final isActive = _selectedFilter == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: isActive ? Border.all(color: const Color(0xFFE5E7EB)) : null,
        ),
        child: Text(
          label,
          style: semiBoldStyle(
            fontSize: FontSize.font12,
            color: isActive ? AppColors.black : AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildTargetChip(String label) {
    final isActive = _selectedTarget == label;
    return InkWell(
      onTap: () => setState(() {
        if (_selectedTarget == label) {
          _selectedTarget = '';
        } else {
          _selectedTarget = label;
        }
      }),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.lightButton : AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isActive ? AppColors.primary : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: regularStyle(
            fontSize: FontSize.font12,
            color: isActive ? AppColors.primary : AppColors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(StakeholderFeedbackItem item) {
    final isResolved = item.status == 'RESOLVED';

    Color statusColor = isResolved
        ? AppColors.statusFinished
        : const Color(0xFFD97706);
    Color statusBg = isResolved
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEF3C7);

    Color targetColor;
    if (item.targetType == 'SUMMARY') {
      targetColor = AppColors.primary;
    } else if (item.targetType == 'REQUIREMENT') {
      targetColor = const Color(0xFFD97706);
    } else {
      targetColor = const Color(0xFF0284C7);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + Target + Context
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  item.status,
                  style: boldStyle(
                    fontSize: FontSize.font10,
                    color: statusColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: targetColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  item.targetType,
                  style: boldStyle(
                    fontSize: FontSize.font10,
                    color: targetColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '· ${item.targetTitle ?? item.targetId ?? 'No Title'}',
                  style: regularStyle(
                    fontSize: FontSize.font12,
                    color: AppColors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Body
          Text(
            item.content,
            style: regularStyle(
              fontSize: FontSize.font14,
              color: AppColors.black,
            ),
          ),

          SizedBox(height: 8.h),

          // Author + date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.author?.displayName ?? 'Unknown'} · ${item.author?.email ?? 'No email'}',
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _formatDate(item.createdAt),
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),

          // Resolution block or Mark resolved button
          if (isResolved) ...[
            if (item.resolutionNote != null &&
                item.resolutionNote!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESOLUTION · ${_formatDate(item.resolvedAt)}',
                      style: boldStyle(
                        fontSize: FontSize.font10,
                        color: AppColors.statusFinished,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.resolutionNote!,
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.statusFinished,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _showResolveDialog(item),
                icon: Icon(
                  Icons.check_circle_outline,
                  size: 16.sp,
                  color: AppColors.grey,
                ),
                label: Text(
                  'Mark resolved',
                  style: semiBoldStyle(
                    fontSize: FontSize.font12,
                    color: AppColors.grey,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
