import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/data/model/score_model.dart';
import 'package:tamdansers_lv2/screens/student/result_screen/result_screen_view.dart';

class CustomScoreCard extends StatelessWidget {
  /// null = follow controller.selectedView
  ///
  /// Home page:
  /// CustomScoreCard(mode: ResultViewMode.monthly)
  ///
  /// Result page:
  /// CustomScoreCard()
  final ResultViewMode? mode;

  final ResultScreenViewController controller =
      Get.find<ResultScreenViewController>();

  CustomScoreCard({
    super.key,
    this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ResultViewMode currentMode =
          mode ?? controller.selectedView.value;

      // =====================================================
      // LOADING
      // =====================================================

      if (currentMode == ResultViewMode.monthly &&
          controller.isRankLoading.value) {
        return _loadingCard();
      }

      if (currentMode == ResultViewMode.semester &&
          controller.isSemesterRankLoading.value) {
        return _loadingCard();
      }

      if (currentMode == ResultViewMode.yearly &&
          controller.isYearRankLoading.value) {
        return _loadingCard();
      }

      // =====================================================
      // MONTHLY
      // =====================================================

      if (currentMode == ResultViewMode.monthly) {
        return _monthlyCard();
      }

      // =====================================================
      // SEMESTER
      // =====================================================

      if (currentMode == ResultViewMode.semester) {
        return _semesterCard();
      }

      // =====================================================
      // YEARLY
      // =====================================================

      return _yearlyCard();
    });
  }

  // =========================================================
  // MONTHLY
  // =========================================================

  Widget _monthlyCard() {
    final ScoreModel? data = controller.rank.value;

    final int? month = controller.selectedMonth.value;

    final String monthName = month == null
        ? ''
        : (controller.months[month]?.tr ?? '');

    final double totalScore =
        (data?.totalScore ?? 0).toDouble();

    final double maxScore =
        (data?.maxScore ?? 100).toDouble();

    final double progress = maxScore > 0
        ? (totalScore / maxScore).clamp(0.0, 1.0)
        : 0;

    return _buildCard(
      title: monthName.isEmpty
          ? 'ranking_for_month'.tr
          : '${'ranking_for_month'.tr} $monthName',
      rank: _rank(data),
      totalScore: totalScore.toStringAsFixed(1),
      average: data?.average ?? '-',
      progress: progress,
    );
  }

  // =========================================================
  // SEMESTER
  // =========================================================

  Widget _semesterCard() {
    final ScoreModel? data =
        controller.semesterRank.value;

    final int semester =
        controller.selectedSemester.value;

    final double semesterResult =
        controller.semesterResult;

    final double monthlyAverage =
        controller.semesterMonthlyAverage;

    return _buildCard(
      title:
          '${'ranking_for_semester'.tr} $semester',
      rank: _rank(data),
      totalScore:
          semesterResult.toStringAsFixed(2),
      average: data?.average.isNotEmpty == true
          ? data!.average
          : monthlyAverage.toStringAsFixed(2),
      progress:
          (semesterResult / 100).clamp(0.0, 1.0),
    );
  }

  // =========================================================
  // YEARLY
  // =========================================================

  Widget _yearlyCard() {
    final ScoreModel? data =
        controller.yearlyRank.value;

    final double yearlyAverage =
        controller.yearlyAverage;

    return _buildCard(
      title: 'ranking_for_year'.tr,
      rank: _rank(data),
      totalScore:
          yearlyAverage.toStringAsFixed(2),
      average: data?.average.isNotEmpty == true
          ? data!.average
          : yearlyAverage.toStringAsFixed(2),
      progress:
          (yearlyAverage / 100).clamp(0.0, 1.0),
    );
  }

  // =========================================================
  // RANK
  // =========================================================

  String _rank(ScoreModel? data) {
    if (data == null) {
      return '-';
    }

    if (data.rank.isEmpty) {
      return '-';
    }

    return data.rank;
  }

  // =========================================================
  // CARD UI
  // =========================================================

  Widget _buildCard({
    required String title,
    required String rank,
    required String totalScore,
    required String average,
    required double progress,
  }) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final bool isNarrow =
            constraints.maxWidth < 340;

        final double circleSize =
            isNarrow ? 48 : 60;

        final double medalSize =
            isNarrow ? 32 : 38;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius:
                BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // =====================================
                    // TITLE
                    // =====================================

                    Text(
                      title,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge
                          .copyWith(
                        color: AppColors.white,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // =====================================
                    // RANK
                    // =====================================

                    Row(
                      children: [
                        Container(
                          width: medalSize,
                          height: medalSize,
                          alignment:
                              Alignment.center,
                          decoration:
                              const BoxDecoration(
                            color:
                                AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            PhosphorIconsFill.medal,
                            size: medalSize * 0.62,
                            color: AppColors.white,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Flexible(
                          child: Text(
                            rank,
                            style: AppTextStyles
                                .headlineMedium
                                .copyWith(
                              color:
                                  AppColors.white,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // =====================================
                    // SCORE INFO
                    // =====================================

                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _infoBox(
                          title:
                              'total_score'.tr,
                          value: totalScore,
                          valueColor:
                              AppColors.error,
                        ),
                        _infoBox(
                          title: 'average'.tr,
                          value: average,
                          valueColor:
                              AppColors.info,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ===========================================
              // CIRCLE
              // ===========================================

              SizedBox(
                width: circleSize,
                height: circleSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: circleSize,
                      height: circleSize,
                      child:
                          CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        strokeCap:
                            StrokeCap.round,
                        color: AppColors.white,
                        backgroundColor:
                            AppColors.white
                                .withValues(
                          alpha: 0.20,
                        ),
                      ),
                    ),

                    Icon(
                      Icons.star,
                      size:
                          isNarrow ? 16 : 20,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // INFO CHIP
  // =========================================================

  Widget _infoBox({
    required String title,
    required String value,
    required Color valueColor,
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
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
              style:
                  AppTextStyles.bodyMedium.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style:
                  AppTextStyles.bodyMedium.copyWith(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // LOADING
  // =========================================================

  Widget _loadingCard() {
    return Container(
      width: double.infinity,
      height: 145,
      decoration: BoxDecoration(
        color: AppColors.primary
            .withValues(alpha: 0.15),
        borderRadius:
            BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}