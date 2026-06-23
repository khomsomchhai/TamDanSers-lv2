import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/services/schedule_api.dart';

part 'schedule_screen_binding.dart';
part 'schedule_screen_controller.dart';

class ScheduleScreenView extends GetView<ScheduleScreenViewController> {
  const ScheduleScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Schedule',
            style: Get.textTheme.titleMedium,
          ),
        ),
        body: Column(
          children: [
            TabBar(
              controller: controller.tabController,
              labelStyle: Get.textTheme.titleSmall!.copyWith(fontSize: 12),
              unselectedLabelStyle:
                  Get.textTheme.titleSmall!.copyWith(fontSize: 12),
              labelColor: AppColors.primary,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              unselectedLabelColor: AppColors.neutral500,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.symmetric(
                  horizontal: 16), // Removes padding around the indicator
              labelPadding: EdgeInsets.symmetric(
                  horizontal: 3), // Removes padding around the label

              indicator: BoxDecoration(color: AppColors.transparent),
              onTap: (value) {
                controller.selectedIndex.value = value;
              },
              tabs: List.generate(
                controller.days.length,
                (index) => dateItem(
                  day: controller.days[index],
                  index: index,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                return TabBarView(
                  controller: controller.tabController,
                  children: List.generate(
                    controller.days.length,
                    (index) {
                      var schedulesList =
                          controller.getSchedulesByDay(controller.days[index]);
                      if (schedulesList.isEmpty) {
                        return Center(
                            child: Text(
                                'No schedule for ${controller.days[index]}'));
                      }
                      //moring
                      final morningSchedules = schedulesList.where((item) {
                        final hour = int.parse(
                            item['start_time'].toString().split(':')[0]);
                        return hour < 12;
                      }).toList();

                      //afternoon
                      final afternoonSchedules = schedulesList.where((item) {
                        final hour = int.parse(
                            item['start_time'].toString().split(':')[0]);
                        return hour >= 12;
                      }).toList();

                      return ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          if (morningSchedules.isNotEmpty) ...[
                            Text(
                              'Morning',
                              style: AppTextStyles.titleMedium,
                            ),
                            SizedBox(height: 8),
                            ...morningSchedules
                                .map((item) => scheduleCard(item)),
                          ],
                          if (afternoonSchedules.isNotEmpty) ...[
                            Text(
                              'Afternoon',
                              style: AppTextStyles.titleMedium,
                            ),
                            SizedBox(height: 8),
                            ...afternoonSchedules
                                .map((item) => scheduleCard(item)),
                          ]
                        ],
                      );
                    },
                  ),
                );
              }),
            )
          ],
        ));
  }

  Widget dateItem({
    required String day,
    required int index,
  }) {
    return Obx(() => Container(
          width: Get.width,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: controller.selectedIndex.value == index
                ? AppColors.white
                : AppColors.lightgrey, // unselected color
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(day),
            ],
          ),
        ));
  }

  Widget scheduleCard(dynamic item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: controller.getSubjectBgColor(item['subject_name'] ?? ''),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                controller.getSubjectIcon(item['subject_name'] ?? ''),
                color: controller.getSubjectColor(item['subject_name'] ?? ''),
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['subject_name'] ?? '',
                  style: Get.textTheme.titleMedium,
                ),
                Text('Teacher: ${item['teacher_name'] ?? ''}',
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 16, color: AppColors.neutral500),
                    Text(
                      ' ${controller.formatTime(item['start_time'] ?? '')} - ${controller.formatTime(item['end_time'] ?? '')}',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.neutral500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
