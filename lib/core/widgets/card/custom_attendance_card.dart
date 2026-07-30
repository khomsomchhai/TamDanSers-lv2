import 'package:flutter/material.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';

class CustomAttendanceCard extends StatelessWidget {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int permissionDays;
  final double attendanceRate;
  final String currentMonth;

  const CustomAttendanceCard({
    super.key,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.permissionDays,
    required this.attendanceRate,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = (attendanceRate / 100).clamp(0.0, 1.0);

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
            color: AppColors.primary.withValues(alpha: 0.20),
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
                  'វត្តមានប្រចាំខែ $currentMonth',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${attendanceRate.toStringAsFixed(0)}%',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'សរុប $totalDays ថ្ងៃ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.80),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatusBadge(
                      title: 'វត្តមាន',
                      count: presentDays,
                      color: AppColors.success,
                      icon: Icons.check_circle_outline,
                    ),
                    _buildStatusBadge(
                      title: 'អវត្តមាន',
                      count: absentDays,
                      color: AppColors.error,
                      icon: Icons.cancel_outlined,
                    ),
                    _buildStatusBadge(
                      title: 'សុំច្បាប់',
                      count: permissionDays,
                      color: Colors.orange,
                      icon: Icons.event_available_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 72,
                width: 72,
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 8,
                  color: AppColors.white,
                  backgroundColor:
                      AppColors.white.withValues(alpha: 0.22),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 22,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 2),
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

  Widget _buildStatusBadge({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(
          AppNumbers.radiusSmall,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            '$title $count',
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}