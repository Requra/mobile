// ── Meeting Domain Models ───────────────────────────────────────────────────

/// Status of a meeting.
enum MeetingStatus {
  scheduled,
  live,
  recording,
  ended,
  cancelled;

  static MeetingStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'SCHEDULED':
        return MeetingStatus.scheduled;
      case 'LIVE':
        return MeetingStatus.live;
      case 'RECORDING':
        return MeetingStatus.recording;
      case 'ENDED':
        return MeetingStatus.ended;
      case 'CANCELLED':
        return MeetingStatus.cancelled;
      default:
        return MeetingStatus.scheduled;
    }
  }

  String get label => name.toUpperCase();
}

/// Status of a recording.
enum RecordingStatus {
  active,
  stopped,
  finalizing,
  ready,
  failed;

  static RecordingStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACTIVE':
        return RecordingStatus.active;
      case 'STOPPED':
        return RecordingStatus.stopped;
      case 'FINALIZING':
        return RecordingStatus.finalizing;
      case 'READY':
        return RecordingStatus.ready;
      case 'FAILED':
        return RecordingStatus.failed;
      default:
        return RecordingStatus.stopped;
    }
  }

  String get label {
    switch (this) {
      case RecordingStatus.active:
        return 'Active';
      case RecordingStatus.stopped:
        return 'Not started';
      case RecordingStatus.finalizing:
        return 'Finalizing…';
      case RecordingStatus.ready:
        return 'Ready';
      case RecordingStatus.failed:
        return 'Failed';
    }
  }
}

/// Status of an invitation.
enum InvitationStatus {
  pending,
  accepted,
  declined,
  expired,
  revoked;

  static InvitationStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDING':
        return InvitationStatus.pending;
      case 'ACCEPTED':
        return InvitationStatus.accepted;
      case 'DECLINED':
        return InvitationStatus.declined;
      case 'EXPIRED':
        return InvitationStatus.expired;
      case 'REVOKED':
        return InvitationStatus.revoked;
      default:
        return InvitationStatus.pending;
    }
  }
}

/// Role of a participant in a meeting.
enum ParticipantRole {
  host,
  member,
  stakeholder,
  guest;

  static ParticipantRole fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'HOST':
        return ParticipantRole.host;
      case 'MEMBER':
        return ParticipantRole.member;
      case 'STAKEHOLDER':
        return ParticipantRole.stakeholder;
      case 'GUEST':
        return ParticipantRole.guest;
      default:
        return ParticipantRole.guest;
    }
  }

  String get label => name.toUpperCase();
}

/// Participant connection status.
enum ParticipantConnectionStatus {
  joined,
  left;

  static ParticipantConnectionStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'JOINED':
        return ParticipantConnectionStatus.joined;
      case 'LEFT':
        return ParticipantConnectionStatus.left;
      default:
        return ParticipantConnectionStatus.left;
    }
  }
}

// ── Data Classes ────────────────────────────────────────────────────────────

/// Full meeting details returned by GET /api/v1/meetings/:meetingId.
class MeetingDetails {
  const MeetingDetails({
    required this.id,
    required this.title,
    required this.status,
    required this.projectId,
    required this.projectName,
    required this.hostName,
    required this.hostId,
    this.startedAt,
    this.recordingStatus,
    required this.participantCount,
  });

  final String id;
  final String title;
  final MeetingStatus status;
  final String projectId;
  final String projectName;
  final String hostName;
  final String hostId;
  final DateTime? startedAt;
  final RecordingStatus? recordingStatus;
  final int participantCount;

  factory MeetingDetails.fromJson(Map<String, dynamic> json) {
    return MeetingDetails(
      id: (json['id'] ?? json['meetingId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      status: MeetingStatus.fromString(
        (json['status'] ?? '').toString(),
      ),
      projectId: (json['projectId'] ?? '').toString(),
      projectName: (json['projectName'] ?? json['project']?['name'] ?? '').toString(),
      hostName: (json['hostName'] ?? json['host']?['displayName'] ?? '').toString(),
      hostId: (json['hostId'] ?? json['host']?['id'] ?? '').toString(),
      startedAt: _parseDateTime(json['startedAt']),
      recordingStatus: json['recordingStatus'] != null
          ? RecordingStatus.fromString(json['recordingStatus'].toString())
          : null,
      participantCount: _parseInt(json['participantCount']),
    );
  }

  MeetingDetails copyWith({
    String? id,
    String? title,
    MeetingStatus? status,
    String? projectId,
    String? projectName,
    String? hostName,
    String? hostId,
    DateTime? startedAt,
    RecordingStatus? recordingStatus,
    int? participantCount,
  }) {
    return MeetingDetails(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      hostName: hostName ?? this.hostName,
      hostId: hostId ?? this.hostId,
      startedAt: startedAt ?? this.startedAt,
      recordingStatus: recordingStatus ?? this.recordingStatus,
      participantCount: participantCount ?? this.participantCount,
    );
  }
}

/// A participant in a meeting.
class Participant {
  const Participant({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.role,
    required this.connectionStatus,
    required this.recordingConsent,
  });

  final String id;
  final String userId;
  final String displayName;
  final ParticipantRole role;
  final ParticipantConnectionStatus connectionStatus;
  final bool recordingConsent;

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: (json['id'] ?? json['participantId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      displayName: (json['displayName'] ?? json['name'] ?? '').toString(),
      role: ParticipantRole.fromString(
        (json['role'] ?? '').toString(),
      ),
      connectionStatus: ParticipantConnectionStatus.fromString(
        (json['status'] ?? json['connectionStatus'] ?? '').toString(),
      ),
      recordingConsent: json['recordingConsent'] == true,
    );
  }

  Participant copyWith({
    String? id,
    String? userId,
    String? displayName,
    ParticipantRole? role,
    ParticipantConnectionStatus? connectionStatus,
    bool? recordingConsent,
  }) {
    return Participant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      recordingConsent: recordingConsent ?? this.recordingConsent,
    );
  }

  /// Returns initials from the display name (up to 2 characters).
  String get initials {
    final List<String> parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

/// An invitation to a meeting.
class Invitation {
  const Invitation({
    required this.id,
    required this.displayName,
    required this.email,
    required this.status,
  });

  final String id;
  final String displayName;
  final String email;
  final InvitationStatus status;

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: (json['id'] ?? json['invitationId'] ?? '').toString(),
      displayName: (json['displayName'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      status: InvitationStatus.fromString(
        (json['status'] ?? '').toString(),
      ),
    );
  }
}

/// Recording details.
class RecordingInfo {
  const RecordingInfo({
    required this.id,
    required this.status,
    this.startedAt,
  });

  final String id;
  final RecordingStatus status;
  final DateTime? startedAt;

  factory RecordingInfo.fromJson(Map<String, dynamic> json) {
    return RecordingInfo(
      id: (json['id'] ?? json['recordingId'] ?? '').toString(),
      status: RecordingStatus.fromString(
        (json['status'] ?? '').toString(),
      ),
      startedAt: _parseDateTime(json['startedAt']),
    );
  }

  RecordingInfo copyWith({
    String? id,
    RecordingStatus? status,
    DateTime? startedAt,
  }) {
    return RecordingInfo(
      id: id ?? this.id,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

/// A project member (for invite flow).
class ProjectMember {
  const ProjectMember({
    required this.id,
    required this.displayName,
    required this.email,
  });

  final String id;
  final String displayName;
  final String email;

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: (json['id'] ?? json['memberId'] ?? '').toString(),
      displayName: (json['displayName'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}

/// A project stakeholder (for invite flow).
class ProjectStakeholder {
  const ProjectStakeholder({
    required this.id,
    required this.displayName,
    required this.email,
  });

  final String id;
  final String displayName;
  final String email;

  factory ProjectStakeholder.fromJson(Map<String, dynamic> json) {
    return ProjectStakeholder(
      id: (json['id'] ?? json['stakeholderId'] ?? '').toString(),
      displayName: (json['displayName'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final String str = value.toString().trim();
  if (str.isEmpty) return null;
  return DateTime.tryParse(str);
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
