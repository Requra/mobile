import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/meeting/presentation/cubit/ai_analysis_cubit.dart';
import 'package:requra/routes/app_routes.dart';
import 'package:requra/features/meeting/data/services/meeting_service.dart';

class AiAnalysisScreen extends StatelessWidget {
  final String projectId;
  final String? meetingId;
  final bool isRegenerating;

  const AiAnalysisScreen({
    super.key,
    required this.projectId,
    this.meetingId,
    this.isRegenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AiAnalysisCubit(const MeetingService())
            ..startAnalysis(projectId, meetingId: meetingId),
      child: _AiAnalysisView(isRegenerating: isRegenerating),
    );
  }
}

class _AiAnalysisView extends StatelessWidget {
  final bool isRegenerating;
  const _AiAnalysisView({required this.isRegenerating});

  final List<String> _steps = const [
    'Reading project sources',
    'Classifying requirements',
    'Running quality checks',
    'Splitting content into analyzable chunks',
    'Grounding requirements in source evidence',
    'Building executive summary',
    'Extracting requirements',
    'Generating user stories and acceptance criteria',
    'Finalizing dashboard contract',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.black),
        title: Text(
          isRegenerating ? 'Regenerating' : 'Processing Meeting',
          style: boldStyle(color: AppColors.black, fontSize: FontSize.font18),
        ),
      ),
      body: BlocConsumer<AiAnalysisCubit, AiAnalysisState>(
        listener: (context, state) {
          if (state is AiAnalysisSuccess) {
            // Wait a moment then navigate to the dashboard
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
              }
            });
          }
        },
        builder: (context, state) {
          int progress = 0;
          String statusTitle = 'Queued for AI analysis';
          String badgeText = 'Queued';
          bool isError = state is AiAnalysisError;
          String? errorMessage = isError
              ? (state as AiAnalysisError).message
              : null;

          if (state is AiAnalysisRunning) {
            progress = state.status.progress;
            statusTitle = state.status.currentNodeLabel.isNotEmpty
                ? state.status.currentNodeLabel
                : 'Processing AI analysis';
            badgeText = 'Running';
          } else if (state is AiAnalysisSuccess) {
            progress = 100;
            statusTitle = 'Analysis Complete';
            badgeText = 'Done';
          }

          int currentStepIndex = (progress / 100 * _steps.length).floor();
          if (currentStepIndex >= _steps.length) {
            currentStepIndex = _steps.length - 1;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Info Card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.access_time_filled,
                          color: const Color(0xFF6B7280),
                          size: 24.r,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    statusTitle,
                                    style: boldStyle(
                                      fontSize: FontSize.font18,
                                      color: const Color(0xFF111827),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E8FF),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (badgeText != 'Done' && !isError) ...[
                                        Icon(
                                          Icons.sync,
                                          color: const Color(0xFF7C3AED),
                                          size: 14.r,
                                        ),
                                        SizedBox(width: 4.w),
                                      ],
                                      Text(
                                        isError ? 'Error' : badgeText,
                                        style: semiBoldStyle(
                                          fontSize: FontSize.font12,
                                          color: isError
                                              ? Colors.red
                                              : const Color(0xFF7C3AED),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              isError
                                  ? errorMessage ??
                                        'An error occurred during analysis.'
                                  : 'Your run is in the queue. This view updates automatically — you can keep working.',
                              style: regularStyle(
                                fontSize: FontSize.font14,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusTitle,
                      style: boldStyle(
                        fontSize: FontSize.font16,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      '$progress%',
                      style: boldStyle(
                        fontSize: FontSize.font16,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 8.h,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF7C3AED),
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Steps List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _steps.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    final isCompleted =
                        index < currentStepIndex || state is AiAnalysisSuccess;
                    final isActive =
                        index == currentStepIndex &&
                        state is! AiAnalysisSuccess;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted || isActive
                                  ? const Color(0xFFE5E7EB)
                                  : const Color(0xFFF3F4F6),
                              width: 2,
                            ),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Container(
                              width: 10.r,
                              height: 10.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? const Color(0xFF7C3AED)
                                    : (isActive
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFFD1D5DB)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            step,
                            style: regularStyle(
                              fontSize: FontSize.font14,
                              color: isCompleted || isActive
                                  ? const Color(0xFF1F2937)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
