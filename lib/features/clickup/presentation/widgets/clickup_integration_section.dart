import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/clickup/presentation/cubit/clickup_cubit.dart';
import 'package:requra/features/clickup/presentation/cubit/clickup_state.dart';
import 'package:requra/features/clickup/presentation/widgets/clickup_oauth_webview.dart';
import 'package:requra/features/clickup/presentation/widgets/push_results_view.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

class ClickUpIntegrationSection extends StatelessWidget {
  final String projectId;

  const ClickUpIntegrationSection({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClickUpCubit, ClickUpState>(
      listener: (context, state) {
        if (state is ClickUpError && !state.isTokenExpired) {
          AppSnackbar.showError(context, state.message);
        } else if (state is ClickUpConnecting) {
          // Open the WebView using a modal or full screen route
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ClickUpCubit>(),
                child: ClickUpOAuthWebView(
                  authUrl: state.authUrl,
                  projectId: state.projectId,
                ),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
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
                  Icon(Icons.integration_instructions_outlined,
                      size: 20.sp, color: AppColors.grey),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ClickUp Integration',
                          style: boldStyle(
                            fontSize: FontSize.font16,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          'Push approved user stories directly to ClickUp',
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
              _buildContent(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ClickUpState state) {
    if (state is ClickUpInitial || state is ClickUpLoading || state is ClickUpExchangingCode || state is ClickUpConnecting) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state is ClickUpDisconnected) {
      return _buildDisconnected(context);
    }

    if (state is ClickUpConnected) {
      return _buildConnected(context, state);
    }

    if (state is ClickUpTokenExpired) {
      return _buildTokenExpired(context);
    }

    if (state is ClickUpPushing) {
      return _buildPushing(context);
    }

    if (state is ClickUpPushComplete) {
      return PushResultsView(result: state.result, projectId: projectId);
    }
    
    if (state is ClickUpError && state.isTokenExpired) {
      return _buildTokenExpired(context);
    }

    // Default or Error state fallback
    return _buildDisconnected(context);
  }

  Widget _buildDisconnected(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Not Connected',
          style: semiBoldStyle(
            fontSize: FontSize.font14,
            color: AppColors.grey,
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedButton.icon(
          onPressed: () {
            context.read<ClickUpCubit>().startConnect(projectId);
          },
          icon: Icon(Icons.link, size: 16.sp, color: AppColors.white),
          label: Text(
            'Connect to ClickUp',
            style: semiBoldStyle(
              fontSize: FontSize.font14,
              color: AppColors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildConnected(BuildContext context, ClickUpConnected state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, size: 16.sp, color: AppColors.statusFinished),
            SizedBox(width: 8.w),
            Text(
              'Connected to ClickUp',
              style: semiBoldStyle(
                fontSize: FontSize.font14,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Team ID: ${state.status.teamId ?? 'N/A'}\n'
          'Space ID: ${state.status.spaceId ?? 'N/A'}\n'
          'List ID: ${state.status.listId ?? 'N/A'}',
          style: regularStyle(
            fontSize: FontSize.font12,
            color: AppColors.grey,
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                context.read<ClickUpCubit>().pushApproved(projectId);
              },
              icon: Icon(Icons.cloud_upload, size: 16.sp, color: AppColors.white),
              label: Text(
                'Push Approved Stories',
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                _showDisconnectDialog(context);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              child: Text(
                'Disconnect',
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTokenExpired(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, size: 16.sp, color: AppColors.error),
            SizedBox(width: 8.w),
            Text(
              'Connection Expired',
              style: semiBoldStyle(
                fontSize: FontSize.font14,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Your ClickUp authorization has expired or is invalid. Please reconnect.',
          style: regularStyle(
            fontSize: FontSize.font12,
            color: AppColors.grey,
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedButton.icon(
          onPressed: () async {
            // First disconnect local state, then start connect
            await context.read<ClickUpCubit>().disconnect(projectId);
            if (context.mounted) {
              context.read<ClickUpCubit>().startConnect(projectId);
            }
          },
          icon: Icon(Icons.refresh, size: 16.sp, color: AppColors.white),
          label: Text(
            'Reconnect to ClickUp',
            style: semiBoldStyle(
              fontSize: FontSize.font14,
              color: AppColors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildPushing(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 16.h),
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 16.h),
        Text(
          'Pushing approved stories to ClickUp...',
          style: semiBoldStyle(
            fontSize: FontSize.font14,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'This may take a moment. Please do not close the app.',
          style: regularStyle(
            fontSize: FontSize.font12,
            color: AppColors.grey,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Disconnect ClickUp',
          style: boldStyle(fontSize: FontSize.font18, color: AppColors.black),
        ),
        content: Text(
          'Are you sure you want to disconnect ClickUp from this project?',
          style: regularStyle(fontSize: FontSize.font14, color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ClickUpCubit>().disconnect(projectId);
            },
            child: Text(
              'Disconnect',
              style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
