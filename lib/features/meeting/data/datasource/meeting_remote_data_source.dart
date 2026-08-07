import 'package:requra/core/api/api_client.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/meeting/data/models/meeting_model.dart';

abstract class MeetingRemoteDataSource {
  Future<List<MeetingModel>> getProjectMeetings(String projectId);
  Future<MeetingModel> createMeeting(String projectId, Map<String, dynamic> data);
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
}
