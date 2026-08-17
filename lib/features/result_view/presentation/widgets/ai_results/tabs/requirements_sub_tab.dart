import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_state.dart';
import 'package:requra/features/result_view/presentation/pages/requirement_detail_screen.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/edit_requirement_dialog.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/reject_requirement_dialog.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/shared/approve_circle_button.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/shared/review_action_popup_menu.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

class RequirementsSubTab extends StatefulWidget {
  final AiResultsDashboard dashboard;
  final String projectId;

  const RequirementsSubTab({
    super.key,
    required this.dashboard,
    required this.projectId,
  });

  @override
  State<RequirementsSubTab> createState() => _RequirementsSubTabState();
}

class _RequirementsSubTabState extends State<RequirementsSubTab> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      _hasFetched = true;
      context.read<ResultViewCubit>().fetchRequirements(widget.projectId);
    }
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

        if (state.requirementsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final requirementsList = state.requirements ?? [];

        if (requirementsList.isEmpty) {
          return Center(
            child: Text(
              'No requirements available',
              style: regularStyle(
                fontSize: FontSize.font16,
                color: AppColors.grey,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Count
              Text(
                '${requirementsList.length} requirements',
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.grey,
                ),
              ),

              SizedBox(height: 12.h),

              // Grid / List
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth > 800;
                  if (isDesktop) {
                    return Wrap(
                      spacing: 16.w,
                      runSpacing: 16.h,
                      children: requirementsList.asMap().entries.map((entry) {
                      return SizedBox(
                        width: (constraints.maxWidth - 16.w) / 2,
                        child: AiRequirementCard(
                          req: entry.value,
                          dashboard: widget.dashboard,
                          displayIndex: entry.key + 1,
                        ),
                      );
                    }).toList(),
                    );
                  } else {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: requirementsList.length,
                      separatorBuilder: (_, __) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        return AiRequirementCard(
                          req: requirementsList[index],
                          dashboard: widget.dashboard,
                          displayIndex: index + 1,
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class AiRequirementCard extends StatefulWidget {
  final AiRequirement req;
  final AiResultsDashboard dashboard;
  final int displayIndex;

  const AiRequirementCard({
    super.key,
    required this.req,
    required this.dashboard,
    required this.displayIndex,
  });

  @override
  State<AiRequirementCard> createState() => _AiRequirementCardState();
}

class _AiRequirementCardState extends State<AiRequirementCard> {
  bool _isDescriptionExpanded = false;
  bool _isApproving = false;

  void _showEditDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: context.read<ResultViewCubit>(),
        child: EditRequirementDialog(
          requirement: widget.req,
          projectId: widget.dashboard.projectId,
        ),
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: context.read<ResultViewCubit>(),
        child: RejectRequirementDialog(
          requirement: widget.req,
          projectId: widget.dashboard.projectId,
        ),
      ),
    );
  }

  Future<void> _approveRequirement() async {
    setState(() {
      _isApproving = true;
    });

    final error = await context.read<ResultViewCubit>().updateRequirementStatus(
      widget.dashboard.projectId,
      widget.req.id,
      'APPROVED',
    );

    if (mounted) {
      setState(() {
        _isApproving = false;
      });

      if (error != null) {
        AppSnackbar.showError(context, 'Error approving requirement: $error');
      } else {
        AppSnackbar.showSuccess(context, 'Requirement approved successfully');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    Color priorityBg;
    if (widget.req.priority.toLowerCase() == 'critical') {
      priorityColor = AppColors.error;
      priorityBg = const Color(0xFFFEE2E2);
    } else if (widget.req.priority.toLowerCase() == 'high') {
      priorityColor = const Color(0xFFD97706);
      priorityBg = const Color(0xFFFEF3C7);
    } else {
      priorityColor = AppColors.statusFinished;
      priorityBg = const Color(0xFFDCFCE7);
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => BlocProvider.value(
              value: context.read<ResultViewCubit>(),
              child: RequirementDetailScreen(
                initialRequirement: widget.req,
                projectId: widget.dashboard.projectId,
              ),
            ),
          ),
        );
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
            // Header: ID and Type and Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.req.sourceRequirementId ?? 'REQ-${widget.displayIndex.toString().padLeft(3, '0')}',
                    style: semiBoldStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.lightButton,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    widget.req.type,
                    style: semiBoldStyle(
                      fontSize: FontSize.font10,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                ReviewActionPopupMenu(
                  onEdit: _showEditDialog,
                  onReject: _showRejectDialog,
                  iconColor: AppColors.grey,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // Title
            Text(
              widget.req.title,
              style: boldStyle(
                fontSize: FontSize.font16,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.h),
            // Description
            LayoutBuilder(
              builder: (context, size) {
                final span = TextSpan(
                  text: widget.req.description,
                  style: regularStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.grey,
                  ),
                );
                final tp = TextPainter(
                  text: span,
                  maxLines: 2,
                  textDirection: TextDirection.ltr,
                );
                tp.layout(maxWidth: size.maxWidth);
                final isOverflowing = tp.didExceedMaxLines;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.req.description,
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.grey,
                      ),
                      maxLines: _isDescriptionExpanded ? null : 2,
                      overflow: _isDescriptionExpanded
                          ? null
                          : TextOverflow.ellipsis,
                    ),
                    if (isOverflowing)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            _isDescriptionExpanded ? 'See less' : 'See more',
                            style: semiBoldStyle(
                              fontSize: FontSize.font12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: 12.h),
            // Tags
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: priorityBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    widget.req.priority,
                    style: semiBoldStyle(
                      fontSize: FontSize.font10,
                      color: priorityColor,
                    ),
                  ),
                ),
                if (widget.req.workflowStatus != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      widget.req.workflowStatus!,
                      style: semiBoldStyle(
                        fontSize: FontSize.font10,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.req.category != null || widget.req.actor != null) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: [
                  if (widget.req.category != null)
                    Text(
                      'Category: ${widget.req.category}',
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.grey,
                      ),
                    ),
                  if (widget.req.category != null && widget.req.actor != null)
                    Text(
                      '•',
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.grey,
                      ),
                    ),
                  if (widget.req.actor != null)
                    Text(
                      'Actor: ${widget.req.actor}',
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.grey,
                      ),
                    ),
                ],
              ),
            ],
            SizedBox(height: 16.h),
            Divider(height: 1, color: const Color(0xFFE5E7EB)),
            SizedBox(height: 12.h),
            // Footer: Confidence and Evidence and Approve Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'CONFIDENCE',
                        style: semiBoldStyle(
                          fontSize: FontSize.font10,
                          color: AppColors.grey,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: widget.req.confidenceScore.clamp(0.0, 1.0),
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFF59E0B),
                            ),
                            minHeight: 4.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${(widget.req.confidenceScore * 100).toInt()}%',
                          style: semiBoldStyle(
                            fontSize: FontSize.font12,
                            color: AppColors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                ApproveCircleButton(
                  isLoading: _isApproving,
                  onTap: _approveRequirement,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
