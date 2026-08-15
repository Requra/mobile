import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/core/storage/secure_token_storage.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/data/services/meeting_service.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:requra/features/meeting/presentation/helpers/date_helper.dart';


class PreJoinMeetingScreen extends StatefulWidget {
  final Meeting meeting;

  const PreJoinMeetingScreen({super.key, required this.meeting});

  @override
  State<PreJoinMeetingScreen> createState() => _PreJoinMeetingScreenState();
}

class _PreJoinMeetingScreenState extends State<PreJoinMeetingScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  StreamSubscription<Uint8List>? _micStreamSubscription;
  double _currentAmplitude = -50.0; // Min value usually around -50 or -160

  bool _isMicEnabled = false;
  String _errorMessage = '';

  // ── Join API state ──
  final MeetingService _meetingService = const MeetingService();
  static const SecureTokenStorage _tokenStorage = SecureTokenStorage();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInitCamera();
  }

  Future<void> _requestPermissionsAndInitCamera() async {
    final micStatus = await Permission.microphone.request();

    if (mounted) {
      setState(() {
        _isMicEnabled = micStatus.isGranted;
      });
    }

    if (micStatus.isGranted) {
      _startMicMeter();
    } else if (micStatus.isPermanentlyDenied) {
      _showPermissionDialog('Microphone');
    }
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _micStreamSubscription?.cancel();
    try {
      _audioRecorder.dispose();
    } catch (e) {
      debugPrint("Error disposing audio recorder: $e");
    }
    super.dispose();
  }

  Future<void> _showPermissionDialog(String title) async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title Permission Required'),
        content: Text('Please allow $title access in your device settings to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _startMicMeter() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final stream = await _audioRecorder.startStream(const RecordConfig());
        _micStreamSubscription = stream.listen((data) {
          // just drain the stream so amplitude works
        });
        
        _amplitudeSubscription = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((amp) {
          if (mounted) {
            setState(() {
              _currentAmplitude = amp.current;
            });
          }
        });
      }
    } catch (e) {
      debugPrint("Error starting mic meter: $e");
    }
  }

  Future<void> _stopMicMeter() async {
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    
    await _micStreamSubscription?.cancel();
    _micStreamSubscription = null;
    
    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
    } catch (e) {
      debugPrint("Ignored error stopping mic meter (likely disposed): $e");
    }
    
    if (mounted) {
      setState(() {
        _currentAmplitude = -50.0;
      });
    }
  }

  Future<void> _toggleMic() async {
    if (_isMicEnabled) {
      setState(() => _isMicEnabled = false);
      _stopMicMeter();
      return;
    }

    final status = await Permission.microphone.request();
    if (status.isGranted) {
      setState(() {
        _isMicEnabled = true;
      });
      _startMicMeter();
    } else {
      _showPermissionDialog('Microphone');
    }
  }

  Future<void> _joinMeeting() async {
    if (_isJoining) return;
    setState(() => _isJoining = true);

    try {
      // Read user profile from JWT token
      final displayName = await _tokenStorage.readDisplayName() ?? 'User';
      final email = await _tokenStorage.readEmail() ?? '';

      final response = await _meetingService.joinMeeting(
        widget.meeting.id,
        displayName: displayName,
        email: email,
      );

      if (!mounted) return;

      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final participantId = (data['id'] ?? data['participantId'] ?? '').toString();

        // Fetch Agora Token
        final tokenResponse = await _meetingService.getAgoraToken(widget.meeting.id);
        String? appId;
        String? channelName;
        String? userAccount;
        int? uid;
        String? token;

        if (tokenResponse.isSuccess && tokenResponse.data is Map<String, dynamic>) {
          final tData = tokenResponse.data as Map<String, dynamic>;
          appId = tData['appId']?.toString();
          channelName = tData['channelName']?.toString();
          
          final rawUid = tData['uid']?.toString() ?? '';
          if (int.tryParse(rawUid) != null) {
            uid = int.parse(rawUid);
          } else if (rawUid.isNotEmpty) {
            userAccount = rawUid;
            uid = 0;
          }
          token = tData['token']?.toString();
        }

        if (!mounted) return;

        await _stopMicMeter();

        if (!mounted) return;

        // Navigate to live meeting with both meetingId and participantId
        Navigator.pushReplacementNamed(
          context,
          '/liveMeeting',
          arguments: <String, dynamic>{
            'meetingId': widget.meeting.id,
            'participantId': participantId,
            'isMicEnabled': _isMicEnabled,
            if (appId != null) 'appId': appId,
            if (channelName != null) 'channelName': channelName,
            if (uid != null) 'uid': uid,
            if (userAccount != null) 'userAccount': userAccount,
            if (token != null) 'token': token,
          },
        );
      } else {
        setState(() => _isJoining = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join meeting: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16181F), // Dark theme like second image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meeting Title & Info
              Text(
                widget.meeting.title,
                style: boldStyle(fontSize: 24.sp, color: Colors.white),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 14.sp),
                  SizedBox(width: 6.w),
                  Text(
                    widget.meeting.scheduledAt != null 
                        ? formatDate(widget.meeting.scheduledAt!)
                        : 'Now',
                    style: regularStyle(fontSize: 14.sp, color: Colors.white70),
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.groups_outlined, color: Colors.white70, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    '${widget.meeting.participantsCount} Participants',
                    style: regularStyle(fontSize: 14.sp, color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Camera Preview Box
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white10, width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video placeholder
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic, color: Colors.white38, size: 64.sp),
                          SizedBox(height: 12.h),
                          Text(
                            _errorMessage.isNotEmpty ? _errorMessage : 'MIC ONLY',
                            style: semiBoldStyle(fontSize: 14.sp, color: Colors.white38),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      // Toggles at bottom
                      Positioned(
                        bottom: 24.h,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Mic with animated wave when active
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_isMicEnabled)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    width: 56.w + ((_currentAmplitude + 50).clamp(0.0, 50.0) / 50.0) * 30.w,
                                    height: 56.w + ((_currentAmplitude + 50).clamp(0.0, 50.0) / 50.0) * 30.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                _buildToggle(
                                  icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
                                  isActive: _isMicEnabled,
                                  onTap: _toggleMic,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 32.h),

              // Join Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: _isJoining ? null : _joinMeeting,
                  child: _isJoining
                      ? SizedBox(
                          width: 24.r,
                          height: 24.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Join Meeting',
                          style: boldStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle({required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isActive ? Colors.black54 : AppColors.error.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? Colors.white30 : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
    );
  }
}

