import 'package:makhsos/interfaces/repository_interface.dart';

abstract class NotificationRepositoryInterface extends RepositoryInterface {
  @override
  Future<dynamic> getList({int? offset, bool handleError = true});
  void saveSeenNotificationCount(int count);
  int? getSeenNotificationCount();
  List<int> getNotificationIdList();
  void addSeenNotificationIdList(List<int> notificationList);
}
