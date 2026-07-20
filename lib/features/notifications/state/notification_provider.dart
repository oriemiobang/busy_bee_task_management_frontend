import 'package:flutter/foundation.dart';
import 'package:frontend/features/notifications/data/notification_repository.dart';
import 'package:frontend/features/notifications/model/notification_model.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider(this._repository);

  List<NotificationModel> _notifications = [];
  NotificationStatus _status = NotificationStatus.initial;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  NotificationStatus get status => _status;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get isLoading => _status == NotificationStatus.loading;

  Future<void> fetchNotifications() async {
    _status = NotificationStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.fetchNotifications();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _status = NotificationStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = NotificationStatus.error;
    }
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      _notifications = _notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> syncFcmToken(String token) async {
    try {
      await _repository.syncFcmToken(token);
    } catch (e) {
      debugPrint('Error syncing FCM token: $e');
    }
  }
}
