import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_endpoints.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/features/notifications/model/notification_model.dart';

class NotificationApi {
  final DioClient _dioClient;

  NotificationApi(this._dioClient);

  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 20}) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.data == null) return [];
    if (response.data is List) {
      return (response.data as List)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> markAsRead(int notificationId) async {
    await _dioClient.dio.patch(ApiEndpoints.markNotificationRead(notificationId));
  }

  Future<void> markAllAsRead() async {
    await _dioClient.dio.patch(ApiEndpoints.markAllNotificationsRead);
  }

  Future<void> updateFcmToken(String token) async {
    await _dioClient.dio.patch(
      ApiEndpoints.fcmToken,
      data: {'fcmToken': token},
    );
  }
}
