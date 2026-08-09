import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_colors.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_header.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_action_buttons.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_lifecycle_card.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_overview_card.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_live_room_card.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_participants_card.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_recording_card.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_cubit.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_state.dart';

/// Displays meeting details with a layout that varies by [Meeting.status].
///
/// Status mapping:
///   • Scheduled → amber badge, Invite / Edit / Start / Cancel buttons
///   • Cancelled → red badge, Invite / Start buttons
///   • Ended     → grey badge, no action buttons, shows started/ended times + recording card
///   • Live      → green badge, Join / Invite / End / Cancel buttons, shows started time
class MeetingDetailsScreen extends StatefulWidget {
  final Meeting meeting;

  const MeetingDetailsScreen({super.key, required this.meeting});

  @override
  State<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final error = await context.read<MeetingCubit>().getMeetingDetails(widget.meeting.id);
      if (mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load details: $error')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meeting details synced.')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeetingCubit, MeetingState>(
      builder: (context, state) {
        Meeting currentMeeting = widget.meeting;
        if (state is MeetingLoaded) {
          final index = state.meetings.indexWhere((m) => m.id == widget.meeting.id);
          if (index != -1) {
            currentMeeting = state.meetings[index];
          }
        }

        final bool isEnded = currentMeeting.status.toUpperCase() == 'ENDED';

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
                MeetingDetailsHeader(meeting: currentMeeting),
                if (!isEnded) MeetingActionButtons(meeting: currentMeeting),
                SizedBox(height: 12.h),
                MeetingLifecycleCard(meeting: currentMeeting),
                SizedBox(height: 14.h),
                MeetingOverviewCard(meeting: currentMeeting),
                SizedBox(height: 14.h),
                const MeetingLiveRoomCard(),
                SizedBox(height: 14.h),
                MeetingParticipantsCard(
                  participantsCount: currentMeeting.participantsCount,
                ),
                if (isEnded) ...[
                  SizedBox(height: 14.h),
                  const MeetingRecordingCard(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

