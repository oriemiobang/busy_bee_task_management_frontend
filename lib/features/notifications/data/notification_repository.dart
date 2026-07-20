import 'package:frontend/features/notifications/data/notification_api.dart';
import 'package:frontend/features/notifications/model/notification_model.dart';

class NotificationRepository {
  final NotificationApi _api;

  NotificationRepository(this._api);

  Future<List<NotificationModel>> fetchNotifications({int page = 1}) {
    return _api.getNotifications(page: page);
  }

  Future<void> markAsRead(int id) => _api.markAsRead(id);
  Future<void> markAllAsRead() => _api.markAllAsRead();
  Future<void> syncFcmToken(String token) => _api.updateFcmToken(token);
}
