import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/di/di_project.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/global_widgets/custom_text_field.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_invite_cubit.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_invite_state.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_colors.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

class MeetingInviteSheet extends StatelessWidget {
  final String meetingId;
  final String projectId;
  final String joinUrl;

  const MeetingInviteSheet({
    super.key,
    required this.meetingId,
    required this.projectId,
    required this.joinUrl,
  });

  static Future<void> show(
    BuildContext context, {
    required String meetingId,
    required String projectId,
    required String joinUrl,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (context) => sl<MeetingInviteCubit>(),
        child: MeetingInviteSheet(
          meetingId: meetingId,
          projectId: projectId,
          joinUrl: joinUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _MeetingInviteSheetContent(
      meetingId: meetingId,
      projectId: projectId,
      joinUrl: joinUrl,
    );
  }
}

class _MeetingInviteSheetContent extends StatefulWidget {
  final String meetingId;
  final String projectId;
  final String joinUrl;

  const _MeetingInviteSheetContent({
    required this.meetingId,
    required this.projectId,
    required this.joinUrl,
  });

  @override
  State<_MeetingInviteSheetContent> createState() => _MeetingInviteSheetContentState();
}

class _MeetingInviteSheetContentState extends State<_MeetingInviteSheetContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Tab 2 (Participants) ──
  String _selectedRole = 'Contributor';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Tab 3 (Guest) ──
  final TextEditingController _guestNameCtrl = TextEditingController();
  final TextEditingController _guestEmailCtrl = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  String? _submittingMemberId;
  bool _submittingGuest = false;
  bool _isLinkCopied = false;
  
  String? _guestNameError;
  String? _guestEmailError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    _guestNameCtrl.addListener(() {
      if (_guestNameError != null && _guestNameCtrl.text.isNotEmpty) {
        setState(() => _guestNameError = null);
      }
    });

    _guestEmailCtrl.addListener(() {
      if (_guestEmailError != null && _guestEmailCtrl.text.isNotEmpty) {
        setState(() => _guestEmailError = null);
      }
    });

    // Initial load
    context.read<MeetingInviteCubit>().loadMembers(widget.projectId);
    context.read<MeetingInviteCubit>().loadInvitations(widget.meetingId);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _guestNameCtrl.dispose();
    _guestEmailCtrl.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final cubit = context.read<MeetingInviteCubit>();
    if (_tabController.index == 3 && cubit.state.needsRefresh) {
      cubit.markNeedsRefresh(false);
      cubit.loadInvitations(widget.meetingId);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    final messenger = _scaffoldMessengerKey.currentState;
    messenger?.clearSnackBars();
    messenger?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: semiBoldStyle(
                  fontSize: FontSize.font14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.only(bottom: 20.h, left: 16.w, right: 16.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Actions ──

  void _inviteParticipant(String memberId) {
    setState(() => _submittingMemberId = memberId);
    context.read<MeetingInviteCubit>().inviteParticipant(
          widget.meetingId,
          memberId,
          _selectedRole,
        );
  }

  void _inviteGuest() {
    final name = _guestNameCtrl.text.trim();
    final email = _guestEmailCtrl.text.trim();
    
    setState(() {
      _guestNameError = name.isEmpty ? 'Name is required' : null;
      _guestEmailError = email.isEmpty ? 'Email is required' : null;
    });

    if (name.isEmpty || email.isEmpty) {
      _showSnack('Cannot send invitation without name and email', isError: true);
      return;
    }

    setState(() => _submittingGuest = true);
    context.read<MeetingInviteCubit>().inviteGuest(widget.meetingId, name, email);
  }

  void _resendInvitation(String invitationId, String displayName) {
    context.read<MeetingInviteCubit>().resendInvitation(
          widget.meetingId,
          invitationId,
          displayName,
        );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MeetingInviteCubit, MeetingInviteState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          _showSnack(state.errorMessage!, isError: true);
          setState(() {
            _submittingMemberId = null;
            _submittingGuest = false;
          });
          context.read<MeetingInviteCubit>().clearMessages();
        } else if (state.successMessage != null) {
          _showSnack(state.successMessage!);
          setState(() {
            _submittingMemberId = null;
            _submittingGuest = false;
          });
          
          if (state.successMessage == 'Guest invited successfully!') {
            _guestNameCtrl.clear();
            _guestEmailCtrl.clear();
          }
          
          context.read<MeetingInviteCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return Container(
          height: 0.85.sh, // Force the height so the internal Scaffold works correctly
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            child: ScaffoldMessenger(
              key: _scaffoldMessengerKey,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
              // Handle
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: MeetingDetailsColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.person_add_alt_1_rounded,
                        color: MeetingDetailsColors.purple, size: 22.r),
                    SizedBox(width: 10.w),
                    Text(
                      'Invite to Meeting',
                      style: semiBoldStyle(
                          fontSize: FontSize.font18,
                          color: MeetingDetailsColors.ink),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Tabs
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                decoration: BoxDecoration(
                  color: MeetingDetailsColors.fieldBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: MeetingDetailsColors.purpleSoft,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: MeetingDetailsColors.purple, width: 1),
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: MeetingDetailsColors.purple,
                  unselectedLabelColor: MeetingDetailsColors.inkSoft,
                  labelPadding: EdgeInsets.zero,
                  labelStyle: semiBoldStyle(
                      fontSize: FontSize.font12,
                      color: MeetingDetailsColors.purple),
                  unselectedLabelStyle: regularStyle(
                      fontSize: FontSize.font12,
                      color: MeetingDetailsColors.inkSoft),
                  tabs: const [
                    Tab(text: 'Link'),
                    Tab(text: 'Participants'),
                    Tab(text: 'Guest'),
                    Tab(text: 'Invitations'),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Content
              Flexible(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLinkTab(),
                    _buildParticipantsTab(state),
                    _buildGuestTab(state),
                    _buildInvitationsTab(state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
},
);
  }

  // ── Tab 1: Link ──
  Widget _buildLinkTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meeting Link',
            style: semiBoldStyle(
                fontSize: FontSize.font14, color: MeetingDetailsColors.ink),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: MeetingDetailsColors.fieldBg,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: MeetingDetailsColors.border),
            ),
            child: Text(
              widget.joinUrl.isEmpty ? 'No link available' : widget.joinUrl,
              style: regularStyle(
                  fontSize: FontSize.font13,
                  color: MeetingDetailsColors.inkSoft),
            ),
          ),
          SizedBox(height: 24.h),
          CustomButton(
            text: _isLinkCopied ? 'Copied Link!' : 'Copy Link',
            icon: _isLinkCopied ? Icons.check_rounded : Icons.copy_rounded,
            color1: _isLinkCopied ? MeetingDetailsColors.green : MeetingDetailsColors.purple,
            color2: _isLinkCopied ? MeetingDetailsColors.green : MeetingDetailsColors.purple,
            onTap: widget.joinUrl.isEmpty || _isLinkCopied
                ? null
                : () {
                    setState(() => _isLinkCopied = true);
                    Clipboard.setData(ClipboardData(text: widget.joinUrl))
                        .then((_) {
                      _showSnack('Invitation link copied!');
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _isLinkCopied = false);
                      });
                    });
                  },
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Participants ──
  Widget _buildParticipantsTab(MeetingInviteState state) {
    final filteredMembers = state.members.where((m) {
      if (_searchQuery.isEmpty) return true;
      return m.displayName.toLowerCase().contains(_searchQuery) ||
             m.email.toLowerCase().contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        // Role Dropdown
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: MeetingDetailsColors.purpleSoft,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: MeetingDetailsColors.purple),
                style: semiBoldStyle(
                    fontSize: FontSize.font14,
                    color: MeetingDetailsColors.purple),
                items: const [
                  DropdownMenuItem(
                    value: 'Contributor',
                    child: Text('Participant (Full Media)'),
                  ),
                  DropdownMenuItem(
                    value: 'Viewer',
                    child: Text('Viewer (Listen Only)'),
                  ),
                  DropdownMenuItem(
                    value: 'Owner',
                    child: Text('Owner'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // Search
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: CustomTextField(
            controller: _searchController,
            hintText: 'Search teammates by name or email...',
            icon: Icons.search,
            searchStyle: true,
            borderColor: MeetingDetailsColors.border,
            borderRadius: 12,
          ),
        ),
        SizedBox(height: 16.h),
        // List
        Expanded(
          child: state.loadingMembers
              ? const Center(
                  child: CircularProgressIndicator(
                      color: MeetingDetailsColors.purple))
              : filteredMembers.isEmpty
                  ? Center(
                      child: Text(
                        'No team members found',
                        style: regularStyle(
                            fontSize: FontSize.font14,
                            color: MeetingDetailsColors.inkSoft),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                      itemCount: filteredMembers.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: MeetingDetailsColors.border, height: 24.h),
                      itemBuilder: (_, i) {
                        final member = filteredMembers[i];
                        return Row(
                          children: [
                            Container(
                              width: 40.r,
                              height: 40.r,
                              decoration: BoxDecoration(
                                color: MeetingDetailsColors.purpleSoft,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _initials(member.displayName),
                                style: semiBoldStyle(
                                    fontSize: FontSize.font14,
                                    color: MeetingDetailsColors.purple),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.displayName,
                                    style: semiBoldStyle(
                                        fontSize: FontSize.font14,
                                        color: MeetingDetailsColors.ink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    member.email,
                                    style: regularStyle(
                                        fontSize: FontSize.font12,
                                        color: MeetingDetailsColors.inkSoft),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: MeetingDetailsColors.greenSoft,
                                      borderRadius:
                                          BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      (member.role == null || member.role!.isEmpty)
                                          ? 'TEAM'
                                          : member.role!.toUpperCase(),
                                      style: semiBoldStyle(
                                          fontSize: FontSize.font10,
                                          color: MeetingDetailsColors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            SizedBox(
                              width: 110.w,
                              child: CustomButton(
                                height: 36.h,
                                fontSize: FontSize.font11,
                                text: (_submittingMemberId == member.id && state.isSubmitting)
                                    ? 'SENDING...'
                                    : 'SEND INVITE',
                                isRegularStyle: false,
                                transparent: true,
                                borderColor: MeetingDetailsColors.border,
                                textColor: (_submittingMemberId == member.id && state.isSubmitting)
                                    ? MeetingDetailsColors.inkSoft
                                    : MeetingDetailsColors.ink,
                                onTap: state.isSubmitting
                                    ? null
                                    : () => _inviteParticipant(member.id),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ── Tab 3: Guest ──
  Widget _buildGuestTab(MeetingInviteState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guest Name',
            style: semiBoldStyle(
                fontSize: FontSize.font13, color: MeetingDetailsColors.ink),
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            controller: _guestNameCtrl,
            hintText: 'e.g. John Doe',
            borderColor: _guestNameError != null ? MeetingDetailsColors.red : MeetingDetailsColors.border,
            errorText: _guestNameError,
            borderRadius: 8,
          ),
          SizedBox(height: 16.h),
          Text(
            'Guest Email',
            style: semiBoldStyle(
                fontSize: FontSize.font13, color: MeetingDetailsColors.ink),
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            controller: _guestEmailCtrl,
            hintText: 'john.doe@example.com',
            keyboardType: TextInputType.emailAddress,
            borderColor: _guestEmailError != null ? MeetingDetailsColors.red : MeetingDetailsColors.border,
            errorText: _guestEmailError,
            borderRadius: 8,
          ),
          SizedBox(height: 24.h),
          CustomButton(
            height: 40.h,
            text: (_submittingGuest && state.isSubmitting) ? 'Sending...' : 'Send Invite',
            color1: MeetingDetailsColors.purple,
            color2: MeetingDetailsColors.purple,
            onTap: state.isSubmitting ? null : _inviteGuest,
          ),
        ],
      ),
    );
  }

  // ── Tab 4: Invitations ──
  Widget _buildInvitationsTab(MeetingInviteState state) {
    if (state.loadingInvitations) {
      return const Center(
          child:
              CircularProgressIndicator(color: MeetingDetailsColors.purple));
    }
    if (state.invitations.isEmpty) {
      return Center(
        child: Text(
          'No invitations sent yet',
          style: regularStyle(
              fontSize: FontSize.font14, color: MeetingDetailsColors.inkSoft),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      itemCount: state.invitations.length,
      separatorBuilder: (_, __) =>
          Divider(color: MeetingDetailsColors.border, height: 24.h),
      itemBuilder: (_, i) {
        final inv = state.invitations[i];
        final bool isResending = state.resendingIds.contains(inv.id);
        
        Color statusColor;
        Color statusBg;
        final s = inv.status.toUpperCase();
        if (s == 'ACCEPTED') {
          statusColor = MeetingDetailsColors.green;
          statusBg = MeetingDetailsColors.greenSoft;
        } else if (s == 'PENDING') {
          statusColor = MeetingDetailsColors.amberInk;
          statusBg = MeetingDetailsColors.amberBg;
        } else {
          statusColor = MeetingDetailsColors.red;
          statusBg = MeetingDetailsColors.redSoft;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: MeetingDetailsColors.fieldBg,
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: Text(
                _initials(inv.displayName),
                style: semiBoldStyle(
                    fontSize: FontSize.font14, color: MeetingDetailsColors.ink),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          inv.displayName,
                          style: semiBoldStyle(
                              fontSize: FontSize.font14,
                              color: MeetingDetailsColors.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: MeetingDetailsColors.bg,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          inv.inviteType.toUpperCase(), // GUEST or PARTICIPANT
                          style: semiBoldStyle(
                              fontSize: FontSize.font10,
                              color: MeetingDetailsColors.inkSoft),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    inv.email,
                    style: regularStyle(
                        fontSize: FontSize.font12,
                        color: MeetingDetailsColors.inkSoft),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        inv.role,
                        style: semiBoldStyle(
                            fontSize: FontSize.font11,
                            color: MeetingDetailsColors.purple),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          inv.status.toUpperCase(),
                          style: semiBoldStyle(
                              fontSize: FontSize.font10, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            IconButton(
              onPressed: isResending ? null : () => _resendInvitation(inv.id, inv.displayName),
              icon: isResending
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.refresh_rounded,
                      color: MeetingDetailsColors.inkSoft, size: 20.r),
              tooltip: 'Resend Invitation',
            ),
          ],
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
