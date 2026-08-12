import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/card/custom_attendance_card.dart';
import 'package:tamdansers_lv2/data/model/attendance_model.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/'
    'parent_attendance_tab/parent_attendance_tab_controller.dart';

class ParentAttendanceTabView
    extends GetView<ParentAttendanceTabViewController> {
  const ParentAttendanceTabView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: "attendance".tr, showBackButton: false,),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.attendanceList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          final monthlyAttendance = controller.filteredAttendance;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.refreshAttendance,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                120,
              ),
              children: [
                CustomAttendanceCard(
                  totalDays: controller.totalDays,
                  presentDays: controller.presentDays.value,
                  absentDays: controller.absentDays.value,
                  permissionDays: controller.permissionDays.value,
                  presentSubjects: controller.presentSubjects.value,
                  absentSubjects: controller.absentSubjects.value,
                  permissionSubjects: controller.permissionSubjects.value,
                  attendanceRate: controller.attendanceRate,
                  currentMonth: controller.currentMonthName,
                ),

                const SizedBox(height: 18),

                // Ask permission function
                _buildAskPermissionCard(
                  context,
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'attendance_history'.tr,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.dark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${monthlyAttendance.length} ${'record'.tr}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.hintColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                if (monthlyAttendance.isEmpty)
                  _buildEmptyState()
                else
                  ...monthlyAttendance.map(
                    (attendance) => _buildAttendanceItem(
                      attendance,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAttendanceItem(
    AttendanceModel attendance,
  ) {
    final statusColor = controller.getStatusColor(
      attendance.status,
    );

    final statusText = controller.getStatusText(
      attendance.status,
    );

    final remark = attendance.remark.trim();

    final subjectName = attendance.subjectName.trim().isEmpty
        ? '-'
        : attendance.subjectName.trim();

    final className =
        attendance.className.trim().isEmpty ? '-' : attendance.className.trim();

    final teacherName = attendance.teacherName.trim().isEmpty
        ? '-'
        : attendance.teacherName.trim();

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppNumbers.radiusLarge,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(
              0,
              5,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppNumbers.radiusMedium,
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$subjectName - $className',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.dark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      '${'teacher'.tr}: $teacherName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    24,
                  ),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 19,
                color: AppColors.neutral500,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.formatDate(
                    attendance.date,
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ),
              const Icon(
                Icons.access_time_rounded,
                size: 20,
                color: AppColors.neutral500,
              ),
              const SizedBox(width: 8),
              Text(
                _formatTimeRange(
                  attendance.startTime,
                  attendance.endTime,
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          if (remark.isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_rounded,
                  size: 18,
                  color: AppColors.grey,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    remark,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAskPermissionCard(
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        AppNumbers.radiusLarge,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          AppNumbers.radiusLarge,
        ),
        onTap: () {
          Get.toNamed(
            AppRoutes.parentPermission,
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(
            16,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(
              AppNumbers.radiusLarge,
            ),
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: 0.18,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    AppNumbers.radiusMedium,
                  ),
                ),
                child: const Icon(
                  Icons.edit_calendar_rounded,
                  color: AppColors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ask_permission'.tr,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.dark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'ask_permission_my_requests'.tr,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeRange(
    String startTime,
    String endTime,
  ) {
    final start = _formatTime(
      startTime,
    );

    final end = _formatTime(
      endTime,
    );

    if (start.isEmpty && end.isEmpty) {
      return '-';
    }

    if (start.isEmpty) {
      return end;
    }

    if (end.isEmpty) {
      return start;
    }

    return '$start - $end';
  }

  String _formatTime(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return '';
    }

    final parts = text.split(':');

    if (parts.length < 2) {
      return text;
    }

    return '${parts[0]}:${parts[1]}';
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 70,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppNumbers.radiusLarge,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              size: 42,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Text(
            'no_attendance'.tr,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.dark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 7,
          ),
        ],
      ),
    );
  }
}
