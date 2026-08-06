import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_state.dart';
import 'package:requra/features/result_view/presentation/screens/create_meeting_screen.dart';

class MeetingsEmptyState extends StatelessWidget {
  const MeetingsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty.png',
              width: 180.w,
              height: 180.h,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.videocam_off_outlined,
                size: 100.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No meetings found',
              style: boldStyle(
                fontSize: FontSize.font18,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Get started by creating a new meeting to collaborate\nwith your team in real-time.',
              textAlign: TextAlign.center,
              style: regularStyle(
                fontSize: FontSize.font14,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Create Meeting',
              icon: Icons.videocam_outlined,
              onTap: () {
                final state = context.read<ResultViewCubit>().state;
                if (state is ResultViewLoaded) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ResultViewCubit>(),
                        child: CreateMeetingScreen(projectId: state.projectDetails.id),
                      ),
                    ),
                  );
                }
              },
              color1: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
