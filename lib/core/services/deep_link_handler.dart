import 'package:flutter/material.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';
import 'package:requra/core/navigation/navigator_key.dart';
import 'package:requra/core/storage/secure_token_storage.dart';
import 'package:requra/features/meeting/data/models/meeting_model.dart';
import 'package:requra/features/meeting/data/services/meeting_service.dart';
import 'package:requra/core/services/deep_link_service.dart';
import 'package:requra/features/meeting/presentation/helpers/date_helper.dart';
import 'package:requra/core/di/di_project.dart';
import 'package:requra/features/meeting/domain/usecases/start_meeting_usecase.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class DeepLinkHandler {
  static const SecureTokenStorage _tokenStorage = SecureTokenStorage();
  static const MeetingService _meetingService = MeetingService();

  /// Handles a meeting deep link.
  /// Returns true if navigation was handled, false if auth is needed.
  static Future<bool> handleMeetingLink(String meetingId) async {
    // 1. Check auth
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      DeepLinkService.instance.savePending(meetingId);
      return false; // caller should redirect to login
    }

    // 2. Fetch meeting details
    final response = await _meetingService.getMeeting(meetingId);

    // 3. Handle errors
    final context = navigatorKey.currentContext;
    if (context == null) return true; // App not fully loaded yet

    if (!response.isSuccess) {
      AppSnackbar.showError(context, "You are not allowed to join this meeting");
      return true;
    }

    // 4. Build Meeting entity & check status
    try {
      final meeting = MeetingModel.fromJson(response.data);
      if (meeting.status.toLowerCase() == 'ended' || meeting.status.toLowerCase() == 'cancelled') {
        AppSnackbar.showError(context, 'This meeting has ${meeting.status.toLowerCase()}');
        return true;
      }

      // 5. Show Invitation Dialog
      await _showInvitationDialog(context, meeting);
    } catch (e) {
      AppSnackbar.showError(context, "Failed to load meeting details");
    }
    return true;
  }

  static Future<void> _showInvitationDialog(BuildContext context, MeetingModel meeting) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: AppColors.white,
          elevation: 5,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.videocam_outlined,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Meeting Invitation',
                        style: boldStyle(fontSize: FontSize.font18, color: AppColors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Text(
                  'Name',
                  style: regularStyle(fontSize: FontSize.font12, color: AppColors.lightgrey),
                ),
                SizedBox(height: 4.h),
                Text(
                  meeting.title,
                  style: semiBoldStyle(fontSize: FontSize.font16, color: AppColors.black),
                ),
                if (meeting.description.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Details',
                    style: regularStyle(fontSize: FontSize.font12, color: AppColors.lightgrey),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    meeting.description,
                    style: regularStyle(fontSize: FontSize.font14, color: AppColors.darkgrey),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 16.h),
                Text(
                  'Time',
                  style: regularStyle(fontSize: FontSize.font12, color: AppColors.lightgrey),
                ),
                SizedBox(height: 4.h),
                Text(
                  meeting.scheduledAt != null ? formatDate(meeting.scheduledAt!) : 'Now',
                  style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.black),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext); // Close dialog
                          Navigator.pushReplacementNamed(context, '/main'); // Return to dashboard
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          'Back',
                          style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogContext); // Close dialog
                          
                          MeetingModel finalMeeting = meeting;
                          if (meeting.status.toLowerCase() == 'scheduled') {
                            try {
                              final startUseCase = sl<StartMeetingUseCase>();
                              await startUseCase(meeting.id);
                              // Optimistically update status to Live
                              finalMeeting = MeetingModel(
                                id: meeting.id,
                                projectId: meeting.projectId,
                                title: meeting.title,
                                description: meeting.description,
                                status: 'Live',
                                joinUrl: meeting.joinUrl,
                                scheduledAt: meeting.scheduledAt,
                                startedAt: meeting.startedAt,
                                endedAt: meeting.endedAt,
                                createdAt: meeting.createdAt,
                                participantsCount: meeting.participantsCount,
                              );
                            } catch (e) {
                              debugPrint("Failed to start meeting: $e");
                            }
                          }
                          
                          Navigator.pushNamed(context, '/preJoinMeeting', arguments: finalMeeting);
                        },
                        child: Text(
                          'Accept this invitation',
                          style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
