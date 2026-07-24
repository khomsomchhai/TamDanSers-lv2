import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/services/notication_api.dart';
import 'package:tamdansers_lv2/data/model/notification_model.dart';

part 'notification_binding.dart';
part 'notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notification'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.notifications.isEmpty) {
          return Center(child: Text('No notifications available.'));
        }
        return ListView.builder(
          physics: ScrollPhysics(),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        color:
                            controller.getNotificationColor(notification.title),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: controller
                                  .getNotificationColor(notification.title)
                                  .withOpacity(0.15),
                              child: Icon(
                                controller
                                    .getNotificationIcon(notification.title),
                                color: controller
                                    .getNotificationColor(notification.title),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title,
                                    style: AppTextStyles.titleSmall
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    notification.message,
                                    style: AppTextStyles.bodyLarge,
                                  ),
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
            );
          },
        );
      }),
    );
  }
}
