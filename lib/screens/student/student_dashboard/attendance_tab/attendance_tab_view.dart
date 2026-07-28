import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/core/api/services/attendance_service.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/card/attendance_card.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/data/model/attendance_model.dart';

part 'attendance_tab_binding.dart';
part 'attendance_tab_controller.dart';

class AttendanceTabView extends GetView<AttendanceTabViewController> {
  const AttendanceTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "attendance".tr,
        showBackButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchAttendance,
        child: Obx(() {
          if (controller.isLoading.value && controller.attendanceList.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppNumbers.screenPadding),
              children: [
                _buildAttendanceSkeleton(),
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
                    child: AttendanceCard(
                      item: item,
                      mapStatus: controller.mapStatus,
                      statusColor: controller.statusColor,
                      formatDate: controller.formatDate,
                      formatTimeRange: controller.formatTimeRange,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAttendanceSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.skeletonBaseColor,
      highlightColor: AppColors.skeletonHighlightColor,
      period: const Duration(milliseconds: 1200),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppNumbers.spacingMedium),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppNumbers.cardPadding),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Container(
                    width: 180,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: AppNumbers.spacingSmall),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: AppNumbers.spacingSmall),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: AppNumbers.spacingSmall),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
}
