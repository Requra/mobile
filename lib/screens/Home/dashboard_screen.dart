// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

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
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App Bar ────────────────────────────────────────────
                  _DashboardAppBar(
                    onNotificationTap: () {
                      setState(() => _showNotifications = !_showNotifications);
                    },
                  ),

                  // ── Purple header ─────────────────────────────────────
                  _HeaderStats(),

                  SizedBox(height: 16.h),

                  // ── Recent Actions ────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _RecentActions(),
                  ),

                  SizedBox(height: 16.h),

                  // ── Projects Overview ─────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _ProjectsOverview(),
                  ),
                ],
              ),
            ),

            // ── Notifications Panel (overlay) ─────────────────────────
            if (_showNotifications)
              _NotificationsPanel(
                onClose: () => setState(() => _showNotifications = false),
              ),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _DashboardAppBar extends StatelessWidget {
  const _DashboardAppBar({required this.onNotificationTap});
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.white,
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 28.h,
            errorBuilder: (_, __, ___) => Icon(
              Icons.smart_toy,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: const Color(0xFFF5F5F5),
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 18.sp,
                color: AppColors.grey,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: const Color(0xFFF5F5F5),
            ),
            child: Icon(
              Icons.menu_rounded,
              size: 18.sp,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header Stats (purple) ─────────────────────────────────────────────────────

class _HeaderStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B46C1), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: boldStyle(
              fontSize: FontSize.font22,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  color: Colors.white70, size: 12.sp),
              SizedBox(width: 4.w),
              Text(
                'Thurs 5-6-2025',
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Stat cards
          _StatCard(
            value: '160',
            label: 'Total Projects',
            icon: Icons.folder_copy_outlined,
            iconBg: const Color(0xFFE8E0FF),
            iconColor: AppColors.primary,
          ),
          SizedBox(height: 10.h),
          _StatCard(
            value: '16',
            label: 'New Community',
            icon: Icons.group_outlined,
            iconBg: const Color(0xFFDCF5E4),
            iconColor: Colors.green,
          ),
          SizedBox(height: 10.h),
          _StatCard(
            value: '7',
            label: 'Pending Review',
            icon: Icons.pending_actions_outlined,
            iconBg: const Color(0xFFFFF0D4),
            iconColor: Colors.orange,
          ),
          SizedBox(height: 10.h),
          _StatCard(
            value: '5',
            label: 'Exports Ready',
            icon: Icons.file_download_outlined,
            iconBg: const Color(0xFFD4EDFF),
            iconColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: boldStyle(
                  fontSize: FontSize.font20,
                  color: AppColors.darkgrey,
                ),
              ),
              Text(
                label,
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.lightgrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recent Actions ────────────────────────────────────────────────────────────

class _RecentActions extends StatelessWidget {
  final _actions = const [
    _ActionData(
        title: "Story #5 · acceptance schema · Project X",
        time: "2/13/25",
        sub: "2 New Comments"),
    _ActionData(
        title: "Story #5 · acceptance schema · Project Y",
        time: "5/20/26",
        sub: "7 New Changes"),
    _ActionData(
        title: "Story #5 · acceptance schema · Project K",
        time: "11/5/26",
        sub: "2 New Community"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Actions',
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.darkgrey,
                ),
              ),
              Text(
                'Show All →',
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ..._actions.map((a) => _ActionRow(data: a)),
        ],
      ),
    );
  }
}

class _ActionData {
  const _ActionData(
      {required this.title, required this.time, required this.sub});
  final String title;
  final String time;
  final String sub;
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.data});
  final _ActionData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            margin: EdgeInsets.only(top: 5.h),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightPrimary,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: regularStyle(
                    fontSize: FontSize.font12,
                    color: AppColors.darkgrey,
                  ),
                ),
                Text(
                  data.sub,
                  style: regularStyle(
                    fontSize: FontSize.font10,
                    color: AppColors.lightgrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.time,
            style: regularStyle(
              fontSize: FontSize.font10,
              color: AppColors.lightgrey,
            ),
          ),
        ],
      ),
    );
  }
}


// ── Projects Overview ─────────────────────────────────────────────────────────

class _ProjectsOverview extends StatelessWidget {
  final _projects = const [
    _ProjectOverviewData(
        name: 'VOIS',
        client: 'Aria Incentive',
        starring: 3,
        comments: 4,
        created: '14 ago',
        status: 'Active'),
    _ProjectOverviewData(
        name: 'Freelance',
        client: 'Amine',
        starring: 0,
        comments: 5,
        created: '12 ago',
        status: 'In Review'),
    _ProjectOverviewData(
        name: 'Nixon',
        client: '',
        starring: 2,
        comments: 6,
        created: '34 ago',
        status: 'Draft'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projects Overview',
            style: semiBoldStyle(
              fontSize: FontSize.font14,
              color: AppColors.darkgrey,
            ),
          ),
          SizedBox(height: 14.h),
          ..._projects.map((p) => _ProjectOverviewRow(data: p)),
        ],
      ),
    );
  }
}

class _ProjectOverviewData {
  const _ProjectOverviewData({
    required this.name,
    required this.client,
    required this.starring,
    required this.comments,
    required this.created,
    required this.status,
  });

  final String name;
  final String client;
  final int starring;
  final int comments;
  final String created;
  final String status;
}

class _ProjectOverviewRow extends StatelessWidget {
  const _ProjectOverviewRow({required this.data});
  final _ProjectOverviewData data;

  Color get _statusColor {
    switch (data.status) {
      case 'Active':
        return const Color(0xFF22C55E);
      case 'In Review':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFF97316);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFEEEEF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                data.name,
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.darkgrey,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  data.status,
                  style: semiBoldStyle(
                    fontSize: FontSize.font10,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (data.client.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              data.client,
              style: regularStyle(
                fontSize: FontSize.font12,
                color: AppColors.lightgrey,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.star_border_rounded,
                  size: 13.sp, color: AppColors.lightgrey),
              SizedBox(width: 3.w),
              Text('${data.starring}',
                  style: regularStyle(
                      fontSize: FontSize.font11, color: AppColors.lightgrey)),
              SizedBox(width: 12.w),
              Icon(Icons.comment_outlined,
                  size: 13.sp, color: AppColors.lightgrey),
              SizedBox(width: 3.w),
              Text('${data.comments}',
                  style: regularStyle(
                      fontSize: FontSize.font11, color: AppColors.lightgrey)),
              SizedBox(width: 12.w),
              Icon(Icons.access_time_outlined,
                  size: 13.sp, color: AppColors.lightgrey),
              SizedBox(width: 3.w),
              Text(data.created,
                  style: regularStyle(
                      fontSize: FontSize.font11, color: AppColors.lightgrey)),
            ],
          ),
        ],
      ),
    );
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
    _NotifData(text: 'Drill: Jane subscribed', time: '1 hour - 100 AM'),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withOpacity(0.3),
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
                      color: Colors.black.withOpacity(0.12),
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
                            icon: Icon(Icons.close,
                                size: 16.sp, color: AppColors.grey),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                                minWidth: 24.w, minHeight: 24.w),
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
                    style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.darkgrey)),
                SizedBox(height: 2.h),
                Text(data.time,
                    style: regularStyle(
                        fontSize: FontSize.font10,
                        color: AppColors.lightgrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


