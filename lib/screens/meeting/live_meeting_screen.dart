import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:requra/features/meeting/data/models/meeting_models.dart';
import 'package:requra/features/meeting/data/services/meeting_service.dart';
import 'package:requra/screens/meeting/widgets/confirmation_sheet.dart';
import 'package:requra/screens/meeting/widgets/invite_sheet.dart';
import 'package:requra/screens/meeting/widgets/meeting_bottom_action_bar.dart';
import 'package:requra/screens/meeting/widgets/pending_invitations_sheet.dart';
import 'package:requra/screens/meeting/widgets/remove_participant_sheet.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

/// The live meeting screen shown when a meeting has status LIVE or RECORDING.
///
/// Receives `meetingId` as a route argument:
/// ```dart
/// Navigator.pushNamed(context, '/liveMeeting', arguments: meetingId);
/// ```
class LiveMeetingScreen extends StatefulWidget {
  const LiveMeetingScreen({super.key});

  @override
  State<LiveMeetingScreen> createState() => _LiveMeetingScreenState();
}

class _LiveMeetingScreenState extends State<LiveMeetingScreen>
    with SingleTickerProviderStateMixin {
  // ── Services ──
  final MeetingService _service = const MeetingService();

  // ── State ──
  MeetingDetails? _meeting;
  List<Participant> _participants = [];
  List<Invitation> _invitations = [];
  RecordingInfo? _recording;
  final Map<int, bool> _chunkMap = {};
  bool _isMuted = false;
  String _currentParticipantId = '';
  bool _isHost = false;
  bool _consentGiven = false;
  bool _consentBannerDismissed = false;

  // ── Loading flags ──
  bool _initialLoading = true;
  bool _recordingLoading = false;
  bool _leavingOrEnding = false;

  // ── Timers ──
  Timer? _pollTimer;
  Timer? _elapsedTimer;
  Timer? _recordingElapsedTimer;
  Timer? _finalizingPollTimer;
  int _elapsedSeconds = 0;
  int _recordingElapsedSeconds = 0;

  // ── Animation ──
  late AnimationController _livePulse;

  // ── Scrolling ──
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _participantsKey = GlobalKey();

  // ── Route param ──
  late String _meetingId;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _livePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      // Use fallback ID '1' so it loads even if opened directly as the initial route without arguments
      _meetingId = args is String ? args : '1';
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _elapsedTimer?.cancel();
    _recordingElapsedTimer?.cancel();
    _finalizingPollTimer?.cancel();
    _livePulse.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── Data Fetching ─────────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchMeeting(),
      _fetchParticipants(),
      _fetchInvitations(),
    ]);

    if (mounted) {
      setState(() => _initialLoading = false);
      _startPolling();
      _startElapsedTimer();
    }
  }

  Future<void> _fetchMeeting() async {
    final response = await _service.getMeeting(_meetingId);
    if (!mounted) return;
    if (response.isSuccess && response.data is Map<String, dynamic>) {
      final meeting = MeetingDetails.fromJson(
        response.data as Map<String, dynamic>,
      );
      setState(() => _meeting = meeting);

      // For testing with the mock API (which returns ENDED), we disable the auto-redirect
      // so you can actually see the screen instead of being kicked out.
      /*
      if (meeting.status == MeetingStatus.ended ||
          meeting.status == MeetingStatus.cancelled) {
        _navigateAway();
      }
      */
    } else {
      _handleApiError(response.message, response.data);
    }
  }

  Future<void> _fetchParticipants() async {
    final response = await _service.getParticipants(_meetingId);
    if (!mounted) return;
    if (response.isSuccess) {
      final data = response.data;
      List? list;
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic> && data['items'] is List) {
        list = data['items'] as List;
      }

      if (list != null) {
        final parsed = list
            .map((e) => Participant.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _participants = parsed;
          _resolveCurrentUser();
        });
      }
    }
  }

  Future<void> _fetchInvitations() async {
    final response = await _service.getInvitations(_meetingId);
    if (!mounted) return;
    if (response.isSuccess) {
      final data = response.data;
      List? list;
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic> && data['items'] is List) {
        list = data['items'] as List;
      }

      if (list != null) {
        setState(() {
          _invitations = list!
              .map((e) => Invitation.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    }
  }

  void _resolveCurrentUser() {
    // Try to identify current user. The first HOST participant, or the
    // one whose userId matches the stored profile. For now we use a
    // heuristic: the first participant with role HOST is "us" if we are
    // the host; otherwise the first JOINED participant is "us".
    // In production this would come from the JWT or user profile.
    if (_participants.isEmpty) return;

    // If we already identified, skip.
    if (_currentParticipantId.isNotEmpty) return;

    // Simple heuristic: first participant in the list is current user.
    final me = _participants.first;
    _currentParticipantId = me.id;

    // For testing with mock API: Force the user to be the host so all features (like remove participant) are visible.
    // In production: _isHost = me.role == ParticipantRole.host;
    _isHost = true;

    _consentGiven = me.recordingConsent;
  }

  void _startPolling() {
    _pollTimer?.cancel();
    // Removed polling every 15 seconds as requested by user
  }

  void _startElapsedTimer() {
    if (_meeting?.startedAt != null) {
      _elapsedSeconds = DateTime.now()
          .difference(_meeting!.startedAt!)
          .inSeconds;
    }
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── Actions ───────────────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  // §2 — Recording Consent
  Future<void> _giveConsent() async {
    final response = await _service.giveConsent(
      _meetingId,
      _currentParticipantId,
    );
    if (!mounted) return;
    if (response.isSuccess) {
      setState(() {
        _consentGiven = true;
        _consentBannerDismissed = true;
        // Update participant list locally.
        _participants = _participants.map((p) {
          if (p.id == _currentParticipantId) {
            return p.copyWith(recordingConsent: true);
          }
          return p;
        }).toList();
      });
    } else {
      _showToast(response.message);
    }
  }

  // §7 — Start Recording
  Future<void> _startRecording() async {
    if (!_consentGiven) {
      setState(() => _consentBannerDismissed = false);
      _showToast('Please consent to recording first');
      return;
    }

    setState(() => _recordingLoading = true);
    final response = await _service.startRecording(_meetingId);
    if (!mounted) return;

    if (response.isSuccess && response.data is Map<String, dynamic>) {
      final rec = RecordingInfo.fromJson(response.data as Map<String, dynamic>);
      setState(() {
        _recording = rec;
        _recordingLoading = false;
        _recordingElapsedSeconds = 0;
      });
      _startRecordingElapsedTimer();
      // Audio capture would start here with a recording plugin.
    } else {
      setState(() => _recordingLoading = false);
      _handleApiError(response.message, response.data);
    }
  }

  // §7 — Stop Recording
  Future<void> _stopRecording() async {
    if (_recording == null) return;

    setState(() => _recordingLoading = true);
    final int lastChunk = _chunkMap.isEmpty
        ? 0
        : _chunkMap.keys.reduce((a, b) => a > b ? a : b);

    final response = await _service.stopRecording(
      _recording!.id,
      _recordingElapsedSeconds,
      lastChunk,
    );
    if (!mounted) return;

    if (response.isSuccess) {
      _recordingElapsedTimer?.cancel();
      setState(() {
        _recording = _recording!.copyWith(status: RecordingStatus.finalizing);
        _recordingLoading = false;
      });
      _startFinalizingPoll();
    } else {
      // Check for MISSING_CHUNKS error.
      final data = response.data;
      if (data is Map<String, dynamic> &&
          data['code']?.toString() == 'MISSING_CHUNKS') {
        // Retry missing chunks then stop again.
        _showToast('Retrying missing chunks…');
        // In production: re-upload missing chunks, then call stop again.
        setState(() => _recordingLoading = false);
      } else {
        setState(() => _recordingLoading = false);
        _handleApiError(response.message, response.data);
      }
    }
  }

  void _startRecordingElapsedTimer() {
    _recordingElapsedTimer?.cancel();
    _recordingElapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordingElapsedSeconds++);
    });
  }

  void _startFinalizingPoll() {
    _finalizingPollTimer?.cancel();
    _finalizingPollTimer = Timer.periodic(const Duration(seconds: 3), (
      _,
    ) async {
      if (_recording == null) {
        _finalizingPollTimer?.cancel();
        return;
      }
      final response = await _service.getRecording(_recording!.id);
      if (!mounted) return;
      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final rec = RecordingInfo.fromJson(
          response.data as Map<String, dynamic>,
        );
        setState(() => _recording = rec);
        if (rec.status == RecordingStatus.ready ||
            rec.status == RecordingStatus.failed) {
          _finalizingPollTimer?.cancel();
        }
      }
    });
  }

  // §9 — Leave Meeting
  Future<void> _leaveMeeting() async {
    final confirmed = await ConfirmationSheet.show(
      context,
      title: 'Leave this meeting?',
      subtitle: 'You can rejoin later if the meeting is still active.',
      confirmLabel: 'Leave',
      confirmColor: AppColors.liveRed,
      icon: Icons.call_end_rounded,
    );
    if (!confirmed || !mounted) return;

    setState(() => _leavingOrEnding = true);
    final response = await _service.leaveMeeting(
      _meetingId,
      _currentParticipantId,
    );
    if (!mounted) return;
    setState(() => _leavingOrEnding = false);

    if (response.isSuccess) {
      Navigator.of(context).pop();
    } else {
      _showToast(response.message);
    }
  }

  // §10 — End Meeting (host only)
  Future<void> _endMeeting() async {
    final confirmed = await ConfirmationSheet.show(
      context,
      title: 'End meeting for everyone?',
      subtitle: 'All participants will be disconnected.',
      confirmLabel: 'End Meeting',
      confirmColor: AppColors.liveRed,
      icon: Icons.call_end_rounded,
    );
    if (!confirmed || !mounted) return;

    setState(() => _leavingOrEnding = true);

    // If recording is active, stop it first.
    if (_recording?.status == RecordingStatus.active) {
      await _stopRecording();
      // Wait briefly for finalizing.
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final response = await _service.endMeeting(_meetingId);
    if (!mounted) return;
    setState(() => _leavingOrEnding = false);

    if (response.isSuccess) {
      _navigateAway();
    } else {
      _showToast(response.message);
    }
  }

  // §4 — Remove Participant (host only)
  Future<void> _removeParticipant(Participant participant) async {
    final response = await _service.removeParticipant(
      _meetingId,
      participant.id,
    );
    if (!mounted) return;
    if (response.isSuccess) {
      _fetchParticipants();
      _showToast('${participant.displayName} removed');
    } else {
      _showToast(response.message);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── Error Handling ────────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleApiError(String message, dynamic data) {
    String? code;
    if (data is Map<String, dynamic>) {
      code = (data['code'] ?? data['error']?['code'])?.toString();
    }

    switch (code) {
      case 'CONSENT_REQUIRED':
        setState(() => _consentBannerDismissed = false);
        _showToast('Please consent to recording');
        break;
      case 'INVALID_STATE':
        _showToast('Meeting state has changed, please refresh');
        _fetchMeeting();
        break;
      case 'INVITATION_INVALID':
        _showToast('This invitation is no longer valid');
        break;
      case 'FORBIDDEN':
        _showToast('Only the host can perform this action');
        break;
      case 'MEETING_NOT_FOUND':
        _showToast('Meeting not found');
        Navigator.of(context).pop();
        break;
      default:
        _showToast(message);
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.meetingCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateAway() {
    if (!mounted) return;
    // Navigate back — in production this would go to a summary screen.
    Navigator.of(context).pop();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── Helpers ───────────────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  String _formatTimer(int totalSeconds) {
    final int m = totalSeconds ~/ 60;
    final int s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get _joinedCount => _participants.length;

  int get _pendingInvitationCount =>
      _invitations.where((i) => i.status == InvitationStatus.pending).length;

  bool get _showConsentBanner =>
      !_consentBannerDismissed &&
      !_consentGiven &&
      (_meeting?.status == MeetingStatus.recording ||
          _meeting?.recordingStatus == RecordingStatus.active ||
          _recording?.status == RecordingStatus.active);

  Color _roleColor(ParticipantRole role) {
    switch (role) {
      case ParticipantRole.host:
        return AppColors.roleHost;
      case ParticipantRole.member:
        return AppColors.roleMember;
      case ParticipantRole.stakeholder:
        return AppColors.roleStakeholder;
      case ParticipantRole.guest:
        return AppColors.roleGuest;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── Build ─────────────────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.meetingBg,
      body: _initialLoading
          ? _buildLoader()
          : (_leavingOrEnding ? _buildLoader() : _buildBody()),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // ── Scrollable content ──
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  _buildHeader(),
                  SizedBox(height: 16.h),
                  if (_showConsentBanner) ...[
                    _buildConsentBanner(),
                    SizedBox(height: 16.h),
                  ],
                  _buildStatsRow(),
                  SizedBox(height: 20.h),
                  _buildParticipantsSection(),
                ],
              ),
            ),
          ),
        ),
        // ── Bottom action bar ──
        MeetingBottomActionBar(
          isMuted: _isMuted,
          isHost: _isHost,
          recordingStatus: _recording?.status ?? _meeting?.recordingStatus,
          isRecordingLoading: _recordingLoading,
          onMuteToggle: () => setState(() => _isMuted = !_isMuted),
          onPeopleTap: () {
            // Scroll to participants section reliably
            if (_participantsKey.currentContext != null) {
              Scrollable.ensureVisible(
                _participantsKey.currentContext!,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
              );
            }
          },
          onRecordTap: () {
            final status = _recording?.status ?? _meeting?.recordingStatus;
            if (status == RecordingStatus.active) {
              _stopRecording();
            } else {
              _startRecording();
            }
          },
          onInviteTap: () {
            InviteSheet.show(
              context,
              meetingId: _meetingId,
              projectId: _meeting?.projectId ?? '',
              onInvited: _fetchInvitations,
            );
          },
          onLeaveOrEndTap: _isHost ? _endMeeting : _leaveMeeting,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── Section Builders ──────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  // §1 — Meeting Header
  Widget _buildHeader() {
    final meeting = _meeting;
    if (meeting == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          children: [
            Icon(Icons.videocam_rounded, color: Colors.white54, size: 20.r),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                meeting.title,
                style: semiBoldStyle(
                  fontSize: FontSize.font18,
                  color: AppColors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.more_vert_rounded, color: Colors.white38, size: 20.r),
          ],
        ),
        SizedBox(height: 12.h),

        // LIVE badge + elapsed timer + project name
        Row(
          children: [
            // LIVE pill
            AnimatedBuilder(
              animation: _livePulse,
              builder: (_, __) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.liveRed.withOpacity(
                        0.5 + _livePulse.value * 0.5,
                      ),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          color: AppColors.liveRed.withOpacity(
                            0.6 + _livePulse.value * 0.4,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'LIVE',
                        style: boldStyle(
                          fontSize: FontSize.font11,
                          color: AppColors.liveRed,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(width: 12.w),

            // Elapsed timer
            Text(
              _formatTimer(_elapsedSeconds),
              style: boldStyle(
                fontSize: FontSize.font20,
                color: AppColors.timerGreen,
              ).copyWith(fontFamily: 'monospace'),
            ),

            const Spacer(),

            // Project name
            Text(
              meeting.projectName,
              style: regularStyle(
                fontSize: FontSize.font12,
                color: Colors.white38,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),

        // Host + started at
        Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              color: Colors.white24,
              size: 14.r,
            ),
            SizedBox(width: 4.w),
            Text(
              'Host: ${meeting.hostName}',
              style: regularStyle(
                fontSize: FontSize.font12,
                color: Colors.white54,
              ),
            ),
            SizedBox(width: 8.w),
            Text('·', style: TextStyle(color: Colors.white24)),
            SizedBox(width: 8.w),
            Text(
              'Started ${_formatStartedAt(meeting.startedAt)}',
              style: regularStyle(
                fontSize: FontSize.font12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatStartedAt(DateTime? dt) {
    if (dt == null) return '--';
    final local = dt.toLocal();
    final hour = local.hour > 12 ? local.hour - 12 : local.hour;
    final amPm = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute $amPm';
  }

  // §2 — Consent Banner
  Widget _buildConsentBanner() {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 8.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.consentAmber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.consentAmber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.consentAmber,
            size: 22.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recording consent required',
                  style: semiBoldStyle(
                    fontSize: FontSize.font13,
                    color: AppColors.consentAmber,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'This session is being recorded',
                  style: regularStyle(
                    fontSize: FontSize.font11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: _giveConsent,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.consentAmber,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Consent',
              style: semiBoldStyle(
                fontSize: FontSize.font12,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // §3 — Stats Row
  Widget _buildStatsRow() {
    final recStatus =
        _recording?.status ??
        _meeting?.recordingStatus ??
        RecordingStatus.stopped;
    final bool recActive = recStatus == RecordingStatus.active;

    return Row(
      children: [
        // Participants count card
        Expanded(
          child: _StatCard(
            icon: Icons.people_outline_rounded,
            iconColor: Colors.white54,
            label: 'Participants',
            value: '$_joinedCount',
          ),
        ),
        SizedBox(width: 12.w),
        // Recording status card
        Expanded(
          child: _StatCard(
            icon: Icons.fiber_manual_record_rounded,
            iconColor: recActive ? AppColors.liveRed : Colors.white38,
            label: 'Recording',
            valueWidget: Row(
              children: [
                if (recActive) ...[
                  _PulsingDot(color: AppColors.liveRed),
                  SizedBox(width: 6.w),
                ],
                Flexible(
                  child: Text(
                    recActive
                        ? '${recStatus.label} · ${_formatTimer(_recordingElapsedSeconds)}'
                        : recStatus.label,
                    style: semiBoldStyle(
                      fontSize: FontSize.font16,
                      color: AppColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // §4 — Participants
  Widget _buildParticipantsSection() {
    return Container(
      key: _participantsKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Text(
                'Participants (${_participants.length})',
                style: semiBoldStyle(
                  fontSize: FontSize.font16,
                  color: AppColors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  InviteSheet.show(
                    context,
                    meetingId: _meetingId,
                    projectId: _meeting?.projectId ?? '',
                    onInvited: _fetchInvitations,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.meetingCardBorder,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add_alt_1_outlined,
                        color: Colors.white60,
                        size: 16.r,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Invite',
                        style: semiBoldStyle(
                          fontSize: FontSize.font12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Participant list
          ..._participants.map(_buildParticipantRow),

          // Pending invitations pill
          if (_pendingInvitationCount > 0) ...[
            SizedBox(height: 12.h),
            _buildPendingInvitationsPill(),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipantRow(Participant p) {
    final bool isMe = p.id == _currentParticipantId;
    final bool isJoined =
        p.connectionStatus == ParticipantConnectionStatus.joined;
    final Color roleCol = _roleColor(p.role);

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.meetingCard,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.meetingCardBorder, width: 1),
        ),
        child: Row(
          children: [
            // ── Avatar ──
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: roleCol.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                p.initials,
                style: semiBoldStyle(fontSize: FontSize.font13, color: roleCol),
              ),
            ),
            SizedBox(width: 12.w),

            // ── Name + meta ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          p.displayName,
                          style: semiBoldStyle(
                            fontSize: FontSize.font14,
                            color: AppColors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 4.w),
                        Text(
                          '(you)',
                          style: regularStyle(
                            fontSize: FontSize.font11,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      // Role badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: roleCol.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          p.role.label,
                          style: boldStyle(
                            fontSize: FontSize.font10,
                            color: roleCol,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Consent status
                      Text(
                        p.recordingConsent ? 'Consented ✓' : 'Awaiting consent',
                        style: regularStyle(
                          fontSize: FontSize.font11,
                          color: p.recordingConsent
                              ? AppColors.timerGreen
                              : AppColors.consentAmber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Online indicator ──
            Container(
              width: 10.r,
              height: 10.r,
              decoration: BoxDecoration(
                color: isJoined ? AppColors.timerGreen : Colors.white24,
                shape: BoxShape.circle,
              ),
            ),

            // ── Remove button (host only, not own row) ──
            if (_isHost && !isMe) ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  RemoveParticipantSheet.show(
                    context,
                    participant: p,
                    onConfirm: () => _removeParticipant(p),
                  );
                },
                child: Icon(
                  Icons.person_remove_outlined,
                  color: Colors.white24,
                  size: 20.r,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // §5 — Pending Invitations Pill
  Widget _buildPendingInvitationsPill() {
    return Center(
      child: GestureDetector(
        onTap: () {
          PendingInvitationsSheet.show(
            context,
            meetingId: _meetingId,
            invitations: _invitations,
            onRefresh: _fetchInvitations,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.meetingCard,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.meetingCardBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mail_outline_rounded,
                color: Colors.white38,
                size: 16.r,
              ),
              SizedBox(width: 8.w),
              Text(
                '$_pendingInvitationCount invitation${_pendingInvitationCount == 1 ? '' : 's'} pending',
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ── Reusable Sub-Widgets ────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════

/// A stat metric card used in the stats row.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.valueWidget,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.meetingCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.meetingCardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16.r),
              SizedBox(width: 6.w),
              Text(
                label,
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          valueWidget ??
              Text(
                value ?? '--',
                style: semiBoldStyle(
                  fontSize: FontSize.font22,
                  color: AppColors.white,
                ),
              ),
        ],
      ),
    );
  }
}

/// A small pulsing red dot indicator.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.5 + _controller.value * 0.5),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
