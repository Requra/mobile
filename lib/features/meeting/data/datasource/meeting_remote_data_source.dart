import 'package:requra/core/api/api_client.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/meeting/data/models/meeting_model.dart';

abstract class MeetingRemoteDataSource {
  Future<MeetingModel> getMeetingDetails(String meetingId);
  Future<List<MeetingModel>> getProjectMeetings(String projectId);
  Future<MeetingModel> createMeeting(String projectId, Map<String, dynamic> data);
  Future<MeetingModel> updateMeeting(String meetingId, Map<String, dynamic> data);
  Future<MeetingModel> cancelMeeting(String meetingId);
  Future<MeetingModel> startMeeting(String meetingId);
  Future<MeetingModel> endMeeting(String meetingId);

  // Invite API
  Future<List<dynamic>> getProjectMembers(String projectId);
  Future<List<dynamic>> getMeetingInvitations(String meetingId);
  Future<void> inviteParticipants(String meetingId, List<Map<String, String>> members);
  Future<void> inviteGuests(String meetingId, List<Map<String, String>> guests);
  Future<void> resendInvitation(String meetingId, String invitationId);
}

class MeetingRemoteDataSourceImpl implements MeetingRemoteDataSource {
  final ApiClient apiClient;

  MeetingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MeetingModel>> getProjectMeetings(String projectId) async {
    try {
      final response = await apiClient.dio
          .get('${ApiConstants.projects}/$projectId/meetings');

      List<dynamic> items = [];
      if (response.data['data'] is List) {
        items = response.data['data'];
      } else if (response.data['data'] != null &&
          response.data['data']['items'] != null) {
        items = response.data['data']['items'];
      } else if (response.data['items'] != null) {
        items = response.data['items'];
      } else if (response.data is List) {
        items = response.data;
      }

      return items.map((json) => MeetingModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MeetingModel> getMeetingDetails(String meetingId) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.meetings}/$meetingId');

      Map<String, dynamic> responseData;
      if (response.data['data'] != null) {
        responseData = response.data['data'];
      } else {
        responseData = response.data;
      }

      return MeetingModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MeetingModel> createMeeting(String projectId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post(
        '${ApiConstants.projects}/$projectId/meetings',
        data: data,
      );

      Map<String, dynamic> responseData;
      if (response.data['data'] != null) {
        responseData = response.data['data'];
      } else {
        responseData = response.data;
      }

      return MeetingModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MeetingModel> updateMeeting(String meetingId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.patch(
        '${ApiConstants.meetings}/$meetingId',
        data: data,
      );

      Map<String, dynamic> responseData;
      if (response.data['data'] != null) {
        responseData = response.data['data'];
      } else {
        responseData = response.data;
      }

      return MeetingModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MeetingModel> cancelMeeting(String meetingId) async {
    try {
      final response = await apiClient.dio.post(
        '${ApiConstants.meetings}/$meetingId/cancel',
      );

      Map<String, dynamic> responseData;
      if (response.data['data'] != null) {
        responseData = response.data['data'];
      } else {
        responseData = response.data;
      }

      return MeetingModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MeetingModel> startMeeting(String meetingId) async {
    try {
      final response = await apiClient.dio.post(
        '${ApiConstants.meetings}/$meetingId/start',
      );

      Map<String, dynamic> responseData;
      if (response.data['data'] != null) {
        responseData = response.data['data'];
      } else {
        responseData = response.data;
      }

      return MeetingModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MeetingModel> endMeeting(String meetingId) async {
    try {
      final response = await apiClient.dio.post(
        '${ApiConstants.meetings}/$meetingId/end',
      );

      Map<String, dynamic> responseData;
      if (response.data['data'] != null) {
        responseData = response.data['data'];
      } else {
        responseData = response.data;
      }

      return MeetingModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // ── Invite API ────────────────────────────────────────────────────────────

  @override
  Future<List<dynamic>> getProjectMembers(String projectId) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.projects}/$projectId/members');
      
      List<dynamic> items = [];
      if (response.data['data'] is List) {
        items = response.data['data'];
      } else if (response.data['data'] != null && response.data['data']['items'] != null) {
        items = response.data['data']['items'];
      } else if (response.data['items'] != null) {
        items = response.data['items'];
      } else if (response.data is List) {
        items = response.data;
      }
      return items;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getMeetingInvitations(String meetingId) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.meetings}/$meetingId/invitations');
      
      List<dynamic> items = [];
      if (response.data['data'] is List) {
        items = response.data['data'];
      } else if (response.data['data'] != null && response.data['data']['items'] != null) {
        items = response.data['data']['items'];
      } else if (response.data['items'] != null) {
        items = response.data['items'];
      } else if (response.data is List) {
        items = response.data;
      }
      return items;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> inviteParticipants(String meetingId, List<Map<String, String>> members) async {
    try {
      await apiClient.dio.post(
        '${ApiConstants.meetings}/$meetingId/invitations/participants',
        data: {'members': members},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> inviteGuests(String meetingId, List<Map<String, String>> guests) async {
    try {
      await apiClient.dio.post(
        '${ApiConstants.meetings}/$meetingId/invitations/guests',
        data: {'guests': guests},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendInvitation(String meetingId, String invitationId) async {
    try {
      await apiClient.dio.post(
        '${ApiConstants.meetings}/$meetingId/invitations/$invitationId/resend',
        data: {},
      );
    } catch (e) {
      rethrow;
    }
  }
}
