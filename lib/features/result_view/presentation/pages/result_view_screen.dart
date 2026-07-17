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
import 'package:requra/features/result_view/presentation/widgets/meetings/meetings_tab.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.backgroundHomeScreen,
        appBar: const CustomAppBar(),
        body: BlocBuilder<ResultViewCubit, ResultViewState>(
          builder: (context, state) {
            if (state is ResultViewLoading || state is ResultViewInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
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
              return Column(
                children: [
                  /// Tab bar (no counts, just tab names)
                  CustomTabBar(
                    tabs: _tabs,
                    isScrollable: false,
                  ),

                  /// Tab views
                  Expanded(
                    child: TabBarView(
                      children: [
                        /// Overview tab
                        OverviewTab(
                          details: state.projectDetails,
                          totalRequirements: state.totalRequirements,
                          documents: state.documents,
                          projectId: state.projectDetails.id,
                        ),

                        /// AI Results tab (placeholder)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.smart_toy_outlined,
                                  size: 64.sp,
                                  color: AppColors.lightgrey),
                              SizedBox(height: 12.h),
                              Text(
                                'AI Results',
                                style: boldStyle(
                                  fontSize: FontSize.font18,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Coming soon...',
                                style: regularStyle(
                                  fontSize: FontSize.font14,
                                  color: AppColors.lightgrey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Meetings tab
                        MeetingsTab(meetings: state.meetings),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
