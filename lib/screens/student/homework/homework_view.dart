import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/api/services/homework_services.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/data/model/homework_model.dart';
import 'package:tamdansers_lv2/data/model/submission_model.dart';
import 'package:tamdansers_lv2/screens/student/homework/homework_detail_view.dart';
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
      appBar: CustomAppBar(
        title: 'homework'.tr,
        showBackButton: false,
      ),
      body: SafeArea(
        child: Column(
          children: [

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
                                  ? (Theme.of(context).brightness ==
                                          Brightness.light
                                      ? AppColors.white
                                      : Colors.grey[850])
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: controller.selectedTabIndex.value == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              Get.locale?.languageCode == 'km'
                                  ? 'រង់ចាំពិនិត្យ'
                                  : 'Pending',
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
                                  ? (Theme.of(context).brightness ==
                                          Brightness.light
                                      ? AppColors.white
                                      : Colors.grey[850])
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: controller.selectedTabIndex.value == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              Get.locale?.languageCode == 'km'
                                  ? 'ពិនិត្យ'
                                  : 'Check',
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
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = controller.selectedTabIndex.value == 0
                    ? controller.ongoingList
                    : controller.completedList;

                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'No homework',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchHomework,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _buildHomeworkCard(context, item);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkCard(BuildContext context, HomeworkItem item) {
    final isKm = Get.locale?.languageCode == 'km';

    String badgeText = '';
    Color badgeTextColor = Colors.black;
    Color badgeBgColor = Colors.grey;
    bool showBadge = false;

    if (item.status == HomeworkStatus.none) {
      badgeText = isKm ? 'រង់ចាំពិនិត្យ' : 'Pending';
      badgeTextColor = const Color(0xffD97706);
      badgeBgColor = const Color(0xffFEF3C7);
      showBadge = true;
    } else if (item.status == HomeworkStatus.submitted) {
      badgeText = isKm ? 'បានប្រគល់' : 'Submitted';
      badgeTextColor = const Color(0xff2563EB);
      badgeBgColor = const Color(0xffDBEAFE);
      showBadge = true;
    } else if (item.status == HomeworkStatus.checked) {
      badgeText = isKm ? 'ពិនិត្យ' : 'Check';
      badgeTextColor = AppColors.success;
      badgeBgColor = AppColors.success.withOpacity(0.12);
      showBadge = true;
    }

    final isCompleted = item.status == HomeworkStatus.submitted ||
        item.status == HomeworkStatus.checked;

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
            color: Colors.black.withValues(alpha: 0.03),
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
                      item.subjectName,
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
                      isKm
                          ? 'គ្រូ៖ ${item.teacherName}'
                          : 'Teacher: ${item.teacherName}',
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
              if (showBadge)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        ? (isKm
                            ? 'បានប្រគល់៖ ${item.date}'
                            : 'Submitted: ${item.date}')
                        : (isKm
                            ? 'ថ្ងៃកំណត់៖ ${item.date}'
                            : 'Deadline: ${item.date}'),
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              // Action Button
              Bounceable(
                onTap: () {
                  controller.showHomeworkDetails(context, item);
                },
                child: Text(
                  isKm ? 'មើលលម្អិត' : 'View details',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
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

    return cardContent;
  }
}
