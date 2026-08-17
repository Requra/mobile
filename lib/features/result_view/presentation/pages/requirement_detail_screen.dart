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
import 'package:requra/features/result_view/presentation/widgets/ai_results/edit_requirement_dialog.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/reject_requirement_dialog.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/shared/review_action_popup_menu.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

class RequirementDetailScreen extends StatefulWidget {
  final AiRequirement initialRequirement;
  final String projectId;

  const RequirementDetailScreen({
    super.key,
    required this.initialRequirement,
    required this.projectId,
  });

  @override
  State<RequirementDetailScreen> createState() => _RequirementDetailScreenState();
}

class _RequirementDetailScreenState extends State<RequirementDetailScreen> {
  bool _isApproving = false;

  Future<void> _approveRequirement(AiRequirement req) async {
    setState(() {
      _isApproving = true;
    });

    final error = await context.read<ResultViewCubit>().updateRequirementStatus(
          widget.projectId,
          req.id,
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

  void _showEditDialog(AiRequirement req) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: context.read<ResultViewCubit>(),
        child: EditRequirementDialog(
          requirement: req,
          projectId: widget.projectId,
        ),
      ),
    );
  }

  void _showRejectDialog(AiRequirement req) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: context.read<ResultViewCubit>(),
        child: RejectRequirementDialog(
          requirement: req,
          projectId: widget.projectId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResultViewCubit, ResultViewState>(
      builder: (context, state) {
        // Try to get updated requirement from state, fallback to initial
        AiRequirement req = widget.initialRequirement;
        if (state is ResultViewLoaded && state.requirements != null) {
          try {
            req = state.requirements!
                .firstWhere((r) => r.id == widget.initialRequirement.id);
          } catch (_) {}
        }

        Color priorityColor;
        Color priorityBg;
        if (req.priority.toLowerCase() == 'critical') {
          priorityColor = AppColors.error;
          priorityBg = const Color(0xFFFEE2E2);
        } else if (req.priority.toLowerCase() == 'high') {
          priorityColor = const Color(0xFFD97706);
          priorityBg = const Color(0xFFFEF3C7);
        } else {
          priorityColor = AppColors.statusFinished;
          priorityBg = const Color(0xFFDCFCE7);
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundHomeScreen,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 1,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Requirement Details',
              style: boldStyle(fontSize: FontSize.font18, color: AppColors.black),
            ),
            actions: [
              ReviewActionPopupMenu(
                onEdit: () => _showEditDialog(req),
                onReject: () => _showRejectDialog(req),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Chips
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          Text(
                            req.id,
                            style: semiBoldStyle(
                                fontSize: FontSize.font14, color: AppColors.primary),
                          ),
                          if (req.workflowStatus != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                req.workflowStatus!,
                                style: semiBoldStyle(
                                  fontSize: FontSize.font12,
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                            ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.lightButton,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              req.type,
                              style: semiBoldStyle(
                                fontSize: FontSize.font12,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: priorityBg,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              req.priority,
                              style: semiBoldStyle(
                                fontSize: FontSize.font12,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      // Title
                      Text(
                        req.title,
                        style: boldStyle(
                            fontSize: FontSize.font22, color: AppColors.black),
                      ),
                      SizedBox(height: 24.h),

                      // Requirement Details
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.description_outlined,
                                    size: 20.sp, color: AppColors.grey),
                                SizedBox(width: 8.w),
                                Text(
                                  'REQUIREMENT',
                                  style: semiBoldStyle(
                                      fontSize: FontSize.font12,
                                      color: AppColors.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              req.description,
                              style: regularStyle(
                                  fontSize: FontSize.font14, color: AppColors.black),
                            ),
                            SizedBox(height: 24.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.feed_outlined,
                                        size: 20.sp, color: AppColors.grey),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'SOURCE EVIDENCE',
                                      style: semiBoldStyle(
                                          fontSize: FontSize.font12,
                                          color: AppColors.grey),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${req.sourceDocumentIds.length} sources',
                                  style: regularStyle(
                                      fontSize: FontSize.font12, color: AppColors.grey),
                                ),
                              ],
                            ),
                            if (req.sourceDocumentIds.isEmpty) ...[
                              SizedBox(height: 12.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'No quoted evidence was returned. Treat this as a review signal before approval.',
                                  style: regularStyle(
                                      fontSize: FontSize.font14, color: AppColors.grey),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // AI Quality
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.verified_outlined,
                                        size: 20.sp, color: AppColors.grey),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'AI QUALITY',
                                      style: semiBoldStyle(
                                          fontSize: FontSize.font12,
                                          color: AppColors.grey),
                                    ),
                                  ],
                                ),
                                if (req.qualityStatus != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      req.qualityStatus!,
                                      style: semiBoldStyle(
                                          fontSize: FontSize.font10,
                                          color: AppColors.grey),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80.w,
                                  child: Text(
                                    'Confidence',
                                    style: regularStyle(
                                        fontSize: FontSize.font14, color: AppColors.grey),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.r),
                                    child: LinearProgressIndicator(
                                      value: req.confidenceScore.clamp(0.0, 1.0),
                                      backgroundColor: const Color(0xFFE5E7EB),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFF59E0B),
                                      ),
                                      minHeight: 6.h,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${(req.confidenceScore * 100).toInt()}%',
                                      style: boldStyle(
                                          fontSize: FontSize.font14, color: AppColors.error),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (req.quality?.score != null) ...[
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 80.w,
                                    child: Text(
                                      'Quality score',
                                      style: regularStyle(
                                          fontSize: FontSize.font14, color: AppColors.grey),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4.r),
                                      child: LinearProgressIndicator(
                                        value: req.quality!.score!.clamp(0.0, 1.0),
                                        backgroundColor: const Color(0xFFE5E7EB),
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                          AppColors.statusFinished,
                                        ),
                                        minHeight: 6.h,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '${(req.quality!.score! * 100).toInt()}%',
                                        style: boldStyle(
                                            fontSize: FontSize.font14,
                                            color: AppColors.statusFinished),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Context Cards
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_mosaic_outlined,
                              size: 20.sp, color: AppColors.grey),
                          SizedBox(width: 8.w),
                          Text(
                            'CONTEXT',
                            style: semiBoldStyle(
                                fontSize: FontSize.font12, color: AppColors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildContextCard(
                                'ACTOR', req.actor ?? 'System'),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildContextCard(
                                'CATEGORY', req.category ?? 'Uncategorized'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.w),
                      Row(
                        children: [
                          Expanded(
                            child: _buildContextCard('TYPE', req.type),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildContextCard('PRIORITY', req.priority),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions
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
                          text: req.workflowStatus == 'APPROVED' ? 'Approved' : 'Approve',
                          icon: Icons.check_circle_outline,
                          color1: req.workflowStatus == 'APPROVED' ? AppColors.statusFinished : AppColors.primary,
                          color2: req.workflowStatus == 'APPROVED' ? AppColors.statusFinished : AppColors.primary,
                          onTap: req.workflowStatus == 'APPROVED' ? null : () => _approveRequirement(req),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContextCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: semiBoldStyle(fontSize: FontSize.font10, color: AppColors.grey),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: regularStyle(fontSize: FontSize.font14, color: AppColors.black),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
