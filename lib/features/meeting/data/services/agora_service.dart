import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:requra/features/meeting/data/models/agora_models.dart';

class AgoraService {
  RtcEngine? _engine;
  final _connectionStateController = StreamController<ConnectionStateType>.broadcast();
  final _participantEventController = StreamController<AgoraParticipantEvent>.broadcast();
  final _tokenExpireController = StreamController<void>.broadcast();
  final _activeSpeakersController = StreamController<Set<int>>.broadcast();
  final _localVolumeController = StreamController<int>.broadcast();

  Stream<ConnectionStateType> get connectionStateStream => _connectionStateController.stream;
  Stream<AgoraParticipantEvent> get participantEventStream => _participantEventController.stream;
  Stream<void> get tokenExpireStream => _tokenExpireController.stream;
  Stream<Set<int>> get activeSpeakersStream => _activeSpeakersController.stream;
  Stream<int> get localVolumeStream => _localVolumeController.stream;

  RtcEngine? get engine => _engine;

  Future<void> initialize(String appId) async {
    if (_engine != null) return;

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Agora joined channel: ${connection.channelId}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _participantEventController.add(UserJoined(remoteUid));
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          _participantEventController.add(UserOffline(remoteUid));
        },
        onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint('Agora connection state changed: state=$state, reason=$reason');
          _connectionStateController.add(state);
        },
        onRemoteVideoStateChanged: (RtcConnection connection, int remoteUid, RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
          final enabled = state == RemoteVideoState.remoteVideoStateStarting || 
                          state == RemoteVideoState.remoteVideoStateDecoding;
          _participantEventController.add(RemoteVideoStateChanged(remoteUid, enabled));
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          _tokenExpireController.add(null);
        },
        onAudioVolumeIndication: (RtcConnection connection, List<AudioVolumeInfo> speakers, int totalVolume, int totalVolumeEx) {
          final activeSpeakers = <int>{};
          int localVol = 0;
          for (final speaker in speakers) {
            if (speaker.uid == 0) {
              localVol = speaker.volume ?? 0;
            }
            // A volume above 5 (or 10) is usually considered talking. Max is 255.
            if (speaker.volume != null && speaker.volume! > 5) {
              // uid == 0 means the local user
              activeSpeakers.add(speaker.uid ?? 0);
            }
          }
          _activeSpeakersController.add(activeSpeakers);
          _localVolumeController.add(localVol);
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('Agora error: $err $msg');
        },
      ),
    );

    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.enableAudio();
    await _engine!.enableVideo(); // Enabled Video!
    await _engine!.setDefaultAudioRouteToSpeakerphone(true);
    await _engine!.enableAudioVolumeIndication(interval: 200, smooth: 3, reportVad: true);
  }

  Future<void> joinChannel({
    required String token,
    required String channelName,
    int? uid,
    String? userAccount,
  }) async {
    if (_engine == null) return;
    
    const options = ChannelMediaOptions(
      autoSubscribeAudio: true,
      publishMicrophoneTrack: true,
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
    );

    if (userAccount != null && userAccount.isNotEmpty) {
      await _engine!.joinChannelWithUserAccount(
        token: token,
        channelId: channelName,
        userAccount: userAccount,
        options: options,
      );
    } else {
      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid ?? 0,
        options: options,
      );
    }
  }

  Future<void> leaveChannel() async {
    if (_engine == null) return;
    await _engine!.leaveChannel();
  }

  Future<void> renewToken(String newToken) async {
    if (_engine == null) return;
    await _engine!.renewToken(newToken);
  }

  Future<void> muteLocalAudio(bool mute) async {
    if (_engine == null) return;
    try {
      // We use enableLocalAudio instead of muteLocalAudioStream so that the mic indicator
      // in the OS status bar actually turns off when muted.
      await _engine!.enableLocalAudio(!mute);
    } catch (e) {
      debugPrint('Failed to mute/unmute local audio: $e');
    }
  }

  Future<void> setLocalVideoEnabled(bool enabled) async {
    if (_engine == null) return;
    try {
      await _engine!.enableLocalVideo(enabled);
      await _engine!.muteLocalVideoStream(!enabled);
    } catch (e) {
      debugPrint('Failed to set local video: $e');
    }
  }

  Future<void> setSpeakerphoneEnabled(bool enabled) async {
    if (_engine == null) return;
    try {
      await _engine!.setEnableSpeakerphone(enabled);
    } catch (e) {
      debugPrint('Failed to set speakerphone: $e');
    }
  }

  Future<void> dispose() async {
    _connectionStateController.close();
    _participantEventController.close();
    _tokenExpireController.close();
    _activeSpeakersController.close();
    _localVolumeController.close();
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
      _engine = null;
    }
  }
}
