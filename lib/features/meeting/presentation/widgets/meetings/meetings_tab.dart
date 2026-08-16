import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/presentation/widgets/meetings/meeting_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_state.dart';
import 'package:requra/features/meeting/presentation/pages/create_meeting_screen.dart';
import 'package:requra/features/meeting/presentation/widgets/meetings/meetings_empty_state.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_cubit.dart';

class MeetingsTab extends StatelessWidget {
  final List<Meeting> meetings;

  const MeetingsTab({super.key, required this.meetings});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        /// Header card
        Container(
          margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Meetings',
                style: boldStyle(
                  fontSize: FontSize.font16,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Manage and join live sync sessions for requirement gathering.',
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.lightgrey,
                ),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'Create Meeting',
                icon: Icons.add,
                color1: AppColors.primary,
                onTap: () {
                  final state = context.read<ResultViewCubit>().state;
                  if (state is ResultViewLoaded) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: context.read<ResultViewCubit>()),
                            BlocProvider.value(value: context.read<MeetingCubit>()),
                          ],
                          child: CreateMeetingScreen(projectId: state.projectDetails.id),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        /// Meetings list or empty state
        if (meetings.isEmpty)
          const MeetingsEmptyState()
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Column(
              children: meetings.map((meeting) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: MeetingCard(meeting: meeting),
              )).toList(),
            ),
          ),
      ],
    );
  }
}

