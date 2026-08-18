import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/core/storage/secure_token_storage.dart';
import 'package:requra/features/auth/data/models/auth_response.dart';

/// Service class that handles all meeting-related API calls.
///
/// Follows the same pattern as [AuthService]: uses [SecureTokenStorage] for
/// Bearer token auth, returns [AuthResponse], auto-retries on 401 after
/// refreshing the token.
class MeetingService {
  const MeetingService();

  static const SecureTokenStorage _tokenStorage = SecureTokenStorage();
  static const Duration _timeout = Duration(seconds: 20);

  // ── Meeting ───────────────────────────────────────────────────────────────

  /// GET /api/meetings/{meetingId}  (Spec #4)
  Future<AuthResponse> getMeeting(String meetingId) {
    return _get(endpoint: ApiConstants.meetingDetails(meetingId));
  }

  /// POST /api/meetings/{meetingId}/agora-token
  Future<AuthResponse> getAgoraToken(String meetingId) {
    return _post(
      endpoint: ApiConstants.agoraToken(meetingId),
      body:
          <String, dynamic>{}, // Provide empty body or necessary payload if any
    );
  }

  // Future<AuthResponse> getAgoraToken(String meetingId) async {
  //   // HARDCODED MOCK FOR TESTING AGORA INTEGRATION
  //   return AuthResponse(
  //     isSuccess: true,
  //     statusCode: 200,
  //     message: "ok",
  //     data: {
  //       "appId": "b3616adc01654052b8b7ba4f97e0a12e",
  //       "channelName": "tmp3",
  //       "uid": 0,
  //       "token":
  //           "007eJxTYNj70E3Ifp2lX+yWSYv+H/l0I2l+34LV696t9jhfK70+cnWSAkOSsZmhWWJKsoGhmamJgalRkkWSeVKiSZqleapBoqFRqr1fQ1ZDICPDUzUBRkYGCATxWRhKcguMGRgA+eUg1A==",
  //       "role": "PUBLISHER",
  //       "expiresAt": "2026-08-15T23:17:47Z",
  //     },
  //     errors: [],
  //   );
  // }

  /// POST /api/meetings/{meetingId}/join  (Spec #14)
  Future<AuthResponse> joinMeeting(
    String meetingId, {
    required String displayName,
    required String email,
  }) {
    return _post(
      endpoint: ApiConstants.joinMeeting(meetingId),
      body: <String, dynamic>{'displayName': displayName, 'email': email},
    );
  }

  /// POST /api/meetings/{meetingId}/leave  (Spec #15)
  Future<AuthResponse> leaveMeeting(String meetingId, String participantId) {
    return _post(
      endpoint: ApiConstants.leaveMeeting(meetingId),
      body: <String, dynamic>{'participantId': participantId},
    );
  }

  /// POST /api/meetings/{meetingId}/end  (Spec #17)
  Future<AuthResponse> endMeeting(String meetingId) {
    return _post(
      endpoint: ApiConstants.endMeeting(meetingId),
      body: <String, dynamic>{},
    );
  }

  // ── Participants ──────────────────────────────────────────────────────────

  /// GET /api/meetings/{meetingId}/participants  (Spec #18)
  Future<AuthResponse> getParticipants(String meetingId) {
    return _get(endpoint: ApiConstants.meetingParticipants(meetingId));
  }

  /// POST /api/meetings/{meetingId}/participants/{participantId}/consent  (Spec #20)
  Future<AuthResponse> giveConsent(String meetingId, String participantId) {
    return _post(
      endpoint: ApiConstants.participantConsent(meetingId, participantId),
      body: <String, dynamic>{'recordingConsent': true},
    );
  }

  /// DELETE /api/meetings/{meetingId}/participants/{participantId}  (Spec #19)
  Future<AuthResponse> removeParticipant(
    String meetingId,
    String participantId,
  ) {
    return _delete(
      endpoint:
          '${ApiConstants.realMeetingsBase}/meetings/$meetingId/participants/$participantId',
    );
  }

  // ── Invitations ───────────────────────────────────────────────────────────

  /// GET /api/v1/meetings/:meetingId/invitations
  Future<AuthResponse> getInvitations(String meetingId) {
    return _get(
      endpoint: '${ApiConstants.meetingsBase}/meetings/$meetingId/invitations',
    );
  }

  /// POST /api/v1/meetings/:meetingId/invitations/project-members
  Future<AuthResponse> inviteProjectMembers(
    String meetingId,
    List<String> memberIds,
    String role,
    {String platform = 'Mobile'}
  ) {
    return _post(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/invitations/project-members',
      body: <String, dynamic>{'memberIds': memberIds, 'role': role, 'platform': platform},
    );
  }

  /// POST /api/v1/meetings/:meetingId/invitations/stakeholders
  Future<AuthResponse> inviteStakeholders(
    String meetingId, {
    List<String>? stakeholderIds,
    List<Map<String, String>>? newStakeholders,
    String role = 'PARTICIPANT',
    String platform = 'Mobile',
  }) {
    final Map<String, dynamic> body = <String, dynamic>{
      'role': role,
      'platform': platform,
    };
    if (stakeholderIds != null && stakeholderIds.isNotEmpty) {
      body['stakeholderIds'] = stakeholderIds;
    }
    if (newStakeholders != null && newStakeholders.isNotEmpty) {
      body['stakeholders'] = newStakeholders;
      body['createIfNotExists'] = true;
    }
    return _post(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/invitations/stakeholders',
      body: body,
    );
  }

  /// POST /api/v1/meetings/:meetingId/invitations/guests
  Future<AuthResponse> inviteGuests(
    String meetingId,
    List<Map<String, String>> guests,
    String role,
    String expiresAt,
    {String platform = 'Mobile'}
  ) {
    return _post(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/invitations/guests',
      body: <String, dynamic>{
        'guests': guests,
        'role': role,
        'expiresAt': expiresAt,
        'platform': platform,
      },
    );
  }

  /// POST /api/v1/meetings/:meetingId/invitations/:invitationId/resend
  Future<AuthResponse> resendInvitation(String meetingId, String invitationId, {String platform = 'Mobile'}) {
    return _post(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/invitations/$invitationId/resend?platform=$platform',
      body: <String, dynamic>{},
    );
  }

  /// DELETE /api/v1/meetings/:meetingId/invitations/:invitationId
  Future<AuthResponse> revokeInvitation(String meetingId, String invitationId) {
    return _delete(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/invitations/$invitationId',
    );
  }

  // ── Meeting Invitations ───────────────────────────────────────────────────

  /// GET /api/meeting-invitations/{token}
  Future<AuthResponse> previewInvitation(String token) {
    return _get(
      endpoint: ApiConstants.previewInvitation(token),
    );
  }

  /// POST /api/meeting-invitations/{token}/accept
  Future<AuthResponse> acceptInvitation(String token, {String? displayName}) {
    return _post(
      endpoint: ApiConstants.acceptInvitation(token),
      body: displayName != null ? <String, dynamic>{'displayName': displayName} : <String, dynamic>{},
    );
  }

  // ── Recording ─────────────────────────────────────────────────────────────

  /// POST /api/meetings/{meetingId}/recordings/start  (Spec #21)
  Future<AuthResponse> startRecording(String meetingId) {
    return _post(
      endpoint: ApiConstants.startRecording(meetingId),
      body: <String, dynamic>{
        'uploadMode': 'Chunked',
        // Send a simple mimeType to ensure exact match with the uploaded chunk
        'mimeType': 'audio/webm',
      },
    );
  }

  /// POST /api/recordings/{recordingId}/stop  (Spec #24)
  Future<AuthResponse> stopRecording(
    String recordingId,
    int durationSeconds,
    int lastChunkIndex,
  ) {
    return _post(
      endpoint: ApiConstants.stopRecording(recordingId),
      body: <String, dynamic>{
        'durationSeconds': durationSeconds,
        'lastChunkIndex': lastChunkIndex,
      },
    );
  }

  /// GET /api/recordings/{recordingId}  (Spec #25)
  Future<AuthResponse> getRecording(String recordingId) {
    return _get(endpoint: ApiConstants.getRecording(recordingId));
  }

  /// POST /api/recordings/{recordingId}/chunks  (Spec #26)
  Future<AuthResponse> uploadChunk(
    String recordingId,
    int chunkIndex,
    String filePath,
    int startedAtMs,
    int endedAtMs,
  ) async {
    final Uri uri = Uri.parse(ApiConstants.uploadChunk(recordingId));

    try {
      final String? token = await _tokenStorage.readAccessToken();
      final Map<String, String> headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${token.trim()}';
      }

      final http.MultipartRequest request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..fields['ChunkIndex'] = chunkIndex.toString()
        ..fields['StartedAtMs'] = startedAtMs.toString()
        ..fields['EndedAtMs'] = endedAtMs.toString()
        ..files.add(
          await http.MultipartFile.fromPath(
            'AudioChunk',
            filePath,
            contentType: MediaType('audio', 'webm'),
          ),
        );

      final http.StreamedResponse streamed = await request.send().timeout(
        _timeout,
      );
      final http.Response response = await http.Response.fromStream(streamed);
      return _buildResponse(response);
    } on TimeoutException {
      return const AuthResponse(
        isSuccess: false,
        data: null,
        message: 'Upload timed out.',
        statusCode: 408,
        errors: <dynamic>['Chunk upload timed out'],
      );
    } catch (e) {
      return AuthResponse(
        isSuccess: false,
        data: null,
        message: 'Upload failed.',
        statusCode: 500,
        errors: <dynamic>[e.toString()],
      );
    }
  }

  // ── Project Members / Stakeholders (for invite flow) ──────────────────────

  /// GET /api/v1/projects/:projectId/members
  Future<AuthResponse> getProjectMembers(String projectId) {
    return _get(
      endpoint: '${ApiConstants.meetingsBase}/projects/$projectId/members',
    );
  }

  /// GET /api/v1/projects/:projectId/stakeholders
  Future<AuthResponse> getProjectStakeholders(String projectId) {
    return _get(
      endpoint: '${ApiConstants.meetingsBase}/projects/$projectId/stakeholders',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── Private HTTP helpers (mirrors AuthService pattern) ─────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  Future<AuthResponse> _get({
    required String endpoint,
    bool includeAuthHeader = true,
  }) async {
    final Uri uri = _resolveUri(endpoint);

    try {
      final Map<String, String> headers = await _buildHeaders(
        includeAuth: includeAuthHeader,
      );
      http.Response response = await http
          .get(uri, headers: headers)
          .timeout(_timeout);

      AuthResponse parsed = _buildResponse(response);

      if (includeAuthHeader && _isUnauthorized(response.statusCode)) {
        final bool refreshed = await _tryRefreshTokens();
        if (refreshed) {
          final Map<String, String> newHeaders = await _buildHeaders(
            includeAuth: true,
          );
          response = await http.get(uri, headers: newHeaders).timeout(_timeout);
          parsed = _buildResponse(response);
        }
      }

      return parsed;
    } on TimeoutException {
      return _timeoutResponse();
    } catch (e) {
      return _errorResponse(e);
    }
  }

  Future<AuthResponse> _post({
    required String endpoint,
    required Map<String, dynamic> body,
    bool includeAuthHeader = true,
  }) async {
    final Uri uri = _resolveUri(endpoint);

    try {
      final Map<String, String> headers = await _buildHeaders(
        includeAuth: includeAuthHeader,
      );
      http.Response response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(_timeout);

      AuthResponse parsed = _buildResponse(response);

      if (includeAuthHeader && _isUnauthorized(response.statusCode)) {
        final bool refreshed = await _tryRefreshTokens();
        if (refreshed) {
          final Map<String, String> newHeaders = await _buildHeaders(
            includeAuth: true,
          );
          response = await http
              .post(uri, headers: newHeaders, body: jsonEncode(body))
              .timeout(_timeout);
          parsed = _buildResponse(response);
        }
      }

      return parsed;
    } on TimeoutException {
      return _timeoutResponse();
    } catch (e) {
      return _errorResponse(e);
    }
  }

  Future<AuthResponse> _delete({
    required String endpoint,
    bool includeAuthHeader = true,
  }) async {
    final Uri uri = _resolveUri(endpoint);

    try {
      final Map<String, String> headers = await _buildHeaders(
        includeAuth: includeAuthHeader,
      );
      http.Response response = await http
          .delete(uri, headers: headers)
          .timeout(_timeout);

      AuthResponse parsed = _buildResponse(response);

      if (includeAuthHeader && _isUnauthorized(response.statusCode)) {
        final bool refreshed = await _tryRefreshTokens();
        if (refreshed) {
          final Map<String, String> newHeaders = await _buildHeaders(
            includeAuth: true,
          );
          response = await http
              .delete(uri, headers: newHeaders)
              .timeout(_timeout);
          parsed = _buildResponse(response);
        }
      }

      return parsed;
    } on TimeoutException {
      return _timeoutResponse();
    } catch (e) {
      return _errorResponse(e);
    }
  }

  // ── AI Runs (Meeting Analysis) ───────────────────────────────────────────

  /// POST /api/projects/{projectId}/ai/runs
  Future<AuthResponse> startAiRun({
    required String projectId,
    String? meetingId,
  }) async {
    final payload = {
      "documentIds": [],
      "meetingId": meetingId,
      "analysisType": "project_results_dashboard",
      "language": "En",
    };

    return _post(
      endpoint: ApiConstants.startAiRun(projectId),
      body: payload,
    );
  }

  /// GET /api/projects/{projectId}/ai/runs/{runId}
  Future<AuthResponse> getAiRunProgress({
    required String projectId,
    required String runId,
  }) async {
    return _get(
      endpoint: ApiConstants.getAiRunProgress(projectId, runId),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Uri _resolveUri(String endpoint) {
    if (endpoint.startsWith('http')) return Uri.parse(endpoint);
    return Uri.parse('${ApiConstants.baseUrl}$endpoint');
  }

  Future<Map<String, String>> _buildHeaders({required bool includeAuth}) async {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth) {
      final String? token = await _tokenStorage.readAccessToken();
      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${token.trim()}';
      }
    }
    return headers;
  }

  bool _isUnauthorized(int statusCode) => statusCode == 401;

  Future<bool> _tryRefreshTokens() async {
    final String? refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      return false;
    }

    try {
      final Uri uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
      );
      final http.Response response = await http
          .post(
            uri,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{
              'refreshToken': refreshToken.trim(),
            }),
          )
          .timeout(_timeout);

      final AuthResponse parsed = _buildResponse(response);
      if (!parsed.isSuccess) {
        await _tokenStorage.clearTokens();
        return false;
      }

      final dynamic data = parsed.data;
      if (data is Map<String, dynamic>) {
        final String newAccess = (data['token'] ?? '').toString().trim();
        final String newRefresh = (data['refreshToken'] ?? '')
            .toString()
            .trim();
        if (newAccess.isNotEmpty && newRefresh.isNotEmpty) {
          await _tokenStorage.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          return true;
        }
      }
      await _tokenStorage.clearTokens();
      return false;
    } catch (_) {
      return false;
    }
  }

  AuthResponse _buildResponse(http.Response response) {
    final String body = response.body;
    if (body.trim().isEmpty) {
      final bool ok = response.statusCode >= 200 && response.statusCode < 300;
      return AuthResponse(
        isSuccess: ok,
        data: null,
        message: ok ? 'Request completed' : 'Request failed',
        statusCode: response.statusCode,
        errors: const <dynamic>[],
      );
    }

    try {
      final dynamic parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) {
        final int statusCode = parsed['statusCode'] is int
            ? parsed['statusCode'] as int
            : response.statusCode;
        final bool isSuccess =
            parsed['isSuccess'] == true ||
            parsed['success'] == true ||
            (statusCode >= 200 && statusCode < 300);
        return AuthResponse(
          isSuccess: isSuccess,
          data: parsed['data'],
          message: (parsed['message'] ?? (isSuccess ? 'OK' : 'Error'))
              .toString(),
          statusCode: statusCode,
          errors: parsed['errors'] is List
              ? parsed['errors'] as List<dynamic>
              : const <dynamic>[],
        );
      }
    } catch (_) {}

    return AuthResponse(
      isSuccess: false,
      data: null,
      message: 'Unexpected response format',
      statusCode: response.statusCode,
      errors: const <dynamic>[],
    );
  }

  AuthResponse _timeoutResponse() {
    return const AuthResponse(
      isSuccess: false,
      data: null,
      message: 'Request timed out. Please try again.',
      statusCode: 408,
      errors: <dynamic>['Request timed out'],
    );
  }

  AuthResponse _errorResponse(Object e) {
    return AuthResponse(
      isSuccess: false,
      data: null,
      message: 'Something went wrong. Please try again.',
      statusCode: 500,
      errors: <dynamic>[e.toString()],
    );
  }
}
