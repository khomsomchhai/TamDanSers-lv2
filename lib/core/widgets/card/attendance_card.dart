import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/data/model/attendance_model.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceModel item;
  final Function(String) mapStatus;
  final Function(String) statusColor;
  final Function(String) formatDate;
  final Function(String, String) formatTimeRange;

  const AttendanceCard({
    super.key,
    required this.item,
    required this.mapStatus,
    required this.statusColor,
    required this.formatDate,
    required this.formatTimeRange,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = mapStatus(item.status);
    final badgeColor = statusColor(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppNumbers.cardPadding,
        vertical: AppNumbers.cardPadding,
      ),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(AppNumbers.radiusRounded),
        border: Border.all(
          color: Get.theme.dividerColor,
          width: 0.5,
        ),
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
                  color: Get.isDarkMode 
                    ? AppColors.primary
                    : AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Get.isDarkMode 
                    ? AppColors.white
                    : AppColors.primary,
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
                    formatDate(item.date),
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
                    formatTimeRange(item.startTime, item.endTime),
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
