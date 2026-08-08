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

class ResultScreenView
    extends GetView<ResultScreenViewController> {
  const ResultScreenView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              const SizedBox(
                height: 8,
              ),

              Container(
                height: 50,
                padding: const EdgeInsets.all(
                  4,
                ),
                decoration: BoxDecoration(
                  color: theme
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(
                    40,
                  ),
                ),
                child: TabBar(
                  controller:
                      controller.tabController,
                  onTap: (index) async {
                    await controller
                        .changeSemester(
                      index + 1,
                    );
                  },
                  indicatorSize:
                      TabBarIndicatorSize.tab,
                  dividerColor:
                      Colors.transparent,
                  overlayColor:
                      WidgetStateProperty.all(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  labelPadding:
                      EdgeInsets.zero,
                  indicator: BoxDecoration(
                    color: theme
                        .colorScheme.primary,
                    borderRadius:
                        BorderRadius.circular(
                      40,
                    ),
                  ),
                  labelColor:
                      theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme
                      .textTheme
                      .bodyLarge
                      ?.color,
                  labelStyle:
                      AppTextStyles.bodyLarge
                          .copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                  unselectedLabelStyle:
                      AppTextStyles.bodyLarge
                          .copyWith(
                    fontWeight:
                        FontWeight.w500,
                  ),
                  tabs: [
                    Tab(
                      child: Center(
                        child: Text(
                          'semester 1'.tr,
                        ),
                      ),
                    ),
                    Tab(
                      child: Center(
                        child: Text(
                          'semester 2'.tr,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Expanded(
                child: Obx(
                  () {
                    if (controller
                        .isLoading.value) {
                      return skeletonLoading();
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: 32,
                          child: monthList(),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        Obx(
                          () {
                            if (controller
                                .isRankLoading
                                .value) {
                              return rankSkeleton();
                            }

                            return CustomScoreCard();
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        Expanded(
                          child: scoreList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget skeletonLoading() {
    final ThemeData theme =
        Get.theme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: theme.dividerColor
                .withOpacity(
              0.25,
            ),
            highlightColor:
                theme.dividerColor
                    .withOpacity(
              0.10,
            ),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Shimmer.fromColors(
            baseColor: theme.dividerColor
                .withOpacity(
              0.25,
            ),
            highlightColor:
                theme.dividerColor
                    .withOpacity(
              0.10,
            ),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Shimmer.fromColors(
            baseColor: theme.dividerColor
                .withOpacity(
              0.25,
            ),
            highlightColor:
                theme.dividerColor
                    .withOpacity(
              0.10,
            ),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget rankSkeleton() {
    final ThemeData theme =
        Get.theme;

    return Shimmer.fromColors(
      baseColor: theme.dividerColor
          .withOpacity(
        0.25,
      ),
      highlightColor:
          theme.dividerColor.withOpacity(
        0.10,
      ),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),
      ),
    );
  }

Widget monthList() {
  final ThemeData theme = Get.theme;

  return Obx(() {
    final List<int> semesterMonths =
        controller.semesterMonths;

    final int? selectedMonth =
        controller.selectedMonth.value;

    if (semesterMonths.isEmpty) {
      return Center(
        child: Text(
          'No months',
          style: AppTextStyles.titleSmall.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(
              0.75,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: semesterMonths.length,
      separatorBuilder: (context, index) {
        return const SizedBox(width: 10);
      },
      itemBuilder: (context, index) {
        final int month = semesterMonths[index];

        final bool isSelected = selectedMonth == month;

        return GestureDetector(
          key: ValueKey(
            'month_${controller.selectedSemester.value}_$month',
          ),
          behavior: HitTestBehavior.opaque,
          onTap: () {
            controller.changeMonth(month);
          },
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            curve: Curves.easeInOut,
            width: 100,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(
                          0.15,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              (controller.months[month] ?? '').tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyLarge?.color,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  });
}
  Widget scoreList() {
    final ThemeData theme =
        Get.theme;

    return Obx(
      () {
        final List<ScoreModel> scores =
            controller.filterScores;

        if (scores.isEmpty) {
          return RefreshIndicator(
            onRefresh:
                controller.refreshResult,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 250,
                  child: Center(
                    child: Text(
                      'no_result'.tr,
                      style: AppTextStyles
                          .titleMedium
                          .copyWith(
                        color: theme
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(
                          0.70,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh:
              controller.refreshResult,
          child: ListView.separated(
            physics:
                const AlwaysScrollableScrollPhysics(),
            itemCount: scores.length,
            separatorBuilder:
                (context, index) {
              return const SizedBox(
                height: 12,
              );
            },
            itemBuilder:
                (context, index) {
              final ScoreModel score =
                  scores[index];

              final String subject =
                  score.subjectName;

              return Container(
                height: 150,
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration:
                    BoxDecoration(
                  color: theme.cardColor,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  border: Border.all(
                    color: theme
                        .dividerColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration:
                              BoxDecoration(
                            color:
                                SubjectUi
                                    .bgColor(
                              subject,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              8,
                            ),
                          ),
                          child: Icon(
                            SubjectUi.icon(
                              subject,
                            ),
                            color:
                                SubjectUi
                                    .color(
                              subject,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                score
                                    .subjectName
                                    .tr,
                                style:
                                    AppTextStyles
                                        .titleMedium
                                        .copyWith(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                '${'teacher'.tr}: ${score.teacherName}',
                                style:
                                    AppTextStyles
                                        .bodyLarge
                                        .copyWith(
                                  color: theme
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withOpacity(
                                    0.75,
                                  ),
                                ),
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    ScoreBar(
                      score: score.score
                          .toDouble(),
                      maxScore: score
                          .maxScore
                          .toDouble(),
                      color:
                          SubjectUi.color(
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
}