import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/screens/student/student_dashboard/student_dashboard_view.dart';

part 'homework_binding.dart';
part 'homework_controller.dart';

class HomeworkView extends GetView<HomeworkViewController> {
  const HomeworkView({super.key});

  @override
  Widget build(BuildContext context) {
    // If the controller isn't registered (e.g. if loaded directly outside dashboard binding), register it.
    final controller = Get.isRegistered<HomeworkViewController>()
        ? Get.find<HomeworkViewController>()
        : Get.put(HomeworkViewController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Circular Back Button
                  Bounceable(
                    onTap: controller.goBackToHome,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.white
                            : Colors.grey[900],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.dark
                            : AppColors.white,
                      ),
                    ),
                  ),
                  
                  // Screen Title
                  Text(
                    'homework'.tr,
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),

                  // Circular Notification Button with Red Badge
                  Bounceable(
                    onTap: () {
                      // Notification handler
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.white
                                : Colors.grey[900],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_rounded,
                            size: 22,
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.dark
                                : AppColors.white,
                          ),
                        ),
                        // Red Notification Badge Dot
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Custom Segmented Tab Bar Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 54,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xffEBEBF1)
                      : Colors.black26,
                  borderRadius: BorderRadius.circular(27),
                ),
                child: Obx(
                  () => Row(
                    children: [
                      // Ongoing Tab Item
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.changeTab(0),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: controller.selectedTabIndex.value == 0
                                  ? (Theme.of(context).brightness == Brightness.light
                                      ? AppColors.white
                                      : Colors.grey[850])
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: controller.selectedTabIndex.value == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              'ongoing'.tr,
                              style: Get.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: controller.selectedTabIndex.value == 0
                                    ? AppColors.primary
                                    : AppColors.hintColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Completed Tab Item
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.changeTab(1),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: controller.selectedTabIndex.value == 1
                                  ? (Theme.of(context).brightness == Brightness.light
                                      ? AppColors.white
                                      : Colors.grey[850])
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: controller.selectedTabIndex.value == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              'completed'.tr,
                              style: Get.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: controller.selectedTabIndex.value == 1
                                    ? AppColors.primary
                                    : AppColors.hintColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 3. Main Homework List Views
            Expanded(
              child: Obx(() {
                final list = controller.selectedTabIndex.value == 0
                    ? controller.ongoingList
                    : controller.completedList;

                if (list.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildHomeworkCard(context, item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkCard(BuildContext context, HomeworkItem item) {
    // Styling attributes based on homework status
    String badgeText = '';
    Color badgeTextColor = Colors.black;
    Color badgeBgColor = Colors.grey;

    switch (item.status) {
      case HomeworkStatus.notDone:
        badgeText = 'not_done'.tr;
        badgeTextColor = const Color(0xffD97706);
        badgeBgColor = const Color(0xffFEF3C7);
        break;
      case HomeworkStatus.preparing:
        badgeText = 'preparing'.tr;
        badgeTextColor = AppColors.primary;
        badgeBgColor = AppColors.primary.withOpacity(0.12);
        break;
      case HomeworkStatus.late:
        badgeText = 'late'.tr;
        badgeTextColor = AppColors.error;
        badgeBgColor = AppColors.error.withOpacity(0.12);
        break;
      case HomeworkStatus.completed:
        badgeText = 'completed'.tr;
        badgeTextColor = AppColors.success;
        badgeBgColor = AppColors.success.withOpacity(0.12);
        break;
    }

    final isLate = item.status == HomeworkStatus.late;
    final isCompleted = item.status == HomeworkStatus.completed;

    Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Icon, Title, Status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: item.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Teacher name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.subjectKey.tr,
                      style: Get.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.dark
                            : AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'teacher_prefix'.tr + item.teacherName,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: badgeTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Row 2: Date icon + date label, View details button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle_outline_rounded
                        : Icons.calendar_today_outlined,
                    color: AppColors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCompleted
                        ? 'submitted_prefix'.tr + item.date
                        : 'deadline_prefix'.tr + item.date,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              
              // Action Button
              Bounceable(
                onTap: isLate
                    ? null
                    : () {
                        // Open details page
                      },
                child: Text(
                  'view_details'.tr,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: isLate ? AppColors.grey : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // If assignment is late, make the card semi-transparent
    if (isLate) {
      return Opacity(
        opacity: 0.6,
        child: cardContent,
      );
    }

    return cardContent;
  }
}