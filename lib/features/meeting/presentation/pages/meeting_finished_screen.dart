import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_finished_cubit.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_finished_state.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_finished/session_recording_card.dart';
import 'package:requra/routes/app_routes.dart';

class MeetingFinishedScreen extends StatelessWidget {
  const MeetingFinishedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB), // Light greyish blue background
      body: SafeArea(
        child: BlocBuilder<MeetingFinishedCubit, MeetingFinishedState>(
          builder: (context, state) {
            if (state is! MeetingFinishedLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final summary = state.summary;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  // Green Checkmark with glow
                  Container(
                    width: 72.r,
                    height: 72.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4), // Very light green
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF22C55E), // Green
                            width: 2.5,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: const Color(0xFF22C55E), // Green
                          size: 20.r,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  
                  // Title
                  Text(
                    'Meeting Finished',
                    style: boldStyle(
                      fontSize: FontSize.font24,
                      color: const Color(0xFF1E2022), // Dark text
                    ),
                  ),
                  SizedBox(height: 12.h),
                  
                  // Subtitle
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: const Color(0xFF7B8794),
                      ),
                      children: [
                        const TextSpan(text: 'The session for "'),
                        TextSpan(
                          text: summary.meetingTitle,
                          style: boldStyle(
                            fontSize: FontSize.font14,
                            color: const Color(0xFF1E2022),
                          ),
                        ),
                        const TextSpan(text: '" has\nended successfully.'),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  
                  // Recording Card
                  SessionRecordingCard(
                    transcriptStatus: summary.transcriptStatus,
                    aiExtractionStatus: summary.aiExtractionStatus,
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Go to Project Dashboard Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate with Project object instead of just projectId
                        // For now we just pop until home because we need the Project object 
                        // for the resultView route in app_routes.dart
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.main,
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6), // Purple
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Go to Project Dashboard →',
                        style: boldStyle(
                          fontSize: FontSize.font16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Home Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.main,
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E2022),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🏠', style: TextStyle(fontSize: FontSize.font16)),
                          SizedBox(width: 8.w),
                          Text(
                            'Home',
                            style: boldStyle(
                              fontSize: FontSize.font16,
                              color: const Color(0xFF1E2022),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Footer text
                  Text(
                    'AI ANALYSIS WILL APPEAR IN YOUR PROJECT\nREQUIREMENTS TAB ONCE COMPLETED.',
                    textAlign: TextAlign.center,
                    style: boldStyle(
                      fontSize: FontSize.font10,
                      color: const Color(0xFF9E9E9E),
                    ).copyWith(height: 1.5),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
