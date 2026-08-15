import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';

import 'package:requra/features/meeting/data/models/meeting_models.dart';
import 'package:requra/features/meeting/data/services/meeting_service.dart';
import 'package:requra/features/meeting/data/services/recording_service.dart';
import 'package:requra/features/meeting/presentation/widgets/live_meeting/leave_end_session_sheet.dart';
import 'package:requra/features/meeting/presentation/widgets/live_meeting/consent_dialog.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_invite_sheet.dart';
import 'package:requra/features/meeting/presentation/widgets/live_meeting/meeting_bottom_action_bar.dart';
import 'package:requra/features/meeting/presentation/widgets/live_meeting/pending_invitations_sheet.dart';
import 'package:requra/features/meeting/presentation/widgets/live_meeting/remove_participant_sheet.dart';
import 'package:requra/features/meeting/domain/entities/meeting_summary.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/routes/app_routes.dart';
import 'package:requra/features/meeting/data/services/agora_service.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // ── Services ──
  final MeetingService _service = const MeetingService();
  late final RecordingService _recordingService;
  late final AgoraService _agoraService;

  // ── Agora State ──
  String? _agoraAppId;
  String? _agoraChannelName;
  int? _agoraUid;
  String? _agoraUserAccount;
  String? _agoraToken;
  ConnectionStateType _connectionState =
      ConnectionStateType.connectionStateDisconnected;
  StreamSubscription? _connectionSub;
  StreamSubscription? _eventSub;
  StreamSubscription? _tokenSub;
  StreamSubscription? _activeSpeakersSub;

  // ── State ──
  MeetingDetails? _meeting;
  List<Participant> _participants = [];
  List<Invitation> _invitations = [];
  RecordingInfo? _recording;
  bool _isMuted = false;
  bool _isCameraEnabled = false;
  Set<int> _activeSpeakers = {};
  CameraController? _cameraController;
  Offset _cameraOffset = Offset(16.w, 500.h); // Initial position for PIP
  String _currentParticipantId = '';
  bool _isHost = false;
  bool _consentGiven = false;
  bool _consentBannerDismissed = false;
  bool _isSpeakerphone = true;

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
    _agoraService = AgoraService();
    _recordingService = RecordingService(_service);
    _recordingService.stateStream.listen((isRecording) {
      if (!mounted) return;
      // You can update UI based on isRecording state here if needed
    });

    _connectionSub = _agoraService.connectionStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _connectionState = state);
      if (state == ConnectionStateType.connectionStateReconnecting) {
        _showToast('Reconnecting to audio...');
      } else if (state == ConnectionStateType.connectionStateFailed) {
        _showToast('Failed to connect to audio.');
      }
    });

    _eventSub = _agoraService.participantEventStream.listen((event) {
      // Handle user joined/offline if needed
    });

    _tokenSub = _agoraService.tokenExpireStream.listen((_) async {
      final response = await _service.getAgoraToken(_meetingId);
      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        await _agoraService.renewToken(data['token']);
      }
    });

    _activeSpeakersSub = _agoraService.activeSpeakersStream.listen((speakers) {
      if (!mounted) return;
      setState(() => _activeSpeakers = speakers);
    });

    WidgetsBinding.instance.addObserver(this);
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
      if (args is Map<String, dynamic>) {
        // New format: Map with meetingId and participantId from join API
        _meetingId = args['meetingId'] ?? '1';
        _currentParticipantId = args['participantId'] ?? '';
        _isMuted =
            !(args['isMicEnabled'] ?? true); // If mic is enabled, not muted
        _isCameraEnabled = args['isCameraEnabled'] ?? false;

        // Agora args
        _agoraAppId = args['appId'];
        _agoraChannelName = args['channelName'];
        _agoraUid = args['uid'];
        _agoraUserAccount = args['userAccount'];
        _agoraToken = args['token'];
      } else if (args is String) {
        // Legacy format: just meetingId string
        _meetingId = args;
      } else {
        _meetingId = '1';
      }

      if (_isCameraEnabled) {
        _initCamera();
      }

      _initAgora();
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _recordingService.dispose();
    _agoraService.dispose();
    _connectionSub?.cancel();
    _eventSub?.cancel();
    _tokenSub?.cancel();
    _activeSpeakersSub?.cancel();
    _pollTimer?.cancel();
    _elapsedTimer?.cancel();
    _recordingElapsedTimer?.cancel();
    _finalizingPollTimer?.cancel();
    _livePulse.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initAgora() async {
    if (_agoraAppId == null ||
        _agoraToken == null ||
        _agoraChannelName == null) return;
    try {
      await _agoraService.initialize(_agoraAppId!);
      _recordingService.setAgoraEngine(_agoraService.engine);

      await _agoraService.joinChannel(
        token: _agoraToken!,
        channelName: _agoraChannelName!,
        uid: _agoraUid,
        userAccount: _agoraUserAccount,
      );
      await _agoraService.muteLocalAudio(_isMuted);
      await _agoraService.setSpeakerphoneEnabled(_isSpeakerphone);
    } catch (e) {
      debugPrint('Agora init error: $e');
    }
  }

  /// Pause/resume polling based on app lifecycle (Section 4.3).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App going to background — stop polling to save resources
      _pollTimer?.cancel();
      _pollTimer = null;
      _agoraService.engine?.disableAudio();
    } else if (state == AppLifecycleState.resumed) {
      // App coming to foreground — refresh data and resume polling
      _agoraService.engine?.enableAudio();
      _agoraService.muteLocalAudio(_isMuted);
      _fetchMeeting();
      _fetchParticipants();
      _startPolling();
    }
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
      setState(() {
        _meeting = meeting;
        // Determine host status from currentUserRole (Section 4 / Spec #4)
        if (meeting.currentUserRole != null) {
          _isHost = meeting.currentUserRole!.toUpperCase() == 'HOST';
        }
        // If meeting has an active recording, update local state
        if (meeting.activeRecordingId != null &&
            meeting.activeRecordingId!.isNotEmpty &&
            _recording == null) {
          _recording = RecordingInfo(
            id: meeting.activeRecordingId!,
            status: RecordingStatus.active,
          );
        }
      });

      // Auto-kick: redirect if meeting ended or cancelled (Section 4.3)
      if (meeting.status == MeetingStatus.ended ||
          meeting.status == MeetingStatus.cancelled) {
        _navigateAway();
      }
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
        // Remove participants who left or were removed, except the current user
        final activeParticipants = parsed
            .where(
              (p) =>
                  p.connectionStatus == ParticipantConnectionStatus.joined ||
                  p.id == _currentParticipantId,
            )
            .toList();
        setState(() {
          _participants = activeParticipants;
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
    if (_participants.isEmpty) return;

    // If participantId was already set from the join API response, use it.
    if (_currentParticipantId.isNotEmpty) {
      final me = _participants.where((p) => p.id == _currentParticipantId);
      if (me.isNotEmpty) {
        _consentGiven = me.first.recordingConsent;
      }
      return;
    }

    // Fallback: first participant in the list is current user.
    final me = _participants.first;
    _currentParticipantId = me.id;

    // Determine host from meeting details currentUserRole if available,
    // otherwise fall back to participant role.
    if (_meeting?.currentUserRole != null) {
      _isHost = _meeting!.currentUserRole!.toUpperCase() == 'HOST';
    } else {
      _isHost = me.role == ParticipantRole.host;
    }

    _consentGiven = me.recordingConsent;
  }

  /// Poll participants every 5 seconds and meeting status to detect
  /// state changes (Section 4.3).
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchParticipants();
      _fetchMeeting();
    });
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

  Future<void> _initCamera() async {
    try {
      // Wait for the previous screen to fully dispose its camera instance
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _isCameraEnabled = false);
        return;
      }

      // Default to front camera for meeting
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed to init camera: $e');
      if (mounted) {
        setState(() {
          _isCameraEnabled = false;
        });
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_isCameraEnabled) {
      setState(() {
        _isCameraEnabled = false;
      });
      // We do not call stopImageStream unless we called startImageStream
      await _cameraController?.dispose();
      _cameraController = null;
    } else {
      setState(() {
        _isCameraEnabled = true;
      });
      await _initCamera();
    }
  }

  // §2 — Recording Consent
  Future<bool> _giveConsent() async {
    final response = await _service.giveConsent(
      _meetingId,
      _currentParticipantId,
    );
    if (!mounted) return false;
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
      _showToast('Consent recorded');
      return true;
    } else {
      _handleApiError(response.message, response.data);
      return false;
    }
  }

  // §7 — Start Recording
  Future<void> _startRecording() async {
    if (!_consentGiven) {
      ConsentDialog.show(
        context,
        onAgree: () async {
          final success = await _giveConsent();
          if (success && mounted) {
            _startRecording();
          }
        },
      );
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

      try {
        await _recordingService.start(_meetingId, rec.id);
      } catch (e) {
        _showToast('Could not start microphone: $e');
        _stopRecording(); // Fallback to stop the server side if mic failed
      }
    } else {
      setState(() => _recordingLoading = false);
      _handleApiError(response.message, response.data);
    }
  }

  // §7 — Stop Recording
  Future<void> _stopRecording([int retryCount = 0]) async {
    if (_recording == null) return;

    setState(() => _recordingLoading = true);

    // 1. Stop local audio capture and flush the upload queue
    final int lastChunk = await _recordingService.stop();

    // 2. Query backend status to check for missing chunks BEFORE stopping
    final statusResponse = await _service.getRecording(_recording!.id);
    if (statusResponse.isSuccess && statusResponse.data is Map<String, dynamic>) {
      final data = statusResponse.data as Map<String, dynamic>;
      final missingList = data['missingChunkIndexes'] as List<dynamic>?;
      if (missingList != null && missingList.isNotEmpty) {
        final missingIndexes = missingList
            .map((e) => int.tryParse(e.toString()) ?? -1)
            .where((e) => e != -1)
            .toList();
        if (missingIndexes.isNotEmpty) {
          _showToast('Uploading missing chunks before finalization…');
          await _recordingService.retryChunks(missingIndexes);
        }
      }
    }

    // 3. Call POST /recordings/{id}/stop
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
      // 4. Handle 409 Conflict (MISSING_CHUNKS)
      // The API spec states missing indexes are in the `errors` array
      if (response.statusCode == 409 && response.errors.isNotEmpty) {
        if (retryCount >= 3) {
          setState(() => _recordingLoading = false);
          _showToast('Failed to finalize recording: some chunks are permanently lost.');
          return;
        }

        final missingIndexes = response.errors
            .map((e) => int.tryParse(e.toString()))
            .where((e) => e != null)
            .cast<int>()
            .toList();

        if (missingIndexes.isEmpty) {
          setState(() => _recordingLoading = false);
          _handleApiError(response.message, response.data);
          return;
        }

        _showToast('Retrying missing chunks: $missingIndexes');

        await _recordingService.retryChunks(missingIndexes);

        setState(() => _recordingLoading = false);

        // Retry stop
        _stopRecording(retryCount + 1);
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

  // §9/§10 — Leave or End Meeting
  Future<void> _showLeaveOrEndDialog() async {
    final result = await LeaveEndSessionSheet.show(context, isHost: _isHost);
    if (result == null || !mounted) return;

    switch (result) {
      case LeaveEndResult.leaveOnly:
        setState(() => _leavingOrEnding = true);
        await _agoraService.leaveChannel();
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
        break;

      case LeaveEndResult.endForAll:
        setState(() => _leavingOrEnding = true);
        // If recording is active, stop it first.
        if (_recording?.status == RecordingStatus.active) {
          await _stopRecording();
          // Wait briefly for finalizing.
          await Future.delayed(const Duration(milliseconds: 500));
        }
        await _agoraService.leaveChannel();
        final response = await _service.endMeeting(_meetingId);
        if (!mounted) return;
        setState(() => _leavingOrEnding = false);
        if (response.isSuccess) {
          _navigateAway();
        } else {
          _showToast(response.message);
        }
        break;
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

    final summary = MeetingSummary(
      meetingTitle: _meeting?.title ?? 'Meeting',
      projectId: _meeting?.projectId ?? '',
      projectName: _meeting?.projectName ?? '',
    );

    Navigator.of(
      context,
    ).pushReplacementNamed(AppRoutes.meetingFinished, arguments: summary);
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
      case ParticipantRole.participant:
        return AppColors.roleMember;
      case ParticipantRole.viewer:
        return AppColors.roleGuest;
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
    return Stack(
      children: [
        Column(
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
              isCameraEnabled: _isCameraEnabled,
              isHost: _isHost,
              recordingStatus: _recording?.status ?? _meeting?.recordingStatus,
              isRecordingLoading: _recordingLoading,
              localVolumeStream: _agoraService.localVolumeStream,
              onMuteToggle: () {
                final newMuted = !_isMuted;
                setState(() => _isMuted = newMuted);
                _agoraService.muteLocalAudio(newMuted);
              },
              onCameraTap: _toggleCamera,
              onRecordTap: () {
                final status = _recording?.status ?? _meeting?.recordingStatus;
                if (status == RecordingStatus.active) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
              onInviteTap: () {
                MeetingInviteSheet.show(
                  context,
                  meetingId: _meetingId,
                  projectId: _meeting?.projectId ?? '',
                  joinUrl: _meeting?.joinUrl ?? '',
                );
              },
              onLeaveOrEndTap: _showLeaveOrEndDialog,
              onMoreTap: _showMoreOptionsSheet,
            ),
          ],
        ),

        // ── Draggable Camera PIP ──
        if (_isCameraEnabled &&
            _cameraController != null &&
            _cameraController!.value.isInitialized)
          Positioned(
            left: _cameraOffset.dx,
            top: _cameraOffset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _cameraOffset = Offset(
                    _cameraOffset.dx + details.delta.dx,
                    _cameraOffset.dy + details.delta.dy,
                  );

                  // Keep PIP within screen bounds
                  final screen = MediaQuery.of(context).size;
                  final pipWidth = 100.w;
                  final pipHeight = 150.h;

                  _cameraOffset = Offset(
                    _cameraOffset.dx.clamp(0, screen.width - pipWidth),
                    _cameraOffset.dy.clamp(
                      0,
                      screen.height - pipHeight - 100.h,
                    ), // 100.h padding for bottom bar
                  );
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 100.w,
                  height: 150.h,
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── More Options Sheet ────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  void _showMoreOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.meetingCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'More Options',
                      style: semiBoldStyle(
                        fontSize: FontSize.font18,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ListTile(
                      leading: Icon(
                        _isSpeakerphone
                            ? Icons.volume_up_rounded
                            : Icons.phone_in_talk_rounded,
                        color: Colors.white,
                      ),
                      title: Text(
                        _isSpeakerphone ? 'Speakerphone' : 'Earpiece',
                        style: regularStyle(
                          fontSize: FontSize.font14,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Switch(
                        value: _isSpeakerphone,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setSheetState(() => _isSpeakerphone = val);
                          setState(() => _isSpeakerphone = val);
                          _agoraService.setSpeakerphoneEnabled(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                      color: AppColors.liveRed.withValues(
                        alpha: 0.5 + _livePulse.value * 0.5,
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
                          color: AppColors.liveRed.withValues(
                            alpha: 0.6 + _livePulse.value * 0.4,
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
        color: AppColors.consentAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.consentAmber.withValues(alpha: 0.3),
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
                  MeetingInviteSheet.show(
                    context,
                    meetingId: _meetingId,
                    projectId: _meeting?.projectId ?? '',
                    joinUrl: '',
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
    final bool isTalking =
        isMe &&
        (_activeSpeakers.contains(0) ||
            (_agoraUid != null && _activeSpeakers.contains(_agoraUid)));

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.meetingCard,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isTalking
                ? AppColors.timerGreen
                : AppColors.meetingCardBorder,
            width: isTalking ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // ── Avatar ──
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: roleCol.withValues(alpha: 0.15),
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
                          color: roleCol.withValues(alpha: 0.15),
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
            color: widget.color.withValues(
              alpha: 0.5 + _controller.value * 0.5,
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
