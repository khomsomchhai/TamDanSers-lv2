import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/services/result_api.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/card/custom_score_card.dart';
import 'package:tamdansers_lv2/core/widgets/subject_ui.dart';
import 'package:tamdansers_lv2/data/model/score_model.dart';

part 'result_screen_binding.dart';
part 'result_screen_controller.dart';

class ResultScreenView extends GetView<ResultScreenViewController> {
  const ResultScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'result'.tr,
        showNotification: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Column(
            children: [
              _buildSemesterSelector(),

              const SizedBox(height: 10),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return SingleChildScrollView(
                      child: _buildSkeletonLoading(),
                    );
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 66,
                        child: _buildMonthList(),
                      ),

                      const SizedBox(height: 12),

                      CustomScoreCard(),

                      const SizedBox(height: 16),

                      Expanded(
                        child: _buildScoreList(),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEMESTER SELECTOR
  // ============================================================

  Widget _buildSemesterSelector() {
    return Obx(() {
      return Container(
        height: 54,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSemesterButton(
                semester: 1,
                title: 'semester 1'.tr,
              ),
            ),

            const SizedBox(width: 6),

            Expanded(
              child: _buildSemesterButton(
                semester: 2,
                title: 'semester 2'.tr,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSemesterButton({
    required int semester,
    required String title,
  }) {
    final bool isSelected =
        controller.selectedSemester.value == semester;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        if (isSelected) return;

        controller.changeSemester(semester);
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? AppColors.white
                : Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MONTH LIST
  // ============================================================

Widget _buildMonthList() {
  return Obx(() {
    final semesterMonths = controller.semesterMonths;
    final selectedMonth = controller.selectedMonth.value;

    if (semesterMonths.isEmpty) {
      return Center(
        child: Text(
          'no_months'.tr,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 7),
      scrollDirection: Axis.horizontal,
      itemCount: semesterMonths.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final month = semesterMonths[index];
        final isSelected = selectedMonth == month;

        return GestureDetector(
          onTap: () {
            controller.changeMonth(month);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 110,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.neutral500,
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              (controller.months[month] ?? 'Month $month').tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  });
}
  // ============================================================
  // SCORE LIST
  // ============================================================

  Widget _buildScoreList() {
    return Obx(() {
      final List<ScoreModel> scores =
          controller.filterScores;

      if (scores.isEmpty) {
        return _buildEmptyScore();
      }

      return ListView.separated(
        padding: const EdgeInsets.only(
          bottom: 24,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: scores.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 14);
        },
        itemBuilder: (context, index) {
          final ScoreModel score = scores[index];

          final String subject =
              score.subjectName ?? '';

          return _buildScoreItem(
            score: score,
            subject: subject,
          );
        },
      );
    });
  }

  Widget _buildScoreItem({
    required ScoreModel score,
    required String subject,
  }) {
    final double scoreValue =
        score.score.toDouble();

    final double maxScoreValue =
        score.maxScore.toDouble();

    final double percentage = maxScoreValue > 0
        ? (scoreValue / maxScoreValue)
            .clamp(0.0, 1.0)
        : 0.0;

    final Color subjectColor =
        SubjectUi.color(subject);

    final Color subjectBackground =
        SubjectUi.bgColor(subject);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.neutral500.withValues(
            alpha: 0.45,
          ),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: subjectBackground,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  SubjectUi.icon(subject),
                  color: subjectColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.tr,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium
                          .copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${'teacher'.tr}: '
                      '${score.teacherName ?? '-'}',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium
                          .copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: subjectBackground,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  '${_formatNumber(scoreValue)}'
                  ' / '
                  '${_formatNumber(maxScoreValue)}',
                  maxLines: 1,
                  style:
                      AppTextStyles.bodyMedium.copyWith(
                    color: subjectColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor:
                  AppColors.neutral500.withValues(
                alpha: 0.22,
              ),
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                subjectColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyScore() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 42,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'មិនមានពិន្ទុសម្រាប់ខែនេះ',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildSkeletonLoading() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor:
                Colors.grey.shade100,
            child: Container(
              width: 120,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor:
                Colors.grey.shade100,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          ...List.generate(
            3,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Shimmer.fromColors(
                  baseColor:
                      Colors.grey.shade300,
                  highlightColor:
                      Colors.grey.shade100,
                  child: Container(
                    width: double.infinity,
                    height: 115,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORMAT NUMBER
  // ============================================================

  String _formatNumber(num value) {
    final double number = value.toDouble();

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }
}