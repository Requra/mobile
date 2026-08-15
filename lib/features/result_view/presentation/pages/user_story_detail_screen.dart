import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_state.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/edit_user_story_dialog.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/regenerate_user_story_dialog.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/shared/approve_circle_button.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/shared/reject_item_dialog.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/shared/review_action_popup_menu.dart';

class UserStoryDetailScreen extends StatefulWidget {
  final AiUserStory initialStory;
  final String projectId;

  const UserStoryDetailScreen({
    super.key,
    required this.initialStory,
    required this.projectId,
  });

  @override
  State<UserStoryDetailScreen> createState() => _UserStoryDetailScreenState();
}

class _UserStoryDetailScreenState extends State<UserStoryDetailScreen> {
  bool _isApproving = false;

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return AppColors.statusFinished;
      case 'REJECTED':
        return AppColors.error;
      case 'EDITED':
        return const Color(0xFFD97706);
      case 'NEEDS_REVIEW':
        return const Color(0xFFD97706);
      default:
        return AppColors.primary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.error;
      case 'HIGH':
        return const Color(0xFFD97706);
      case 'MEDIUM':
        return const Color(0xFF0284C7);
      case 'LOW':
        return const Color(0xFF059669);
      default:
        return AppColors.grey;
    }
  }

  void _showEditDialog(AiUserStory story) {
    showDialog(
      context: context,
      builder: (context) => EditUserStoryDialog(
        userStory: story,
        projectId: widget.projectId,
      ),
    );
  }

  void _showRegenerateDialog(AiUserStory story) {
    showDialog(
      context: context,
      builder: (context) => RegenerateUserStoryDialog(
        userStory: story,
        projectId: widget.projectId,
      ),
    );
  }

  void _showRejectDialog(AiUserStory story) {
    showDialog(
      context: context,
      builder: (context) => RejectItemDialog(
        title: 'Reject user story',
        subtitle: 'Explain what must change so the decision remains useful and auditable.',
        successMessage: 'User story rejected successfully',
        onReject: (feedback) async {
          final cubit = context.read<ResultViewCubit>();
          return await cubit.updateUserStoryStatus(
            widget.projectId,
            story.id,
            'REJECTED',
            reviewFeedback: feedback,
          );
        },
      ),
    );
  }

  Future<void> _approveStory(AiUserStory story) async {
    setState(() {
      _isApproving = true;
    });

    final cubit = context.read<ResultViewCubit>();
    final error = await cubit.updateUserStoryStatus(
      widget.projectId,
      story.id,
      'APPROVED',
    );

    if (mounted) {
      setState(() {
        _isApproving = false;
      });

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving user story: $error')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User story approved successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResultViewCubit, ResultViewState>(
      builder: (context, state) {
        AiUserStory story = widget.initialStory;
        
        if (state is ResultViewLoaded) {
          final aiDashboard = state.aiDashboard;
          if (aiDashboard != null) {
            final updatedStory = aiDashboard.userStories.firstWhere(
              (s) => s.id == widget.initialStory.id,
              orElse: () => widget.initialStory,
            );
            story = updatedStory;
          }
        }

        final statusColor = _getStatusColor(story.workflowStatus ?? 'GENERATED');
        final priorityColor = _getPriorityColor(story.priority);
        final double score = story.quality?.score ?? 0;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'User Story Details',
              style: boldStyle(fontSize: FontSize.font18, color: AppColors.black),
            ),
            actions: [
              ReviewActionPopupMenu(
                onEdit: () => _showEditDialog(story),
                onReject: () => _showRejectDialog(story),
                showRegenerate: true,
                onRegenerate: () => _showRegenerateDialog(story),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              story.id,
                              style: semiBoldStyle(
                                fontSize: FontSize.font12,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              story.workflowStatus ?? 'GENERATED',
                              style: semiBoldStyle(
                                fontSize: FontSize.font10,
                                color: statusColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              story.priority.toUpperCase(),
                              style: semiBoldStyle(
                                fontSize: FontSize.font10,
                                color: priorityColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF5FF),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.link, size: 14.sp, color: const Color(0xFF1D4ED8)),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    story.requirementId,
                                    overflow: TextOverflow.ellipsis,
                                    style: semiBoldStyle(
                                      fontSize: FontSize.font12,
                                      color: const Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        story.title,
                        style: boldStyle(
                          fontSize: FontSize.font20,
                          color: AppColors.black,
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      Text(
                        'User Story',
                        style: semiBoldStyle(
                          fontSize: FontSize.font16,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          story.userStory,
                          style: regularStyle(
                            fontSize: FontSize.font16,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      Text(
                        'Acceptance Criteria',
                        style: semiBoldStyle(
                          fontSize: FontSize.font16,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...story.acceptanceCriteria.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key + 1}. ',
                                style: semiBoldStyle(
                                  fontSize: FontSize.font14,
                                  color: AppColors.black,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: regularStyle(
                                    fontSize: FontSize.font14,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      if (story.sourceRefs.isNotEmpty) ...[
                        SizedBox(height: 24.h),
                        Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Text(
                              'Source Evidence (${story.sourceRefs.length})',
                              style: semiBoldStyle(
                                fontSize: FontSize.font16,
                                color: AppColors.black,
                              ),
                            ),
                            children: story.sourceRefs.map((ref) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 8.h),
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.description_outlined,
                                            size: 16.sp, color: AppColors.grey),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            ref.documentTitle ?? 'Unknown Source',
                                            style: semiBoldStyle(
                                              fontSize: FontSize.font14,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      '"${ref.quote ?? ""}"',
                                      style: regularStyle(
                                        fontSize: FontSize.font14,
                                        color: const Color(0xFF4B5563),
                                      ).copyWith(fontStyle: FontStyle.italic),
                                    ),
                                    if (ref.confidenceScore != null) ...[
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Icon(Icons.analytics_outlined,
                                              size: 14.sp, color: AppColors.grey),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Confidence: ${(ref.confidenceScore! * 100).toInt()}%',
                                            style: regularStyle(
                                              fontSize: FontSize.font12,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      
                      SizedBox(height: 24.h),
                      Text(
                        'AI Quality',
                        style: semiBoldStyle(
                          fontSize: FontSize.font16,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Quality Score',
                                    style: semiBoldStyle(
                                      fontSize: FontSize.font14,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    story.quality?.score != null 
                                        ? '${(score * 100).toInt()}%' 
                                        : 'N/A',
                                    style: boldStyle(
                                      fontSize: FontSize.font14,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: score,
                                minHeight: 8.h,
                                backgroundColor: const Color(0xFFE5E7EB),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Evaluation Status',
                                    style: semiBoldStyle(
                                      fontSize: FontSize.font14,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      story.qualityStatus ?? 'PENDING',
                                      overflow: TextOverflow.ellipsis,
                                      style: semiBoldStyle(
                                        fontSize: FontSize.font12,
                                        color: const Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      Text(
                        'Revision Info',
                        style: semiBoldStyle(
                          fontSize: FontSize.font16,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Revision number',
                                    style: regularStyle(
                                      fontSize: FontSize.font14,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    'v${story.revisionNumber ?? story.version ?? 1}',
                                    style: semiBoldStyle(
                                      fontSize: FontSize.font14,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Source',
                                    style: regularStyle(
                                      fontSize: FontSize.font14,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    story.revisionSource ?? 'AI Generated',
                                    style: semiBoldStyle(
                                      fontSize: FontSize.font14,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action Bar
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: _isApproving
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : CustomButton(
                          text: story.workflowStatus == 'APPROVED' ? 'Approved' : 'Approve',
                          icon: Icons.check_circle_outline,
                          color1: story.workflowStatus == 'APPROVED' ? AppColors.statusFinished : AppColors.primary,
                          color2: story.workflowStatus == 'APPROVED' ? AppColors.statusFinished : AppColors.primary,
                          onTap: story.workflowStatus == 'APPROVED' ? null : () => _approveStory(story),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
