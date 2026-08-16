import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/customAppBar.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/Dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:requra/features/Dashboard/presentation/cubit/dashboard_state.dart';
import 'package:requra/features/Dashboard/presentation/widgets/dashboard_stat_card.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/project_view/presentation/helpers/project_helpers.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_error_state.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_loading_state.dart';
import 'package:requra/routes/app_routes.dart';
import 'package:requra/widgets/section_label.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundHomeScreen,
      appBar: CustomAppBar(
        onNotificationTap: () {
          setState(() => _showNotifications = !_showNotifications);
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading || state is DashboardInitial) {
                  return const ProjectLoadingState();
                }

                if (state is DashboardError) {
                  return ProjectErrorState(
                    onRetry: () => context.read<DashboardCubit>().loadDashboard(),
                  );
                }

                if (state is DashboardLoaded) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      await context.read<DashboardCubit>().loadDashboard();
                    },
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 20.h),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderStats(state),
                          SizedBox(height: 16.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionLabel(label: 'FOCUS'),
                                SizedBox(height: 8.h),
                                Text(
                                  'Continue working',
                                  style: semiBoldStyle(
                                    fontSize: FontSize.font14,
                                    color: AppColors.darkgrey,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                _buildFocusSection(context, state.focusProjects),
                                
                                SizedBox(height: 24.h),
                                
                                const SectionLabel(label: 'PORTFOLIO'),
                                SizedBox(height: 8.h),
                                Text(
                                  'Recently created projects',
                                  style: semiBoldStyle(
                                    fontSize: FontSize.font14,
                                    color: AppColors.darkgrey,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                _buildPortfolioSection(context, state.recentProjects),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            if (_showNotifications)
              _NotificationsPanel(
                onClose: () => setState(() => _showNotifications = false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStats(DashboardLoaded state) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B46C1), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 0, 24.h), // Right padding 0 to let cards scroll off-screen
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.userName.isNotEmpty 
                      ? 'Welcome, ${state.userName}.' 
                      : 'Welcome back!',
                  style: boldStyle(
                    fontSize: FontSize.font22,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Monitor active projects and move your requirements forward.',
                  style: regularStyle(
                    fontSize: FontSize.font12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DashboardStatCard(
                  value: state.totalProjects.toString(),
                  label: 'All Projects',
                  icon: Icons.folder_copy_outlined,
                  iconBg: const Color(0xFFE8E0FF),
                  iconColor: AppColors.primary,
                ),
                DashboardStatCard(
                  value: state.inProgressCount.toString(),
                  label: 'In Progress',
                  icon: Icons.access_time_outlined,
                  iconBg: const Color(0xFFD4EDFF),
                  iconColor: Colors.blue,
                ),
                DashboardStatCard(
                  value: state.draftsCount.toString(),
                  label: 'Drafts',
                  icon: Icons.description_outlined,
                  iconBg: const Color(0xFFFFF0D4),
                  iconColor: Colors.orange,
                ),
                DashboardStatCard(
                  value: state.completedCount.toString(),
                  label: 'Completed',
                  icon: Icons.check_circle_outline,
                  iconBg: const Color(0xFFDCF5E4),
                  iconColor: Colors.green,
                ),
                SizedBox(width: 4.w), // Extra padding at the end of the scroll
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusSection(BuildContext context, List<Project> focusProjects) {
    if (focusProjects.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: Text(
            'No projects in progress.',
            style: regularStyle(fontSize: FontSize.font14, color: AppColors.lightgrey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFEEEEF0)),
      ),
      child: Column(
        children: focusProjects.map((project) {
          final isLast = project == focusProjects.last;
          return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimaryBorder,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.work_outline, color: AppColors.primary, size: 20.sp),
                ),
                title: Text(
                  project.name,
                  style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.darkgrey),
                ),
                subtitle: Text(
                  project.clientName,
                  style: regularStyle(fontSize: FontSize.font12, color: AppColors.lightgrey),
                ),
                trailing: Icon(Icons.chevron_right, color: AppColors.lightgrey, size: 20.sp),
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .pushNamed(AppRoutes.resultView, arguments: project);
                },
              ),
              if (!isLast)
                Divider(height: 1.h, thickness: 1, color: const Color(0xFFEEEEF0), indent: 16.w, endIndent: 16.w),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPortfolioSection(BuildContext context, List<Project> recentProjects) {
    if (recentProjects.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: Text(
            'No projects found.',
            style: regularStyle(fontSize: FontSize.font14, color: AppColors.lightgrey),
          ),
        ),
      );
    }

    return Column(
      children: recentProjects.map((project) {
        final badge = projectStatusBadge(project.status);
        final badgeBg = statusBadgeBg(badge);
        final badgeColor = statusBadgeColor(badge);
        final dateStr = project.createdAt != null 
            ? '${_getMonth(project.createdAt!.month)} ${project.createdAt!.day}, ${project.createdAt!.year}'
            : 'Unknown date';

        return GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(AppRoutes.resultView, arguments: project);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFEEEEF0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: semiBoldStyle(
                          fontSize: FontSize.font14,
                          color: AppColors.darkgrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        badge,
                        style: semiBoldStyle(
                          fontSize: FontSize.font10,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                if (project.description.isNotEmpty) ...[
                  Text(
                    project.description,
                    style: regularStyle(fontSize: FontSize.font12, color: AppColors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                ],
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14.sp, color: AppColors.lightgrey),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        project.clientName.isEmpty ? 'No Client' : project.clientName,
                        style: regularStyle(fontSize: FontSize.font12, color: AppColors.lightgrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.calendar_today_outlined, size: 14.sp, color: AppColors.lightgrey),
                    SizedBox(width: 4.w),
                    Text(
                      dateStr,
                      style: regularStyle(fontSize: FontSize.font12, color: AppColors.lightgrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}

// ── Notifications Panel ───────────────────────────────────────────────────────

class _NotificationsPanel extends StatelessWidget {
  const _NotificationsPanel({required this.onClose});
  final VoidCallback onClose;

  final _notifications = const [
    _NotifData(text: 'You have a bug that..', time: 'Just Now'),
    _NotifData(text: 'New user registered', time: '10 hours ago'),
    _NotifData(text: 'You have a...', time: '10 hours ago'),
    _NotifData(text: 'Drill: Jane subscribed', time: '1 hour - 1:00 AM'),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {}, // prevent close when tapping panel
              child: Container(
                width: 220.w,
                margin: EdgeInsets.only(top: 56.h, right: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 12.h, 8.w, 0),
                      child: Row(
                        children: [
                          Text(
                            'Notifications',
                            style: semiBoldStyle(
                              fontSize: FontSize.font14,
                              color: AppColors.darkgrey,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: onClose,
                            icon: Icon(Icons.close, size: 16.sp, color: AppColors.grey),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.w),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1.h, color: const Color(0xFFEEEEF0)),
                    ..._notifications.map((n) => _NotifTile(data: n)),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotifData {
  const _NotifData({required this.text, required this.time});
  final String text;
  final String time;
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.data});
  final _NotifData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            margin: EdgeInsets.only(top: 4.h),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.text,
                    style: regularStyle(fontSize: FontSize.font12, color: AppColors.darkgrey)),
                SizedBox(height: 2.h),
                Text(data.time,
                    style: regularStyle(fontSize: FontSize.font10, color: AppColors.lightgrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
