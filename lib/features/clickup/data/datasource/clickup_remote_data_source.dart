import 'package:requra/core/api/api_client.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/clickup/data/models/clickup_push_result_model.dart';
import 'package:requra/features/clickup/data/models/clickup_status_model.dart';

abstract class ClickUpRemoteDataSource {
  /// Returns the authUrl string to open in a WebView.
  Future<String> getAuthorizeUrl(String projectId);

  /// Sends the OAuth code+projectId to complete the connection.
  Future<void> completeCallback(String code, String projectId);

  /// Fetches the current connection status.
  Future<ClickUpStatusModel> getStatus(String projectId);

  /// Disconnects ClickUp from the project.
  Future<void> disconnect(String projectId);

  /// Pushes all approved user stories to ClickUp.
  Future<ClickUpPushResultModel> pushApproved(String projectId);
}

class ClickUpRemoteDataSourceImpl implements ClickUpRemoteDataSource {
  final ApiClient apiClient;

  ClickUpRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> getAuthorizeUrl(String projectId) async {
    final response = await apiClient.dio.get(
      ApiConstants.clickUpAuthorize(projectId),
    );
    // Extract from standard envelope: response.data['data']['authUrl']
    return response.data['data']['authUrl'];
  }

  @override
  Future<void> completeCallback(String code, String projectId) async {
    await apiClient.dio.post(
      ApiConstants.clickUpCallback,
      data: {"code": code, "projectId": projectId},
    );
  }

  @override
  Future<ClickUpStatusModel> getStatus(String projectId) async {
    final response = await apiClient.dio.get(
      ApiConstants.clickUpStatus(projectId),
    );
    return ClickUpStatusModel.fromJson(response.data['data']);
  }

  @override
  Future<void> disconnect(String projectId) async {
    await apiClient.dio.post(ApiConstants.clickUpDisconnect(projectId));
  }

  @override
  Future<ClickUpPushResultModel> pushApproved(String projectId) async {
    final response = await apiClient.dio.post(
      ApiConstants.clickUpPushApproved(projectId),
    );
    return ClickUpPushResultModel.fromJson(response.data['data']);
  }
}
