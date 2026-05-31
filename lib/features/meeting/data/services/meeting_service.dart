import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  /// GET /api/v1/meetings/:meetingId
  Future<AuthResponse> getMeeting(String meetingId) {
    return _get(endpoint: '${ApiConstants.meetingsBase}/meetings/$meetingId');
  }

  /// POST /api/v1/meetings/:meetingId/leave
  Future<AuthResponse> leaveMeeting(String meetingId, String participantId) {
    return _post(
      endpoint: '${ApiConstants.meetingsBase}/meetings/$meetingId/leave',
      body: <String, dynamic>{'participantId': participantId},
    );
  }

  /// POST /api/v1/meetings/:meetingId/end
  Future<AuthResponse> endMeeting(String meetingId) {
    return _post(
      endpoint: '${ApiConstants.meetingsBase}/meetings/$meetingId/end',
      body: <String, dynamic>{},
    );
  }

  // ── Participants ──────────────────────────────────────────────────────────

  /// GET /api/v1/meetings/:meetingId/participants
  Future<AuthResponse> getParticipants(String meetingId) {
    return _get(
      endpoint: '${ApiConstants.meetingsBase}/meetings/$meetingId/participants',
    );
  }

  /// POST /api/v1/meetings/:meetingId/participants/:participantId/consent
  Future<AuthResponse> giveConsent(String meetingId, String participantId) {
    return _post(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/participants/$participantId/consent',
      body: <String, dynamic>{'recordingConsent': true},
    );
  }

  /// DELETE /api/v1/meetings/:meetingId/participants/:participantId
  Future<AuthResponse> removeParticipant(
    String meetingId,
    String participantId,
  ) {
    return _delete(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/participants/$participantId',
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
  ) {
    return _post(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/invitations/project-members',
      body: <String, dynamic>{'memberIds': memberIds, 'role': role},
    );
  }

  /// POST /api/v1/meetings/:meetingId/invitations/stakeholders
  Future<AuthResponse> inviteStakeholders(
    String meetingId, {
    List<String>? stakeholderIds,
    List<Map<String, String>>? newStakeholders,
    String role = 'PARTICIPANT',
  }) {
    final Map<String, dynamic> body = <String, dynamic>{'role': role};
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
  ) {
    return _post(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/invitations/guests',
      body: <String, dynamic>{
        'guests': guests,
        'role': role,
        'expiresAt': expiresAt,
      },
    );
  }

  /// POST /api/v1/meetings/:meetingId/invitations/:invitationId/resend
  Future<AuthResponse> resendInvitation(
    String meetingId,
    String invitationId,
  ) {
    return _post(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/invitations/$invitationId/resend',
      body: <String, dynamic>{},
    );
  }

  /// DELETE /api/v1/meetings/:meetingId/invitations/:invitationId
  Future<AuthResponse> revokeInvitation(
    String meetingId,
    String invitationId,
  ) {
    return _delete(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/invitations/$invitationId',
    );
  }

  // ── Recording ─────────────────────────────────────────────────────────────

  /// POST /api/v1/meetings/:meetingId/recordings/start
  Future<AuthResponse> startRecording(String meetingId) {
    return _post(
      endpoint:
          '${ApiConstants.meetingsBase}/meetings/$meetingId/recordings/start',
      body: <String, dynamic>{
        'uploadMode': 'CHUNKED',
        'mimeType': 'audio/webm',
      },
    );
  }

  /// POST /api/v1/recordings/:recordingId/stop
  Future<AuthResponse> stopRecording(
    String recordingId,
    int durationSeconds,
    int lastChunkIndex,
  ) {
    return _post(
      endpoint: '${ApiConstants.meetingsBase}/recordings/$recordingId/stop',
      body: <String, dynamic>{
        'durationSeconds': durationSeconds,
        'lastChunkIndex': lastChunkIndex,
      },
    );
  }

  /// GET /api/v1/recordings/:recordingId
  Future<AuthResponse> getRecording(String recordingId) {
    return _get(
      endpoint: '${ApiConstants.meetingsBase}/recordings/$recordingId',
    );
  }

  /// POST /api/v1/recordings/:recordingId/chunks  (multipart/form-data)
  Future<AuthResponse> uploadChunk({
    required String recordingId,
    required int chunkIndex,
    required List<int> audioBytes,
    required int startedAtMs,
    required int endedAtMs,
  }) async {
    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.meetingsBase}/recordings/$recordingId/chunks',
    );

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
        ..fields['chunkIndex'] = chunkIndex.toString()
        ..fields['startedAtMs'] = startedAtMs.toString()
        ..fields['endedAtMs'] = endedAtMs.toString()
        ..files.add(
          http.MultipartFile.fromBytes(
            'audioChunk',
            audioBytes,
            filename: 'chunk_$chunkIndex.webm',
          ),
        );

      final http.StreamedResponse streamed = await request.send();
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
      endpoint:
          '${ApiConstants.meetingsBase}/projects/$projectId/stakeholders',
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
      final Map<String, String> headers =
          await _buildHeaders(includeAuth: includeAuthHeader);
      http.Response response = await http
          .get(uri, headers: headers)
          .timeout(_timeout);

      AuthResponse parsed = _buildResponse(response);

      if (includeAuthHeader && _isUnauthorized(response.statusCode)) {
        final bool refreshed = await _tryRefreshTokens();
        if (refreshed) {
          final Map<String, String> newHeaders =
              await _buildHeaders(includeAuth: true);
          response = await http
              .get(uri, headers: newHeaders)
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

  Future<AuthResponse> _post({
    required String endpoint,
    required Map<String, dynamic> body,
    bool includeAuthHeader = true,
  }) async {
    final Uri uri = _resolveUri(endpoint);

    try {
      final Map<String, String> headers =
          await _buildHeaders(includeAuth: includeAuthHeader);
      http.Response response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(_timeout);

      AuthResponse parsed = _buildResponse(response);

      if (includeAuthHeader && _isUnauthorized(response.statusCode)) {
        final bool refreshed = await _tryRefreshTokens();
        if (refreshed) {
          final Map<String, String> newHeaders =
              await _buildHeaders(includeAuth: true);
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
      final Map<String, String> headers =
          await _buildHeaders(includeAuth: includeAuthHeader);
      http.Response response = await http
          .delete(uri, headers: headers)
          .timeout(_timeout);

      AuthResponse parsed = _buildResponse(response);

      if (includeAuthHeader && _isUnauthorized(response.statusCode)) {
        final bool refreshed = await _tryRefreshTokens();
        if (refreshed) {
          final Map<String, String> newHeaders =
              await _buildHeaders(includeAuth: true);
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
      final Uri uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshToken}');
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
        final String newRefresh =
            (data['refreshToken'] ?? '').toString().trim();
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
        final int statusCode =
            parsed['statusCode'] is int
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
