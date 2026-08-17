import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_card.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_colors.dart';

import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_invite_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_invite_cubit.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_invite_state.dart';

/// Participants summary + empty-state invite CTA.
class MeetingParticipantsCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingParticipantsCard({
    super.key,
    required this.meeting,
  });

  @override
  Widget build(BuildContext context) {
    return MeetingDetailsCard(
      children: [
        const MeetingDetailsCardHeader(icon: Icons.people_outline, title: 'Participants & Roster'),

        // Summary strip
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF6F4FF), Color(0xFFF7F7FA)],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Icon(Icons.people_outline,
                      size: 18.sp, color: MeetingDetailsColors.purple),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${meeting.participantsCount} Expected Participants',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: MeetingDetailsColors.ink,
                        fontFamily: FontConstants.fontFamily,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Real-time status of session invitees and participant connections.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: MeetingDetailsColors.inkSoft,
                        height: 1.4,
                        fontFamily: FontConstants.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Invitations List / Empty State
        BlocBuilder<MeetingInviteCubit, MeetingInviteState>(
          builder: (context, state) {
            if (state.loadingInvitations) {
              return const Center(
                  child: CircularProgressIndicator(color: MeetingDetailsColors.purple));
            }
            if (state.invitations.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildInvitationsList(context, state);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: MeetingDetailsColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: MeetingDetailsColors.purpleSoft,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(child: Icon(Icons.mail_outline, size: 20.sp, color: MeetingDetailsColors.purple)),
          ),
          SizedBox(height: 14.h),
          Text(
            'No Invitations Found',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: MeetingDetailsColors.ink,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Invite teammates, stakeholders, or external guests to join this session and collaborate in real-time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: MeetingDetailsColors.inkSoft,
              height: 1.5,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
          SizedBox(height: 18.h),
          GestureDetector(
            onTap: () {
              MeetingInviteSheet.show(
                context,
                meetingId: meeting.id,
                projectId: meeting.projectId,
                joinUrl: meeting.joinUrl,
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: MeetingDetailsColors.border, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt, size: 16.sp, color: MeetingDetailsColors.ink),
                  SizedBox(width: 6.w),
                  Text(
                    'Send First Invite',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: MeetingDetailsColors.ink,
                      fontFamily: FontConstants.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsList(BuildContext context, MeetingInviteState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: MeetingDetailsColors.border),
      ),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: state.invitations.length,
            separatorBuilder: (_, __) => Divider(color: MeetingDetailsColors.border, height: 24.h),
            itemBuilder: (_, i) {
              final inv = state.invitations[i];
              Color statusColor = MeetingDetailsColors.purple;
              Color statusBg = MeetingDetailsColors.purpleSoft;
              final s = inv.status.toUpperCase();
              if (s == 'ACCEPTED') {
                statusColor = const Color(0xFF16A34A);
                statusBg = const Color(0xFFDCFCE7);
              } else if (s == 'PENDING') {
                statusColor = const Color(0xFFD97706);
                statusBg = const Color(0xFFFEF3C7);
              } else {
                statusColor = const Color(0xFFDC2626);
                statusBg = const Color(0xFFFEE2E2);
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: MeetingDetailsColors.fieldBg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      inv.displayName.isNotEmpty ? inv.displayName[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: MeetingDetailsColors.ink),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inv.displayName,
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: MeetingDetailsColors.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          inv.email,
                          style: TextStyle(fontSize: 12.sp, color: MeetingDetailsColors.inkSoft),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4.r)),
                          child: Text(
                            inv.status.toUpperCase(),
                            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: GestureDetector(
              onTap: () {
                MeetingInviteSheet.show(
                  context,
                  meetingId: meeting.id,
                  projectId: meeting.projectId,
                  joinUrl: meeting.joinUrl,
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: MeetingDetailsColors.border, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt, size: 16.sp, color: MeetingDetailsColors.ink),
                    SizedBox(width: 6.w),
                    Text(
                      'Manage Invitations',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: MeetingDetailsColors.ink,
                        fontFamily: FontConstants.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

