import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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

      return LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 340;
          final circleSize = isNarrow ? 48.0 : 60.0;
          final trophySize = isNarrow ? 30.0 : 36.0;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        month == null
                            ? 'ranking_for_month'.tr
                            : '${'ranking_for_month'.tr} ${(controller.months[month] ?? "").tr}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: trophySize,
                            height: trophySize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success
                              
                            ),
                            child: Icon(
                              PhosphorIconsFill.medal,
                              size: trophySize * 0.62,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                currentRank,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.lightBackground,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(
                                    AppNumbers.radiusSmall),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${'total_score'.tr}: ',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                          color: AppColors.info,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '$totalScore',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(
                                    AppNumbers.radiusSmall),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${'average'.tr}: $average',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Align(
                  alignment: Alignment.topCenter,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: circleSize,
                        width: circleSize,
                        child: CircularProgressIndicator(
                          value: percent,
                          strokeWidth: 8,
                          color: AppColors.white,
                          backgroundColor:
                              AppColors.white.withValues(alpha: 0.2),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Icon(Icons.star,
                          size: isNarrow ? 16 : 20, color: AppColors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}