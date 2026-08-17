import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/clickup/domain/entities/clickup_push_result.dart';
import 'package:requra/features/clickup/presentation/cubit/clickup_cubit.dart';

class PushResultsView extends StatelessWidget {
  final ClickUpPushResult result;
  final String projectId;

  const PushResultsView({
    Key? key,
    required this.result,
    required this.projectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(Icons.cloud_done_outlined,
                  size: 20.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Push Complete',
                      style: boldStyle(
                        fontSize: FontSize.font16,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      '${result.createdCount} created · ${result.updatedCount} updated · ${result.failedCount} failed',
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
          SizedBox(height: 16.h),
          _buildDetailList(context),
          SizedBox(height: 16.h),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                context.read<ClickUpCubit>().fetchStatus(projectId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                'Done',
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailList(BuildContext context) {
    if (result.details.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Text(
          'No stories were pushed.',
          style: regularStyle(fontSize: FontSize.font14, color: AppColors.grey),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300.h),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: result.details.length,
        separatorBuilder: (_, __) => Divider(color: const Color(0xFFE5E7EB)),
        itemBuilder: (context, index) {
          final detail = result.details[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detail.userStoryId,
                      style: semiBoldStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.black,
                      ),
                    ),
                    _buildBadge(detail.action, detail.success),
                  ],
                ),
                if (detail.clickUpTaskId != null && detail.clickUpTaskId!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Task ID: ${detail.clickUpTaskId}',
                    style: regularStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
                if (!detail.success && detail.message != null && detail.message!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    detail.message!,
                    style: regularStyle(
                      fontSize: FontSize.font12,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(String action, bool success) {
    Color bgColor;
    Color textColor;

    if (success) {
      if (action.toLowerCase() == 'skipped') {
        bgColor = const Color(0xFFF3F4F6);
        textColor = AppColors.grey;
      } else {
        bgColor = const Color(0xFFDCFCE7);
        textColor = AppColors.statusFinished;
      }
    } else {
      bgColor = const Color(0xFFFEE2E2);
      textColor = AppColors.error;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        action.toUpperCase(),
        style: boldStyle(
          fontSize: FontSize.font10,
          color: textColor,
        ),
      ),
    );
  }
}
