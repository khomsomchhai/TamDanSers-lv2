import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';

class CustomAttendanceCard extends StatelessWidget {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int permissionDays;

  final int presentSubjects;
  final int absentSubjects;
  final int permissionSubjects;

  final double attendanceRate;
  final String currentMonth;

  const CustomAttendanceCard({
    super.key,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.permissionDays,
    required this.presentSubjects,
    required this.absentSubjects,
    required this.permissionSubjects,
    required this.attendanceRate,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = (attendanceRate / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCard(
          progressValue: progressValue,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                title: 'present_days'.tr,
                dayCount: presentDays,
                subjectCount: presentSubjects,
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                title: 'absent_days'.tr,
                dayCount: absentDays,
                subjectCount: absentSubjects,
                icon: Icons.cancel_outlined,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                title: 'permission_days'.tr,
                dayCount: permissionDays,
                subjectCount: permissionSubjects,
                icon: Icons.event_available_outlined,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required double progressValue,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(
          AppNumbers.radiusLarge,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.20,
            ),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'attendance_summary'.tr} ${currentMonth.tr}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${attendanceRate.toStringAsFixed(0)}%',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'attendance_total_days'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(
                      alpha: 0.78,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 82,
                height: 82,
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 9,
                  strokeCap: StrokeCap.round,
                  color: AppColors.white,
                  backgroundColor: AppColors.white.withValues(
                    alpha: 0.20,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.white,
                    size: 23,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${attendanceRate.toStringAsFixed(0)}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildStatusCard({
    required String title,
    required int dayCount,
    required int subjectCount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppNumbers.radiusLarge,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.hintColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _buildIconBox(
                icon: icon,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                subjectCount.toString(),
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.dark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'subjects'.tr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.hintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(
          AppNumbers.radiusMedium,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 18,
      ),
    );
  }
}
