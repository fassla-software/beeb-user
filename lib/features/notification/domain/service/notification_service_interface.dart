import 'package:makhsos/features/notification/domain/models/notification_model.dart';

abstract class NotificationServiceInterface {
  Future<List<NotificationModel>?> getNotificationList(
      {bool handleError = true});
  void saveSeenNotificationCount(int count);
  int? getSeenNotificationCount();
  List<int> getNotificationIdList();
  void addSeenNotificationIdList(List<int> notificationList);
}
