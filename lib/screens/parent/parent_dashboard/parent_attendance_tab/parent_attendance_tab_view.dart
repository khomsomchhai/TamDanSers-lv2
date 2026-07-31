import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
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
      backgroundColor: AppColors.lightBackground,
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
                24,
                20,
                120,
              ),
              children: [
                Text(
                  'វត្តមាន',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.dark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ប្រវត្តិវត្តមាន',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.dark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${monthlyAttendance.length} កំណត់ត្រា',
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
                    (attendance) => _buildAttendanceItem(attendance),
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

    final remark = attendance.remark.toString().trim() ?? '';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppNumbers.radiusLarge,
        ),
        border: Border.all(
          color: statusColor.withValues(
            alpha: 0.18,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(
              alpha: 0.05,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(
                AppNumbers.radiusMedium,
              ),
            ),
            child: Icon(
              controller.getStatusIcon(
                attendance.status,
              ),
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.getStatusText(
                    attendance.status,
                  ),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.dark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: AppColors.hintColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        controller.formatDate(
                          attendance.date,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (remark.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notes_rounded,
                        size: 15,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 6),
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
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _getShortStatus(
                attendance.status,
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
          const SizedBox(height: 18),
          Text(
            'មិនមានទិន្នន័យវត្តមាន',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.dark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'ទិន្នន័យវត្តមានរបស់សិស្សនឹងបង្ហាញនៅទីនេះ',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getShortStatus(
    dynamic status,
  ) {
    final value = controller.normalizeStatus(
      status,
    );

    switch (value) {
      case 'p':
      case 'present':
        return 'P';

      case 'a':
      case 'absent':
        return 'A';

      case 'l':
      case 'leave':
      case 'permission':
      case 'permitted':
        return 'L';

      default:
        return '-';
    }
  }
}
