import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/features/meeting/presentation/widgets/meeting_details/meeting_details_colors.dart';
import 'package:requra/features/meeting/domain/entities/meeting.dart';
import 'package:requra/features/meeting/data/services/meeting_service.dart';
import 'package:requra/features/meeting/data/models/meeting_models.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

/// Dark-themed session recording card shown only when the meeting has ended.
class MeetingRecordingCard extends StatefulWidget {
  final Meeting meeting;

  const MeetingRecordingCard({super.key, required this.meeting});

  @override
  State<MeetingRecordingCard> createState() => _MeetingRecordingCardState();
}

class _MeetingRecordingCardState extends State<MeetingRecordingCard> {
  final MeetingService _meetingService = const MeetingService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLoading = true;
  RecordingInfo? _recordingInfo;
  String? _fileUrl;
  double _fileSizeMB = 0;
  String _mimeType = '';

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double? _dragPosition;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _fetchRecordingDetails();

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
        if (state.processingState == ProcessingState.completed) {
          _audioPlayer.pause();
          _audioPlayer.seek(Duration.zero);
        }
      }
    });

    _audioPlayer.durationStream.listen((newDuration) {
      if (mounted && newDuration != null && newDuration.inSeconds > _duration.inSeconds) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.positionStream.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchRecordingDetails() async {
    if (widget.meeting.activeRecordingId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final response = await _meetingService.getRecording(widget.meeting.activeRecordingId!);
    if (mounted) {
      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _recordingInfo = RecordingInfo.fromJson(data);
          _fileUrl = data['fileUrl']?.toString();
          _mimeType = data['mimeType']?.toString() ?? 'Unknown';
          
          final sizeBytes = int.tryParse(data['fileSize']?.toString() ?? '0') ?? 0;
          _fileSizeMB = sizeBytes / (1024 * 1024);

          // If the backend didn't provide a duration, we might get it when the audio loads.
          final durSecs = int.tryParse(data['durationSeconds']?.toString() ?? '0') ?? 0;
          if (durSecs > 0) {
            _duration = Duration(seconds: durSecs);
          }
          
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_fileUrl == null || _fileUrl!.isEmpty) {
      AppSnackbar.showError(context, 'Audio file not available yet.');
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.audioSource == null) {
          await _audioPlayer.setUrl(_fileUrl!);
        }
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to play audio: $e');
      }
    }
  }

  Future<void> _toggleMute() async {
    try {
      if (_isMuted) {
        await _audioPlayer.setVolume(1.0);
        setState(() => _isMuted = false);
      } else {
        await _audioPlayer.setVolume(0.0);
        setState(() => _isMuted = true);
      }
    } catch (e) {
      debugPrint('Failed to toggle mute: $e');
    }
  }

  String _formatDuration(Duration d) {
    final int min = d.inMinutes;
    final int sec = d.inSeconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 18.w),
        padding: EdgeInsets.all(18.w),
        height: 150.h,
        decoration: BoxDecoration(
          color: const Color(0xFF14151A),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFF23252C)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: MeetingDetailsColors.green),
        ),
      );
    }

    if (_recordingInfo == null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 18.w),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: const Color(0xFF14151A),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFF23252C)),
        ),
        child: Center(
          child: Text(
            'No session recording available.',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white54,
              fontFamily: FontConstants.fontFamily,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14151A), Color(0xFF0C0D10)],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFF23252C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          SizedBox(height: 16.h),
          _metaRow(),
          SizedBox(height: 12.h),
          _playerRow(),
          SizedBox(height: 16.h),
          _downloadButton(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: MeetingDetailsColors.green,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'Session Recording',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: FontConstants.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _metaRow() {
    String formatName = 'AUDIO';
    if (_mimeType.isNotEmpty) {
      if (_mimeType.contains('webm')) formatName = 'WEBM';
      if (_mimeType.contains('mp4') || _mimeType.contains('m4a')) formatName = 'M4A';
      if (_mimeType.contains('mpeg') || _mimeType.contains('mp3')) formatName = 'MP3';
    }

    String durationStr;
    if (_duration.inMinutes > 0) {
      durationStr = '${_duration.inMinutes} MIN';
    } else {
      durationStr = '${_duration.inSeconds} SEC';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C22),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF26272F)),
      ),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: _metaLabel('FORMAT: $formatName'),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: _metaLabel('DURATION: $durationStr'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.5.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: const Color(0xFF9A9CA8),
        fontFamily: FontConstants.fontFamily,
      ),
    );
  }

  Widget _playerRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF26272F)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 26.w,
              height: 26.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2B2C34),
              ),
              child: Center(
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            '${_formatDuration(_dragPosition != null ? Duration(seconds: _dragPosition!.toInt()) : _position)} / ${_formatDuration(_duration)}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD7D8DE),
              fontFamily: FontConstants.fontFamily,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Builder(
              builder: (context) {
                double effectiveMax = _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0;
                double currentValue = _position.inSeconds.toDouble();
                if (currentValue > effectiveMax) {
                  effectiveMax = currentValue;
                }
                
                return SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
                    activeTrackColor: MeetingDetailsColors.green,
                    inactiveTrackColor: const Color(0xFF3A3B44),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    min: 0,
                    max: effectiveMax,
                    value: (_dragPosition ?? currentValue).clamp(0.0, effectiveMax),
                    onChanged: (value) {
                      setState(() {
                        _dragPosition = value;
                      });
                    },
                    onChangeEnd: (value) async {
                      final position = Duration(seconds: value.toInt());
                      setState(() {
                        _position = position;
                      });
                      await _audioPlayer.seek(position);
                      if (_isPlaying) {
                        await _audioPlayer.play();
                      }
                      setState(() {
                        _dragPosition = null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: _toggleMute,
            child: Icon(
              _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: const Color(0xFFB7B8C1),
              size: 18.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadButton() {
    final sizeStr = _fileSizeMB > 0 ? ' (${_fileSizeMB.toStringAsFixed(2)} MB)' : '';

    return GestureDetector(
      onTap: () async {
        if (_fileUrl != null && _fileUrl!.isNotEmpty) {
          final Uri url = Uri.parse(_fileUrl!);
          try {
            final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
            if (!launched) {
              final launchedFallback = await launchUrl(url, mode: LaunchMode.platformDefault);
              if (!launchedFallback) {
                throw Exception('Failed to launch');
              }
            }
          } catch (e) {
            if (mounted) {
              Clipboard.setData(ClipboardData(text: url.toString()));
              AppSnackbar.showError(context, 'Could not open. Link copied to clipboard!');
            }
          }
        } else {
          AppSnackbar.showError(context, 'Audio file not ready.');
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: MeetingDetailsColors.green,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'DOWNLOAD AUDIO FILE$sizeStr',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: const Color(0xFF04241A),
            fontFamily: FontConstants.fontFamily,
          ),
        ),
      ),
    );
  }
}
