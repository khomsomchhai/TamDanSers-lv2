import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/services/schedule_api.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/subject_ui.dart';

part 'schedule_screen_binding.dart';
part 'schedule_screen_controller.dart';

class ScheduleScreenView extends GetView<ScheduleScreenViewController> {
  const ScheduleScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: 'schedule'.tr),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: controller.tabController,
                labelStyle: Get.textTheme.titleSmall!.copyWith(fontSize: 12),
                unselectedLabelStyle:
                    Get.textTheme.titleSmall!.copyWith(fontSize: 12),
                labelColor: AppColors.primary,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                unselectedLabelColor: AppColors.white,
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
                              'morning'.tr,
                              style: Get.textTheme.titleMedium,
                            ),
                            SizedBox(height: 8),
                            ...morningSchedules
                                .map((item) => scheduleCard(item)),
                          ],
                          if (afternoonSchedules.isNotEmpty) ...[
                            Text(
                              'afternoon'.tr,
                              style: Get.textTheme.titleMedium,
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
                ? AppColors.secondary
                : AppColors.primary, // unselected color
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
    final subject = item['subject_name'] ?? '';
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: SubjectUi.bgColor( subject),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                SubjectUi.icon( subject),
                color: SubjectUi.color( subject),
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['subject_name'] ?? ''.tr,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.hintColor),
                ),
                Text.rich(TextSpan(children: [
                  TextSpan(text: 'Teacher: ', style: AppTextStyles.bodyLarge),
                  TextSpan(
                      text: item['teacher_name'],
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700))
                ])),
                SizedBox(height: 10),
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
