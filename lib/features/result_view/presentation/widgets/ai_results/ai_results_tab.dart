import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_tab_bar.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/ai_results_header.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/tabs/evidence_sub_tab.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/tabs/export_sub_tab.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/tabs/requirements_sub_tab.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/tabs/review_queue_sub_tab.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/tabs/summary_sub_tab.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/tabs/user_stories_sub_tab.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/tabs/stakeholder_feedback_sub_tab.dart';

class AiResultsTab extends StatelessWidget {
  final AiResultsDashboard dashboard;
  final String projectId;
  final String projectName;

  const AiResultsTab({
    super.key,
    required this.dashboard,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    final subTabs = [
      'Summary',
      'Requirements',
      'User Stories',
      'Review Queue',
      'Feedback',
      'Evidence',
      'Export',
    ];

    final counts = [
      -1, // Summary
      dashboard.metrics.totalRequirements,
      dashboard.metrics.userStories,
      dashboard.metrics.risksCount +
          dashboard.metrics.openQuestionsCount +
          (dashboard.qualityReport?.highSeverityIssueCount ??
              0), // Review Queue
      -1, // Evidence
      -1, // Export
    ];

    return DefaultTabController(
      length: subTabs.length,
      child: NestedScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
                child: AiResultsHeader(
                    dashboard: dashboard, projectId: projectId, projectName: projectName)),
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.white,
              elevation: 0,
              toolbarHeight: 0,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48.h),
                child: Container(
                  color: AppColors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CustomTabBar(tabs: subTabs, isScrollable: true),
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: AppColors.backgroundHomeScreen,
          child: TabBarView(
            children: [
              SummarySubTab(dashboard: dashboard),
              RequirementsSubTab(dashboard: dashboard, projectId: projectId),
              UserStoriesSubTab(dashboard: dashboard, projectId: projectId),
              ReviewQueueSubTab(dashboard: dashboard),
              StakeholderFeedbackSubTab(
                dashboard: dashboard,
                projectId: projectId,
              ),
              EvidenceSubTab(dashboard: dashboard),
              ExportSubTab(dashboard: dashboard),
            ],
          ),
        ),
      ),
    );
  }
}
