import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/services/result_api.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/card/custom_score_card.dart';
import 'package:tamdansers_lv2/core/widgets/score_bar.dart';
import 'package:tamdansers_lv2/core/widgets/subject_ui.dart';
import 'package:tamdansers_lv2/data/model/score_model.dart';

part 'result_screen_binding.dart';
part 'result_screen_controller.dart';

class ResultScreenView extends GetView<ResultScreenViewController> {
  const ResultScreenView({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'result'.tr,
        showNotification: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),

              // ===============================================
              // Monthly / Semester / Yearly
              // ===============================================

              resultTypeSelector(),

              // ===============================================
              // Semester selector
              // Not shown in Yearly
              // ===============================================

              Obx(
                () {
                  if (controller.selectedView.value == ResultViewMode.yearly) {
                    return const SizedBox(
                      height: 18,
                    );
                  }

                  return Column(
                    children: [
                      const SizedBox(
                        height: 14,
                      ),
                      semesterSelector(),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  );
                },
              ),

              // ===============================================
              // Content
              // ===============================================

              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoading.value) {
                      return skeletonLoading();
                    }

                    switch (controller.selectedView.value) {
                      case ResultViewMode.monthly:
                        return monthlyView();

                      case ResultViewMode.semester:
                        return semesterView();

                      case ResultViewMode.yearly:
                        return yearlyView();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // VIEW SELECTOR
  // ===========================================================

  Widget resultTypeSelector() {
    final ThemeData theme = Get.theme;

    return Obx(
      () => Container(
        width: double.infinity,
        height: 62,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color: theme.dividerColor.withOpacity(
              0.65,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(
                0.05,
              ),
              blurRadius: 10,
              offset: const Offset(
                0,
                3,
              ),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ResultViewMode>(
            value: controller.selectedView.value,
            isExpanded: true,
            borderRadius: BorderRadius.circular(
              18,
            ),
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(
                  0.10,
                ),
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            items: [
              DropdownMenuItem(
                value: ResultViewMode.monthly,
                child: _ResultTypeItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'monthly'.tr,
                ),
              ),
              DropdownMenuItem(
                value: ResultViewMode.semester,
                child: _ResultTypeItem(
                  icon: Icons.school_outlined,
                  title: 'semester'.tr,
                ),
              ),
              DropdownMenuItem(
                value: ResultViewMode.yearly,
                child: _ResultTypeItem(
                  icon: Icons.workspace_premium_outlined,
                  title: 'yearly'.tr,
                ),
              ),
            ],
            onChanged: (ResultViewMode? value) {
              if (value == null) {
                return;
              }

              controller.changeView(
                value,
              );
            },
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // SEMESTER SELECTOR
  // ===========================================================

  Widget semesterSelector() {
    final ThemeData theme = Get.theme;

    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          5,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(
            0.65,
          ),
          borderRadius: BorderRadius.circular(
            16,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: semesterButton(
                theme: theme,
                semester: 1,
                title: 'semester 1'.tr,
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            Expanded(
              child: semesterButton(
                theme: theme,
                semester: 2,
                title: 'semester 2'.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget semesterButton({
    required ThemeData theme,
    required int semester,
    required String title,
  }) {
    final bool selected = controller.selectedSemester.value == semester;

    return InkWell(
      borderRadius: BorderRadius.circular(
        13,
      ),
      onTap: () {
        controller.changeSemester(
          semester,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(
            13,
          ),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // MONTHLY VIEW
  // ===========================================================

  Widget monthlyView() {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: monthList(),
        ),
        const SizedBox(
          height: 16,
        ),
        Obx(
          () {
            if (controller.isRankLoading.value) {
              return rankSkeleton();
            }

            return CustomScoreCard();
          },
        ),
        const SizedBox(
          height: 18,
        ),
        Expanded(
          child: scoreList(),
        ),
      ],
    );
  }

  // ===========================================================
  // MONTH LIST
  // ===========================================================

  Widget monthList() {
    final ThemeData theme = Get.theme;

    return Obx(
      () {
        final List<int> available = controller.semesterMonths
            .where(
              (int month) => month >= 1 && month <= 12,
            )
            .toList();

        final int? selectedMonth = controller.selectedMonth.value;

        if (available.isEmpty) {
          return Center(
            child: Text(
              'No months',
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(
                  0.65,
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: available.length,
          separatorBuilder: (
            BuildContext context,
            int index,
          ) {
            return const SizedBox(
              width: 10,
            );
          },
          itemBuilder: (
            BuildContext context,
            int index,
          ) {
            final int month = available[index];

            final bool selected = selectedMonth == month;

            final String label = controller.months[month]?.tr ?? 'Month $month';

            return InkWell(
              borderRadius: BorderRadius.circular(
                14,
              ),
              onTap: () {
                controller.changeMonth(
                  month,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),
                constraints: const BoxConstraints(
                  minWidth: 105,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? theme.colorScheme.primary : theme.cardColor,
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                  ),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================
  // SUBJECT SCORE LIST
  //
  // IMPORTANT:
  // NO duplicate score on top-right.
  // ScoreBar will show the score.
  // ===========================================================

  Widget scoreList() {
    final ThemeData theme = Get.theme;

    return Obx(
      () {
        final List<ScoreModel> scores = controller.filterScores;

        if (scores.isEmpty) {
          return emptyResult();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshResult,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 24,
            ),
            itemCount: scores.length,
            separatorBuilder: (
              BuildContext context,
              int index,
            ) {
              return const SizedBox(
                height: 8,
              );
            },
            itemBuilder: (
              BuildContext context,
              int index,
            ) {
              final ScoreModel score = scores[index];

              final String subject = score.subjectName;

              return Container(
                padding: const EdgeInsets.all(
                  16,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(
                    18,
                  ),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(
                      0.75,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // =========================================
                    // Subject + teacher only
                    // =========================================

                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: SubjectUi.bgColor(
                              subject,
                            ),
                            borderRadius: BorderRadius.circular(
                              14,
                            ),
                          ),
                          child: Icon(
                            SubjectUi.icon(
                              subject,
                            ),
                            color: SubjectUi.color(
                              subject,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                score.subjectName.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '${'teacher'.tr}: '
                                '${score.teacherName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(
                                    0.65,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // =========================================
                    // Score only here
                    // =========================================

                    ScoreBar(
                      score: score.score,
                      maxScore: score.maxScore,
                      color: SubjectUi.color(
                        subject,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ===========================================================
  // SEMESTER VIEW
  // ===========================================================

  Widget semesterView() {
    final ThemeData theme = Get.theme;

    return Obx(
      () {
        final double monthlyAverage = controller.semesterMonthlyAverage;

        final double semesterResult = controller.semesterResult;

        final List<Map<String, dynamic>> monthly =
            controller.semesterMonthlyResults;

        return RefreshIndicator(
          onRefresh: controller.refreshResult,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 24,
            ),
            children: [
              // =========================================
              // SEMESTER SUMMARY
              // =========================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  22,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(
                    22,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(
                        0.16,
                      ),
                      blurRadius: 16,
                      offset: const Offset(
                        0,
                        7,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              0.15,
                            ),
                            borderRadius: BorderRadius.circular(
                              13,
                            ),
                          ),
                          child: const Icon(
                            Icons.school_outlined,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          controller.selectedSemester.value == 1
                              ? 'semester 1'.tr
                              : 'semester 2'.tr,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: semesterSummaryItem(
                            title: 'average_month'.tr,
                            value: monthlyAverage.toStringAsFixed(
                              2,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 52,
                          color: Colors.white24,
                        ),
                        Expanded(
                          child: semesterSummaryItem(
                            title: 'result'.tr,
                            value: semesterResult.toStringAsFixed(
                              2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              Text(
                'ranking_for_month'.tr,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              if (monthly.isEmpty) emptyResultCard(),

              // =========================================
              // Monthly result cards
              // Month 0 can never appear here
              // =========================================

              ...monthly.map(
                (
                  Map<String, dynamic> item,
                ) {
                  final int month = item['month'] as int;

                  if (month < 1 || month > 12) {
                    return const SizedBox.shrink();
                  }

                  final double total = item['totalScore'] as double;

                  final int subjects = item['subjects'] as int;

                  final double average = item['average'] as double;

                  final String monthName =
                      controller.months[month]?.tr ?? 'Month $month';

                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(
                          0.70,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(
                              0.10,
                            ),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: Icon(
                            Icons.calendar_month_outlined,
                            size: 21,
                            color: theme.colorScheme.primary,
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                monthName,
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Total '
                                '${total.toStringAsFixed(0)}'
                                '  •  '
                                '$subjects Subjects',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(
                                    0.60,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        // =====================================
                        // Smaller average font
                        // =====================================

                        Text(
                          average.toStringAsFixed(
                            2,
                          ),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================
  // SEMESTER SUMMARY ITEM
  // ===========================================================

  Widget semesterSummaryItem({
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // YEARLY VIEW
  //
  // Web-style yearly result:
  // - Final yearly average + yearly rank
  // - Semester 1 summary
  // - Semester 2 summary
  // - Each semester shows:
  //   Monthly Average
  //   Semester Exam Average
  //   Semester Result
  // ===========================================================

  Widget yearlyView() {
    final ThemeData theme = Get.theme;

    return Obx(
      () {
        final double finalAverage = controller.yearlyAverage;

        final ScoreModel? rankData = controller.yearlyRank.value;

        final String rank =
            rankData?.rank.isNotEmpty == true ? rankData!.rank : '-';

        return RefreshIndicator(
          onRefresh: controller.refreshResult,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 30,
            ),
            children: [
              // ===============================================
              // YEARLY SUMMARY CARD
              // ===============================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(
                    22,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(
                        0.18,
                      ),
                      blurRadius: 18,
                      offset: const Offset(
                        0,
                        8,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // -----------------------------------------
                    // Title
                    // -----------------------------------------

                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              0.15,
                            ),
                            borderRadius: BorderRadius.circular(
                              13,
                            ),
                          ),
                          child: const Icon(
                            Icons.workspace_premium_outlined,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            'result_yearly'.tr,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // -----------------------------------------
                    // Average + Rank
                    // -----------------------------------------

                    Row(
                      children: [
                        Expanded(
                          child: yearlyTopSummaryItem(
                            title: 'average_year'.tr,
                            value: finalAverage.toStringAsFixed(
                              2,
                            ),
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 62,
                          color: Colors.white24,
                        ),

                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'rank'.tr,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              controller.isYearRankLoading.value
                                  ? const SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      rank,
                                      style: AppTextStyles.titleLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 26,
              ),

              // ===============================================
              // SECTION TITLE
              // ===============================================

              Text(
                'result_yearly'.tr,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              // ===============================================
              // SEMESTER 1
              // ===============================================

              yearlySemesterSummaryCard(
                theme: theme,
                semester: 1,
                monthlyAverage: controller.semester1MonthlyAverage,
                examAverage: controller.semester1ExamAverage,
                semesterResult: controller.semester1Result,
              ),

              const SizedBox(
                height: 14,
              ),

              // ===============================================
              // SEMESTER 2
              // ===============================================

              yearlySemesterSummaryCard(
                theme: theme,
                semester: 2,
                monthlyAverage: controller.semester2MonthlyAverage,
                examAverage: controller.semester2ExamAverage,
                semesterResult: controller.semester2Result,
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================
  // YEARLY TOP SUMMARY ITEM
  // ===========================================================

  Widget yearlyTopSummaryItem({
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // YEARLY SEMESTER SUMMARY CARD
  // ===========================================================

  Widget yearlySemesterSummaryCard({
    required ThemeData theme,
    required int semester,
    required double monthlyAverage,
    required double examAverage,
    required double semesterResult,
  }) {
    final String semesterName =
        semester == 1 ? 'semester 1'.tr : 'semester 2'.tr;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        18,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: theme.dividerColor.withOpacity(
            0.70,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(
              0.04,
            ),
            blurRadius: 12,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          // -------------------------------------------
          // Semester header
          // -------------------------------------------

          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(
                    0.10,
                  ),
                  borderRadius: BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  Icons.school_outlined,
                  color: theme.colorScheme.primary,
                  size: 23,
                ),
              ),
              const SizedBox(
                width: 13,
              ),
              Expanded(
                child: Text(
                  semesterName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Divider(
            height: 1,
            color: theme.dividerColor.withOpacity(
              0.70,
            ),
          ),

          const SizedBox(
            height: 17,
          ),

          // -------------------------------------------
          // Monthly average
          // -------------------------------------------

          yearlyResultRow(
            theme: theme,
            icon: Icons.calendar_month_outlined,
            title: 'average_month'.tr,
            value: monthlyAverage,
          ),

          const SizedBox(
            height: 14,
          ),

          // -------------------------------------------
          // Semester exam average
          // -------------------------------------------

          yearlyResultRow(
            theme: theme,
            icon: Icons.edit_note_rounded,
            title: 'semester_exam_average'.tr,
            value: examAverage,
          ),

          const SizedBox(
            height: 14,
          ),

          // -------------------------------------------
          // Final semester result
          // -------------------------------------------

          yearlyResultRow(
            theme: theme,
            icon: Icons.bar_chart_rounded,
            title: 'semester_result'.tr,
            value: semesterResult,
            highlight: true,
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // YEARLY RESULT ROW
  // ===========================================================

  Widget yearlyResultRow({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required double value,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? theme.colorScheme.primary.withOpacity(
                0.07,
              )
            : theme.colorScheme.surfaceContainerHighest.withOpacity(
                0.35,
              ),
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(
                0.10,
              ),
              borderRadius: BorderRadius.circular(
                11,
              ),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight:
                    highlight ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Text(
            value.toStringAsFixed(
              2,
            ),
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: highlight ? 19 : 17,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // EMPTY RESULT
  // ===========================================================

  Widget emptyResult() {
    return RefreshIndicator(
      onRefresh: controller.refreshResult,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 280,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 48,
                    color: Get.theme.colorScheme.primary.withOpacity(
                      0.30,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    'no_result'.tr,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyResultCard() {
    return Container(
      height: 130,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: Get.theme.dividerColor,
        ),
      ),
      child: Text(
        'no_result'.tr,
        style: AppTextStyles.bodyLarge.copyWith(
          color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(
            0.60,
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // SKELETON
  // ===========================================================

  Widget skeletonLoading() {
    final ThemeData theme = Get.theme;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        shimmerBox(
          theme: theme,
          height: 58,
        ),
        const SizedBox(
          height: 16,
        ),
        shimmerBox(
          theme: theme,
          height: 155,
        ),
        const SizedBox(
          height: 16,
        ),
        shimmerBox(
          theme: theme,
          height: 135,
        ),
        const SizedBox(
          height: 12,
        ),
        shimmerBox(
          theme: theme,
          height: 135,
        ),
      ],
    );
  }

  Widget rankSkeleton() {
    return shimmerBox(
      theme: Get.theme,
      height: 150,
    );
  }

  Widget shimmerBox({
    required ThemeData theme,
    required double height,
  }) {
    return Shimmer.fromColors(
      baseColor: theme.dividerColor.withOpacity(
        0.20,
      ),
      highlightColor: theme.dividerColor.withOpacity(
        0.08,
      ),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(
            18,
          ),
        ),
      ),
    );
  }
}

// =============================================================
// RESULT TYPE DROPDOWN ITEM
// =============================================================

class _ResultTypeItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ResultTypeItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(
              0.10,
            ),
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
