import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/meeting.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:requra/features/result_view/presentation/helpers/date_helper.dart';

class PreJoinMeetingScreen extends StatefulWidget {
  final Meeting meeting;

  const PreJoinMeetingScreen({super.key, required this.meeting});

  @override
  State<PreJoinMeetingScreen> createState() => _PreJoinMeetingScreenState();
}

class _PreJoinMeetingScreenState extends State<PreJoinMeetingScreen> {
  CameraController? _cameraController;
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  StreamSubscription<Uint8List>? _micStreamSubscription;
  double _currentAmplitude = -50.0; // Min value usually around -50 or -160

  bool _isCameraInitialized = false;
  bool _isCameraEnabled = false;
  bool _isMicEnabled = false;
  bool _cameraPermissionGranted = false;
  bool _micPermissionGranted = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInitCamera();
  }

  Future<void> _requestPermissionsAndInitCamera() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (mounted) {
      setState(() {
        _cameraPermissionGranted = cameraStatus.isGranted;
        _micPermissionGranted = micStatus.isGranted;

        _isCameraEnabled = cameraStatus.isGranted;
        _isMicEnabled = micStatus.isGranted;
      });
    }

    if (cameraStatus.isGranted) {
      _initCamera();
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera access is required for video.';
        });
      }
      if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
        _showPermissionDialog('Camera and Microphone');
      }
    }

    if (micStatus.isGranted) {
      _startMicMeter();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _errorMessage = 'No cameras found.');
        }
        return;
      }
      
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error initializing camera: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _stopMicMeter();
    _audioRecorder.dispose();
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

  Future<void> _toggleCamera() async {
    if (_isCameraEnabled) {
      setState(() => _isCameraEnabled = false);
      return;
    }

    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _cameraPermissionGranted = true;
        _isCameraEnabled = true;
      });
      if (!_isCameraInitialized) {
        _initCamera();
      }
    } else {
      _showPermissionDialog('Camera');
    }
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
    
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
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
        _micPermissionGranted = true;
        _isMicEnabled = true;
      });
      _startMicMeter();
    } else {
      _showPermissionDialog('Microphone');
    }
  }

  void _joinMeeting() {
    // Currently liveMeeting expects meetingId
    Navigator.pushReplacementNamed(
      context,
      '/liveMeeting',
      arguments: widget.meeting.id,
    );
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
                      // Video feed
                      if (_isCameraInitialized && _isCameraEnabled)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18.r),
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _cameraController!.value.previewSize!.height,
                                height: _cameraController!.value.previewSize!.width,
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          ),
                        ),
                      
                      // Disabled state
                      if (!_isCameraEnabled || !_cameraPermissionGranted)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam_off, color: Colors.white38, size: 64.sp),
                            SizedBox(height: 12.h),
                            Text(
                              _errorMessage.isNotEmpty ? _errorMessage : 'CAMERA IS DISABLED',
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
                            SizedBox(width: 24.w),
                            _buildToggle(
                              icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
                              isActive: _isCameraEnabled,
                              onTap: _toggleCamera,
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
                  onPressed: _joinMeeting,
                  child: Text(
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
