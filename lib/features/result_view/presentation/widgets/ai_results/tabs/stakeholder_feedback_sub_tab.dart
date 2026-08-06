import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';

class StakeholderFeedbackSubTab extends StatefulWidget {
  final AiResultsDashboard dashboard;

  const StakeholderFeedbackSubTab({super.key, required this.dashboard});

  @override
  State<StakeholderFeedbackSubTab> createState() =>
      _StakeholderFeedbackSubTabState();
}

class _StakeholderFeedbackSubTabState extends State<StakeholderFeedbackSubTab> {
  int _selectedFilter = 0; // 0=All, 1=Open, 2=Resolved

  // Mock feedback data — the API doesn't provide this yet,
  // so we synthesise it from what we know about the run.
  List<_FeedbackItem> get _feedbackItems => [
        _FeedbackItem(
          status: 'RESOLVED',
          target: 'Summary',
          context: 'Executive summary',
          body: 'The scope section looks complete to me.',
          author: 'Amy Accepted',
          email: 'amy.accepted@example.com',
          date: 'Jun 3, 2026 · 02:00 PM',
          resolution: 'Confirmed scope with the client.',
          resolutionDate: 'JUN 4, 2026 · 12:00 PM',
        ),
        _FeedbackItem(
          status: 'OPEN',
          target: 'Requirement',
          context: 'Generate user stories with acceptance criteria',
          body:
              'Acceptance criteria should follow Given/When/Then consistently.',
          author: 'Amy Accepted',
          email: 'amy.accepted@example.com',
          date: 'Jun 3, 2026 · 01:00 PM',
        ),
        _FeedbackItem(
          status: 'OPEN',
          target: 'User Story',
          context: 'Extract requirements from notes',
          body:
              'Can we add a confidence indicator to each extracted requirement?',
          author: 'Amy Accepted',
          email: 'amy.accepted@example.com',
          date: 'Jun 3, 2026 · 12:00 PM',
        ),
      ];

  List<_FeedbackItem> get _filtered {
    if (_selectedFilter == 1) {
      return _feedbackItems.where((e) => e.status == 'OPEN').toList();
    }
    if (_selectedFilter == 2) {
      return _feedbackItems.where((e) => e.status == 'RESOLVED').toList();
    }
    return _feedbackItems;
  }

  int get _openCount =>
      _feedbackItems.where((e) => e.status == 'OPEN').length;
  int get _resolvedCount =>
      _feedbackItems.where((e) => e.status == 'RESOLVED').length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 24.sp, color: AppColors.black),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stakeholder feedback',
                            style: boldStyle(
                              fontSize: FontSize.font18,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Comments shared by stakeholders reviewing this project. The AI Review Queue is unchanged — this is the human feedback inbox.',
                            style: regularStyle(
                              fontSize: FontSize.font12,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Badges
                Row(
                  children: [
                    _buildCountBadge(
                        '$_openCount OPEN', const Color(0xFFD97706)),
                    SizedBox(width: 8.w),
                    _buildCountBadge(
                        '$_resolvedCount RESOLVED', AppColors.statusFinished),
                    SizedBox(width: 8.w),
                    _buildCountBadge(
                        '${_feedbackItems.length} UNREAD',
                        AppColors.primary),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Filter row
          Row(
            children: [
              // All / Open / Resolved tabs
              _buildFilterTab('All', 0),
              SizedBox(width: 4.w),
              _buildFilterTab('Open', 1),
              SizedBox(width: 4.w),
              _buildFilterTab('Resolved', 2),
              const Spacer(),
              // Target chips
              Row(
                children: [
                  Icon(Icons.filter_alt_outlined,
                      size: 14.sp, color: AppColors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    'TARGET',
                    style: semiBoldStyle(
                      fontSize: FontSize.font10,
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _buildTargetChip('Summary'),
                  SizedBox(width: 4.w),
                  _buildTargetChip('Requirement'),
                  SizedBox(width: 4.w),
                  _buildTargetChip('User Story'),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Feedback cards
          ..._filtered.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildFeedbackCard(item),
              )),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: boldStyle(fontSize: FontSize.font10, color: color),
      ),
    );
  }

  Widget _buildFilterTab(String label, int index) {
    final isActive = _selectedFilter == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: isActive
              ? Border.all(color: const Color(0xFFE5E7EB))
              : null,
        ),
        child: Text(
          label,
          style: semiBoldStyle(
            fontSize: FontSize.font12,
            color: isActive ? AppColors.black : AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildTargetChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: regularStyle(fontSize: FontSize.font12, color: AppColors.black),
      ),
    );
  }

  Widget _buildFeedbackCard(_FeedbackItem item) {
    final isResolved = item.status == 'RESOLVED';

    Color statusColor =
        isResolved ? AppColors.statusFinished : const Color(0xFFD97706);
    Color statusBg = isResolved
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEF3C7);

    Color targetColor;
    if (item.target == 'Summary') {
      targetColor = AppColors.primary;
    } else if (item.target == 'Requirement') {
      targetColor = const Color(0xFFD97706);
    } else {
      targetColor = const Color(0xFF0284C7);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + Target + Context
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  item.status,
                  style:
                      boldStyle(fontSize: FontSize.font10, color: statusColor),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: targetColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  item.target,
                  style:
                      boldStyle(fontSize: FontSize.font10, color: targetColor),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '· ${item.context}',
                  style: regularStyle(
                      fontSize: FontSize.font12, color: AppColors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Body
          Text(
            item.body,
            style:
                regularStyle(fontSize: FontSize.font14, color: AppColors.black),
          ),

          SizedBox(height: 8.h),

          // Author + date
          Text(
            '${item.author} · ${item.email} · ${item.date}',
            style:
                regularStyle(fontSize: FontSize.font12, color: AppColors.grey),
          ),

          // Resolution block or Mark resolved button
          if (isResolved && item.resolution != null) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESOLUTION · ${item.resolutionDate ?? ''}',
                    style: boldStyle(
                      fontSize: FontSize.font10,
                      color: AppColors.statusFinished,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.resolution!,
                    style: regularStyle(
                      fontSize: FontSize.font14,
                      color: AppColors.statusFinished,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (!isResolved) ...[
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.check_circle_outline,
                    size: 16.sp, color: AppColors.grey),
                label: Text(
                  'Mark resolved',
                  style: semiBoldStyle(
                    fontSize: FontSize.font12,
                    color: AppColors.grey,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 8.h),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedbackItem {
  final String status;
  final String target;
  final String context;
  final String body;
  final String author;
  final String email;
  final String date;
  final String? resolution;
  final String? resolutionDate;

  const _FeedbackItem({
    required this.status,
    required this.target,
    required this.context,
    required this.body,
    required this.author,
    required this.email,
    required this.date,
    this.resolution,
    this.resolutionDate,
  });
}
