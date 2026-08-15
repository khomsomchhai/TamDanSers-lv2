part of 'notification_view.dart';

class NotificationController
    extends GetxController {
  final NotificationApi api =
      NotificationApi();

  final notifications =
      <NotificationModel>[].obs;

  final expandedNotificationIds =
      <int>{}.obs;

  final unreadCount = 0.obs;

  final isLoading = false.obs;

  final GetStorage box =
      GetStorage();

  // =========================================================
  // STORAGE KEY
  //
  // IMPORTANT:
  // Each account gets its own notificationCount.
  // =========================================================

  String get _accountKey {
    final String role =
        box.read('role')?.toString() ?? '';

    // Student account
    if (role == 'student') {
      final dynamic studentId =
          box.read('student_id');

      return 'student_${studentId ?? 'unknown'}';
    }

    // Parent account
    if (role == 'parent') {
      final dynamic parent =
          box.read('parent');

      if (parent is Map) {
        final dynamic parentId =
            parent['id'] ??
            parent['parent_id'];

        return 'parent_${parentId ?? 'unknown'}';
      }

      return 'parent_unknown';
    }

    return 'unknown_account';
  }

  String get _notificationCountKey =>
      'notificationsCount_$_accountKey';

  // =========================================================
  // INIT
  // =========================================================

  @override
  void onInit() {
    super.onInit();

    loadNotifications();
  }

  // =========================================================
  // LOAD NOTIFICATIONS
  // =========================================================

Future<void> loadNotifications() async {
  final String token =
      box.read('token')?.toString().trim() ?? '';

  if (token.isEmpty) {
    notifications.clear();
    unreadCount.value = 0;
    isLoading.value = false;

    debugPrint(
      'SKIP NOTIFICATIONS: NO AUTH TOKEN',
    );

    return;
  }

  try {
    isLoading.value = true;

    final List<NotificationModel> fetched =
        await api.getNotifications();

    fetched.sort(
      (a, b) =>
          b.createdAt.compareTo(a.createdAt),
    );

    notifications.assignAll(fetched);

    _updateUnreadCount();
  } catch (e) {
    debugPrint(
      'LOAD NOTIFICATION ERROR: $e',
    );
  } finally {
    isLoading.value = false;
  }
}
  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  // =========================================================
  // EXPAND / COLLAPSE
  // =========================================================

  void toggleExpand(
    int id,
  ) {
    if (expandedNotificationIds.contains(
      id,
    )) {
      expandedNotificationIds.remove(
        id,
      );
    } else {
      expandedNotificationIds.add(
        id,
      );
    }
  }

  bool isExpanded(
    int id,
  ) {
    return expandedNotificationIds.contains(
      id,
    );
  }

  // =========================================================
  // MARK ALL READ
  // =========================================================

  Future<void> markAllRead() async {
    unreadCount.value = 0;

    await box.write(
      _notificationCountKey,
      notifications.length,
    );

    debugPrint(
      'NOTIFICATIONS MARKED READ => '
      'account=$_accountKey, '
      'count=${notifications.length}',
    );
  }

  // =========================================================
  // UPDATE UNREAD COUNT
  // =========================================================

  void _updateUnreadCount() {
    final dynamic stored =
        box.read(
      _notificationCountKey,
    );

    int lastCount = 0;

    if (stored is int) {
      lastCount = stored;
    } else if (stored != null) {
      lastCount =
          int.tryParse(
        stored.toString(),
      ) ??
      0;
    }

    final int difference =
        notifications.length -
            lastCount;

    unreadCount.value =
        difference > 0
            ? difference
            : 0;
  }

  // =========================================================
  // CONFIRM DELETE
  // =========================================================

  Future<void> confirmDeleteNotification(
    BuildContext context,
    int id,
  ) async {
    final ThemeData theme =
        Theme.of(context);

    final bool? confirmed =
        await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),
        title: Text(
          'delete_notification_title'.tr,
        ),
        content: Text(
          'delete_notification_message'.tr,
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Get.back(
                result: false,
              );
            },
            style:
                OutlinedButton.styleFrom(
              side: BorderSide(
                color:
                    theme.dividerColor,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
            ),
            child: Text(
              'no'.tr,
              style: theme
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(
                result: true,
              );
            },
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  theme.colorScheme.error,
              foregroundColor:
                  theme
                      .colorScheme
                      .onError,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
            ),
            child: Text(
              'delete'.tr,
              style: theme
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                fontWeight:
                    FontWeight.w600,
                color:
                    theme
                        .colorScheme
                        .onError,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      await deleteNotification(
        id,
      );
    }
  }

  // =========================================================
  // DELETE NOTIFICATION
  // =========================================================

  Future<void> deleteNotification(
    int id,
  ) async {
    try {
      await api.deleteNotification(
        id,
      );

      notifications.removeWhere(
        (
          NotificationModel notification,
        ) =>
            notification.id == id,
      );

      expandedNotificationIds.remove(
        id,
      );

      // Update read-count storage so deletion
      // does not create a wrong unread value.
      final dynamic stored =
          box.read(
        _notificationCountKey,
      );

      int lastCount = 0;

      if (stored is int) {
        lastCount = stored;
      } else if (stored != null) {
        lastCount =
            int.tryParse(
          stored.toString(),
        ) ??
        0;
      }

      if (lastCount >
          notifications.length) {
        await box.write(
          _notificationCountKey,
          notifications.length,
        );
      }

      _updateUnreadCount();

      debugPrint(
        'NOTIFICATION DELETED: $id',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'DELETE NOTIFICATION ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      Get.snackbar(
        'Error',
        'Unable to delete notification',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    }
  }

  // =========================================================
  // CLEAR CURRENT ACCOUNT STATE
  //
  // Call this when user logs out.
  // =========================================================

  void clearForLogout() {
    notifications.clear();

    expandedNotificationIds.clear();

    unreadCount.value = 0;

    isLoading.value = false;

    debugPrint(
      'NOTIFICATION STATE CLEARED FOR LOGOUT',
    );
  }

  // =========================================================
  // GROUP NOTIFICATIONS
  // =========================================================

  Map<String, List<NotificationModel>>
      get groupedNotifications {
    final Map<
        String,
        List<
            NotificationModel>> groups =
        <String,
            List<
                NotificationModel>>{};

    final DateTime now =
        DateTime.now();

    final DateTime todayDate =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final DateTime yesterdayDate =
        todayDate.subtract(
      const Duration(
        days: 1,
      ),
    );

    for (final NotificationModel notification
        in notifications) {
      final DateTime itemDate =
          DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String key;

      if (itemDate.isAtSameMomentAs(
        todayDate,
      )) {
        key =
            'today_header'.tr;
      } else if (itemDate
          .isAtSameMomentAs(
        yesterdayDate,
      )) {
        key =
            'yesterday_header'.tr;
      } else {
        key =
            'earlier_header'.tr;
      }

      groups.putIfAbsent(
        key,
        () =>
            <NotificationModel>[],
      );

      groups[key]!.add(
        notification,
      );
    }

    return groups;
  }

  // =========================================================
  // TIME AGO
  // =========================================================

  String formatTimeAgo(
    DateTime dateTime,
  ) {
    final DateTime now =
        DateTime.now();

    final Duration difference =
        now.difference(
      dateTime,
    );

    if (difference.inSeconds < 60) {
      return Get.locale
                  ?.languageCode ==
              'km'
          ? 'អម្បាញ់មិញ'
          : 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    return '${difference.inDays}d ago';
  }

  // =========================================================
  // ICON
  // =========================================================

  IconData getNotificationIcon(
    String title,
  ) {
    final String text =
        title.toLowerCase();

    if (text.contains(
      'homework',
    )) {
      return Icons
          .assignment_outlined;
    }

    if (text.contains(
      'attendance',
    )) {
      return Icons
          .fact_check_outlined;
    }

    if (text.contains(
      'event',
    )) {
      return Icons
          .event_available_rounded;
    }

    if (text.contains('score') ||
        text.contains('result')) {
      return Icons
          .bar_chart_rounded;
    }

    if (text.contains(
      'permission',
    )) {
      return Icons
          .assignment_turned_in_outlined;
    }

    return Icons
        .notifications_none_rounded;
  }

  // =========================================================
  // COLOR
  // =========================================================

  Color getNotificationColor(
    String title,
  ) {
    final String text =
        title.toLowerCase();

    if (text.contains(
      'homework',
    )) {
      return const Color(
        0xFFF97316,
      );
    }

    if (text.contains(
      'attendance',
    )) {
      return const Color(
        0xFFEF4444,
      );
    }

    if (text.contains(
      'event',
    )) {
      return const Color(
        0xFF0EA5E9,
      );
    }

    if (text.contains('score') ||
        text.contains('result')) {
      return const Color(
        0xFF22C55E,
      );
    }

    if (text.contains(
      'permission',
    )) {
      return const Color(
        0xFFA855F7,
      );
    }

    return const Color(
      0xFF6763EB,
    );
  }

  // =========================================================
  // BACKGROUND COLOR
  // =========================================================

  Color getNotificationBgColor(
    String title,
  ) {
    final String text =
        title.toLowerCase();

    if (text.contains(
      'homework',
    )) {
      return const Color(
        0xFFFFF7ED,
      );
    }

    if (text.contains(
      'attendance',
    )) {
      return const Color(
        0xFFFEE2E2,
      );
    }

    if (text.contains(
      'event',
    )) {
      return const Color(
        0xFFE0F2FE,
      );
    }

    if (text.contains('score') ||
        text.contains('result')) {
      return const Color(
        0xFFDCFCE7,
      );
    }

    if (text.contains(
      'permission',
    )) {
      return const Color(
        0xFFF3E8FF,
      );
    }

    return const Color(
      0xFFEEF2FF,
    );
  }
}