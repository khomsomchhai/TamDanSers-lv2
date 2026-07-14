import 'package:flutter/material.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';

class CustomScoreCard extends StatelessWidget {
  final double averageScore;
  final double totalScore;
  final int rank;
  final String currentMonth;

  const CustomScoreCard({
    super.key,
    required this.averageScore,
    required this.totalScore,
    required this.rank,
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
              Text('ពិន្ទុប្រចាំខែ $currentMonth',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
              Text(averageScore.toStringAsFixed(1),
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
                    child: Text("សរុប $totalScore",
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppNumbers.radiusSmall),
                    ),
                    child: Text("ចំណាត់ថ្នាក់ #$rank",
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.warning,
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
                value: averageScore / 100,
                strokeWidth: 8,
                color: AppColors.white,
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
                strokeCap: StrokeCap.round,
              ),
            ),
            Icon(Icons.star, size: 20, color: AppColors.white)
          ])
        ],
      ),
    );
  }
}
