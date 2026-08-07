import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/meeting.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_details_colors.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_details_header.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_action_buttons.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_lifecycle_card.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_overview_card.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_live_room_card.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_participants_card.dart';
import 'package:requra/features/result_view/presentation/widgets/meeting_details/meeting_recording_card.dart';

/// Displays meeting details with a layout that varies by [Meeting.status].
///
/// Status mapping:
///   • Scheduled → amber badge, Invite / Edit / Start / Cancel buttons
///   • Cancelled → red badge, Invite / Start buttons
///   • Ended     → grey badge, no action buttons, shows started/ended times + recording card
///   • Live      → green badge, Join / Invite / End / Cancel buttons, shows started time
class MeetingDetailsScreen extends StatelessWidget {
  final Meeting meeting;

  const MeetingDetailsScreen({super.key, required this.meeting});

  bool get _isEnded => meeting.status.toUpperCase() == 'ENDED';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeetingDetailsColors.bg,
      appBar: AppBar(
        backgroundColor: MeetingDetailsColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Meeting Details',
          style: boldStyle(fontSize: FontSize.font16, color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MeetingDetailsHeader(meeting: meeting),
            if (!_isEnded) MeetingActionButtons(meeting: meeting),
            SizedBox(height: 12.h),
            MeetingLifecycleCard(meeting: meeting),
            SizedBox(height: 14.h),
            MeetingOverviewCard(meeting: meeting),
            SizedBox(height: 14.h),
            const MeetingLiveRoomCard(),
            SizedBox(height: 14.h),
            MeetingParticipantsCard(
              participantsCount: meeting.participantsCount,
            ),
            if (_isEnded) ...[
              SizedBox(height: 14.h),
              const MeetingRecordingCard(),
            ],
          ],
        ),
      ),
    );
  }
}
