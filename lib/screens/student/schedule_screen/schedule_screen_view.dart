import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'schedule'.tr, showNotification: false),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDayTabBar(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return loadingSkeleton();
              }
              return TabBarView(
                controller: controller.tabController,
                children: List.generate(
                  controller.days.length,
                  (index) {
                    final schedulesList =
                        controller.getSchedulesByDay(controller.days[index]);
                    if (schedulesList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 72,
                                color: theme.colorScheme.primary.withOpacity(0.14),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'no_schedule_for'.tr,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: theme.textTheme.titleSmall?.color,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'check_back_later'.tr,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final morningSchedules = schedulesList.where((item) {
                      final hour = int.parse(
                          item['start_time'].toString().split(':')[0]);
                      return hour < 12;
                    }).toList();

                    final afternoonSchedules = schedulesList.where((item) {
                      final hour = int.parse(
                          item['start_time'].toString().split(':')[0]);
                      return hour >= 12;
                    }).toList();

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (morningSchedules.isNotEmpty) ...[
                          Text(
                            'morning'.tr,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: theme.textTheme.titleSmall?.color,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...morningSchedules.map((item) => scheduleCard(item)),
                        ],
                        if (afternoonSchedules.isNotEmpty) ...[
                          Text(
                            'afternoon'.tr,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: theme.textTheme.titleSmall?.color,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...afternoonSchedules.map((item) => scheduleCard(item)),
                        ],
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTabBar() {
    final theme = Get.theme;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = 8.0;
          final totalSpacing = gap * (controller.days.length - 1);
          final tabWidth = (constraints.maxWidth - 2 - totalSpacing) / controller.days.length;

          return AnimatedBuilder(
            animation: controller.tabController.animation!,
            builder: (context, child) {
              final currentPosition = controller.tabController.animation!.value;
              final activeIndex = currentPosition.round();
              final left = currentPosition * (tabWidth + gap);

              return Stack(
                children: [
                  Positioned(
                    left: left,
                    top: 9,
                    child: Container(
                      width: 54,
                      height: 34,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      controller.days.length,
                      (index) {
                        final selected = activeIndex == index;
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == controller.days.length - 1 ? 0 : gap,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () {
                              controller.tabController.animateTo(index);
                            },
                            child: SizedBox(
                              width: tabWidth,
                              height: 54,
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 180),
                                  style: Get.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.textTheme.bodyLarge?.color?.withOpacity(0.75),
                                  ),
                                  child: Text(
                                    controller.days[index],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget scheduleCard(dynamic item) {
    final theme = Get.theme;
    final subject = item['subject_name'] ?? '';
    final teacher = item['teacher_name'] ?? '-';
    final isMorning = controller.isMorning(item['start_time'] ?? '00:00');
    final accentBackground = isMorning
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.secondaryContainer;
    final accentTextColor = isMorning
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSecondaryContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SubjectUi.bgColor(subject),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  SubjectUi.icon(subject),
                  color: SubjectUi.color(subject),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: theme.textTheme.titleSmall?.color,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'teacher_prefix'.tr}$teacher',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: theme.dividerColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: accentBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: accentTextColor,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "${controller.formatTime(item['start_time'] ?? '')} - ${controller.formatTime(item['end_time'] ?? '')}",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: accentTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isMorning ? 'morning'.tr : 'afternoon'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget loadingSkeleton() {
    final theme = Get.theme;
    final baseColor = theme.brightness == Brightness.dark
        ? theme.dividerColor.withOpacity(0.65)
        : theme.dividerColor.withOpacity(0.25);
    final highlightColor = theme.brightness == Brightness.dark
        ? theme.dividerColor.withOpacity(0.45)
        : theme.dividerColor.withOpacity(0.15);

    return ListView.builder(
      itemCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: theme.dividerColor.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 140,
                            height: 14,
                            decoration: BoxDecoration(
                              color: theme.dividerColor.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: theme.dividerColor.withOpacity(0.25),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 80,
                      height: 38,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
