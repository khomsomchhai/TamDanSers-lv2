import 'package:flutter/material.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';

class CustomAttendanceCard extends StatelessWidget {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final double attendanceRate;
  final String currentMonth;

  const CustomAttendanceCard({
    super.key,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.attendanceRate,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('វត្តមានប្រចាំខែ $currentMonth',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
              Text('${attendanceRate.toStringAsFixed(0)}%',
                  style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppNumbers.radiusSmall),
                    ),
                    child: Text("វត្តមាន​ $presentDays",
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppNumbers.radiusSmall),
                    ),
                    child: Text("អវត្តមាន​ $absentDays",
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
          Spacer(),
          Stack(alignment: Alignment.center, children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                value: attendanceRate / 100,
                strokeWidth: 8,
                color: AppColors.white,
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
                strokeCap: StrokeCap.round,
              ),
            ),
            Icon(Icons.check_circle, size: 20, color: AppColors.white)
          ])
        ],
      ),
    );
  }
}
