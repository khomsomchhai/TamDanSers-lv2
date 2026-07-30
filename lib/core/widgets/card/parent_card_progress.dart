import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/parent_home_tab/parent_home_tab_view.dart';

class ParentCardProgress extends StatelessWidget {
  ParentCardProgress({super.key});

  final ParentHomeTabViewController controller =
      Get.find<ParentHomeTabViewController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 115,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
      }

      final dashboard = controller.dashboard.value;
      final rankData = dashboard?.rank;

      final totalScore =
          controller.formatNumber(rankData?.totalScore);

      final rank =
          rankData?.rank?.toString() ?? '-';

      final average =
          controller.formatNumber(rankData?.average);

      return Row(
        children: [
          Expanded(
            child: _buildCard(
              title: 'total_score'.tr,
              value: totalScore,
              icon: Icons.stars_rounded,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _buildCard(
              title: 'rank'.tr,
              
              value: rank,
              icon: Icons.emoji_events_rounded,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _buildCard(
              title: 'average'.tr,
              value: average,
              icon: Icons.analytics_rounded,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      height: 118,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.55),
          width: 1.3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.white,
            size: 22,
          ),

          const SizedBox(height: 7),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.white.withValues(alpha: 0.82),
              
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}