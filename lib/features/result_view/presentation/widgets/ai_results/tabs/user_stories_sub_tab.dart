import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/features/result_view/presentation/pages/user_story_detail_screen.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/edit_user_story_dialog.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/regenerate_user_story_dialog.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/shared/approve_circle_button.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/shared/reject_item_dialog.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/shared/review_action_popup_menu.dart';

class UserStoriesSubTab extends StatelessWidget {
  final AiResultsDashboard dashboard;
  final String projectId;

  const UserStoriesSubTab({
    super.key,
    required this.dashboard,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    if (dashboard.userStories.isEmpty) {
      return Center(
        child: Text(
          'No user stories available',
          style: regularStyle(fontSize: FontSize.font16, color: AppColors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: dashboard.userStories.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final story = dashboard.userStories[index];
        return AiUserStoryCard(
          story: story,
          projectId: projectId,
        );
      },
    );
  }
}

class AiUserStoryCard extends StatefulWidget {
  final AiUserStory story;
  final String projectId;

  const AiUserStoryCard({
    super.key,
    required this.story,
    required this.projectId,
  });

  @override
  State<AiUserStoryCard> createState() => _AiUserStoryCardState();
}

class _AiUserStoryCardState extends State<AiUserStoryCard> {
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

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => EditUserStoryDialog(
        userStory: widget.story,
        projectId: widget.projectId,
      ),
    );
  }

  void _showRegenerateDialog() {
    showDialog(
      context: context,
      builder: (context) => RegenerateUserStoryDialog(
        userStory: widget.story,
        projectId: widget.projectId,
      ),
    );
  }

  void _showRejectDialog() {
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
            widget.story.id,
            'REJECTED',
            reviewFeedback: feedback,
          );
        },
      ),
    );
  }

  Future<void> _approveStory() async {
    setState(() {
      _isApproving = true;
    });

    final cubit = context.read<ResultViewCubit>();
    final error = await cubit.updateUserStoryStatus(
      widget.projectId,
      widget.story.id,
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
    final statusColor = _getStatusColor(widget.story.workflowStatus ?? 'GENERATED');
    final priorityColor = _getPriorityColor(widget.story.priority);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ResultViewCubit>(),
            child: UserStoryDetailScreen(
              initialStory: widget.story,
              projectId: widget.projectId,
            ),
          ),
        ));
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
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
                          widget.story.id,
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
                          widget.story.workflowStatus ?? 'GENERATED',
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
                          widget.story.priority.toUpperCase(),
                          style: semiBoldStyle(
                            fontSize: FontSize.font10,
                            color: priorityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                ReviewActionPopupMenu(
                  onEdit: _showEditDialog,
                  onReject: _showRejectDialog,
                  showRegenerate: true,
                  onRegenerate: _showRegenerateDialog,
                  iconColor: AppColors.grey,
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Linked Requirement Indicator
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
                      widget.story.requirementId,
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
            SizedBox(height: 12.h),

            // Title
            Text(
              widget.story.title,
              style: boldStyle(
                fontSize: FontSize.font16,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.h),

            // User Story Description (Max 2 lines)
            Text(
              widget.story.userStory,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: regularStyle(
                fontSize: FontSize.font14,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: 12.h),

            // Acceptance Criteria preview (First 2)
            if (widget.story.acceptanceCriteria.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acceptance Criteria',
                      style: semiBoldStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    ...widget.story.acceptanceCriteria.take(2).map(
                          (ac) => Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ', style: regularStyle(fontSize: FontSize.font12, color: AppColors.grey)),
                                Expanded(
                                  child: Text(
                                    ac,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: regularStyle(
                                      fontSize: FontSize.font12,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    if (widget.story.acceptanceCriteria.length > 2)
                      Text(
                        '+ ${widget.story.acceptanceCriteria.length - 2} more',
                        style: regularStyle(
                          fontSize: FontSize.font12,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),

            SizedBox(height: 16.h),
            Divider(height: 1, color: const Color(0xFFE5E7EB)),
            SizedBox(height: 12.h),

            // Footer
            LayoutBuilder(
              builder: (context, constraints) {
                final double score = widget.story.quality?.score ?? 0;
                return Row(
                  children: [
                    // Confidence Bar Area
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'AI Quality Score',
                                  style: semiBoldStyle(
                                    fontSize: FontSize.font12,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  widget.story.quality?.score != null
                                      ? '${(score * 100).toInt()}%'
                                      : 'N/A',
                                  style: boldStyle(
                                    fontSize: FontSize.font12,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: score,
                              minHeight: 6.h,
                              backgroundColor: const Color(0xFFE5E7EB),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),

                    ApproveCircleButton(
                      isLoading: _isApproving,
                      onTap: _approveStory,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
