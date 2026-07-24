part of 'notification_view.dart';

class NotificationController extends GetxController {
  final NotificationApi api = NotificationApi();

  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;

      notifications.value = await api.getNotifications();

      final lastCount = box.read("notificationsCount") ?? 0;

      unreadCount.value = notifications.length - (lastCount as int);

      // កុំឱ្យ unreadCount អវិជ្ជមាន
      if (unreadCount.value < 0) {
        unreadCount.value = 0;
      }
    } catch (e) {
      print("Load notification error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void markAllRead() {
    unreadCount.value = 0;

    box.write(
      "notificationsCount",
      notifications.length,
    );
  }

  IconData getNotificationIcon(String title) {
    final text = title.toLowerCase();

    if (text.contains("homework")) {
      return Icons.menu_book;
    }

    if (text.contains("attendance")) {
      return Icons.fact_check;
    }

    if (text.contains("event")) {
      return Icons.event;
    }

    if (text.contains("score") || text.contains("result")) {
      return Icons.bar_chart;
    }

    if (text.contains("permission")) {
      return Icons.assignment;
    }

    if (text.contains("exam")) {
      return Icons.description;
    }

    return Icons.notifications;
  }

  Color getNotificationColor(String title) {
    final text = title.toLowerCase();

    if (text.contains("homework")) {
      return Colors.orange;
    }

    if (text.contains("attendance")) {
      return Colors.red;
    }

    if (text.contains("event")) {
      return Colors.blue;
    }

    if (text.contains("score") || text.contains("result")) {
      return Colors.green;
    }

    if (text.contains("permission")) {
      return Colors.purple;
    }

    return Colors.grey;
  }
}
