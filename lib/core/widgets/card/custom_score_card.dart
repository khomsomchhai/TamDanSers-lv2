import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/screens/student/result_screen/result_screen_view.dart';

class CustomScoreCard extends StatelessWidget {
  final ResultScreenViewController controller =
      Get.find<ResultScreenViewController>();

  CustomScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rankData = controller.rank.value;

      final totalScore = rankData?.totalScore ?? 0;
      final month = rankData?.month;
      final currentRank = rankData?.rank ?? "-";
      final totalMax = rankData?.maxScore ?? 100;
      final average = rankData?.average ?? "-";
      final percent =
          totalMax > 0 ? (totalScore / totalMax).clamp(0.0, 1.0) : 0.0;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    month == null
                        ? 'ranking_for_month'.tr
                        : '${'ranking_for_month'.tr} ${(controller.months[month] ?? "").tr}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    currentRank,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.lightBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius:
                              BorderRadius.circular(AppNumbers.radiusSmall),
                        ),
                        child: Text(
                          "${'total_score'.tr}: ${totalScore.toStringAsFixed(0)}",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius:
                              BorderRadius.circular(AppNumbers.radiusSmall),
                        ),
                        child: Text('${'average'.tr}: $average',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 8,
                    color: AppColors.white,
                    backgroundColor: AppColors.white.withValues(alpha: 0.2),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const Icon(Icons.star, size: 20, color: AppColors.white),
              ],
            ),
          ],
        ),
      );
    });
  }
}
