import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/core/api/services/notication_api.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/data/model/notification_model.dart';

part 'notification_binding.dart';
part 'notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'notification'.tr,
        showNotification: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No notifications available.',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final grouped = controller.groupedNotifications;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24, top: 4),
          itemCount: grouped.length,
          itemBuilder: (context, groupIndex) {
            final groupTitle = grouped.keys.elementAt(groupIndex);
            final groupItems = grouped[groupTitle]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header (TODAY, YESTERDAY, EARLIER)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: 10,
                  ),
                  child: Text(
                    groupTitle.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                // Group Items
                ...groupItems.map(
                    (notification) => _buildNotificationCard(context, notification)),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, NotificationModel notification) {
    final catColor = controller.getNotificationColor(notification.title);
    final catBg = controller.getNotificationBgColor(notification.title);
    final catIcon = controller.getNotificationIcon(notification.title);
    final timeAgo = controller.formatTimeAgo(notification.createdAt);

    final hasSubtitle =
        notification.subtitle != null && notification.subtitle!.isNotEmpty;
    final hasDueDate =
        notification.dueDate != null && notification.dueDate!.isNotEmpty;

    final dateStr =
        "${notification.createdAt.year}-${notification.createdAt.month.toString().padLeft(2, '0')}-${notification.createdAt.day.toString().padLeft(2, '0')} ${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')}";

    return Obx(() {
      final isExpanded = controller.isExpanded(notification.id);

      return GestureDetector(
        onTap: () => controller.toggleExpand(notification.id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.03),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left Category Color Accent Strip
                  Container(
                    width: 4.5,
                    color: catColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Circular Icon Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: catBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              catIcon,
                              color: catColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Content Area
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Title + Time Ago + Arrow Icon
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        style: const TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      timeAgo,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    // Expand / Collapse Arrow Icon
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: const Color(0xFF94A3B8),
                                      size: 22,
                                    ),
                                  ],
                                ),
                                if (hasSubtitle) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.subtitle!,
                                    style: TextStyle(
                                      color: catColor.withValues(alpha: 0.9),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                if (notification.message.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.message,
                                    maxLines: isExpanded ? null : 2,
                                    overflow: isExpanded
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                                if (hasDueDate) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${'due_date_prefix'.tr}${notification.dueDate}',
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                // Expanded Details Card
                                if (isExpanded) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time_rounded,
                                              size: 14,
                                              color: Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              dateStr,
                                              style: const TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (notification.type != null &&
                                            notification.type!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.category_outlined,
                                                size: 14,
                                                color: Color(0xFF64748B),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                notification.type!,
                                                style: const TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
