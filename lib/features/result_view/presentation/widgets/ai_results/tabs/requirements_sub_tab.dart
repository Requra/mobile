import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';

class RequirementsSubTab extends StatelessWidget {
  final AiResultsDashboard dashboard;

  const RequirementsSubTab({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Count
          Text(
            '${dashboard.requirements.length} requirements',
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
                  children: dashboard.requirements.map((req) {
                    return SizedBox(
                      width: (constraints.maxWidth - 16.w) / 2,
                      child: AiRequirementCard(req: req, dashboard: dashboard),
                    );
                  }).toList(),
                );
              } else {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dashboard.requirements.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    return AiRequirementCard(
                      req: dashboard.requirements[index],
                      dashboard: dashboard,
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class AiRequirementCard extends StatefulWidget {
  final AiRequirement req;
  final AiResultsDashboard dashboard;

  const AiRequirementCard({
    super.key,
    required this.req,
    required this.dashboard,
  });

  @override
  State<AiRequirementCard> createState() => _AiRequirementCardState();
}

class _AiRequirementCardState extends State<AiRequirementCard> {
  bool _isDescriptionExpanded = false;

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

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID and Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.req.id,
                style: semiBoldStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.grey,
                ),
              ),
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
            ],
          ),
          SizedBox(height: 8.h),
          // Title
          Text(
            widget.req.title,
            style: boldStyle(fontSize: FontSize.font16, color: AppColors.black),
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
          Row(
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
              // Mock tags for design
              SizedBox(width: 8.w),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(height: 1, color: const Color(0xFFE5E7EB)),
          SizedBox(height: 12.h),
          // Footer: Confidence and Evidence
          Row(
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: widget.req.confidenceScore,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFF59E0B),
                    ),
                    minHeight: 4.h,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${(widget.req.confidenceScore * 100).toInt()}%',
                style: semiBoldStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
