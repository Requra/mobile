import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/customAppBar.dart';
import 'package:requra/core/global_widgets/custom_tab_bar.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_state.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_cubit.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_state.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/ai_results_tab.dart';
import 'package:requra/features/meeting/presentation/widgets/meetings/meetings_tab.dart';
import 'package:requra/features/result_view/presentation/widgets/overview/overview_tab.dart';

class ResultViewScreen extends StatefulWidget {
  final Project project;

  const ResultViewScreen({super.key, required this.project});

  @override
  State<ResultViewScreen> createState() => _ResultViewScreenState();
}

class _ResultViewScreenState extends State<ResultViewScreen> {
  static const _tabs = ['Overview', 'AI Results', 'Meetings'];

  @override
  void initState() {
    super.initState();
    context.read<ResultViewCubit>().fetchResultView(
          widget.project.id,
          totalRequirements: widget.project.totalRequirements,
        );
    context.read<MeetingCubit>().fetchProjectMeetings(widget.project.id);
  }

  Future<void> _onRefresh() async {
    context.read<ResultViewCubit>().fetchResultView(
          widget.project.id,
          totalRequirements: widget.project.totalRequirements,
        );
    context.read<MeetingCubit>().fetchProjectMeetings(widget.project.id);
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.backgroundHomeScreen,
        appBar: const CustomAppBar(),
        body: Column(
          children: [
            /// Tab bar (no counts, just tab names)
            const CustomTabBar(
              tabs: _tabs,
              isScrollable: false,
            ),
            Expanded(
              child: BlocBuilder<ResultViewCubit, ResultViewState>(
                builder: (context, state) {
                  if (state is ResultViewLoading || state is ResultViewInitial) {
                    return CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      ],
                    );
                  }

            if (state is ResultViewError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off,
                          size: 48.sp, color: AppColors.error),
                      SizedBox(height: 12.h),
                      Text(
                        'Failed to load project details',
                        style: boldStyle(
                          fontSize: FontSize.font16,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: regularStyle(
                          fontSize: FontSize.font14,
                          color: AppColors.grey,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ResultViewCubit>().fetchResultView(
                                  widget.project.id,
                                  totalRequirements:
                                      widget.project.totalRequirements,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: semiBoldStyle(
                            fontSize: FontSize.font14,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ResultViewLoaded) {
              return TabBarView(
                children: [
                        /// Overview tab
                        RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: AppColors.primary,
                          child: OverviewTab(
                            details: state.projectDetails,
                            totalRequirements: state.totalRequirements,
                            documents: state.documents,
                            projectId: state.projectDetails.id,
                          ),
                        ),

                        /// AI Results tab
                        RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: AppColors.primary,
                          child: state.aiDashboard != null
                              ? AiResultsTab(
                                  dashboard: state.aiDashboard!,
                                  projectId: state.projectDetails.id,
                                  projectName: state.projectDetails.name,
                                )
                              : ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(height: 100.h),
                                    Icon(Icons.error_outline,
                                        size: 64.sp, color: AppColors.error),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'Failed to load AI Results',
                                      textAlign: TextAlign.center,
                                      style: boldStyle(
                                        fontSize: FontSize.font18,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                        ),

                        /// Meetings tab
                        RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: AppColors.primary,
                          child: BlocBuilder<MeetingCubit, MeetingState>(
                            builder: (context, meetingState) {
                              if (meetingState is MeetingLoading) {
                                return ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(height: 100.h),
                                    const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                  ]
                                );
                              } else if (meetingState is MeetingError) {
                                return ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(height: 100.h),
                                    Center(child: Text(meetingState.message, style: TextStyle(color: AppColors.error))),
                                  ]
                                );
                              } else if (meetingState is MeetingLoaded) {
                                return MeetingsTab(meetings: meetingState.meetings);
                              }
                              return ListView(physics: const AlwaysScrollableScrollPhysics());
                            },
                          ),
                        ),
                      ],
                    );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      ],
      ),
      ),
    );
  }
}
