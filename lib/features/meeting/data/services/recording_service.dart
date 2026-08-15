import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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
  AudioRecorder _audioRecorder = AudioRecorder();
  final MeetingService _meetingService;
  RtcEngine? _agoraEngine;

  void setAgoraEngine(RtcEngine? engine) {
    _agoraEngine = engine;
  }

  Timer? _chunkTimer;
  String? _currentRecordingId;
  String? _currentChunkPath;

  int _chunkIndex = 0;
  int _chunkStartTimeMs = 0;
  int _successfulUploads = 0;

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
      _successfulUploads = 0;
      _isRecording = true;
      _stateController.add(_isRecording);

      // Recreate AudioRecorder to ensure clean state for subsequent recordings
      try {
        await _audioRecorder.dispose();
      } catch (_) {}
      _audioRecorder = AudioRecorder();

      // Clear any zombie chunks from previous crashed sessions
      for (var chunk in _uploadQueue) {
        try {
          final file = File(chunk.filePath);
          if (await file.exists()) await file.delete();
        } catch (_) {}
      }
      _uploadQueue.clear();
      await _saveQueue();

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
    // Always use .webm extension with Opus encoder as required by backend API
    final String ext = 'webm';
    final filePath =
        '${tempDir.path}/rec_${_currentRecordingId}_${_chunkIndex}.$ext';

    _currentChunkPath = filePath;
    _chunkStartTimeMs = DateTime.now().millisecondsSinceEpoch;

    // Using the record plugin to capture audio in WebM/Opus format.
    // (Agora engine does not support direct WebM/Opus file recording)
    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.opus),
      path: filePath,
    );
  }

  Future<void> _rotateChunk() async {
    if (!_isRecording) return;

    // The record plugin returns the ACTUAL path where the file was saved.
    final path = await _audioRecorder.stop();
    final endTimeMs = DateTime.now().millisecondsSinceEpoch;

    if (path != null && path.isNotEmpty) {
      // Wait for the OS to finish flushing the file to disk
      final bool fileReady = await _waitForFile(path);
      if (fileReady) {
        _queueChunkForUpload(_chunkIndex, path, _chunkStartTimeMs, endTimeMs);
      } else {
        debugPrint(
          '⚠️ Chunk $_chunkIndex: file never appeared at $path, skipping',
        );
      }
    } else {
      debugPrint(
        '⚠️ Chunk $_chunkIndex: recorder returned null/empty path, skipping',
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

    if (path != null && path.isNotEmpty) {
      final bool fileReady = await _waitForFile(path);
      if (fileReady) {
        final chunk = PendingChunk(
          index: _chunkIndex,
          filePath: path,
          startedAtMs: _chunkStartTimeMs,
          endedAtMs: endTimeMs,
        );
        _uploadQueue.add(chunk);
        await _saveQueue();
      } else {
        debugPrint(
          '⚠️ Final chunk $_chunkIndex: file never appeared at $path, skipping',
        );
      }
    } else {
      debugPrint(
        '⚠️ Final chunk $_chunkIndex: recorder returned null/empty path, skipping',
      );
    }

    // Force process the queue
    _processUploadQueue();

    // Wait for the queue to finish processing with a timeout to avoid hanging
    int waitCount = 0;
    while ((_isUploading || _uploadQueue.isNotEmpty) && waitCount < 60) {
      await Future.delayed(const Duration(milliseconds: 500));
      waitCount++;
    }
    if (waitCount >= 60) {
      debugPrint('⚠️ Upload queue did not finish within 30s timeout');
    }

    return _chunkIndex;
  }

  void _queueChunkForUpload(int index, String path, int startMs, int endMs) {
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

  /// Waits for a file to appear on disk (handles OS flush delays).
  /// Retries up to [maxRetries] times with [delay] between each attempt.
  Future<bool> _waitForFile(
    String path, {
    int maxRetries = 10,
    Duration delay = const Duration(milliseconds: 200),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      final file = File(path);
      if (await file.exists() && (await file.length()) > 0) {
        return true;
      }
      debugPrint(
        '⏳ Waiting for chunk file (attempt ${i + 1}/$maxRetries): $path',
      );
      await Future.delayed(delay);
    }
    debugPrint(
      '❌ Chunk file never appeared after ${maxRetries} retries: $path',
    );
    return false;
  }

  Future<void> _processUploadQueue() async {
    if (_isUploading || _uploadQueue.isEmpty || _currentRecordingId == null) {
      return;
    }
    _isUploading = true;

    while (_uploadQueue.isNotEmpty) {
      final chunk = _uploadQueue.first;
      try {
        // Verify the chunk file exists before attempting upload
        final chunkFile = File(chunk.filePath);
        if (!await chunkFile.exists()) {
          debugPrint('❌ Chunk file not found, skipping: ${chunk.filePath}');
          _uploadQueue.removeAt(0);
          await _saveQueue();
          continue;
        }

        final response = await _meetingService.uploadChunk(
          _currentRecordingId!,
          chunk.index,
          chunk.filePath,
          chunk.startedAtMs,
          chunk.endedAtMs,
        );

        if (response.isSuccess) {
          // Upload successful, remove from queue
          _uploadQueue.removeAt(0);
          _successfulUploads++;
          await _saveQueue();
          debugPrint(
            '✅ Chunk ${chunk.index} uploaded successfully (total: $_successfulUploads)',
          );
          // Delete the temp file to save space
          try {
            if (await chunkFile.exists()) {
              await chunkFile.delete();
            }
          } catch (e) {
            debugPrint('Failed to delete chunk file: $e');
          }
        } else {
          // If the server explicitly rejected the chunk (e.g. 400 Bad Request)
          debugPrint('❌ Upload failed: ${response.message}, errors: ${response.errors}');
          
          // If the error is a validation error, the chunk will NEVER succeed.
          // The backend might return 500 for logic errors, so we also check the message.
          final errorMsg = response.errors.toString().toLowerCase();
          final isPermanent = response.statusCode == 400 || 
                              response.statusCode == 422 || 
                              response.statusCode == 409 ||
                              errorMsg.contains('already exists') ||
                              errorMsg.contains('does not match');
                              
          if (isPermanent) {
            debugPrint('⚠️ Discarding chunk ${chunk.index} due to permanent error');
            _uploadQueue.removeAt(0);
            await _saveQueue();
            continue; // Move to next chunk
          }
          
          // Otherwise retry after a delay.
          await Future.delayed(const Duration(seconds: 3));
          continue; // Keep trying the same chunk
        }
      } catch (e) {
        debugPrint('Upload exception: $e');
        await Future.delayed(const Duration(seconds: 3));
        continue; // Keep trying on network error
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
