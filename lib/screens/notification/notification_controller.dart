part of 'notification_view.dart';

class NotificationController extends GetxController {
  final NotificationApi api = NotificationApi();

  var notifications = <NotificationModel>[].obs;
  var expandedNotificationIds = <int>{}.obs;
  var deletedNotificationIds = <int>{}.obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;
  final box = GetStorage();

  static const _deletedNotificationIdsKey = 'deletedNotificationIds';

  void toggleExpand(int id) {
    if (expandedNotificationIds.contains(id)) {
      expandedNotificationIds.remove(id);
    } else {
      expandedNotificationIds.add(id);
    }
  }

  bool isExpanded(int id) => expandedNotificationIds.contains(id);

  @override
  void onInit() {
    super.onInit();
    loadDeletedNotificationIds().whenComplete(loadNotifications);
  }

  Future<void> loadDeletedNotificationIds() async {
    final stored = box.read(_deletedNotificationIdsKey);
    if (stored is List) {
      deletedNotificationIds.assignAll(stored
          .map((item) {
            if (item is int) return item;
            return int.tryParse(item.toString());
          })
          .whereType<int>()
          .toSet());
    }
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;

      final fetched = await api.getNotifications();
      fetched.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifications.assignAll(
          fetched.where((notification) => !deletedNotificationIds.contains(notification.id)).toList());

      final lastCount = box.read("notificationsCount") ?? 0;
      unreadCount.value = notifications.length - (lastCount as int);

      if (unreadCount.value < 0) {
        unreadCount.value = 0;
      }
    } catch (e) {
      debugPrint("Load notification error: $e");
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

  void _updateUnreadCount() {
    final lastCount = box.read("notificationsCount") ?? 0;
    unreadCount.value = notifications.length - (lastCount as int);

    if (unreadCount.value < 0) {
      unreadCount.value = 0;
    }
  }

  Future<void> confirmDeleteNotification(BuildContext context, int id) async {
    final theme = Theme.of(context);
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('delete_notification_title'.tr),
        content: Text('delete_notification_message'.tr),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(result: false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.dividerColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: Text(
              'no'.tr,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: Text(
              'delete'.tr,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      deleteNotification(id);
    }
  }

  void deleteNotification(int id) {
    deletedNotificationIds.add(id);
    box.write(_deletedNotificationIdsKey, deletedNotificationIds.toList());
    notifications.removeWhere((notification) => notification.id == id);
    expandedNotificationIds.remove(id);
    _updateUnreadCount();
  }

  Map<String, List<NotificationModel>> get groupedNotifications {
    final Map<String, List<NotificationModel>> groups = {};

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    for (var notification in notifications) {
      final itemDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String key;
      if (itemDate.isAtSameMomentAs(todayDate)) {
        key = 'today_header'.tr;
      } else if (itemDate.isAtSameMomentAs(yesterdayDate)) {
        key = 'yesterday_header'.tr;
      } else {
        key = 'earlier_header'.tr;
      }

      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(notification);
    }

    return groups;
  }

  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return Get.locale?.languageCode == 'km' ? 'អម្បាញ់មិញ' : 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  IconData getNotificationIcon(String title) {
    final text = title.toLowerCase();

    if (text.contains("homework")) {
      return Icons.assignment_outlined;
    }

    if (text.contains("attendance")) {
      return Icons.fact_check_outlined;
    }

    if (text.contains("event")) {
      return Icons.event_available_rounded;
    }

    if (text.contains("score") || text.contains("result")) {
      return Icons.bar_chart_rounded;
    }

    if (text.contains("permission")) {
      return Icons.assignment_turned_in_outlined;
    }

    return Icons.notifications_none_rounded;
  }

  Color getNotificationColor(String title) {
    final text = title.toLowerCase();

    if (text.contains("homework")) {
      return const Color(0xFFF97316);
    }

    if (text.contains("attendance")) {
      return const Color(0xFFEF4444);
    }

    if (text.contains("event")) {
      return const Color(0xFF0EA5E9);
    }

    if (text.contains("score") || text.contains("result")) {
      return const Color(0xFF22C55E);
    }

    if (text.contains("permission")) {
      return const Color(0xFFA855F7);
    }

    return const Color(0xFF6763EB);
  }

  Color getNotificationBgColor(String title) {
    final text = title.toLowerCase();

    if (text.contains("homework")) {
      return const Color(0xFFFFF7ED);
    }

    if (text.contains("attendance")) {
      return const Color(0xFFFEE2E2);
    }

    if (text.contains("event")) {
      return const Color(0xFFE0F2FE);
    }

    if (text.contains("score") || text.contains("result")) {
      return const Color(0xFFDCFCE7);
    }

    if (text.contains("permission")) {
      return const Color(0xFFF3E8FF);
    }

    return const Color(0xFFEEF2FF);
  }
}
