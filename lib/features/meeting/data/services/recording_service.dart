import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:requra/features/meeting/data/services/meeting_service.dart';

class PendingChunk {
  final int index;
  final String filePath;
  final int startedAtMs;
  final int endedAtMs;

  PendingChunk({
    required this.index,
    required this.filePath,
    required this.startedAtMs,
    required this.endedAtMs,
  });

  Map<String, dynamic> toJson() => {
        'index': index,
        'filePath': filePath,
        'startedAtMs': startedAtMs,
        'endedAtMs': endedAtMs,
      };

  factory PendingChunk.fromJson(Map<String, dynamic> json) => PendingChunk(
        index: json['index'] as int,
        filePath: json['filePath'] as String,
        startedAtMs: json['startedAtMs'] as int,
        endedAtMs: json['endedAtMs'] as int,
      );
}

class RecordingService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final MeetingService _meetingService;

  Timer? _chunkTimer;
  String? _currentRecordingId;

  int _chunkIndex = 0;
  int _chunkStartTimeMs = 0;

  bool _isRecording = false;
  bool _isUploading = false;

  final String _queuePrefsKey = 'recording_chunk_queue';
  List<PendingChunk> _uploadQueue = [];

  // Used to notify the UI
  final _stateController = StreamController<bool>.broadcast();
  Stream<bool> get stateStream => _stateController.stream;

  RecordingService(this._meetingService) {
    _loadQueue();
  }

  void dispose() {
    _chunkTimer?.cancel();
    _audioRecorder.dispose();
    _stateController.close();
  }

  Future<void> _loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueStr = prefs.getString(_queuePrefsKey);
    if (queueStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(queueStr);
        _uploadQueue = decoded.map((e) => PendingChunk.fromJson(e)).toList();
        if (_uploadQueue.isNotEmpty) {
          _processUploadQueue();
        }
      } catch (e) {
        debugPrint('Error loading chunk queue: $e');
      }
    }
  }

  Future<void> _saveQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = jsonEncode(_uploadQueue.map((e) => e.toJson()).toList());
    await prefs.setString(_queuePrefsKey, queueJson);
  }

  Future<void> start(String meetingId, String recordingId) async {
    if (await _audioRecorder.hasPermission()) {
      _currentRecordingId = recordingId;
      _chunkIndex = 0;
      _isRecording = true;
      _stateController.add(_isRecording);

      await _startNewChunk();

      // Chunk every 10 seconds
      _chunkTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
        await _rotateChunk();
      });
    } else {
      throw Exception('Microphone permission not granted');
    }
  }

  Future<void> _startNewChunk() async {
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/rec_${_currentRecordingId}_${_chunkIndex}.m4a';

    _chunkStartTimeMs = DateTime.now().millisecondsSinceEpoch;
    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc, // Use aacLc for broader support on both iOS and Android if webm/opus is not fully supported by the plugin
      ),
      path: filePath,
    );
  }

  Future<void> _rotateChunk() async {
    if (!_isRecording) return;

    final path = await _audioRecorder.stop();
    final endTimeMs = DateTime.now().millisecondsSinceEpoch;

    if (path != null) {
      _queueChunkForUpload(
        _chunkIndex,
        path,
        _chunkStartTimeMs,
        endTimeMs,
      );
    }

    _chunkIndex++;
    if (_isRecording) {
      await _startNewChunk();
    }
  }

  Future<int> stop() async {
    if (!_isRecording) return _chunkIndex;
    _isRecording = false;
    _chunkTimer?.cancel();
    _stateController.add(_isRecording);

    final path = await _audioRecorder.stop();
    final endTimeMs = DateTime.now().millisecondsSinceEpoch;

    if (path != null) {
      _queueChunkForUpload(
        _chunkIndex,
        path,
        _chunkStartTimeMs,
        endTimeMs,
      );
    }

    // Wait for the queue to finish processing
    while (_isUploading) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return _chunkIndex;
  }

  void _queueChunkForUpload(
      int index, String path, int startMs, int endMs) {
    final chunk = PendingChunk(
      index: index,
      filePath: path,
      startedAtMs: startMs,
      endedAtMs: endMs,
    );
    _uploadQueue.add(chunk);
    _saveQueue();
    _processUploadQueue();
  }

  Future<void> _processUploadQueue() async {
    if (_isUploading || _uploadQueue.isEmpty || _currentRecordingId == null) {
      return;
    }
    _isUploading = true;

    while (_uploadQueue.isNotEmpty) {
      final chunk = _uploadQueue.first;
      try {
        final response = await _meetingService.uploadChunk(
          _currentRecordingId!,
          chunk.filePath,
          chunk.startedAtMs,
          chunk.endedAtMs,
        );

        if (response.isSuccess) {
          // Upload successful, remove from queue
          _uploadQueue.removeAt(0);
          await _saveQueue();
          // Optionally delete the temp file here to save space
          try {
            final file = File(chunk.filePath);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            debugPrint('Failed to delete chunk file: $e');
          }
        } else {
          // If the server explicitly rejected the chunk (e.g. 400 Bad Request)
          // we might want to drop it to avoid an infinite loop, or retry later.
          // For now, retry after a delay.
          debugPrint('Upload failed: ${response.message}');
          await Future.delayed(const Duration(seconds: 3));
          break; // Stop processing and let another call trigger it later
        }
      } catch (e) {
        debugPrint('Upload exception: $e');
        await Future.delayed(const Duration(seconds: 3));
        break; // Stop processing on network error
      }
    }

    _isUploading = false;
  }

  Future<void> retryChunks(List<int> missingIndexes) async {
    // If the server says some chunks are missing during finalization,
    // we would check our local storage for those chunks and re-queue them.
    // However, we delete chunks on success to save space.
    // If they failed, they would still be in `_uploadQueue`.
    // If the server lost them but we already deleted them, they are gone.
    // For robust implementation, we could keep them until finalization is done.
    
    // In our current simple implementation, we just trigger the queue again.
    _processUploadQueue();
    
    // Wait for the queue to finish processing (if it gave up, _isUploading will be false)
    while (_isUploading) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
