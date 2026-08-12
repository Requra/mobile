import 'package:equatable/equatable.dart';

class AgoraTokenResponse extends Equatable {
  final String appId;
  final String channelName;
  final int uid;
  final String token;
  final String role;
  final String? expiresAt;

  const AgoraTokenResponse({
    required this.appId,
    required this.channelName,
    required this.uid,
    required this.token,
    required this.role,
    this.expiresAt,
  });

  factory AgoraTokenResponse.fromJson(Map<String, dynamic> json) {
    return AgoraTokenResponse(
      appId: (json['appId'] ?? '').toString(),
      channelName: (json['channelName'] ?? '').toString(),
      uid: json['uid'] is int ? json['uid'] as int : int.tryParse(json['uid']?.toString() ?? '0') ?? 0,
      token: (json['token'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      expiresAt: json['expiresAt']?.toString(),
    );
  }

  @override
  List<Object?> get props => [appId, channelName, uid, token, role, expiresAt];
}

abstract class AgoraParticipantEvent extends Equatable {
  const AgoraParticipantEvent();
  @override
  List<Object?> get props => [];
}

class UserJoined extends AgoraParticipantEvent {
  final int uid;
  const UserJoined(this.uid);
  @override
  List<Object?> get props => [uid];
}

class UserOffline extends AgoraParticipantEvent {
  final int uid;
  const UserOffline(this.uid);
  @override
  List<Object?> get props => [uid];
}
