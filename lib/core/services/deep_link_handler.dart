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
  static Future<bool> handleMeetingLink(MeetingDeepLink link) async {
    final context = navigatorKey.currentContext;
    if (context == null) return true; // App not fully loaded yet

    if (link.token != null) {
      // Guest or member invitation link
      final response = await _meetingService.previewInvitation(link.token!);
      if (!response.isSuccess) {
        AppSnackbar.showError(context, "Invalid or expired invitation");
        return true;
      }
      final data = response.data as Map<String, dynamic>;
      await _showGuestInvitationDialog(context, link, data);
      return true;
    } else {
      // Normal member meeting link
      // 1. Check auth
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        DeepLinkService.instance.savePending(link);
        return false; // caller should redirect to login
      }

      // 2. Fetch meeting details
      final response = await _meetingService.getMeeting(link.meetingId);

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

  static Future<void> _showGuestInvitationDialog(BuildContext context, MeetingDeepLink link, Map<String, dynamic> previewData) async {
    final title = previewData['meetingTitle'] ?? 'Meeting';
    final scheduledAtStr = previewData['scheduledAt'];
    final scheduledAt = scheduledAtStr != null ? DateTime.parse(scheduledAtStr) : null;
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        bool isAccepting = false;
        
        return StatefulBuilder(
          builder: (context, setState) {
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
                      'Meeting Name',
                      style: regularStyle(fontSize: FontSize.font12, color: AppColors.lightgrey),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      title,
                      style: semiBoldStyle(fontSize: FontSize.font16, color: AppColors.black),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Time',
                      style: regularStyle(fontSize: FontSize.font12, color: AppColors.lightgrey),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      scheduledAt != null ? formatDate(scheduledAt) : 'Now',
                      style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.black),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Invited As',
                      style: regularStyle(fontSize: FontSize.font12, color: AppColors.lightgrey),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${previewData['inviteeDisplayName'] ?? 'Guest'} (${previewData['inviteeType'] ?? 'GUEST'})',
                      style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.black),
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext); // Close dialog
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: Text(
                              'Cancel',
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
                            onPressed: isAccepting ? null : () async {
                              setState(() => isAccepting = true);
                              final acceptResponse = await _meetingService.acceptInvitation(link.token!);
                              if (acceptResponse.isSuccess) {
                                final acceptData = acceptResponse.data as Map<String, dynamic>;
                                if (acceptData['guestAccessToken'] != null) {
                                  await _tokenStorage.writeGuestAccessToken(acceptData['guestAccessToken']);
                                  await _tokenStorage.writeGuestDisplayName(previewData['inviteeDisplayName'] ?? 'Guest');
                                }
                                
                                final meeting = MeetingModel(
                                  id: link.meetingId,
                                  projectId: '',
                                  title: title,
                                  description: '',
                                  status: 'Live',
                                  joinUrl: '',
                                  scheduledAt: scheduledAt,
                                  startedAt: null,
                                  endedAt: null,
                                  createdAt: DateTime.now(),
                                  participantsCount: 1,
                                );
                                
                                if (context.mounted) {
                                  Navigator.pop(dialogContext); // Close dialog
                                  Navigator.pushNamed(context, '/preJoinMeeting', arguments: meeting);
                                }
                              } else {
                                setState(() => isAccepting = false);
                                if (context.mounted) {
                                  AppSnackbar.showError(context, "Failed to accept invitation");
                                }
                              }
                            },
                            child: isAccepting
                              ? SizedBox(
                                  width: 20.r,
                                  height: 20.r,
                                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Join Meeting',
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
          }
        );
      },
    );
  }
}
