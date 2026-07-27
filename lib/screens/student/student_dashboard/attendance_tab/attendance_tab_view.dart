import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/services/attendance_service.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/data/model/attendance_model.dart';

part 'attendance_tab_binding.dart';
part 'attendance_tab_controller.dart';

class AttendanceTabView extends GetView<AttendanceTabViewController> {
  const AttendanceTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('attendance'.tr,style: AppTextStyles.titleMedium),
        
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchAttendance,
        child: Obx(() {
          if (controller.isLoading.value && controller.attendanceList.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 520,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            );
          }

          final items = controller.displayedAttendance;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppNumbers.screenPadding),
            children: [
              _buildDateSelector(context),
              const SizedBox(height: AppNumbers.spacingMedium),
              if (items.isEmpty)
                SizedBox(
                  height: 260,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 52,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: AppNumbers.spacingSmall),
                      Text(
                        'attendance_no_records'.tr,
                        style: Get.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppNumbers.spacingMedium),
                    child: _buildAttendanceCard(item),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Obx(() {
      final hasDate = controller.selectedDate.value != null;

      return InkWell(
        onTap: () => controller.pickDate(context),
        borderRadius: BorderRadius.circular(AppNumbers.radiusRounded),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppNumbers.spacingMedium,
            vertical: AppNumbers.spacingMedium,
          ),
          decoration: BoxDecoration(
            color: Get.theme.cardColor,
            borderRadius: BorderRadius.circular(AppNumbers.radiusRounded),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.03),
                blurRadius: AppNumbers.shadowBlur,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: AppNumbers.avatarMedium,
                height: AppNumbers.avatarMedium,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppNumbers.radiusSmall),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  size: AppNumbers.icon16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppNumbers.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'attendance_select_date'.tr,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      hasDate
                          ? controller.formatDate(
                              controller.selectedDate.value!
                                  .toIso8601String()
                                  .split('T')
                                  .first,
                            )
                          : 'attendance_all_days'.tr,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (hasDate)
                GestureDetector(
                  onTap: controller.clearDateFilter,
                  child: Container(
                    width: AppNumbers.iconLarge,
                    height: AppNumbers.iconLarge,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius:
                          BorderRadius.circular(AppNumbers.radiusSmall),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: AppNumbers.icon16,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: AppColors.grey,
                  size: AppNumbers.iconSmall,
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAttendanceCard(AttendanceModel item) {
    final statusText = controller.mapStatus(item.status);
    final badgeColor = controller.statusColor(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppNumbers.cardPadding,
        vertical: AppNumbers.cardPadding,
      ),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(AppNumbers.radiusRounded),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: AppNumbers.shadowBlur,
            offset: Offset(0, 6),
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
                width: AppNumbers.avatarLarge,
                height: AppNumbers.avatarLarge,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                  size: AppNumbers.iconMedium,
                ),
              ),
              const SizedBox(width: AppNumbers.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${item.subjectName} - ${item.className}',
                      style: Get.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Teacher: ${item.teacherName}',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppNumbers.spacingSmall, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                ),
                child: Text(
                  statusText,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.formatDate(item.date),
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.formatTimeRange(item.startTime, item.endTime),
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
